import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';

class PadreScreen extends StatefulWidget {
  final String userId;

  const PadreScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<PadreScreen> createState() => _PadreScreenState();
}

class _PadreScreenState extends State<PadreScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final MapController _mapController = MapController();

  List<Estudiante> _misHijos = [];
  String? _rutaActivaId;
  LatLng? _ubicacionBus;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _escucharUbicacionBus();
  }

  Future<void> _cargarDatos() async {
    try {
      // Cargar información de los hijos
      QuerySnapshot estudiantesSnap = await FirebaseFirestore.instance
          .collection('estudiantes')
          .where('idPadre', isEqualTo: widget.userId)
          .get();

      List<Estudiante> hijos = estudiantesSnap.docs
          .map((doc) => Estudiante.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      setState(() {
        _misHijos = hijos;
        _cargando = false;
      });

      // Buscar si hay viaje activo para alguno de los hijos
      if (_misHijos.isNotEmpty) {
        String rutaId = _misHijos.first.idRuta;
        QuerySnapshot viajeSnap = await FirebaseFirestore.instance
            .collection('viajes')
            .where('idRuta', isEqualTo: rutaId)
            .where('estado', isEqualTo: 'activo')
            .limit(1)
            .get();

        if (viajeSnap.docs.isNotEmpty) {
          setState(() {
            _rutaActivaId = viajeSnap.docs.first.id;
          });
        }
      }
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _cargando = false);
    }
  }

  void _escucharUbicacionBus() {
    if (_rutaActivaId != null) {
      FirebaseFirestore.instance
          .collection('viajes')
          .doc(_rutaActivaId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          if (data['ubicacionActual'] != null) {
            setState(() {
              _ubicacionBus = LatLng(
                data['ubicacionActual']['latitude'],
                data['ubicacionActual']['longitude'],
              );
            });
          }
        }
      });
    }
  }

  Future<void> _notificarRecogerEstudiante(String estudianteId) async {
    try {
      bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Recoger Estudiante'),
          content: const Text(
              '¿Confirma que va a recoger a su hijo/a y NO usará el transporte escolar hoy?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Confirmar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      // Crear notificación para el conductor
      await FirebaseFirestore.instance
          .collection('notificaciones_conductor')
          .add({
        'idEstudiante': estudianteId,
        'tipo': 'padre_recoge',
        'mensaje': 'El padre recogió al estudiante - NO viaja en bus hoy',
        'timestamp': FieldValue.serverTimestamp(),
        'leido': false,
      });

      // Actualizar estado del estudiante para hoy
      await FirebaseFirestore.instance
          .collection('estudiantes')
          .doc(estudianteId)
          .update({
        'estadoHoy': 'recogido_por_padre',
        'timestampRecogida': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación enviada al conductor'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Padre de Familia'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Ir a pantalla de notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _firebaseService.cerrarSesion();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de los hijos
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Hijos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._misHijos
                    .map((hijo) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(hijo.nombre[0].toUpperCase()),
                            ),
                            title: Text(hijo.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Grado: ${hijo.grado}'),
                                Text('Ruta: ${hijo.idRuta}'),
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () =>
                                  _notificarRecogerEstudiante(hijo.id),
                              icon:
                                  const Icon(Icons.person_pin_circle, size: 18),
                              label: const Text('Yo Recojo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),

          // Mapa con ubicación en tiempo real
          Expanded(
            child: _rutaActivaId != null
                ? Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _ubicacionBus ?? const LatLng(4.142, -73.626),
                          initialZoom: 14.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.transporte_escolar',
                          ),
                          if (_ubicacionBus != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _ubicacionBus!,
                                  width: 60,
                                  height: 60,
                                  child: const Icon(
                                    Icons.directions_bus,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.bus_alert, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      'Bus en Ruta',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_ubicacionBus != null)
                                  Text(
                                    'Ubicación: ${_ubicacionBus!.latitude.toStringAsFixed(4)}, ${_ubicacionBus!.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay viajes activos en este momento',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),

          // Eventos recientes
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Eventos Recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _rutaActivaId != null
                        ? FirebaseFirestore.instance
                            .collection('viajes')
                            .doc(_rutaActivaId)
                            .collection('eventos')
                            .where('idEstudiante',
                                whereIn: _misHijos.map((h) => h.id).toList())
                            .orderBy('timestamp', descending: true)
                            .limit(3)
                            .snapshots()
                        : null,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No hay eventos recientes'),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var evento = EventoViaje.fromFirestore(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>,
                            snapshot.data!.docs[index].id,
                          );

                          IconData icono;
                          Color color;
                          String texto;

                          switch (evento.tipo) {
                            case TipoEvento.abordaje:
                              icono = Icons.login;
                              color = Colors.green;
                              texto = 'Subió al bus';
                              break;
                            case TipoEvento.bajada:
                              icono = Icons.logout;
                              color = Colors.red;
                              texto = 'Bajó del bus';
                              break;
                            case TipoEvento.mitadCamino:
                              icono = Icons.location_on;
                              color = Colors.blue;
                              texto = 'A mitad de camino';
                              break;
                            case TipoEvento.llegada:
                              icono = Icons.home;
                              color = Colors.orange;
                              texto = 'Llegó a casa';
                              break;
                          }

                          return ListTile(
                            dense: true,
                            leading: Icon(icono, color: color),
                            title: Text(texto),
                            subtitle: Text(
                              '${evento.timestamp.hour}:${evento.timestamp.minute.toString().padLeft(2, '0')}',
                            ),
                          );
                        },
                      );
                    },
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
