import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== AUTENTICACIÓN ====================

  Future<User?> iniciarSesion(String email, String password) async {
    try {
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return resultado.user;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  User? get usuarioActual => _auth.currentUser;

  Stream<User?> get estadoAuth => _auth.authStateChanges();

  // ==================== USUARIOS ====================

  Future<Usuario?> obtenerUsuario(String uid) async {
    try {
      print('🔍 Buscando usuario con UID: $uid'); // ✅ AGREGADO

      DocumentSnapshot doc =
          await _firestore.collection('usuarios').doc(uid).get();

      print('📄 Documento existe: ${doc.exists}'); // ✅ AGREGADO
      print('📄 Datos del documento: ${doc.data()}'); // ✅ AGREGADO

      if (doc.exists) {
        return Usuario.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ ERROR al obtener usuario: $e'); // ✅ AGREGADO
      throw Exception('Error al obtener usuario: $e');
    }
  }

  Future<void> crearUsuario(String uid, Usuario usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .set(usuario.toFirestore());
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  // ==================== ESTUDIANTES ====================

  Future<List<Estudiante>> obtenerEstudiantes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('estudiantes')
          .where('activo', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => Estudiante.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id)) // ✅
          .toList();
    } catch (e) {
      throw Exception('Error al obtener estudiantes: $e');
    }
  }

  Future<List<Estudiante>> obtenerEstudiantesPorPadre(String idPadre) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('estudiantes')
          .where('idPadre', isEqualTo: idPadre)
          .where('activo', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => Estudiante.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id)) // ✅
          .toList();
    } catch (e) {
      throw Exception('Error al obtener estudiantes del padre: $e');
    }
  }

  Future<Estudiante?> obtenerEstudiante(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('estudiantes').doc(id).get();
      if (doc.exists) {
        return Estudiante.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id); // ✅
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener estudiante: $e');
    }
  }

  Future<void> crearEstudiante(Estudiante estudiante) async {
    try {
      await _firestore.collection('estudiantes').add(estudiante.toFirestore());
    } catch (e) {
      throw Exception('Error al crear estudiante: $e');
    }
  }

  // ==================== RUTAS ====================

  Future<List<Ruta>> obtenerRutas() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('rutas')
          .where('activa', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => Ruta.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id)) // ✅
          .toList();
    } catch (e) {
      throw Exception('Error al obtener rutas: $e');
    }
  }

  Future<List<Ruta>> obtenerRutasPorConductor(String idConductor) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('rutas')
          .where('idConductor', isEqualTo: idConductor)
          .where('activa', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => Ruta.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id)) // ✅
          .toList();
    } catch (e) {
      throw Exception('Error al obtener rutas del conductor: $e');
    }
  }

  Future<Ruta?> obtenerRuta(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('rutas').doc(id).get();
      if (doc.exists) {
        return Ruta.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id); // ✅
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener ruta: $e');
    }
  }

  // ==================== VIAJES ====================

  Future<String> iniciarViaje(Viaje viaje) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('viajes').add(viaje.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al iniciar viaje: $e');
    }
  }

  Future<void> actualizarUbicacionViaje(
      String idViaje, LatLng ubicacion) async {
    try {
      await _firestore.collection('viajes').doc(idViaje).update({
        'ubicacionActual': {
          'latitude': ubicacion.latitude,
          'longitude': ubicacion.longitude,
        },
      });
    } catch (e) {
      throw Exception('Error al actualizar ubicación: $e');
    }
  }

  Future<void> registrarAbordaje(String idViaje, String idEstudiante) async {
    try {
      await _firestore.collection('viajes').doc(idViaje).update({
        'estudiantesAbordados': FieldValue.arrayUnion([idEstudiante]),
      });
    } catch (e) {
      throw Exception('Error al registrar abordaje: $e');
    }
  }

  Future<void> registrarBajada(String idViaje, String idEstudiante) async {
    try {
      await _firestore.collection('viajes').doc(idViaje).update({
        'estudiantesAbordados': FieldValue.arrayRemove([idEstudiante]),
      });
    } catch (e) {
      throw Exception('Error al registrar bajada: $e');
    }
  }

  Future<void> finalizarViaje(String idViaje) async {
    try {
      await _firestore.collection('viajes').doc(idViaje).update({
        'estado': 'finalizado',
        'fechaFin': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al finalizar viaje: $e');
    }
  }

  Stream<Viaje?> viajeEnCursoStream(String idConductor) {
    return _firestore
        .collection('viajes')
        .where('idConductor', isEqualTo: idConductor)
        .where('estado', isEqualTo: 'enCurso')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Viaje.fromFirestore(
          snapshot.docs.first.data(), snapshot.docs.first.id); // ✅
    });
  }

  Stream<Viaje?> viajeActivoPorEstudianteStream(String idEstudiante) {
    return _firestore
        .collection('viajes')
        .where('estudiantesEsperados', arrayContains: idEstudiante)
        .where('estado', whereIn: ['enEspera', 'enCurso'])
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return Viaje.fromFirestore(
              snapshot.docs.first.data(), snapshot.docs.first.id); // ✅
        });
  }

  // ==================== EVENTOS ====================

  Future<void> registrarEvento(String idViaje, EventoViaje evento) async {
    try {
      await _firestore
          .collection('viajes')
          .doc(idViaje)
          .collection('eventos')
          .add(evento.toFirestore());
    } catch (e) {
      throw Exception('Error al registrar evento: $e');
    }
  }

  Stream<List<EventoViaje>> eventosViajeStream(String idViaje) {
    return _firestore
        .collection('viajes')
        .doc(idViaje)
        .collection('eventos')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventoViaje.fromFirestore(doc.data(), doc.id)) // ✅
          .toList();
    });
  }

  Future<List<EventoViaje>> obtenerEventosEstudiante(
      String idViaje, String idEstudiante) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('viajes')
          .doc(idViaje)
          .collection('eventos')
          .where('idEstudiante', isEqualTo: idEstudiante)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => EventoViaje.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id)) // ✅
          .toList();
    } catch (e) {
      throw Exception('Error al obtener eventos del estudiante: $e');
    }
  }

  // ==================== RETIROS MANUALES ====================

  Future<void> registrarRetiroManual(RetiroManual retiro) async {
    try {
      await _firestore.collection('retiros_manuales').add(retiro.toFirestore());
    } catch (e) {
      throw Exception('Error al registrar retiro manual: $e');
    }
  }

  Future<List<RetiroManual>> obtenerRetirosDeHoy() async {
    try {
      DateTime hoy = DateTime.now();
      DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      DateTime finDia = inicioDia.add(const Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('retiros_manuales')
          .where('fechaRetiro',
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
          .where('fechaRetiro', isLessThan: Timestamp.fromDate(finDia))
          .get();

      return snapshot.docs
          .map((doc) => RetiroManual.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id)) // ✅
          .toList();
    } catch (e) {
      throw Exception('Error al obtener retiros del día: $e');
    }
  }

  Stream<List<RetiroManual>> retirosDeHoyStream() {
    DateTime hoy = DateTime.now();
    DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    DateTime finDia = inicioDia.add(const Duration(days: 1));

    return _firestore
        .collection('retiros_manuales')
        .where('fechaRetiro',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('fechaRetiro', isLessThan: Timestamp.fromDate(finDia))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RetiroManual.fromFirestore(doc.data(), doc.id)) // ✅
          .toList();
    });
  }
}
