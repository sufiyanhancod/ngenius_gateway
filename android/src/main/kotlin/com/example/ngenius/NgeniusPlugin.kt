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
import payment.sdk.android.PaymentClient
import payment.sdk.android.cardpayment.CardPaymentData
import payment.sdk.android.cardpayment.CardPaymentRequest

private const val CHANNEL = "ngenius"
private const val METHOD = "createOrder"
private const val SAMSUNG_PAY_SERVICE_ID = ""
private const val REQUEST_CODE = 100

class NgeniusPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private lateinit var channel: MethodChannel
  private lateinit var result: Result
  private var activity: Activity? = null
  private var binding: ActivityPluginBinding? = null
//  private var paymentsLauncher: PaymentsLauncher? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding
    this.activity = binding.activity
    binding.addActivityResultListener(this)
//    initializePaymentsLauncher()
  }

//  private fun initializePaymentsLauncher() {
//    activity?.let { currentActivity ->
//        if (currentActivity is androidx.activity.ComponentActivity) {
//            paymentsLauncher = PaymentsLauncher(currentActivity) { paymentResult ->
//                handlePaymentResult(paymentResult)
//            }
//        } else {
//            Log.e("NgeniusPlugin", "Activity is not ComponentActivity")
//            result.error("INITIALIZATION_ERROR", "Activity must be ComponentActivity", null)
//        }
//    }
//  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    this.result = result
    when (call.method) {
      METHOD -> {
        val authUrl = call.argument<String>("authUrl") ?: ""
        val payPageUrl = call.argument<String>("payPageUrl") ?: ""

        val urlSplit = payPageUrl.split("=")
        var code = ""
        if (urlSplit.size > 1) {
          code = urlSplit[1]
        }

        if (authUrl.isBlank() && code.isBlank()) {
          result.error("INITIALISATION_ERROR", "Please provide valid gatewayUrl and code", "")
          return
        }

        activity?.let {
          PaymentClient(it, SAMSUNG_PAY_SERVICE_ID).launchCardPayment(
            request = CardPaymentRequest.builder()
              .gatewayUrl(authUrl)
              .code(code)
              .build(),
            requestCode = REQUEST_CODE
          )
        }

//       Try to initialize launcher if it's null
        /*if (paymentsLauncher == null) {
          initializePaymentsLauncher()
        }*/

        /*val request = PaymentsRequest.builder()
          .gatewayAuthorizationUrl(authUrl)
          .payPageUrl(payPageUrl)
          .build()

        paymentsLauncher?.launch(request) ?: run {
          result.error("LAUNCHER_ERROR", "Payment launcher not initialized", null)
        }*/

      }
      else -> result.notImplemented()
    }
  }

  /*private fun handlePaymentResult(paymentResult: PaymentsResult) {
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
  }*/

  override fun onDetachedFromActivityForConfigChanges() {
    this.activity = null
//    paymentsLauncher = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
//    initializePaymentsLauncher()
  }

  override fun onDetachedFromActivity() {
    this.activity = null
    this.binding?.removeActivityResultListener(this)
    this.binding = null
//    paymentsLauncher = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (resultCode == Activity.RESULT_OK) {
        when(requestCode) {
            REQUEST_CODE -> {
                if (data != null) {
                    val paymentData = CardPaymentData.getFromIntent(data)
                    val status = when (paymentData.code) {
                        CardPaymentData.STATUS_PAYMENT_AUTHORIZED -> "AUTH_SUCCESS"
                        CardPaymentData.STATUS_PAYMENT_CAPTURED -> "CAPTURE_SUCCESS"
                        CardPaymentData.STATUS_PAYMENT_PURCHASED -> "PURCHASE_SUCCESS"
                        CardPaymentData.STATUS_POST_AUTH_REVIEW -> "REVIEW_SUCCESS"
                        CardPaymentData.STATUS_PAYMENT_FAILED -> "FAILED"
                        else -> "ERROR"
                    }
                    result.success(status)
                } else {
                    result.success("ERROR")
                }
            }
            else -> {}
        }
    } else {
        result.success("CANCELLED")
    }
    return false
  }
}