#!/bin/bash

# Script de Instalación Automática
# Sistema de Transporte Escolar

echo "🚌 ======================================"
echo "   Sistema de Transporte Escolar"
echo "   Script de Instalación Automática"
echo "======================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Verificar si Flutter está instalado
echo "📱 Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado"
    echo ""
    echo "Por favor instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi
print_success "Flutter está instalado"

# Verificar versión de Flutter
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_info "$FLUTTER_VERSION"

echo ""
echo "🔧 Verificando dependencias..."

# Verificar que el proyecto esté en la ubicación correcta
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encuentra pubspec.yaml"
    print_info "Por favor ejecuta este script desde la raíz del proyecto"
    exit 1
fi
print_success "Proyecto encontrado"

echo ""
echo "📦 Instalando dependencias de Flutter..."
flutter pub get

if [ $? -eq 0 ]; then
    print_success "Dependencias instaladas correctamente"
else
    print_error "Error al instalar dependencias"
    exit 1
fi

echo ""
echo "🔥 Verificando configuración de Firebase..."

# Verificar si existe google-services.json
if [ ! -f "android/app/google-services.json" ]; then
    print_error "No se encuentra google-services.json"
    echo ""
    print_info "Pasos para configurar Firebase:"
    echo "1. Ve a https://console.firebase.google.com/"
    echo "2. Crea un nuevo proyecto o selecciona uno existente"
    echo "3. Agrega una app Android"
    echo "4. Descarga google-services.json"
    echo "5. Colócalo en: android/app/google-services.json"
    echo ""
    read -p "¿Deseas continuar sin Firebase? (no recomendado) (s/N): " response
    if [[ ! "$response" =~ ^[Ss]$ ]]; then
        print_info "Instalación cancelada. Por favor configura Firebase primero."
        exit 1
    fi
else
    print_success "google-services.json encontrado"
fi

echo ""
echo "🔧 Configurando Android..."

# Verificar configuración de Android
if [ ! -d "android" ]; then
    print_error "Carpeta android no encontrada"
    exit 1
fi

# Crear archivo de propiedades local si no existe
if [ ! -f "android/local.properties" ]; then
    print_info "Creando android/local.properties..."
    
    # Detectar ubicación del SDK de Android
    if [ -d "$HOME/Android/Sdk" ]; then
        echo "sdk.dir=$HOME/Android/Sdk" > android/local.properties
        print_success "local.properties creado"
    else
        print_error "SDK de Android no encontrado"
        print_info "Por favor instala Android Studio y el SDK"
    fi
fi

echo ""
echo "🧹 Limpiando proyecto..."
flutter clean
print_success "Proyecto limpiado"

echo ""
echo "🔨 Compilando proyecto..."
flutter pub get
print_success "Proyecto compilado"

echo ""
echo "📱 Verificando dispositivos disponibles..."
flutter devices

echo ""
echo "✅ ======================================"
echo "   Instalación Completa"
echo "======================================="
echo ""
print_success "El proyecto está listo para ejecutarse"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Configurar Firebase (si aún no lo hiciste):"
echo "   - Descarga google-services.json"
echo "   - Colócalo en: android/app/google-services.json"
echo "   - Actualiza credenciales en lib/main.dart"
echo ""
echo "2. Configurar Cloud Functions:"
echo "   cd firebase_functions"
echo "   npm install"
echo "   firebase deploy --only functions"
echo ""
echo "3. Crear datos de prueba:"
echo "   - Sigue las instrucciones en DATOS_PRUEBA.md"
echo ""
echo "4. Ejecutar la aplicación:"
echo "   flutter run"
echo ""
echo "📚 Documentación adicional:"
echo "   - README.md          : Documentación completa"
echo "   - GUIA_VISUAL.md     : Guía visual del sistema"
echo "   - DATOS_PRUEBA.md    : Script de datos de prueba"
echo ""
echo "🚀 Para ejecutar ahora:"
echo "   flutter run"
echo ""

# Preguntar si desea ejecutar la app
read -p "¿Deseas ejecutar la aplicación ahora? (s/N): " run_app
if [[ "$run_app" =~ ^[Ss]$ ]]; then
    echo ""
    print_info "Iniciando aplicación..."
    flutter run
fi

echo ""
print_success "¡Gracias por usar el Sistema de Transporte Escolar!"
echo ""
