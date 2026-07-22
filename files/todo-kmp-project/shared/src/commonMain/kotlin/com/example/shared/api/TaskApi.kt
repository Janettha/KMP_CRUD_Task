package com.example.shared.api

import com.example.shared.models.Task
import com.example.shared.models.CreateTaskRequest
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

class TaskApi(private val baseUrl: String = "http://localhost:8080") {
    
    private val client = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = true
                isLenient = true
                ignoreUnknownKeys = true
            })
        }
    }
    
    suspend fun getTasks(): Result<List<Task>> {
        return try {
            val tasks: List<Task> = client.get("$baseUrl/tasks").body()
            Result.success(tasks)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun getTask(id: Long): Result<Task> {
        return try {
            val task: Task = client.get("$baseUrl/tasks/$id").body()
            Result.success(task)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun createTask(title: String, description: String): Result<Task> {
        return try {
            //val request = CreateTaskRequest(title, description)
            val task = Task(
                title = title,
                description = description,
                createdAt = getCurrentTimestamp()
            )
            val created: Task = client.post("$baseUrl/tasks") {
                contentType(ContentType.Application.Json)
                setBody(task)
            }.body()
            Result.success(created)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun updateTask(id: Long, task: Task): Result<Task> {
        return try {
            val updated: Task = client.put("$baseUrl/tasks/$id") {
                contentType(ContentType.Application.Json)
                setBody(task)
            }.body()
            Result.success(updated)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun deleteTask(id: Long): Result<Unit> {
        return try {
            client.delete("$baseUrl/tasks/$id")
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    private fun getCurrentTimestamp(): String {
        // Esta es una implementación simple. En producción, usa kotlinx-datetime
        return "2025-02-06T12:00:00Z"
    }
}
