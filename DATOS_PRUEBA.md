# Script de Datos de Prueba para Firebase

Este script te ayudará a configurar datos de prueba en tu proyecto de Firebase.

## 🔧 Configuración Inicial

### 1. Instalar Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 2. Inicializar Proyecto

```bash
cd transporte_escolar
firebase init
```

Selecciona:
- ✅ Firestore
- ✅ Functions
- ✅ Authentication

## 📝 Crear Usuarios de Prueba

### Opción 1: Desde Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Authentication** > **Users** > **Add user**

Crea los siguientes usuarios:

| Tipo | Email | Password | UID sugerido |
|------|-------|----------|--------------|
| Conductor | conductor@ejemplo.com | conductor123 | conductor001 |
| Padre | padre@ejemplo.com | padre123 | padre001 |
| Admin | admin@ejemplo.com | admin123 | admin001 |

### Opción 2: Programáticamente

Crea un archivo `setup_users.js` en la raíz del proyecto:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function crearUsuarios() {
  try {
    // Crear Conductor
    const conductor = await auth.createUser({
      uid: 'conductor001',
      email: 'conductor@ejemplo.com',
      password: 'conductor123',
      displayName: 'Juan Pérez'
    });
    
    await db.collection('usuarios').doc('conductor001').set({
      nombre: 'Juan Pérez',
      email: 'conductor@ejemplo.com',
      tipo: 'conductor',
      telefono: '+57 3001234567',
      fechaCreacion: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✓ Conductor creado');

    // Crear Padre
    const padre = await auth.createUser({
      uid: 'padre001',
      email: 'padre@ejemplo.com',
      password: 'padre123',
      displayName: 'María García'
    });
    
    await db.collection('usuarios').doc('padre001').set({
      nombre: 'María García',
      email: 'padre@ejemplo.com',
      tipo: 'padre',
      telefono: '+57 3007654321',
      fechaCreacion: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✓ Padre creado');

    // Crear Admin
    const administrador = await auth.createUser({
      uid: 'admin001',
      email: 'admin@ejemplo.com',
      password: 'admin123',
      displayName: 'Carlos Admin'
    });
    
    await db.collection('usuarios').doc('admin001').set({
      nombre: 'Carlos Admin',
      email: 'admin@ejemplo.com',
      tipo: 'admin',
      telefono: '+57 3009876543',
      fechaCreacion: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log('✓ Administrador creado');

  } catch (error) {
    console.error('Error:', error);
  }
}

crearUsuarios();
```

Ejecutar:
```bash
node setup_users.js
```

## 👥 Crear Estudiantes de Prueba

Crea un archivo `setup_students.js`:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function crearEstudiantes() {
  try {
    // Estudiante 1 - Sofía
    await db.collection('estudiantes').add({
      nombre: 'Sofía García',
      grado: '3° Primaria',
      idPadre: 'padre001',
      nombrePadre: 'María García',
      ubicacionCasa: {
        latitude: 4.1520,
        longitude: -73.6350
      },
      direccion: 'Cra 40 #25-30, Villavicencio',
      telefonoEmergencia: '+57 3001112222',
      activo: true
    });
    console.log('✓ Sofía creada');

    // Estudiante 2 - Miguel
    await db.collection('estudiantes').add({
      nombre: 'Miguel Rodríguez',
      grado: '5° Primaria',
      idPadre: 'padre002',
      nombrePadre: 'Ana Rodríguez',
      ubicacionCasa: {
        latitude: 4.1480,
        longitude: -73.6320
      },
      direccion: 'Cra 38 #28-15, Villavicencio',
      telefonoEmergencia: '+57 3002223333',
      activo: true
    });
    console.log('✓ Miguel creado');

    // Estudiante 3 - Valentina
    await db.collection('estudiantes').add({
      nombre: 'Valentina López',
      grado: '4° Primaria',
      idPadre: 'padre001',
      nombrePadre: 'María García',
      ubicacionCasa: {
        latitude: 4.1505,
        longitude: -73.6340
      },
      direccion: 'Cra 42 #24-20, Villavicencio',
      telefonoEmergencia: '+57 3003334444',
      activo: true
    });
    console.log('✓ Valentina creada');

    // Estudiante 4 - Daniel
    await db.collection('estudiantes').add({
      nombre: 'Daniel Martínez',
      grado: '2° Primaria',
      idPadre: 'padre003',
      nombrePadre: 'Pedro Martínez',
      ubicacionCasa: {
        latitude: 4.1495,
        longitude: -73.6310
      },
      direccion: 'Cra 36 #26-10, Villavicencio',
      telefonoEmergencia: '+57 3004445555',
      activo: true
    });
    console.log('✓ Daniel creado');

    // Estudiante 5 - Isabella
    await db.collection('estudiantes').add({
      nombre: 'Isabella Gómez',
      grado: '1° Primaria',
      idPadre: 'padre004',
      nombrePadre: 'Laura Gómez',
      ubicacionCasa: {
        latitude: 4.1525,
        longitude: -73.6360
      },
      direccion: 'Cra 44 #27-05, Villavicencio',
      telefonoEmergencia: '+57 3005556666',
      activo: true
    });
    console.log('✓ Isabella creada');

  } catch (error) {
    console.error('Error:', error);
  }
}

crearEstudiantes();
```

Ejecutar:
```bash
node setup_students.js
```

## 🛣️ Crear Ruta de Prueba

Crea un archivo `setup_routes.js`:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function crearRutas() {
  try {
    // Primero, obtener los IDs de los estudiantes creados
    const estudiantesSnapshot = await db.collection('estudiantes').get();
    const idsEstudiantes = estudiantesSnapshot.docs.map(doc => doc.id);

    // Crear Ruta 1
    await db.collection('rutas').add({
      nombre: 'Ruta Mañana - Norte',
      descripcion: 'Ruta matinal para estudiantes del sector norte de Villavicencio',
      idsEstudiantes: idsEstudiantes,
      idConductor: 'conductor001',
      nombreConductor: 'Juan Pérez',
      horaInicio: '06:00 AM',
      horaFin: '07:30 AM',
      activa: true
    });
    console.log('✓ Ruta 1 creada');

    // Crear Ruta 2
    await db.collection('rutas').add({
      nombre: 'Ruta Tarde - Centro',
      descripcion: 'Ruta vespertina para estudiantes del sector centro',
      idsEstudiantes: idsEstudiantes.slice(0, 3),
      idConductor: 'conductor001',
      nombreConductor: 'Juan Pérez',
      horaInicio: '12:00 PM',
      horaFin: '01:30 PM',
      activa: true
    });
    console.log('✓ Ruta 2 creada');

  } catch (error) {
    console.error('Error:', error);
  }
}

crearRutas();
```

Ejecutar:
```bash
node setup_routes.js
```

## 🔥 Script Completo de Configuración

Crea un archivo `setup_all.js` que ejecute todo:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function configurarTodo() {
  console.log('🚀 Iniciando configuración...\n');

  try {
    // 1. Crear Usuarios
    console.log('📝 Creando usuarios...');
    
    const usuarios = [
      {
        uid: 'conductor001',
        email: 'conductor@ejemplo.com',
        password: 'conductor123',
        displayName: 'Juan Pérez',
        tipo: 'conductor',
        telefono: '+57 3001234567'
      },
      {
        uid: 'padre001',
        email: 'padre@ejemplo.com',
        password: 'padre123',
        displayName: 'María García',
        tipo: 'padre',
        telefono: '+57 3007654321'
      },
      {
        uid: 'admin001',
        email: 'admin@ejemplo.com',
        password: 'admin123',
        displayName: 'Carlos Admin',
        tipo: 'admin',
        telefono: '+57 3009876543'
      }
    ];

    for (const usuario of usuarios) {
      try {
        await auth.createUser({
          uid: usuario.uid,
          email: usuario.email,
          password: usuario.password,
          displayName: usuario.displayName
        });

        await db.collection('usuarios').doc(usuario.uid).set({
          nombre: usuario.displayName,
          email: usuario.email,
          tipo: usuario.tipo,
          telefono: usuario.telefono,
          fechaCreacion: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`  ✓ ${usuario.displayName} creado`);
      } catch (error) {
        if (error.code === 'auth/email-already-exists') {
          console.log(`  ⚠ ${usuario.email} ya existe`);
        } else {
          throw error;
        }
      }
    }

    // 2. Crear Estudiantes
    console.log('\n👥 Creando estudiantes...');
    
    const estudiantes = [
      {
        nombre: 'Sofía García',
        grado: '3° Primaria',
        idPadre: 'padre001',
        nombrePadre: 'María García',
        ubicacionCasa: { latitude: 4.1520, longitude: -73.6350 },
        direccion: 'Cra 40 #25-30, Villavicencio',
        telefonoEmergencia: '+57 3001112222'
      },
      {
        nombre: 'Miguel Rodríguez',
        grado: '5° Primaria',
        idPadre: 'padre002',
        nombrePadre: 'Ana Rodríguez',
        ubicacionCasa: { latitude: 4.1480, longitude: -73.6320 },
        direccion: 'Cra 38 #28-15, Villavicencio',
        telefonoEmergencia: '+57 3002223333'
      },
      {
        nombre: 'Valentina López',
        grado: '4° Primaria',
        idPadre: 'padre001',
        nombrePadre: 'María García',
        ubicacionCasa: { latitude: 4.1505, longitude: -73.6340 },
        direccion: 'Cra 42 #24-20, Villavicencio',
        telefonoEmergencia: '+57 3003334444'
      }
    ];

    const idsEstudiantes = [];
    for (const estudiante of estudiantes) {
      const docRef = await db.collection('estudiantes').add({
        ...estudiante,
        activo: true
      });
      idsEstudiantes.push(docRef.id);
      console.log(`  ✓ ${estudiante.nombre} creado`);
    }

    // 3. Crear Rutas
    console.log('\n🛣️  Creando rutas...');
    
    await db.collection('rutas').add({
      nombre: 'Ruta Mañana - Norte',
      descripcion: 'Ruta matinal para estudiantes del sector norte',
      idsEstudiantes: idsEstudiantes,
      idConductor: 'conductor001',
      nombreConductor: 'Juan Pérez',
      horaInicio: '06:00 AM',
      horaFin: '07:30 AM',
      activa: true
    });
    console.log('  ✓ Ruta Mañana creada');

    console.log('\n✅ ¡Configuración completa!\n');
    console.log('📱 Usuarios de prueba:');
    console.log('   Conductor: conductor@ejemplo.com / conductor123');
    console.log('   Padre: padre@ejemplo.com / padre123');
    console.log('   Admin: admin@ejemplo.com / admin123');

  } catch (error) {
    console.error('❌ Error:', error);
  }
}

configurarTodo();
```

## 🚀 Ejecutar Todo

1. Descarga tu clave de cuenta de servicio de Firebase:
   - Ve a Firebase Console > Project Settings > Service Accounts
   - Click en "Generate New Private Key"
   - Guarda como `serviceAccountKey.json`

2. Instala dependencias:
```bash
npm install firebase-admin
```

3. Ejecuta el script:
```bash
node setup_all.js
```

## ✅ Verificación

Después de ejecutar los scripts, verifica en Firebase Console que se hayan creado:

- ✅ 3 usuarios en Authentication
- ✅ 3 documentos en `usuarios` collection
- ✅ 3-5 estudiantes en `estudiantes` collection
- ✅ 1-2 rutas en `rutas` collection

¡Listo! Ahora puedes iniciar sesión en la app con cualquiera de los usuarios de prueba.
