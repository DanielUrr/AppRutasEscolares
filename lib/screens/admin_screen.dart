import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';

class AdminScreen extends StatefulWidget {
  final String userId;

  const AdminScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.route), text: 'Rutas'),
            Tab(icon: Icon(Icons.school), text: 'Estudiantes'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Conductores'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _firebaseService.cerrarSesion();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResumenTab(),
          _buildRutasTab(),
          _buildEstudiantesTab(),
          _buildConductoresTab(),
          _buildHistorialTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarMenuCrear(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResumenTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rutas').snapshots(),
      builder: (context, rutasSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('estudiantes').snapshots(),
          builder: (context, estudiantesSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('viajes')
                  .where('estado', isEqualTo: 'activo')
                  .snapshots(),
              builder: (context, viajesSnap) {
                int totalRutas = rutasSnap.data?.docs.length ?? 0;
                int totalEstudiantes = estudiantesSnap.data?.docs.length ?? 0;
                int viajesActivos = viajesSnap.data?.docs.length ?? 0;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del Sistema',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Rutas',
                              totalRutas.toString(),
                              Icons.route,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Estudiantes',
                              totalEstudiantes.toString(),
                              Icons.school,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Viajes Activos',
                              viajesActivos.toString(),
                              Icons.directions_bus,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Padres',
                              '-',
                              Icons.people,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Actividad Reciente',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collectionGroup('eventos')
                              .orderBy('timestamp', descending: true)
                              .limit(20)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
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
                                    texto = 'Estudiante abordó el bus';
                                    break;
                                  case TipoEvento.bajada:
                                    icono = Icons.logout;
                                    color = Colors.red;
                                    texto = 'Estudiante bajó del bus';
                                    break;
                                  case TipoEvento.mitadCamino:
                                    icono = Icons.location_on;
                                    color = Colors.blue;
                                    texto = 'A mitad de camino';
                                    break;
                                  case TipoEvento.llegada:
                                    icono = Icons.home;
                                    color = Colors.orange;
                                    texto = 'Estudiante llegó a casa';
                                    break;
                                }

                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: color,
                                      child: Icon(icono, color: Colors.white),
                                    ),
                                    title: Text(texto),
                                    subtitle: Text(
                                      '${evento.timestamp.day}/${evento.timestamp.month}/${evento.timestamp.year} - ${evento.timestamp.hour}:${evento.timestamp.minute.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRutasTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rutas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Ruta> rutas = snapshot.data!.docs
            .map((doc) =>
                Ruta.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rutas.length,
          itemBuilder: (context, index) {
            Ruta ruta = rutas[index];
            return Card(
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(ruta.nombre[0].toUpperCase()),
                ),
                title: Text(ruta.nombre),
                subtitle: Text('${ruta.paradas.length} paradas'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paradas:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...ruta.paradas
                            .map((parada) => ListTile(
                                  dense: true,
                                  leading:
                                      const Icon(Icons.location_on, size: 20),
                                  title: Text(parada.direccion),
                                  subtitle: Text(
                                    '${parada.ubicacion.latitude.toStringAsFixed(4)}, ${parada.ubicacion.longitude.toStringAsFixed(4)}',
                                  ),
                                ))
                            .toList(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _editarRuta(ruta),
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                            ),
                            TextButton.icon(
                              onPressed: () => _eliminarRuta(ruta.id),
                              icon: const Icon(Icons.delete),
                              label: const Text('Eliminar'),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEstudiantesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('estudiantes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Estudiante> estudiantes = snapshot.data!.docs
            .map((doc) => Estudiante.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: estudiantes.length,
          itemBuilder: (context, index) {
            Estudiante estudiante = estudiantes[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(estudiante.nombre[0].toUpperCase()),
                ),
                title: Text(estudiante.nombre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grado: ${estudiante.grado}'),
                    Text('Ruta: ${estudiante.idRuta}'),
                    Text('Dirección: ${estudiante.direccion}'),
                  ],
                ),
                isThreeLine: true,
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editarEstudiante(estudiante);
                    } else if (value == 'delete') {
                      _eliminarEstudiante(estudiante.id);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConductoresTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('rol', isEqualTo: 'conductor')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(data['nombre'] ?? 'Conductor'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email'] ?? 'N/A'}'),
                    Text('Ruta asignada: ${data['idRuta'] ?? 'Sin asignar'}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistorialTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('viajes')
          .orderBy('fechaInicio', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            String estado = data['estado'] ?? 'desconocido';
            Color estadoColor = estado == 'activo' ? Colors.green : Colors.grey;
            DateTime? fechaInicio =
                (data['fechaInicio'] as Timestamp?)?.toDate();
            DateTime? fechaFin = (data['fechaFin'] as Timestamp?)?.toDate();

            return Card(
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: estadoColor,
                  child: Icon(
                    estado == 'activo' ? Icons.directions_bus : Icons.check,
                    color: Colors.white,
                  ),
                ),
                title: Text('Ruta: ${data['idRuta']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado: $estado'),
                    Text(
                      'Inicio: ${fechaInicio?.day}/${fechaInicio?.month}/${fechaInicio?.year} ${fechaInicio?.hour}:${fechaInicio?.minute}',
                    ),
                  ],
                ),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('viajes')
                        .doc(doc.id)
                        .collection('eventos')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, eventosSnap) {
                      if (!eventosSnap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Column(
                        children: eventosSnap.data!.docs.map((eventoDoc) {
                          var eventoData =
                              eventoDoc.data() as Map<String, dynamic>;
                          DateTime timestamp =
                              (eventoData['timestamp'] as Timestamp).toDate();

                          return ListTile(
                            dense: true,
                            leading: Icon(
                              _getIconoEvento(eventoData['tipo']),
                              color: _getColorEvento(eventoData['tipo']),
                            ),
                            title: Text(_getTextoEvento(eventoData['tipo'])),
                            subtitle: Text(
                              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconoEvento(String tipo) {
    switch (tipo) {
      case 'abordaje':
        return Icons.login;
      case 'bajada':
        return Icons.logout;
      case 'mitad_camino':
      case 'mitadCamino':
        return Icons.location_on;
      case 'llegada':
        return Icons.home;
      default:
        return Icons.info;
    }
  }

  Color _getColorEvento(String tipo) {
    switch (tipo) {
      case 'abordaje':
        return Colors.green;
      case 'bajada':
        return Colors.red;
      case 'mitad_camino':
      case 'mitadCamino':
        return Colors.blue;
      case 'llegada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTextoEvento(String tipo) {
    switch (tipo) {
      case 'abordaje':
        return 'Abordaje';
      case 'bajada':
        return 'Bajada';
      case 'mitad_camino':
      case 'mitadCamino':
        return 'Mitad de camino';
      case 'llegada':
        return 'Llegada';
      default:
        return 'Evento';
    }
  }

  void _mostrarMenuCrear() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Crear Ruta'),
              onTap: () {
                Navigator.pop(context);
                _crearRuta();
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Registrar Estudiante'),
              onTap: () {
                Navigator.pop(context);
                _crearEstudiante();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Registrar Conductor'),
              onTap: () {
                Navigator.pop(context);
                _crearConductor();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _crearRuta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de crear ruta - Por implementar')),
    );
  }

  void _editarRuta(Ruta ruta) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de editar ruta - Por implementar')),
    );
  }

  void _eliminarRuta(String rutaId) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ruta'),
        content: const Text('¿Está seguro de eliminar esta ruta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection('rutas').doc(rutaId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta eliminada')),
      );
    }
  }

  void _crearEstudiante() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Función de crear estudiante - Por implementar')),
    );
  }

  void _editarEstudiante(Estudiante estudiante) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Función de editar estudiante - Por implementar')),
    );
  }

  void _eliminarEstudiante(String estudianteId) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Estudiante'),
        content: const Text('¿Está seguro de eliminar este estudiante?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance
          .collection('estudiantes')
          .doc(estudianteId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante eliminado')),
      );
    }
  }

  void _crearConductor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Función de crear conductor - Por implementar')),
    );
  }
}
