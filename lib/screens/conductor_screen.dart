import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class ConductorScreen extends StatefulWidget {
  final String idConductor;
  final String nombreConductor;

  const ConductorScreen({
    Key? key,
    required this.idConductor,
    required this.nombreConductor,
  }) : super(key: key);

  @override
  State<ConductorScreen> createState() => _ConductorScreenState();
}

class _ConductorScreenState extends State<ConductorScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final MapController _mapController = MapController();

  List<Ruta> _rutas = [];
  Ruta? _rutaSeleccionada;
  List<Estudiante> _estudiantesRuta = [];
  
  bool _viajeIniciado = false;
  String? _viajeActivoId;
  Set<String> _estudiantesAbordados = {};
  
  Position? _posicionActual;
  StreamSubscription<Position>? _positionStream;
  bool _mitadCaminoNotificada = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _notificationService.initialize();
    await _cargarRutas();
    await _verificarPermisos();
  }

  Future<void> _verificarPermisos() async {
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    
    if (permiso == LocationPermission.deniedForever) {
      _mostrarError('Los permisos de ubicación están deshabilitados permanentemente');
    }
  }

  Future<void> _cargarRutas() async {
    try {
      setState(() => _isLoading = true);
      List<Ruta> rutas = await _firebaseService.obtenerRutasPorConductor(widget.idConductor);
      setState(() {
        _rutas = rutas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar rutas: $e');
    }
  }

  Future<void> _seleccionarRuta(Ruta ruta) async {
    try {
      setState(() => _isLoading = true);
      
      List<Estudiante> estudiantes = [];
      for (String idEstudiante in ruta.idsEstudiantes) {
        Estudiante? estudiante = await _firebaseService.obtenerEstudiante(idEstudiante);
        if (estudiante != null) {
          estudiantes.add(estudiante);
        }
      }

      setState(() {
        _rutaSeleccionada = ruta;
        _estudiantesRuta = estudiantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar estudiantes: $e');
    }
  }

  Future<void> _iniciarViaje() async {
    if (_rutaSeleccionada == null) return;

    try {
      setState(() => _isLoading = true);

      // Obtener ubicación actual
      Position posicion = await Geolocator.getCurrentPosition();
      
      // Crear viaje
      Viaje viaje = Viaje(
        id: '',
        idRuta: _rutaSeleccionada!.id,
        nombreRuta: _rutaSeleccionada!.nombre,
        idConductor: widget.idConductor,
        nombreConductor: widget.nombreConductor,
        fechaInicio: DateTime.now(),
        estado: EstadoViaje.enCurso,
        estudiantesEsperados: _rutaSeleccionada!.idsEstudiantes,
        estudiantesAbordados: [],
        ubicacionActual: LatLng(posicion.latitude, posicion.longitude),
      );

      String viajeId = await _firebaseService.iniciarViaje(viaje);

      // Iniciar tracking GPS
      _iniciarTrackingGPS(viajeId);

      setState(() {
        _viajeIniciado = true;
        _viajeActivoId = viajeId;
        _posicionActual = posicion;
        _isLoading = false;
      });

      _notificationService.mostrarNotificacion(
        'Viaje Iniciado',
        'Ruta ${_rutaSeleccionada!.nombre} en curso',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error al iniciar viaje: $e');
    }
  }

  void _iniciarTrackingGPS(String viajeId) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      setState(() => _posicionActual = position);

      // Actualizar ubicación en Firebase
      try {
        await _firebaseService.actualizarUbicacionViaje(
          viajeId,
          LatLng(position.latitude, position.longitude),
        );

        // Verificar mitad de camino (esto es una simplificación)
        if (!_mitadCaminoNotificada && _estudiantesAbordados.length > _estudiantesRuta.length / 2) {
          await _enviarNotificacionMitadCamino();
        }

        // Centrar mapa en ubicación actual
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15,
        );
      } catch (e) {
        print('Error al actualizar ubicación: $e');
      }
    });
  }

  Future<void> _registrarAbordaje(Estudiante estudiante) async {
    if (_viajeActivoId == null) return;

    try {
      await _firebaseService.registrarAbordaje(_viajeActivoId!, estudiante.id);

      EventoViaje evento = EventoViaje(
        idEstudiante: estudiante.id,
        tipo: TipoEvento.abordaje,
        timestamp: DateTime.now(),
        ubicacion: LatLng(
          _posicionActual?.latitude ?? 0,
          _posicionActual?.longitude ?? 0,
        ),
      );

      await _firebaseService.registrarEvento(_viajeActivoId!, evento);

      setState(() => _estudiantesAbordados.add(estudiante.id));

      _notificationService.mostrarNotificacion(
        'Estudiante Abordado',
        '${estudiante.nombre} ha subido al bus',
      );
    } catch (e) {
      _mostrarError('Error al registrar abordaje: $e');
    }
  }

  Future<void> _registrarBajada(Estudiante estudiante) async {
    if (_viajeActivoId == null) return;

    try {
      await _firebaseService.registrarBajada(_viajeActivoId!, estudiante.id);

      EventoViaje evento = EventoViaje(
        idEstudiante: estudiante.id,
        tipo: TipoEvento.bajada,
        timestamp: DateTime.now(),
        ubicacion: LatLng(
          _posicionActual?.latitude ?? 0,
          _posicionActual?.longitude ?? 0,
        ),
      );

      await _firebaseService.registrarEvento(_viajeActivoId!, evento);

      setState(() => _estudiantesAbordados.remove(estudiante.id));

      _notificationService.mostrarNotificacion(
        'Estudiante Desabordado',
        '${estudiante.nombre} ha llegado a su destino',
      );
    } catch (e) {
      _mostrarError('Error al registrar bajada: $e');
    }
  }

  Future<void> _enviarNotificacionMitadCamino() async {
    if (_viajeActivoId == null || _mitadCaminoNotificada) return;

    try {
      for (Estudiante estudiante in _estudiantesRuta) {
        if (_estudiantesAbordados.contains(estudiante.id)) {
          EventoViaje evento = EventoViaje(
            idEstudiante: estudiante.id,
            tipo: TipoEvento.mitadCamino,
            timestamp: DateTime.now(),
            ubicacion: LatLng(
              _posicionActual?.latitude ?? 0,
              _posicionActual?.longitude ?? 0,
            ),
          );

          await _firebaseService.registrarEvento(_viajeActivoId!, evento);
        }
      }

      setState(() => _mitadCaminoNotificada = true);

      _notificationService.mostrarNotificacion(
        'Mitad de Camino',
        'El bus va a mitad de camino',
      );
    } catch (e) {
      _mostrarError('Error al enviar notificación: $e');
    }
  }

  Future<void> _finalizarViaje() async {
    if (_viajeActivoId == null) return;

    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Viaje'),
        content: const Text('¿Está seguro de que desea finalizar el viaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _firebaseService.finalizarViaje(_viajeActivoId!);
      _positionStream?.cancel();

      setState(() {
        _viajeIniciado = false;
        _viajeActivoId = null;
        _estudiantesAbordados.clear();
        _mitadCaminoNotificada = false;
      });

      _notificationService.mostrarNotificacion(
        'Viaje Finalizado',
        'El viaje ha terminado correctamente',
      );
    } catch (e) {
      _mostrarError('Error al finalizar viaje: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conductor: ${widget.nombreConductor}'),
        backgroundColor: Colors.blue[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_viajeIniciado) _buildSeleccionRuta(),
                if (_viajeIniciado) _buildMapaYEstudiantes(),
              ],
            ),
    );
  }

  Widget _buildSeleccionRuta() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Seleccione una ruta para iniciar el viaje',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rutas.length,
              itemBuilder: (context, index) {
                Ruta ruta = _rutas[index];
                bool seleccionada = _rutaSeleccionada?.id == ruta.id;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: seleccionada ? 8 : 2,
                  color: seleccionada ? Colors.blue[50] : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[700],
                      child: const Icon(Icons.route, color: Colors.white),
                    ),
                    title: Text(
                      ruta.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${ruta.idsEstudiantes.length} estudiantes | ${ruta.horaInicio} - ${ruta.horaFin}',
                    ),
                    trailing: seleccionada
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () => _seleccionarRuta(ruta),
                  ),
                );
              },
            ),
          ),
          if (_rutaSeleccionada != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _iniciarViaje,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Iniciar Viaje',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapaYEstudiantes() {
    return Expanded(
      child: Column(
        children: [
          // Mapa
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _posicionActual != null
                    ? LatLng(_posicionActual!.latitude, _posicionActual!.longitude)
                    : const LatLng(4.1420, -73.6266),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.transporte_escolar',
                ),
                MarkerLayer(
                  markers: [
                    // Marcador del bus
                    if (_posicionActual != null)
                      Marker(
                        point: LatLng(_posicionActual!.latitude, _posicionActual!.longitude),
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    // Marcadores de estudiantes
                    ..._estudiantesRuta.map((estudiante) {
                      bool abordado = _estudiantesAbordados.contains(estudiante.id);
                      return Marker(
                        point: estudiante.ubicacionCasa,
                        width: 40,
                        height: 40,
                        child: Icon(
                          abordado ? Icons.check_circle : Icons.home,
                          color: abordado ? Colors.green : Colors.red,
                          size: 30,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Lista de estudiantes
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[700],
                  child: Text(
                    'Estudiantes (${_estudiantesAbordados.length}/${_estudiantesRuta.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _estudiantesRuta.length,
                    itemBuilder: (context, index) {
                      Estudiante estudiante = _estudiantesRuta[index];
                      bool abordado = _estudiantesAbordados.contains(estudiante.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: abordado ? Colors.green : Colors.grey,
                          child: Icon(
                            abordado ? Icons.check : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(estudiante.nombre),
                        subtitle: Text('${estudiante.grado} | ${estudiante.direccion}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!abordado)
                              IconButton(
                                icon: const Icon(Icons.arrow_upward, color: Colors.green),
                                onPressed: () => _registrarAbordaje(estudiante),
                                tooltip: 'Subió al bus',
                              ),
                            if (abordado)
                              IconButton(
                                icon: const Icon(Icons.arrow_downward, color: Colors.red),
                                onPressed: () => _registrarBajada(estudiante),
                                tooltip: 'Bajó del bus',
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (!_mitadCaminoNotificada)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _enviarNotificacionMitadCamino,
                            icon: const Icon(Icons.notifications),
                            label: const Text('Mitad de Camino'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ),
                      if (!_mitadCaminoNotificada) const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _finalizarViaje,
                          icon: const Icon(Icons.stop),
                          label: const Text('Finalizar Viaje'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
