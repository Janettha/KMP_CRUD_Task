#!/bin/bash

# Script de inicio rápido para el proyecto Todo KMP
# Este script ayuda a configurar y ejecutar el proyecto

echo "🚀 Todo KMP - Script de Inicio Rápido"
echo "======================================"
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Verificar Java
print_info "Verificando Java..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    print_success "Java encontrado: $JAVA_VERSION"
else
    print_error "Java no encontrado. Por favor instala JDK 17 o superior."
    exit 1
fi

# Menú principal
echo ""
echo "¿Qué deseas hacer?"
echo "1) Iniciar el servidor"
echo "2) Compilar módulo compartido para iOS"
echo "3) Ver estructura del proyecto"
echo "4) Probar el API con curl"
echo "5) Ver instrucciones completas"
echo "6) Salir"
echo ""
read -p "Selecciona una opción (1-6): " choice

case $choice in
    1)
        print_info "Iniciando servidor Ktor..."
        cd server
        if [ -f "build.gradle.kts" ]; then
            print_info "Compilando y ejecutando servidor..."
            ./gradlew run
        else
            print_error "No se encuentra build.gradle.kts en la carpeta server"
            print_info "Asegúrate de estar en el directorio raíz del proyecto"
        fi
        ;;
    2)
        print_info "Compilando framework compartido para iOS..."
        cd shared
        if [ -f "build.gradle.kts" ]; then
            ./gradlew :shared:assembleXCFramework
            print_success "Framework compilado exitosamente"
            print_info "Ahora puedes abrir el proyecto de Xcode en ios-app/"
        else
            print_error "No se encuentra build.gradle.kts en la carpeta shared"
        fi
        ;;
    3)
        print_info "Estructura del proyecto:"
        echo ""
        echo "📦 todo-kmp-project/"
        echo "├── 🖥️  server/                  # Servidor Ktor (Backend)"
        echo "│   ├── Application.kt           # Punto de entrada del servidor"
        echo "│   └── build.gradle.kts         # Configuración de dependencias"
        echo "│"
        echo "├── 📚 shared/                   # Código compartido"
        echo "│   ├── commonMain/"
        echo "│   │   ├── models/Task.kt       # Modelo de datos compartido"
        echo "│   │   ├── api/TaskApi.kt       # Cliente HTTP compartido"
        echo "│   │   └── repository/          # Lógica de negocio compartida"
        echo "│   ├── androidMain/             # Código específico Android"
        echo "│   ├── iosMain/                 # Código específico iOS"
        echo "│   └── jsMain/                  # Código específico Web"
        echo "│"
        echo "├── 📱 android-app/              # App Android"
        echo "│   └── MainActivity.kt          # UI con Jetpack Compose"
        echo "│"
        echo "├── 🍎 ios-app/                 # App iOS"
        echo "│   └── ContentView.swift        # UI con SwiftUI"
        echo "│"
        echo "├── 🌐 web-app/                 # App Web"
        echo "│   └── (Kotlin/JS + React)"
        echo "│"
        echo "└── 📖 README.md                # Documentación completa"
        ;;
    4)
        print_info "Probando el API..."
        echo ""
        
        print_info "1. Verificando que el servidor esté corriendo..."
        if curl -s http://localhost:8080/health > /dev/null; then
            print_success "Servidor está corriendo"
            echo ""
            
            print_info "2. Obteniendo todas las tareas..."
            curl -s http://localhost:8080/tasks | python3 -m json.tool
            echo ""
            
            print_info "3. Para crear una nueva tarea, ejecuta:"
            echo "curl -X POST http://localhost:8080/tasks \\"
            echo "  -H 'Content-Type: application/json' \\"
            echo "  -d '{\"title\":\"Mi tarea\",\"description\":\"Descripción\",\"completed\":false,\"createdAt\":\"2025-02-06T12:00:00Z\"}'"
        else
            print_error "El servidor no está corriendo en http://localhost:8080"
            print_info "Inicia el servidor primero con la opción 1"
        fi
        ;;
    5)
        print_info "Instrucciones completas:"
        echo ""
        echo "=== PASO 1: Iniciar el Servidor ==="
        echo "cd server"
        echo "./gradlew run"
        echo "# El servidor estará en http://localhost:8080"
        echo ""
        echo "=== PASO 2: Android ==="
        echo "1. Abre Android Studio"
        echo "2. File > Open > Selecciona 'android-app'"
        echo "3. Actualiza la URL en TaskApi.kt:"
        echo "   - Emulador: http://10.0.2.2:8080"
        echo "   - Dispositivo: http://TU_IP_LOCAL:8080"
        echo "4. Click en Run ▶️"
        echo ""
        echo "=== PASO 3: iOS (Solo en Mac) ==="
        echo "cd shared"
        echo "./gradlew :shared:assembleXCFramework"
        echo "open iosApp/iosApp.xcworkspace"
        echo "# En Xcode, selecciona un simulador y presiona Run"
        echo ""
        echo "=== PASO 4: Web ==="
        echo "cd web-app"
        echo "npm install"
        echo "npm run dev"
        echo "# La app estará en http://localhost:3000"
        echo ""
        print_info "Para más detalles, consulta README.md"
        ;;
    6)
        print_info "¡Hasta luego!"
        exit 0
        ;;
    *)
        print_error "Opción inválida"
        exit 1
        ;;
esac
