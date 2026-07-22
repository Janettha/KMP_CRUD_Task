package com.example.shared.models

import kotlinx.serialization.Serializable

@Serializable
data class Task(
    val id: Long = 0,
    val title: String,
    val description: String,
    val completed: Boolean = false,
    val createdAt: String
)

@Serializable
data class CreateTaskRequest(
    val title: String,
    val description: String
)
