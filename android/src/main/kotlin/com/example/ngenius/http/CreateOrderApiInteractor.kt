package com.example.ngenius.http

import android.util.Log
import com.example.myapplication.model.Environment
import com.example.myapplication.model.OrderRequest
import payment.sdk.android.core.Order

class CreateOrderApiInteractor(private val apiService: ApiService) {
    suspend fun createOrder(environment: Environment, orderRequest: OrderRequest): Result<Order> {
        Log.i("Create Order","${environment.getIdentityUrl()}")
        Log.i("Create Order","${environment.apiKey}")
        Log.i("Create Order","${environment.realm}")

        val accessToken = apiService.getAccessToken(
            url = environment.getIdentityUrl(),
            apiKey = environment.apiKey,
            realm = environment.realm
        )

        if (accessToken == null) {
            return Result.Error(message = "Failed to get access token")
        }

        val order = apiService.createOrder(
            url = environment.getGatewayUrl(),
            accessToken = accessToken,
            orderRequest = orderRequest
        )

        if (order == null) {
            return Result.Error(message = "Failed to create order")
        }
        return Result.Success(data = order)
    }
}