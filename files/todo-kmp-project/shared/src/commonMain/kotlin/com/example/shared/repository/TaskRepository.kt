package com.example.shared.repository

import com.example.shared.api.TaskApi
import com.example.shared.models.Task
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class TaskRepository(private val api: TaskApi = TaskApi()) {
    
    private val _tasks = MutableStateFlow<List<Task>>(emptyList())
    val tasks: StateFlow<List<Task>> = _tasks.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()
    
    suspend fun loadTasks() {
        _isLoading.value = true
        _error.value = null
        
        api.getTasks()
            .onSuccess { taskList ->
                _tasks.value = taskList
            }
            .onFailure { exception ->
                _error.value = exception.message ?: "Error desconocido"
            }
        
        _isLoading.value = false
    }
    
    suspend fun addTask(title: String, description: String): Boolean {
        if (title.isBlank()) {
            _error.value = "El título no puede estar vacío"
            return false
        }
        
        _isLoading.value = true
        _error.value = null
        
        val result = api.createTask(title, description)
            .onSuccess { newTask ->
                _tasks.value = _tasks.value + newTask
            }
            .onFailure { exception ->
                _error.value = exception.message ?: "Error al crear la tarea"
            }
        
        _isLoading.value = false
        return result.isSuccess
    }
    
    suspend fun toggleTaskCompletion(taskId: Long) {
        val task = _tasks.value.find { it.id == taskId } ?: return
        
        _isLoading.value = true
        _error.value = null
        
        val updatedTask = task.copy(completed = !task.completed)
        
        api.updateTask(taskId, updatedTask)
            .onSuccess { updated ->
                _tasks.value = _tasks.value.map { 
                    if (it.id == taskId) updated else it 
                }
            }
            .onFailure { exception ->
                _error.value = exception.message ?: "Error al actualizar la tarea"
            }
        
        _isLoading.value = false
    }
    
    suspend fun deleteTask(taskId: Long) {
        _isLoading.value = true
        _error.value = null
        
        api.deleteTask(taskId)
            .onSuccess {
                _tasks.value = _tasks.value.filter { it.id != taskId }
            }
            .onFailure { exception ->
                _error.value = exception.message ?: "Error al eliminar la tarea"
            }
        
        _isLoading.value = false
    }
    
    fun clearError() {
        _error.value = null
    }
}
