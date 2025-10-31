import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Solicitar permisos
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificación otorgados');
    } else {
      print('Permisos de notificación denegados');
      return;
    }

    // Configurar notificaciones locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificación para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'transporte_escolar_channel',
      'Notificaciones de Transporte Escolar',
      description: 'Canal para notificaciones del sistema de transporte escolar',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Obtener token FCM
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Configurar listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Manejar notificación que abrió la app (cuando estaba cerrada)
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    _initialized = true;
  }

  /// Manejar mensajes en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensaje recibido en primer plano: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'transporte_escolar_channel',
            'Notificaciones de Transporte Escolar',
            channelDescription:
                'Canal para notificaciones del sistema de transporte escolar',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['payload'],
      );
    }
  }

  /// Manejar cuando se toca una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notificación tocada: ${message.messageId}');
    // Aquí puedes navegar a una pantalla específica basada en el mensaje
  }

  /// Callback cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    print('Notificación local tocada: ${response.payload}');
    // Aquí puedes navegar a una pantalla específica
  }

  /// Suscribirse a un tema
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Suscrito al tema: $topic');
  }

  /// Desuscribirse de un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Desuscrito del tema: $topic');
  }

  /// Guardar token FCM del usuario
  Future<void> saveUserToken(String userId) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  /// Enviar notificación cuando un estudiante aborda el bus
  Future<void> notificarAbordaje(String estudianteId, String nombreEstudiante) async {
    // Obtener información del padre
    DocumentSnapshot estudianteDoc = await FirebaseFirestore.instance
        .collection('estudiantes')
        .doc(estudianteId)
        .get();

    if (!estudianteDoc.exists) return;

    String idPadre = (estudianteDoc.data() as Map<String, dynamic>)['idPadre'];

    // Obtener token del padre
    DocumentSnapshot padreDoc =
        await FirebaseFirestore.instance.collection('usuarios').doc(idPadre).get();

    if (!padreDoc.exists) return;

    Map<String, dynamic> padreData = padreDoc.data() as Map<String, dynamic>;
    String? fcmToken = padreData['fcmToken'];

    if (fcmToken == null) return;

    // Crear notificación en Firestore (Cloud Function la enviará)
    await FirebaseFirestore.instance.collection('notificaciones_pendientes').add({
      'token': fcmToken,
      'titulo': '🚌 Estudiante Abordó el Bus',
      'mensaje': '$nombreEstudiante ha subido al bus escolar',
      'tipo': 'abordaje',
      'estudianteId': estudianteId,
      'timestamp': FieldValue.serverTimestamp(),
      'enviada': false,
    });
  }

  /// Enviar notificación de mitad de camino
  Future<void> notificarMitadCamino(
      String estudianteId, String nombreEstudiante) async {
    DocumentSnapshot estudianteDoc = await FirebaseFirestore.instance
        .collection('estudiantes')
        .doc(estudianteId)
        .get();

    if (!estudianteDoc.exists) return;

    String idPadre = (estudianteDoc.data() as Map<String, dynamic>)['idPadre'];

    DocumentSnapshot padreDoc =
        await FirebaseFirestore.instance.collection('usuarios').doc(idPadre).get();

    if (!padreDoc.exists) return;

    Map<String, dynamic> padreData = padreDoc.data() as Map<String, dynamic>;
    String? fcmToken = padreData['fcmToken'];

    if (fcmToken == null) return;

    await FirebaseFirestore.instance.collection('notificaciones_pendientes').add({
      'token': fcmToken,
      'titulo': '📍 A Mitad de Camino',
      'mensaje': '$nombreEstudiante va a mitad de camino a casa',
      'tipo': 'mitad_camino',
      'estudianteId': estudianteId,
      'timestamp': FieldValue.serverTimestamp(),
      'enviada': false,
    });
  }

  /// Enviar notificación de llegada a casa
  Future<void> notificarLlegada(String estudianteId, String nombreEstudiante) async {
    DocumentSnapshot estudianteDoc = await FirebaseFirestore.instance
        .collection('estudiantes')
        .doc(estudianteId)
        .get();

    if (!estudianteDoc.exists) return;

    String idPadre = (estudianteDoc.data() as Map<String, dynamic>)['idPadre'];

    DocumentSnapshot padreDoc =
        await FirebaseFirestore.instance.collection('usuarios').doc(idPadre).get();

    if (!padreDoc.exists) return;

    Map<String, dynamic> padreData = padreDoc.data() as Map<String, dynamic>;
    String? fcmToken = padreData['fcmToken'];

    if (fcmToken == null) return;

    await FirebaseFirestore.instance.collection('notificaciones_pendientes').add({
      'token': fcmToken,
      'titulo': '🏠 Estudiante Llegó a Casa',
      'mensaje': '$nombreEstudiante ha llegado a su destino',
      'tipo': 'llegada',
      'estudianteId': estudianteId,
      'timestamp': FieldValue.serverTimestamp(),
      'enviada': false,
    });
  }

  /// Enviar notificación al conductor sobre padre recogiendo estudiante
  Future<void> notificarConductorPadreRecoge(
      String conductorId, String nombreEstudiante) async {
    DocumentSnapshot conductorDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(conductorId)
        .get();

    if (!conductorDoc.exists) return;

    Map<String, dynamic> conductorData = conductorDoc.data() as Map<String, dynamic>;
    String? fcmToken = conductorData['fcmToken'];

    if (fcmToken == null) return;

    await FirebaseFirestore.instance.collection('notificaciones_pendientes').add({
      'token': fcmToken,
      'titulo': '⚠️ Estudiante No Viajará',
      'mensaje': 'El padre recogió a $nombreEstudiante - NO viaja en bus hoy',
      'tipo': 'padre_recoge',
      'timestamp': FieldValue.serverTimestamp(),
      'enviada': false,
    });
  }
}

/// Handler para mensajes en segundo plano (debe ser función top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje recibido en segundo plano: ${message.messageId}');
}
