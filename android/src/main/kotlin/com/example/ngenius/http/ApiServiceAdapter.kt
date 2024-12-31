package com.example.ngenius.http

import android.util.Log
import com.example.myapplication.model.OrderRequest
import com.example.myapplication.model.toMap
import com.google.gson.Gson
import com.google.gson.JsonParser
import payment.sdk.android.core.Order
import payment.sdk.android.core.api.Body
import payment.sdk.android.core.api.HttpClient
import payment.sdk.android.core.api.SDKHttpResponse

class ApiServiceAdapter(
    private val httpClient: HttpClient
) : ApiService {
    override suspend fun getAccessToken(url: String, apiKey: String, realm: String): String? {
        Log.i("Create Order","${url}")
        Log.i("Create Order","${apiKey}")
        Log.i("Create Order","${realm}")

        val response = httpClient.post(
            url = url,
            headers = mapOf(
                HEADER_CONTENT_TYPE to "application/vnd.ni-identity.v1+json",
                HEADER_AUTH to "Basic $apiKey"
            ),
            body = Body.Json(
                mapOf(
                    "realmName" to realm
                )
            )
        )
        Log.i("Create Order","${response}")
        return when (response) {
            is SDKHttpResponse.Failed -> null
            is SDKHttpResponse.Success -> {
                Log.i("Create Order","${response.body}")
                JsonParser.parseString(response.body).asJsonObject.get("access_token")?.asString
            }
        }
    }

    override suspend fun getOrder(
        url: String,
        orderReference: String,
        accessToken: String
    ): Order? {
        val response = httpClient.get(
            url = "$url/$orderReference",
            headers = mapOf(
                HEADER_CONTENT_TYPE to "application/vnd.ni-payment.v2+json",
                HEADER_ACCEPT to "application/vnd.ni-payment.v2+json",
                HEADER_AUTH to "Bearer $accessToken"
            ),
            body = Body.Empty()
        )
        return when (response) {
            is SDKHttpResponse.Failed -> null
            is SDKHttpResponse.Success -> {
                return Gson().fromJson(response.body, Order::class.java)
            }
        }
    }

    override suspend fun createOrder(
        url: String,
        accessToken: String,
        orderRequest: OrderRequest
    ): Order? {
        val response = httpClient.post(
            url = url,
            headers = mapOf(
                HEADER_CONTENT_TYPE to "application/vnd.ni-payment.v2+json",
                HEADER_ACCEPT to "application/vnd.ni-payment.v2+json",
                HEADER_AUTH to "Bearer $accessToken"
            ),
            body = Body.Json(
                orderRequest.toMap()
            )
        )
        return when (response) {
            is SDKHttpResponse.Failed -> null
            is SDKHttpResponse.Success -> {
                return Gson().fromJson(response.body, Order::class.java)
            }
        }
    }

    companion object {
        const val HEADER_AUTH = "Authorization"
        const val HEADER_ACCEPT = "Content-Type"
        const val HEADER_CONTENT_TYPE = "Content-Type"
    }
}