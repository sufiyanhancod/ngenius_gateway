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

private const val REQUEST_CODE = 100
private const val CHANNEL = "ngenius"
private const val METHOD = "createOrder"

/** NgeniusPlugin */
class NgeniusPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private lateinit var result: Result

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    this.activity = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    this.result = result
    when (call.method) {
      METHOD -> {
        val gatewayUrl = call.argument<String>("gatewayUrl") ?: ""
        val code = call.argument<String>("code") ?: ""

        if (gatewayUrl.isBlank() && code.isBlank()) {
          result.error("INITIALISATION_ERROR", "Please provide valid gatewayUrl and code", "")
          return
        }

        activity?.let {
          PaymentClient(it).launchCardPayment(
            request = CardPaymentRequest.builder()
              .gatewayUrl(gatewayUrl)
              .code(code)
              .build(),
            requestCode = REQUEST_CODE
          )
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    when(requestCode) {
      REQUEST_CODE -> {
        data?.let {
          val paymentData = CardPaymentData.getFromIntent(it)
          when(paymentData.code) {
            CardPaymentData.STATUS_PAYMENT_CAPTURED -> {
              result.error("STATUS_PAYMENT_CAPTURED", "Payment captured", "")
            }
            CardPaymentData.STATUS_PAYMENT_AUTHORIZED -> {
              result.error("STATUS_PAYMENT_AUTHORIZED", "Payment authorized", "")
            }
            CardPaymentData.STATUS_PAYMENT_FAILED -> {
              result.error("STATUS_PAYMENT_FAILED", "Payment failed", "")
            }
            else -> {
              result.error("ERROR", "Generic failure", "")
            }
          }
        }
      }
      else -> {}
    }
    return true
  }
}