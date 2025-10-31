# 📱 Guía Visual del Sistema de Transporte Escolar

## 🎯 Flujos de Usuario

### 👨‍✈️ Flujo del Conductor

```
┌─────────────────┐
│  Login Screen   │
│                 │
│  [Email Input]  │
│  [Pass Input]   │
│  [Login Button] │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Selección de Ruta      │
│                         │
│  ┌─────────────────┐   │
│  │ Ruta Mañana     │ ✓ │
│  │ 5 estudiantes   │   │
│  │ 06:00 - 07:30   │   │
│  └─────────────────┘   │
│                         │
│  [Iniciar Viaje]        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────────────┐
│  Vista del Viaje                │
│                                 │
│  ┌──────── MAPA ────────┐      │
│  │    🚌 Bus (ubicación) │      │
│  │    📍 Estudiante 1    │      │
│  │    📍 Estudiante 2    │      │
│  │    ✅ Estudiante 3    │      │
│  └───────────────────────┘      │
│                                 │
│  Estudiantes: 2/5               │
│  ┌─────────────────────┐       │
│  │ ✅ Sofía García      │       │
│  │ ⬆️ Subió al bus      │       │
│  ├─────────────────────┤       │
│  │ ⭕ Miguel Rodríguez  │       │
│  │ [⬆️ Subir] [Info]    │       │
│  └─────────────────────┘       │
│                                 │
│  [🔔 Mitad Camino] [⏹ Fin]    │
└─────────────────────────────────┘
```

### 👨‍👩‍👧 Flujo del Padre

```
┌─────────────────┐
│  Login Screen   │
│                 │
│  [Email Input]  │
│  [Pass Input]   │
│  [Login Button] │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Mis Hijos              │
│                         │
│  ┌─────────────────┐   │
│  │ 👧 Sofía García  │ → │
│  │ 3° Primaria     │   │
│  │ Estado: En ruta │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ 👧 Valentina    │ → │
│  │ 4° Primaria     │   │
│  │ Estado: En casa │   │
│  └─────────────────┘   │
└─────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│  Seguimiento de Sofía            │
│                                  │
│  ┌────────── MAPA ──────────┐   │
│  │   🚌 Bus (tiempo real)   │   │
│  │   ··· Ruta estimada ···  │   │
│  │   🏠 Mi casa             │   │
│  └──────────────────────────┘   │
│                                  │
│  📍 Estado: En camino            │
│  ⏱️ Llegada estimada: 07:15 AM  │
│  🚌 Distancia: 2.3 km           │
│                                  │
│  🔔 Notificaciones recientes:    │
│  ┌──────────────────────────┐   │
│  │ ✅ Subió al bus - 06:45  │   │
│  │ 🔔 Mitad camino - 07:00  │   │
│  └──────────────────────────┘   │
│                                  │
│  [🏃 Yo lo recojo hoy]          │
│  [📜 Ver historial]              │
└──────────────────────────────────┘
```

### 👨‍💼 Flujo del Administrador

```
┌─────────────────┐
│  Login Screen   │
│                 │
│  [Email Input]  │
│  [Pass Input]   │
│  [Login Button] │
└────────┬────────┘
         │
         ▼
┌────────────────────────────────┐
│  Dashboard Administrativo      │
│                                │
│  📊 Estadísticas Hoy:          │
│  ┌──────┬──────┬──────────┐   │
│  │ 12   │ 8    │ 95%      │   │
│  │Viajes│Rutas │Eficiencia│   │
│  └──────┴──────┴──────────┘   │
│                                │
│  🚌 Viajes en Curso (3):       │
│  ┌──────────────────────────┐ │
│  │ Ruta Mañana - Juan       │ │
│  │ 5/5 estudiantes          │ │
│  │ [Ver] [Monitorear]       │ │
│  └──────────────────────────┘ │
│                                │
│  [👥 Estudiantes]              │
│  [🛣️  Rutas]                  │
│  [👨‍✈️ Conductores]            │
│  [📊 Reportes]                 │
└────────────────────────────────┘
```

## 🎨 Paleta de Colores

```
Primario:  #1976D2 (Azul)
Secundario: #4CAF50 (Verde)
Alerta:    #FF9800 (Naranja)
Error:     #F44336 (Rojo)
Fondo:     #FAFAFA (Gris claro)
Texto:     #212121 (Negro)
```

## 📲 Pantallas Detalladas

### 1. Pantalla de Login

**Características:**
- Diseño limpio y moderno
- Gradiente azul de fondo
- Logo del colegio
- Campos de email y contraseña
- Botón de inicio de sesión prominente
- Usuarios de prueba visibles (para desarrollo)

**Elementos UI:**
```
┌────────────────────────────┐
│                            │
│         🎓                 │
│    [Logo Escolar]          │
│                            │
│  Transporte Escolar        │
│  Seguimiento en Tiempo Real│
│                            │
│  ┌──────────────────────┐ │
│  │ 📧 Email             │ │
│  └──────────────────────┘ │
│                            │
│  ┌──────────────────────┐ │
│  │ 🔒 Contraseña        │ │
│  └──────────────────────┘ │
│                            │
│  ┌──────────────────────┐ │
│  │  INICIAR SESIÓN      │ │
│  └──────────────────────┘ │
│                            │
│  Usuarios de Prueba:       │
│  👨‍✈️ conductor@ejemplo.com │
│  👨‍👩‍👧 padre@ejemplo.com    │
│  👨‍💼 admin@ejemplo.com     │
└────────────────────────────┘
```

### 2. Conductor - Mapa en Tiempo Real

**Características:**
- Mapa de OpenStreetMap
- Marcador animado del bus (azul)
- Marcadores de estudiantes:
  - Rojo 📍: Esperando
  - Verde ✅: Ya recogido
  - Gris 🏁: Ya dejado en casa
- Panel inferior con lista de estudiantes
- Botones de acción rápida

**Leyenda del Mapa:**
```
Símbolos:
🚌  = Bus (ubicación actual)
📍  = Estudiante pendiente
✅  = Estudiante abordado
🏠  = Destino del estudiante
⬆️  = Acción: Subir al bus
⬇️  = Acción: Bajar del bus
```

### 3. Padre - Seguimiento del Hijo

**Características:**
- Vista de mapa centrada en el bus
- Línea punteada mostrando ruta aproximada
- Información de ETA (tiempo estimado)
- Tarjetas de notificaciones recientes
- Botón de "Yo lo recojo" prominente
- Historial de viajes accesible

**Estados posibles:**
```
Estados del estudiante:
🏠 En casa      = Aún no ha salido
🚌 En el bus    = Subió al bus
🛣️  En camino   = Bus se acerca
✅ Llegó        = Ya bajó del bus
```

### 4. Admin - Gestión de Estudiantes

**Características:**
- Lista completa de estudiantes
- Búsqueda y filtros
- Tarjetas con foto (o inicial)
- Información resumida
- Acciones rápidas (editar, desactivar)
- Botón FAB para agregar nuevo

**Layout:**
```
┌─────────────────────────────┐
│ [🔍 Buscar estudiantes...]  │
├─────────────────────────────┤
│                             │
│ ┌─────────────────────────┐ │
│ │ 👧 S  Sofía García      │ │
│ │       3° Primaria        │ │
│ │       Padre: María G.    │ │
│ │       [✏️ Editar] [👁️]   │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ 👦 M  Miguel Rodríguez  │ │
│ │       5° Primaria        │ │
│ │       Padre: Ana R.      │ │
│ │       [✏️ Editar] [👁️]   │ │
│ └─────────────────────────┘ │
│                             │
│            [➕]             │
└─────────────────────────────┘
```

## 🔔 Sistema de Notificaciones

### Tipos de Notificaciones

#### 1. Abordaje
```
┌──────────────────────────┐
│ 🚌 Estudiante Abordado   │
├──────────────────────────┤
│ Sofía García subió al    │
│ bus a las 6:45 AM        │
│                          │
│ 📍 Cra 40 #25-30         │
└──────────────────────────┘
```

#### 2. Mitad de Camino
```
┌──────────────────────────┐
│ 🔔 Mitad de Camino       │
├──────────────────────────┤
│ El bus va a mitad de     │
│ camino. Llegada estimada:│
│ 7:15 AM                  │
│                          │
│ [Ver en mapa]            │
└──────────────────────────┘
```

#### 3. Cerca de Casa
```
┌──────────────────────────┐
│ 🏠 Cerca de Casa         │
├──────────────────────────┤
│ El bus está a 500m de    │
│ tu casa. Sofía llegará   │
│ en 3 minutos.            │
│                          │
│ [Prepararse] [Ver mapa]  │
└──────────────────────────┘
```

#### 4. Llegada
```
┌──────────────────────────┐
│ ✅ Estudiante en Casa    │
├──────────────────────────┤
│ Sofía García llegó a     │
│ casa a las 7:12 AM       │
│                          │
│ 🚌 Viaje completado      │
└──────────────────────────┘
```

## 📊 Dashboard Administrativo

### Widgets de Información

#### 1. Estadísticas Rápidas
```
┌──────────────────────────────┐
│  Hoy: Miércoles, 29 Oct 2025 │
├────────┬────────┬─────────────┤
│   12   │   8    │    95%      │
│ Viajes │ Rutas  │ Puntualidad │
└────────┴────────┴─────────────┘
```

#### 2. Viajes Activos
```
┌─────────────────────────────┐
│ 🚌 Viajes en Curso (3)      │
├─────────────────────────────┤
│ • Ruta Mañana Norte         │
│   Juan Pérez | 5/5          │
│   [Monitorear]              │
├─────────────────────────────┤
│ • Ruta Tarde Centro         │
│   Ana López | 3/4           │
│   [Monitorear]              │
└─────────────────────────────┘
```

#### 3. Alertas
```
┌─────────────────────────────┐
│ ⚠️  Alertas Recientes       │
├─────────────────────────────┤
│ • Retiro manual: Sofía G.   │
│   Padre la recogió - 12:00  │
├─────────────────────────────┤
│ • Bus detenido más de 15min │
│   Ruta Tarde - Verificar    │
└─────────────────────────────┘
```

## 🎬 Animaciones y Transiciones

### Transiciones entre Pantallas
- **Fade**: Login → Dashboard
- **Slide**: Entre secciones del dashboard
- **Scale**: Al seleccionar estudiante
- **Flip**: Al cambiar entre mapa y lista

### Animaciones en Mapa
- **Pulse**: Marcador del bus (cada 2 segundos)
- **Bounce**: Al agregar nuevo marcador
- **Trail**: Línea de ruta dibujándose
- **Smooth Pan**: Al seguir el bus

### Feedback Visual
- **Ripple**: Al tocar botones
- **Shake**: En errores de formulario
- **Check Animation**: Al completar acción
- **Loading Spinner**: Durante operaciones

## 📐 Dimensiones y Espaciado

### Estándares de Diseño
```
Padding:
- Pequeño:  8px
- Medio:    16px
- Grande:   24px
- XGrande:  32px

Bordes:
- Cards:    12px
- Botones:  8px
- Inputs:   8px

Sombras:
- Leve:     elevation 2
- Media:    elevation 4
- Fuerte:   elevation 8
```

### Tamaños de Fuente
```
- Título:      32px, Bold
- Subtítulo:   24px, Bold
- Header:      18px, Bold
- Normal:      16px, Regular
- Pequeño:     14px, Regular
- Caption:     12px, Regular
```

## 🖼️ Iconografía

### Iconos Principales
```
🚌 directions_bus      - Bus
👥 group               - Estudiantes
🛣️  route              - Rutas
📍 location_on         - Ubicación
🔔 notifications       - Notificaciones
✅ check_circle        - Completado
⚠️  warning            - Alerta
📊 analytics           - Estadísticas
⚙️  settings           - Configuración
🏠 home                - Casa
📱 phone               - Teléfono
✏️  edit               - Editar
👁️  visibility         - Ver
🗑️  delete             - Eliminar
```

## 🎯 Casos de Uso Visualizados

### Caso 1: Padre Reporta Retiro Manual

```
1. Padre abre app
   ↓
2. Selecciona hijo
   ↓
3. Presiona "Yo lo recojo"
   ↓
4. Confirma en diálogo
   ↓
5. Sistema notifica al conductor
   ↓
6. Conductor ve alerta en su pantalla
```

### Caso 2: Conductor Inicia Viaje

```
1. Conductor inicia sesión
   ↓
2. Selecciona ruta del día
   ↓
3. Revisa lista de estudiantes
   ↓
4. Presiona "Iniciar Viaje"
   ↓
5. GPS se activa automáticamente
   ↓
6. Padres reciben notificación
   ↓
7. Mapa se muestra en tiempo real
```

### Caso 3: Notificación Automática

```
Bus se mueve
   ↓
Sistema detecta ubicación
   ↓
¿Estudiante abordado?
   │
   ├─ Sí → ¿A mitad de camino?
   │       │
   │       ├─ Sí → Enviar notificación
   │       └─ No → Continuar
   │
   └─ No → Esperar abordaje
```

## 💡 Tips de UX

### Para Conductores
- Botones grandes para fácil uso mientras conduce
- Confirmaciones claras antes de acciones importantes
- Feedback visual inmediato
- Vista de mapa siempre visible

### Para Padres
- Información más importante arriba
- Mapa interactivo pero simple
- Notificaciones claras y concisas
- Acción de "Yo lo recojo" prominente

### Para Administradores
- Dashboard con métricas clave
- Acceso rápido a todas las secciones
- Búsqueda y filtros eficientes
- Visualización de datos clara

## 🎨 Temas y Personalización

### Tema Claro (Default)
- Fondo: Blanco/Gris muy claro
- Texto: Negro/Gris oscuro
- Acentos: Azul y Verde

### Tema Oscuro (Opcional - Futura implementación)
- Fondo: Gris oscuro/Negro
- Texto: Blanco/Gris claro
- Acentos: Azul claro y Verde claro

---

**Esta guía visual ayuda a entender cómo funciona cada pantalla y cómo interactúan los usuarios con el sistema.**
