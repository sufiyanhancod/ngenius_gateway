package com.example.ngenius

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.app.Activity
import android.util.Log

import com.example.ngenius.http.ApiServiceAdapter
import com.example.ngenius.http.CreateOrderApiInteractor
import com.example.ngenius.http.Result
import com.example.ngenius.model.Environment
import com.example.ngenius.model.EnvironmentType
import com.example.ngenius.model.OrderRequest
import com.example.ngenius.model.PaymentOrderAmount


/** NgeniusPlugin */
class NgeniusPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private lateinit var paymentClient: PaymentClient

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ngenius")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "createOrder" -> {
        CoroutineScope(Dispatchers.Main).launch {
          handleCreateOrder(call, result)
        }
      }
      else -> result.notImplemented()
    }
  }

  private suspend fun handleCreateOrder(call: MethodCall, result: Result) {
    try {
      withContext(Dispatchers.IO) {
        val amount = call.argument<Double>("amount") ?: throw IllegalArgumentException("Amount is required")
        val currency = call.argument<String>("currency") ?: "AED"
        
        val orderRequest = OrderRequest(
          "AUTH",
          PaymentOrderAmount(amount, currency)
        )
        
        val createOrderApiInteractor = CreateOrderApiInteractor(
          ApiServiceAdapter(CoroutinesGatewayHttpClient())
        )
        
        val orderResult = createOrderApiInteractor.createOrder(
          Environment(
            EnvironmentType.UAT,
            "YOUR_API_KEY",
            "YOUR_OUTLET_REF",
            "ni"
          ),
          orderRequest
        )
        
        handlePaymentResult(orderResult, result)
      }
    } catch (e: Exception) {
      result.error("CREATE_ORDER_ERROR", e.message, null)
    }
  }

  private fun handlePaymentResult(orderResult: Result<Order>, flutterResult: Result) {
    when (orderResult) {
      is Result.Success -> {
        val order = orderResult.data
        val paymentData = mapOf(
          "payPageUrl" to order.getPayPageUrl(),
          "authorizationUrl" to order.getAuthorizationUrl()
        )
        flutterResult.success(paymentData)
      }
      is Result.Error -> {
        flutterResult.error("PAYMENT_ERROR", orderResult.message, null)
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
