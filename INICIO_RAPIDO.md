# 🚀 Inicio Rápido - Sistema de Transporte Escolar

## ⚡ Empezar en 5 Minutos

### 1️⃣ Prerequisitos Rápidos
```bash
# Verificar Flutter
flutter doctor

# Si todo está ✓, continúa
```

### 2️⃣ Instalación Express
```bash
# En la carpeta del proyecto
./install.sh

# O manualmente:
flutter pub get
```

### 3️⃣ Configuración Mínima

**Firebase (obligatorio):**
1. Crea proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Descarga `google-services.json`
3. Colócalo en: `android/app/google-services.json`
4. Actualiza credenciales en `lib/main.dart`

**Datos de Prueba (recomendado):**
```javascript
// En Firebase Console > Authentication, crea:
conductor@ejemplo.com / conductor123
padre@ejemplo.com / padre123
admin@ejemplo.com / admin123
```

### 4️⃣ Ejecutar
```bash
flutter run
```

---

## 📂 Estructura de Archivos

```
transporte_escolar/
├── 📄 README.md              ← Documentación completa
├── 📄 CHECKLIST.md           ← Checklist paso a paso
├── 📄 GUIA_VISUAL.md         ← Guía visual de interfaces
├── 📄 DATOS_PRUEBA.md        ← Scripts de datos de prueba
├── 📄 INICIO_RAPIDO.md       ← Este archivo
├── 🔧 install.sh             ← Script de instalación
├── 📦 pubspec.yaml           ← Dependencias
│
├── lib/
│   ├── 🎯 main.dart          ← Punto de entrada
│   ├── models/
│   │   └── models.dart       ← Modelos de datos
│   ├── services/
│   │   ├── firebase_service.dart       ← Lógica de Firebase
│   │   └── notification_service.dart   ← Notificaciones
│   └── screens/
│       ├── login_screen.dart      ← Pantalla de login
│       ├── conductor_screen.dart  ← Pantalla del conductor
│       ├── padre_screen.dart      ← Pantalla de padres
│       └── admin_screen.dart      ← Pantalla de admin
│
├── firebase_functions/
│   ├── index.js          ← Cloud Functions
│   └── package.json      ← Dependencias de Functions
│
└── android/
    └── app/
        ├── google-services.json  ← ⚠️ DEBES AGREGARLO
        └── src/main/
            └── AndroidManifest.xml
```

---

## 🎯 Usuarios de Prueba

| Rol | Email | Password |
|-----|-------|----------|
| 🚌 Conductor | conductor@ejemplo.com | conductor123 |
| 👨‍👩‍👧 Padre | padre@ejemplo.com | padre123 |
| 👨‍💼 Admin | admin@ejemplo.com | admin123 |

---

## 🔥 Comandos Firebase Esenciales

```bash
# Instalar CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar proyecto
firebase init

# Desplegar Functions
cd firebase_functions
npm install
firebase deploy --only functions

# Ver logs
firebase functions:log
```

---

## 🐛 Solución Rápida de Problemas

### Error: "No se encuentra google-services.json"
```
✓ Descarga desde Firebase Console
✓ Coloca en: android/app/google-services.json
✓ Ejecuta: flutter clean && flutter pub get
```

### Error: "Location permissions denied"
```
✓ Acepta permisos cuando la app los pida
✓ Verifica AndroidManifest.xml tenga los permisos
```

### Error: "Firebase not initialized"
```
✓ Verifica google-services.json esté en su lugar
✓ Actualiza credenciales en lib/main.dart
✓ Reinicia la app
```

### El mapa no carga
```
✓ Verifica conexión a internet
✓ Verifica que flutter_map esté instalado
✓ Intenta con otro dispositivo/emulador
```

---

## 📱 Flujo Básico de Uso

### Como Conductor 🚌
1. Login → Seleccionar Ruta → Iniciar Viaje
2. Registrar cuando cada estudiante sube
3. Enviar notificación de mitad de camino
4. Registrar cuando cada estudiante baja
5. Finalizar viaje

### Como Padre 👨‍👩‍👧
1. Login → Ver mis hijos → Seleccionar hijo
2. Ver ubicación del bus en tiempo real
3. Recibir notificaciones automáticas
4. Si lo recoges tú, presionar "Yo lo recojo"

### Como Admin 👨‍💼
1. Login → Ver dashboard
2. Gestionar estudiantes y rutas
3. Monitorear viajes en curso
4. Ver reportes y estadísticas

---

## 🎨 Personalización Rápida

### Cambiar Colores
Edita `lib/main.dart`:
```dart
primarySwatch: Colors.blue,  // ← Cambia aquí
```

### Cambiar Nombre de la App
Edita `android/app/src/main/AndroidManifest.xml`:
```xml
android:label="Tu Nombre Aquí"
```

### Cambiar Icono
Reemplaza iconos en:
```
android/app/src/main/res/mipmap-*/ic_launcher.png
```

---

## 📚 ¿Qué Leer Después?

1. **Primera vez con Flutter?**
   → Empieza con `README.md` sección "Instalación"

2. **¿Quieres entender el código?**
   → Lee `GUIA_VISUAL.md` para ver cómo funciona cada pantalla

3. **¿Listo para producción?**
   → Sigue el `CHECKLIST.md` completo

4. **¿Necesitas datos de prueba?**
   → Usa scripts en `DATOS_PRUEBA.md`

---

## 🆘 Soporte

- **Documentación**: Lee README.md para detalles completos
- **Problemas comunes**: Revisa sección de troubleshooting
- **Stack Overflow**: Busca con tags `flutter` + `firebase`
- **Firebase Support**: [firebase.google.com/support](https://firebase.google.com/support)

---

## ✅ Checklist Express

Antes de empezar a desarrollar, verifica que tengas:

- [ ] Flutter instalado y funcionando (`flutter doctor`)
- [ ] Proyecto de Firebase creado
- [ ] `google-services.json` en `android/app/`
- [ ] Credenciales actualizadas en `lib/main.dart`
- [ ] Usuarios de prueba creados en Firebase Authentication
- [ ] Al menos una ruta y estudiantes en Firestore

Si todo está ✓, ejecuta:
```bash
flutter run
```

---

## 🎯 Objetivo del Sistema

Este sistema permite:
- 📍 **Tracking GPS en tiempo real** del bus escolar
- 🔔 **Notificaciones automáticas** a padres en cada evento
- 👥 **Gestión completa** de estudiantes, rutas y viajes
- 📊 **Dashboard administrativo** con estadísticas
- 🏃 **Retiros manuales** cuando el padre recoge al niño

---

## 🚀 ¡A Empezar!

```bash
# 1. Entra a la carpeta
cd transporte_escolar

# 2. Instala
./install.sh

# 3. Configura Firebase
# (descarga google-services.json)

# 4. Ejecuta
flutter run

# 5. Login con:
# conductor@ejemplo.com / conductor123
```

**¡Listo! Ya tienes el sistema corriendo** 🎉

---

## 💡 Tips Finales

- **Desarrollo**: Usa datos de prueba libremente
- **Producción**: Cambia TODAS las contraseñas
- **Costos**: Firebase tiene plan gratuito generoso
- **Backup**: Exporta Firestore regularmente
- **Updates**: Mantén Flutter y dependencias actualizadas

---

**¿Preguntas?** Revisa el README.md o el CHECKLIST.md

**¡Buena suerte con tu proyecto! 🚌📱**
