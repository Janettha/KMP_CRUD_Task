package com.example.todoserver

import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.application.*
import io.ktor.server.routing.*
import io.ktor.server.response.*
import io.ktor.server.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.cors.routing.*
import kotlinx.serialization.*
import kotlinx.serialization.json.*
import java.util.concurrent.atomic.AtomicLong

@Serializable
data class Task(
    val id: Long = 0,
    val title: String,
    val description: String,
    val completed: Boolean = false,
    val createdAt: String
)

// Base de datos en memoria simple para demostración
object TaskDatabase {
    private val tasks = mutableListOf<Task>()
    private val idCounter = AtomicLong(0)
    
    init {
        // Datos de ejemplo
        tasks.add(Task(
            id = idCounter.incrementAndGet(),
            title = "Aprender Kotlin Multiplatform",
            description = "Completar el tutorial y crear mi primer proyecto",
            completed = false,
            createdAt = "2025-02-06T10:00:00Z"
        ))
        tasks.add(Task(
            id = idCounter.incrementAndGet(),
            title = "Configurar el servidor Ktor",
            description = "Instalar dependencias y crear los endpoints CRUD",
            completed = true,
            createdAt = "2025-02-06T09:00:00Z"
        ))
    }
    
    fun getAllTasks(): List<Task> = tasks.toList()
    
    fun getTaskById(id: Long): Task? = tasks.find { it.id == id }
    
    fun createTask(task: Task): Task {
        val newTask = task.copy(id = idCounter.incrementAndGet())
        tasks.add(newTask)
        return newTask
    }
    
    fun updateTask(id: Long, task: Task): Task? {
        val index = tasks.indexOfFirst { it.id == id }
        return if (index != -1) {
            val updated = task.copy(id = id)
            tasks[index] = updated
            updated
        } else null
    }
    
    fun deleteTask(id: Long): Boolean {
        return tasks.removeIf { it.id == id }
    }
}

fun main() {
    embeddedServer(Netty, port = 8080, host = "0.0.0.0") {
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = true
                isLenient = true
            })
        }
        
        install(CORS) {
            anyHost()
            allowHeader(HttpHeaders.ContentType)
            allowMethod(HttpMethod.Get)
            allowMethod(HttpMethod.Post)
            allowMethod(HttpMethod.Put)
            allowMethod(HttpMethod.Delete)
            allowMethod(HttpMethod.Options)
        }
        
        routing {
            taskRoutes()
        }
    }.start(wait = true)
}

fun Route.taskRoutes() {
    route("/tasks") {
        // GET /tasks - Obtener todas las tareas
        get {
            call.respond(TaskDatabase.getAllTasks())
        }
        
        // GET /tasks/{id} - Obtener una tarea por ID
        get("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
            if (id == null) {
                call.respond(HttpStatusCode.BadRequest, "Invalid ID")
                return@get
            }
            
            val task = TaskDatabase.getTaskById(id)
            if (task != null) {
                call.respond(task)
            } else {
                call.respond(HttpStatusCode.NotFound, "Task not found")
            }
        }
        
        // POST /tasks - Crear una nueva tarea
        post {
            val task = call.receive<Task>()
            val created = TaskDatabase.createTask(task)
            call.respond(HttpStatusCode.Created, created)
        }
        
        // PUT /tasks/{id} - Actualizar una tarea
        put("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
            if (id == null) {
                call.respond(HttpStatusCode.BadRequest, "Invalid ID")
                return@put
            }
            
            val task = call.receive<Task>()
            val updated = TaskDatabase.updateTask(id, task)
            if (updated != null) {
                call.respond(updated)
            } else {
                call.respond(HttpStatusCode.NotFound, "Task not found")
            }
        }
        
        // DELETE /tasks/{id} - Eliminar una tarea
        delete("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
            if (id == null) {
                call.respond(HttpStatusCode.BadRequest, "Invalid ID")
                return@delete
            }
            
            val deleted = TaskDatabase.deleteTask(id)
            if (deleted) {
                call.respond(HttpStatusCode.NoContent)
            } else {
                call.respond(HttpStatusCode.NotFound, "Task not found")
            }
        }
    }
    
    // Endpoint de salud para verificar que el servidor está funcionando
    get("/health") {
        call.respondText("Server is running!", ContentType.Text.Plain)
    }
}
