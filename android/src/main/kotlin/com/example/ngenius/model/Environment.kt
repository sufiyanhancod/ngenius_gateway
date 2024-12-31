package com.example.ngenius.model

import java.util.*

enum class EnvironmentType(val value: String) {
    DEV("DEV"),
    UAT("UAT"),
    PROD("PROD")
}

data class Environment(
    val type: EnvironmentType,
    val apiKey: String,
    val outletReference: String,
    val realm: String
) {

    fun getGatewayUrl(): String {
        return when (type) {
            EnvironmentType.DEV -> "https://api-gateway-dev.ngenius-payments.com/transactions/outlets/$outletReference/orders"
            EnvironmentType.UAT -> "https://api-gateway-uat.ngenius-payments.com/transactions/outlets/$outletReference/orders"
            EnvironmentType.PROD -> "https://api-gateway.ngenius-payments.com/transactions/outlets/$outletReference/orders"
        }
    }

    fun getIdentityUrl(): String {
        return when (type) {
            EnvironmentType.DEV -> "https://api-gateway-dev.ngenius-payments.com/identity/auth/access-token"
            EnvironmentType.UAT -> "https://api-gateway-uat.ngenius-payments.com/identity/auth/access-token"
            EnvironmentType.PROD -> "https://api-gateway.ngenius-payments.com/identity/auth/access-token"
        }
    }
}