import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== ENUMERACIONES ====================

enum TipoUsuario { conductor, padre, admin }

enum TipoEvento { abordaje, bajada, mitadCamino }

enum EstadoViaje { enEspera, enCurso, finalizado }

// ==================== MODELO DE USUARIO ====================

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final TipoUsuario tipo;
  final String? telefono;
  final DateTime fechaCreacion;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.tipo,
    this.telefono,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      tipo: TipoUsuario.values.firstWhere(
        (e) => e.toString() == 'TipoUsuario.${data['tipo']}',
        orElse: () => TipoUsuario.padre,
      ),
      telefono: data['telefono'],
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'email': email,
      'tipo': tipo.toString().split('.').last,
      'telefono': telefono,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}

// ==================== MODELO DE ESTUDIANTE ====================

class Estudiante {
  final String id;
  final String nombre;
  final String grado;
  final String idPadre;
  final String nombrePadre;
  final LatLng ubicacionCasa;
  final String direccion;
  final String? telefonoEmergencia;
  final bool activo;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.grado,
    required this.idPadre,
    required this.nombrePadre,
    required this.ubicacionCasa,
    required this.direccion,
    this.telefonoEmergencia,
    this.activo = true,
  });

  factory Estudiante.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Estudiante(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      grado: data['grado'] ?? '',
      idPadre: data['idPadre'] ?? '',
      nombrePadre: data['nombrePadre'] ?? '',
      ubicacionCasa: LatLng(
        data['ubicacionCasa']['latitude'] ?? 0.0,
        data['ubicacionCasa']['longitude'] ?? 0.0,
      ),
      direccion: data['direccion'] ?? '',
      telefonoEmergencia: data['telefonoEmergencia'],
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'grado': grado,
      'idPadre': idPadre,
      'nombrePadre': nombrePadre,
      'ubicacionCasa': {
        'latitude': ubicacionCasa.latitude,
        'longitude': ubicacionCasa.longitude,
      },
      'direccion': direccion,
      'telefonoEmergencia': telefonoEmergencia,
      'activo': activo,
    };
  }
}

// ==================== MODELO DE RUTA ====================

class Ruta {
  final String id;
  final String nombre;
  final String descripcion;
  final List<String> idsEstudiantes;
  final String idConductor;
  final String nombreConductor;
  final String horaInicio;
  final String horaFin;
  final bool activa;

  Ruta({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.idsEstudiantes,
    required this.idConductor,
    required this.nombreConductor,
    required this.horaInicio,
    required this.horaFin,
    this.activa = true,
  });

  factory Ruta.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Ruta(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      idsEstudiantes: List<String>.from(data['idsEstudiantes'] ?? []),
      idConductor: data['idConductor'] ?? '',
      nombreConductor: data['nombreConductor'] ?? '',
      horaInicio: data['horaInicio'] ?? '',
      horaFin: data['horaFin'] ?? '',
      activa: data['activa'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'idsEstudiantes': idsEstudiantes,
      'idConductor': idConductor,
      'nombreConductor': nombreConductor,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'activa': activa,
    };
  }
}

// ==================== MODELO DE VIAJE ====================

class Viaje {
  final String id;
  final String idRuta;
  final String nombreRuta;
  final String idConductor;
  final String nombreConductor;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final EstadoViaje estado;
  final List<String> estudiantesEsperados;
  final List<String> estudiantesAbordados;
  final LatLng? ubicacionActual;

  Viaje({
    required this.id,
    required this.idRuta,
    required this.nombreRuta,
    required this.idConductor,
    required this.nombreConductor,
    required this.fechaInicio,
    this.fechaFin,
    required this.estado,
    required this.estudiantesEsperados,
    required this.estudiantesAbordados,
    this.ubicacionActual,
  });

  factory Viaje.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Viaje(
      id: doc.id,
      idRuta: data['idRuta'] ?? '',
      nombreRuta: data['nombreRuta'] ?? '',
      idConductor: data['idConductor'] ?? '',
      nombreConductor: data['nombreConductor'] ?? '',
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp?)?.toDate(),
      estado: EstadoViaje.values.firstWhere(
        (e) => e.toString() == 'EstadoViaje.${data['estado']}',
        orElse: () => EstadoViaje.enEspera,
      ),
      estudiantesEsperados:
          List<String>.from(data['estudiantesEsperados'] ?? []),
      estudiantesAbordados:
          List<String>.from(data['estudiantesAbordados'] ?? []),
      ubicacionActual: data['ubicacionActual'] != null
          ? LatLng(
              data['ubicacionActual']['latitude'],
              data['ubicacionActual']['longitude'],
            )
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'idRuta': idRuta,
      'nombreRuta': nombreRuta,
      'idConductor': idConductor,
      'nombreConductor': nombreConductor,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'estado': estado.toString().split('.').last,
      'estudiantesEsperados': estudiantesEsperados,
      'estudiantesAbordados': estudiantesAbordados,
      'ubicacionActual': ubicacionActual != null
          ? {
              'latitude': ubicacionActual!.latitude,
              'longitude': ubicacionActual!.longitude,
            }
          : null,
    };
  }
}

// ==================== MODELO DE EVENTO ====================

class EventoViaje {
  final String? id;
  final String idEstudiante;
  final TipoEvento tipo;
  final DateTime timestamp;
  final LatLng ubicacion;
  final String? notas;

  EventoViaje({
    this.id,
    required this.idEstudiante,
    required this.tipo,
    required this.timestamp,
    required this.ubicacion,
    this.notas,
  });

  factory EventoViaje.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventoViaje(
      id: doc.id,
      idEstudiante: data['idEstudiante'] ?? '',
      tipo: TipoEvento.values.firstWhere(
        (e) => e.toString() == 'TipoEvento.${data['tipo']}',
        orElse: () => TipoEvento.abordaje,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      ubicacion: LatLng(
        data['ubicacion']['latitude'],
        data['ubicacion']['longitude'],
      ),
      notas: data['notas'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'idEstudiante': idEstudiante,
      'tipo': tipo.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'ubicacion': {
        'latitude': ubicacion.latitude,
        'longitude': ubicacion.longitude,
      },
      'notas': notas,
    };
  }
}

// ==================== MODELO DE RETIRO MANUAL ====================

class RetiroManual {
  final String id;
  final String idEstudiante;
  final String nombreEstudiante;
  final String idPadre;
  final String nombrePadre;
  final DateTime fechaRetiro;
  final String motivo;
  final String? idViaje;

  RetiroManual({
    required this.id,
    required this.idEstudiante,
    required this.nombreEstudiante,
    required this.idPadre,
    required this.nombrePadre,
    required this.fechaRetiro,
    required this.motivo,
    this.idViaje,
  });

  factory RetiroManual.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RetiroManual(
      id: doc.id,
      idEstudiante: data['idEstudiante'] ?? '',
      nombreEstudiante: data['nombreEstudiante'] ?? '',
      idPadre: data['idPadre'] ?? '',
      nombrePadre: data['nombrePadre'] ?? '',
      fechaRetiro: (data['fechaRetiro'] as Timestamp).toDate(),
      motivo: data['motivo'] ?? '',
      idViaje: data['idViaje'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'idEstudiante': idEstudiante,
      'nombreEstudiante': nombreEstudiante,
      'idPadre': idPadre,
      'nombrePadre': nombrePadre,
      'fechaRetiro': Timestamp.fromDate(fechaRetiro),
      'motivo': motivo,
      'idViaje': idViaje,
    };
  }
}
