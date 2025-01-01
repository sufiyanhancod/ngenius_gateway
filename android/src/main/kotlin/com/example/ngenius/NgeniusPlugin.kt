package com.example.ngenius

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import payment.sdk.android.payments.PaymentsLauncher
import payment.sdk.android.payments.PaymentsRequest
import payment.sdk.android.payments.PaymentsResult
import androidx.activity.ComponentActivity
import android.util.Log
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.android.FlutterFragmentActivity

private const val CHANNEL = "ngenius"
private const val METHOD = "createOrder"

class NgeniusPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private lateinit var result: Result
  private var binding: ActivityPluginBinding? = null
  private var paymentsLauncher: PaymentsLauncher? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    this.binding = binding
    binding.addActivityResultListener(this)
    initializePaymentsLauncher()
  }

  private fun initializePaymentsLauncher() {
      activity?.let { currentActivity ->
          try {
              // Cast to FlutterFragmentActivity which extends ComponentActivity
              val componentActivity = currentActivity as androidx.fragment.app.FragmentActivity
              paymentsLauncher = PaymentsLauncher(componentActivity) { paymentResult ->
                  handlePaymentResult(paymentResult)
              }
          } catch (e: Exception) {
              Log.e("NgeniusPlugin", "Error initializing PaymentsLauncher", e)
              result.error("INITIALIZATION_ERROR", "Failed to initialize payment launcher: ${e.message}", null)
          }
      } ?: run {
          Log.e("NgeniusPlugin", "Activity is null")
          result.error("INITIALIZATION_ERROR", "Activity is null", null)
      }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    this.result = result
    when (call.method) {
      METHOD -> {
        val authUrl = call.argument<String>("authUrl") ?: ""
        val payPageUrl = call.argument<String>("payPageUrl") ?: ""

        if (authUrl.isBlank() && payPageUrl.isBlank()) {
          result.error("INITIALISATION_ERROR", "Please provide valid gatewayUrl and code", "")
          return
        }
        
        // Debug logs
        Log.d("NgeniusPlugin", "AuthURL: $authUrl")
        Log.d("NgeniusPlugin", "PayPageURL: $payPageUrl")
        Log.d("NgeniusPlugin", "PaymentsLauncher is null: ${paymentsLauncher == null}")
        Log.d("NgeniusPlugin", "Activity is null: ${activity == null}")

        // Try to initialize launcher if it's null
        if (paymentsLauncher == null) {
          initializePaymentsLauncher()
        }

        val request = PaymentsRequest.builder()
          .gatewayAuthorizationUrl(authUrl)
          .payPageUrl(payPageUrl)
          .build()

        if (paymentsLauncher != null) {
          try {
            paymentsLauncher?.launch(request)
          } catch (e: Exception) {
            Log.e("NgeniusPlugin", "Error launching payment", e)
            result.error("LAUNCH_ERROR", "Failed to launch payment: ${e.message}", null)
          }
        } else {
          Log.e("NgeniusPlugin", "PaymentsLauncher is still null after initialization attempt")
          result.error("LAUNCHER_ERROR", "Payment launcher initialization failed", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun handlePaymentResult(paymentResult: PaymentsResult) {
    when (paymentResult) {
      PaymentsResult.Success -> {
        result.success(mapOf(
          "status" to "success",
          "message" to "Payment completed successfully"
        ))
      }
      PaymentsResult.Authorised -> {
        result.success(mapOf(
          "status" to "authorized",
          "message" to "Payment authorized successfully"
        ))
      }
      PaymentsResult.Cancelled -> {
        result.error("PAYMENT_CANCELLED", "Payment was cancelled by user", null)
      }
      is PaymentsResult.Failed -> {
        result.error("PAYMENT_FAILED", paymentResult.error, null)
      }
      PaymentsResult.PartialAuthDeclineFailed -> {
        result.error("PARTIAL_AUTH_DECLINE_FAILED", "Partial authorization decline failed", null)
      }
      PaymentsResult.PartialAuthDeclined -> {
        result.error("PARTIAL_AUTH_DECLINED", "Partial authorization declined", null)
      }
      PaymentsResult.PartiallyAuthorised -> {
        result.success(mapOf(
          "status" to "partially_authorized",
          "message" to "Payment partially authorized"
        ))
      }
      PaymentsResult.PostAuthReview -> {
        result.success(mapOf(
          "status" to "post_auth_review",
          "message" to "Payment requires post authorization review"
        ))
      }
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.activity = null
    paymentsLauncher = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    initializePaymentsLauncher()
  }

  override fun onDetachedFromActivity() {
    this.activity = null
    this.binding?.removeActivityResultListener(this)
    this.binding = null
    paymentsLauncher = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    return false
  }
}