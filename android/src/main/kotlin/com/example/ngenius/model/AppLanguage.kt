package com.example.ngenius.model

enum class AppLanguage(override val code: String, override val displayValue: String) : PickerItem {
    ENGLISH("en", "English"),
    ARABIC("ar", "Arabic")
}