package com.example.ngenius.model

import payment.sdk.android.PaymentClient
import payment.sdk.android.core.Order
import payment.sdk.android.core.SavedCard

data class OrderRequest(
    val action: String,
    val amount: PaymentOrderAmount,
    val language: String = "en",
    val description: String = "Android Demo App",
    val merchantAttributes: Map<String, Any> = mapOf(),
    val savedCard: SavedCard? = null
)

data class PaymentOrderAmount(
    val value: Double,
    val currencyCode: String
)

data class MainViewModelEffect(
    val order: Order,
    val type: PaymentType
)

enum class PaymentType {
    SAMSUNG_PAY,
    CARD,
    SAVED_CARD,
}

fun OrderRequest.toMap(): MutableMap<String, Any> {
    val bodyMap = mutableMapOf(
        "action" to action,
        "amount" to mapOf(
            "currencyCode" to amount.currencyCode,
            "value" to amount.value * 100
        ),
        "language" to language,
        "description" to description
    )
    if (merchantAttributes.isNotEmpty()) {
        bodyMap["merchantAttributes"] = merchantAttributes
    }
    savedCard?.let {
        bodyMap["savedCard"] = mapOf(
            "maskedPan" to it.maskedPan,
            "expiry" to it.expiry,
            "cardholderName" to it.cardholderName,
            "scheme" to it.scheme,
            "cardToken" to it.cardToken,
            "recaptureCsc" to it.recaptureCsc
        )
    }
    return bodyMap
}