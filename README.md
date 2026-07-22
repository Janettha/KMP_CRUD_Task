# 📱 Todo App - Kotlin Multiplatform CRUD Completo

Una aplicación completa de gestión de tareas (To-Do List) construida con Kotlin Multiplatform que demuestra cómo compartir código entre Android, iOS y Web.

## 🏗️ Arquitectura

```
📦 todo-kmp-project/
├── 🖥️  server/              # Servidor Ktor (Backend)
├── 📚 shared/               # Código compartido (Lógica de negocio)
├── 📱 android-app/          # App Android (Jetpack Compose)
├── 🍎 ios-app/             # App iOS (SwiftUI)
└── 🌐 web-app/             # App Web (Kotlin/JS + React)
```

## 🎯 Características

- ✅ **Create**: Crear nuevas tareas
- 📖 **Read**: Ver lista de tareas
- ✏️ **Update**: Marcar tareas como completadas
- 🗑️ **Delete**: Eliminar tareas

## 🛠️ Stack Tecnológico

### Backend
- **Ktor Server**: Framework web de Kotlin
- **kotlinx.serialization**: Serialización JSON
- **Base de datos**: En memoria (puedes extender a PostgreSQL/H2)

### Shared (Código Compartido)
- **Ktor Client**: Cliente HTTP multiplataforma
- **Kotlin Coroutines**: Programación asíncrona
- **StateFlow**: Manejo de estado reactivo

### Android
- **Jetpack Compose**: UI declarativa
- **Material 3**: Sistema de diseño de Google

### iOS
- **SwiftUI**: UI declarativa de Apple
- **Combine**: Programación reactiva (para observar StateFlows)

### Web
- **Kotlin/JS**: Compilación de Kotlin a JavaScript
- **React**: Framework de UI (con wrappers de Kotlin)

## 📋 Requisitos Previos

### Para todos
- JDK 17 o superior
- Gradle 8.0+

### Para Android
- Android Studio Hedgehog o superior
- Android SDK (API 24+)

### Para iOS
- macOS con Xcode 15+
- CocoaPods

### Para Web
- Node.js 16+

## 🚀 Instalación y Ejecución

### 1️⃣ Clonar/Copiar el Proyecto

```bash
# Estructura ya proporcionada en los archivos adjuntos
```

### 2️⃣ Ejecutar el Servidor

```bash
cd server
./gradlew run

# El servidor estará disponible en http://localhost:8080
# Prueba: curl http://localhost:8080/health
```

### 3️⃣ Ejecutar Android

```bash
# Opción 1: Desde Android Studio
# 1. Abre Android Studio
# 2. File > Open > Selecciona la carpeta android-app
# 3. Espera a que Gradle sincronice
# 4. Click en Run ▶️

# Opción 2: Desde terminal
cd android-app
./gradlew installDebug
```

**IMPORTANTE**: Antes de ejecutar en Android, actualiza la URL del servidor en `shared/commonMain/api/TaskApi.kt`:

```kotlin
// Si usas emulador:
private val baseUrl = "http://10.0.2.2:8080"

// Si usas dispositivo físico, usa tu IP local:
private val baseUrl = "http://192.168.1.X:8080"  // Reemplaza X con tu IP
```

### 4️⃣ Ejecutar iOS

```bash
# 1. Primero, compila el framework compartido
cd shared
./gradlew :shared:assembleXCFramework

# 2. Abre el proyecto en Xcode
open iosApp/iosApp.xcworkspace

# 3. En Xcode, selecciona un simulador y presiona Run ▶️
```

**IMPORTANTE**: Actualiza la URL del servidor en `shared/commonMain/api/TaskApi.kt`:

```kotlin
// Para simulador de iOS:
private val baseUrl = "http://localhost:8080"
```

### 5️⃣ Ejecutar Web

```bash
cd web-app
npm install
npm run dev

# La app estará en http://localhost:3000
```

## 📱 Uso de la Aplicación

### Crear una Tarea
1. Click en el botón "+" (Android/iOS) o "Add Task" (Web)
2. Ingresa título y descripción
3. Click en "Crear" / "Create"

### Completar una Tarea
- Click en el checkbox al lado de la tarea

### Eliminar una Tarea
- Click en el ícono de basura 🗑️

## 🧪 Testing del API

Puedes probar el API directamente con curl:

```bash
# Ver todas las tareas
curl http://localhost:8080/tasks

# Crear una tarea
curl -X POST http://localhost:8080/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Nueva tarea",
    "description": "Descripción de la tarea",
    "completed": false,
    "createdAt": "2025-02-06T12:00:00Z"
  }'

# Actualizar una tarea (cambiar ID según necesites)
curl -X PUT http://localhost:8080/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "title": "Tarea actualizada",
    "description": "Nueva descripción",
    "completed": true,
    "createdAt": "2025-02-06T12:00:00Z"
  }'

# Eliminar una tarea
curl -X DELETE http://localhost:8080/tasks/1
```

## 🔍 Explicación del Código Compartido

### Modelos (shared/commonMain/models/Task.kt)

```kotlin
@Serializable
data class Task(
    val id: Long = 0,
    val title: String,
    val description: String,
    val completed: Boolean = false,
    val createdAt: String
)
```

Este modelo se usa **exactamente igual** en Android, iOS y Web.

### API Client (shared/commonMain/api/TaskApi.kt)

```kotlin
class TaskApi {
    suspend fun getTasks(): Result<List<Task>>
    suspend fun createTask(...): Result<Task>
    suspend fun updateTask(...): Result<Task>
    suspend fun deleteTask(...): Result<Unit>
}
```

El cliente HTTP funciona en **todas las plataformas** sin cambios.

### Repository (shared/commonMain/repository/TaskRepository.kt)

```kotlin
class TaskRepository {
    val tasks: StateFlow<List<Task>>
    val isLoading: StateFlow<Boolean>
    val error: StateFlow<String?>
    
    suspend fun loadTasks()
    suspend fun addTask(...)
    suspend fun toggleTaskCompletion(...)
    suspend fun deleteTask(...)
}
```

La lógica de negocio es **100% compartida**.

## 🎨 Comparación de UI

### Android (Compose)
```kotlin
@Composable
fun TaskItem(task: Task, ...) {
    Card {
        Row {
            Checkbox(checked = task.completed, ...)
            Text(task.title)
            IconButton { Icon(Delete) }
        }
    }
}
```

### iOS (SwiftUI)
```swift
struct TaskRow: View {
    var body: some View {
        HStack {
            Button { Image("circle") }
            Text(task.title)
            Button { Image("trash") }
        }
    }
}
```

**Nota**: La sintaxis es diferente, pero la estructura es muy similar.

## 🔧 Personalización y Extensión

### Agregar Persistencia Local

Instala SQLDelight en `shared/build.gradle.kts`:

```kotlin
plugins {
    id("com.squareup.sqldelight") version "1.5.5"
}

sqldelight {
    database("TaskDatabase") {
        packageName = "com.example.shared.db"
    }
}
```

### Agregar Autenticación

1. Agrega un modelo `User` en `shared/commonMain/models/`
2. Crea `AuthRepository` en `shared/commonMain/repository/`
3. Implementa endpoints `/login` y `/register` en el servidor
4. Guarda tokens con `expect/actual` para cada plataforma

### Conectar a Base de Datos Real

En `server/Application.kt`, reemplaza `TaskDatabase` con Exposed:

```kotlin
object TasksTable : LongIdTable() {
    val title = varchar("title", 255)
    val description = text("description")
    val completed = bool("completed")
    val createdAt = varchar("created_at", 50)
}

Database.connect(
    "jdbc:postgresql://localhost:5432/tasks",
    driver = "org.postgresql.Driver",
    user = "postgres",
    password = "password"
)
```

## 📚 Recursos Adicionales

- **Documentación KMP**: https://kotlinlang.org/docs/multiplatform.html
- **Ktor**: https://ktor.io
- **Jetpack Compose**: https://developer.android.com/jetpack/compose
- **SwiftUI**: https://developer.apple.com/xcode/swiftui/

## 🐛 Solución de Problemas

### Error: "Connection refused" en Android
- Asegúrate de usar `http://10.0.2.2:8080` para el emulador
- Para dispositivo físico, usa tu IP local y verifica que estén en la misma red

### Error: "Module not found" en iOS
- Ejecuta `./gradlew :shared:assembleXCFramework`
- Limpia el build de Xcode: Product > Clean Build Folder

### Error de CORS en Web
- Verifica que CORS esté configurado en el servidor (ya está en el código)
- Usa `http://localhost` no `127.0.0.1`

## 🎓 Conceptos Aprendidos

Al completar este proyecto, habrás aprendido:

✅ Arquitectura Kotlin Multiplatform
✅ Ktor para servidor y cliente
✅ StateFlow y programación reactiva
✅ Jetpack Compose (Android)
✅ SwiftUI (iOS)
✅ Kotlin/JS (Web)
✅ Operaciones CRUD completas
✅ Manejo de errores multiplataforma

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Siéntete libre de:
- Reportar bugs
- Sugerir nuevas características
- Mejorar la documentación
- Enviar pull requests

## 👨‍💻 Autor

Creado como guía educativa para aprender Kotlin Multiplatform.

---

**¡Feliz codificación! 🚀**
