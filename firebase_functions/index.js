const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Función que se dispara cuando se crea una notificación pendiente
 * Envía la notificación push al token FCM correspondiente
 */
exports.enviarNotificaciones = functions.firestore
    .document('notificaciones_pendientes/{notifId}')
    .onCreate(async (snap, context) => {
        const notif = snap.data();
        
        // Verificar que no haya sido enviada
        if (notif.enviada) {
            console.log('Notificación ya fue enviada');
            return null;
        }
        
        // Construir mensaje
        const message = {
            notification: {
                title: notif.titulo,
                body: notif.mensaje,
            },
            data: {
                tipo: notif.tipo || '',
                estudianteId: notif.estudianteId || '',
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    channelId: 'transporte_escolar_channel',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
            token: notif.token,
        };
        
        try {
            // Enviar notificación
            const response = await messaging.send(message);
            console.log('Notificación enviada exitosamente:', response);
            
            // Marcar como enviada
            await snap.ref.update({ 
                enviada: true,
                messageId: response,
                fechaEnvio: admin.firestore.FieldValue.serverTimestamp(),
            });
            
            return { success: true, messageId: response };
        } catch (error) {
            console.error('Error enviando notificación:', error);
            
            // Guardar error en el documento
            await snap.ref.update({
                error: error.message,
                intentosFallidos: admin.firestore.FieldValue.increment(1),
            });
            
            return { success: false, error: error.message };
        }
    });

/**
 * Función que se dispara cuando un viaje se actualiza
 * Envía notificaciones automáticas según eventos
 */
exports.monitorizarViaje = functions.firestore
    .document('viajes/{viajeId}')
    .onUpdate(async (change, context) => {
        const viajeAnterior = change.before.data();
        const viajeActual = change.after.data();
        
        // Detectar cuando se finaliza un viaje
        if (viajeAnterior.estado === 'activo' && viajeActual.estado === 'finalizado') {
            console.log(`Viaje ${context.params.viajeId} finalizado`);
            
            // Aquí podrías enviar notificaciones de resumen, etc.
            // Por ejemplo, notificar al administrador
        }
        
        return null;
    });

/**
 * Función que se dispara cuando se crea un evento de viaje
 * Envía notificaciones según el tipo de evento
 */
exports.procesarEventoViaje = functions.firestore
    .document('viajes/{viajeId}/eventos/{eventoId}')
    .onCreate(async (snap, context) => {
        const evento = snap.data();
        const viajeId = context.params.viajeId;
        const eventoId = context.params.eventoId;
        
        console.log(`Nuevo evento ${evento.tipo} para estudiante ${evento.idEstudiante}`);
        
        try {
            // Obtener información del estudiante
            const estudianteDoc = await db.collection('estudiantes').doc(evento.idEstudiante).get();
            
            if (!estudianteDoc.exists) {
                console.error('Estudiante no encontrado:', evento.idEstudiante);
                return null;
            }
            
            const estudiante = estudianteDoc.data();
            const idPadre = estudiante.idPadre;
            
            // Obtener información del padre
            const padreDoc = await db.collection('usuarios').doc(idPadre).get();
            
            if (!padreDoc.exists) {
                console.error('Padre no encontrado:', idPadre);
                return null;
            }
            
            const padre = padreDoc.data();
            const fcmToken = padre.fcmToken;
            
            if (!fcmToken) {
                console.error('Padre no tiene token FCM:', idPadre);
                return null;
            }
            
            // Crear notificación según tipo de evento
            let titulo, mensaje, icono;
            
            switch (evento.tipo) {
                case 'abordaje':
                    titulo = '🚌 Estudiante Abordó el Bus';
                    mensaje = `${estudiante.nombre} ha subido al bus escolar`;
                    icono = 'login';
                    break;
                    
                case 'mitad_camino':
                    titulo = '📍 A Mitad de Camino';
                    mensaje = `${estudiante.nombre} va a mitad de camino a casa`;
                    icono = 'location';
                    break;
                    
                case 'llegada':
                    titulo = '🏠 Estudiante Llegó a Casa';
                    mensaje = `${estudiante.nombre} ha llegado a su destino`;
                    icono = 'home';
                    break;
                    
                default:
                    console.log('Tipo de evento desconocido:', evento.tipo);
                    return null;
            }
            
            // Crear documento de notificación pendiente
            await db.collection('notificaciones_pendientes').add({
                token: fcmToken,
                titulo: titulo,
                mensaje: mensaje,
                tipo: evento.tipo,
                estudianteId: evento.idEstudiante,
                viajeId: viajeId,
                eventoId: eventoId,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                enviada: false,
            });
            
            console.log('Notificación creada para:', padre.nombre);
            return { success: true };
            
        } catch (error) {
            console.error('Error procesando evento:', error);
            return { success: false, error: error.message };
        }
    });

/**
 * Función que limpia notificaciones antiguas (más de 30 días)
 * Se ejecuta diariamente a medianoche
 */
exports.limpiarNotificacionesAntiguas = functions.pubsub
    .schedule('0 0 * * *') // Cada día a medianoche
    .timeZone('America/Bogota')
    .onRun(async (context) => {
        const hace30Dias = new Date();
        hace30Dias.setDate(hace30Dias.getDate() - 30);
        
        try {
            // Buscar notificaciones antiguas
            const snapshot = await db.collection('notificaciones_pendientes')
                .where('timestamp', '<', hace30Dias)
                .get();
            
            console.log(`Encontradas ${snapshot.size} notificaciones antiguas`);
            
            // Eliminar en lotes
            const batch = db.batch();
            snapshot.docs.forEach(doc => {
                batch.delete(doc.ref);
            });
            
            await batch.commit();
            console.log(`${snapshot.size} notificaciones eliminadas`);
            
            return { eliminadas: snapshot.size };
        } catch (error) {
            console.error('Error limpiando notificaciones:', error);
            return { error: error.message };
        }
    });

/**
 * Función que detecta viajes que no se han finalizado correctamente
 * Se ejecuta cada hora
 */
exports.detectarViajesAnormales = functions.pubsub
    .schedule('0 * * * *') // Cada hora
    .timeZone('America/Bogota')
    .onRun(async (context) => {
        try {
            // Buscar viajes activos de hace más de 4 horas
            const hace4Horas = new Date();
            hace4Horas.setHours(hace4Horas.getHours() - 4);
            
            const snapshot = await db.collection('viajes')
                .where('estado', '==', 'activo')
                .where('fechaInicio', '<', hace4Horas)
                .get();
            
            console.log(`Encontrados ${snapshot.size} viajes potencialmente anormales`);
            
            // Notificar al administrador
            for (const doc of snapshot.docs) {
                const viaje = doc.data();
                
                // Buscar administradores
                const adminSnapshot = await db.collection('usuarios')
                    .where('rol', '==', 'admin')
                    .get();
                
                for (const adminDoc of adminSnapshot.docs) {
                    const admin = adminDoc.data();
                    
                    if (admin.fcmToken) {
                        await db.collection('notificaciones_pendientes').add({
                            token: admin.fcmToken,
                            titulo: '⚠️ Viaje Anormal Detectado',
                            mensaje: `El viaje ${doc.id} lleva más de 4 horas activo. Verificar con el conductor.`,
                            tipo: 'alerta_viaje',
                            viajeId: doc.id,
                            timestamp: admin.firestore.FieldValue.serverTimestamp(),
                            enviada: false,
                        });
                    }
                }
            }
            
            return { viajesAnormales: snapshot.size };
        } catch (error) {
            console.error('Error detectando viajes anormales:', error);
            return { error: error.message };
        }
    });

/**
 * Función que genera estadísticas diarias
 * Se ejecuta a las 11:00 PM
 */
exports.generarEstadisticasDiarias = functions.pubsub
    .schedule('0 23 * * *') // 11:00 PM cada día
    .timeZone('America/Bogota')
    .onRun(async (context) => {
        try {
            const hoy = new Date();
            hoy.setHours(0, 0, 0, 0);
            const manana = new Date(hoy);
            manana.setDate(manana.getDate() + 1);
            
            // Contar viajes del día
            const viajesSnapshot = await db.collection('viajes')
                .where('fechaInicio', '>=', hoy)
                .where('fechaInicio', '<', manana)
                .get();
            
            // Contar eventos del día
            let totalEventos = 0;
            for (const viajeDoc of viajesSnapshot.docs) {
                const eventosSnapshot = await viajeDoc.ref.collection('eventos').get();
                totalEventos += eventosSnapshot.size;
            }
            
            // Guardar estadísticas
            await db.collection('estadisticas_diarias').add({
                fecha: hoy,
                totalViajes: viajesSnapshot.size,
                totalEventos: totalEventos,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
            
            console.log(`Estadísticas del día: ${viajesSnapshot.size} viajes, ${totalEventos} eventos`);
            
            return { viajes: viajesSnapshot.size, eventos: totalEventos };
        } catch (error) {
            console.error('Error generando estadísticas:', error);
            return { error: error.message };
        }
    });

/**
 * Función HTTP para pruebas (opcional)
 */
exports.testNotification = functions.https.onRequest(async (req, res) => {
    const token = req.body.token || req.query.token;
    
    if (!token) {
        res.status(400).send('Token FCM requerido');
        return;
    }
    
    const message = {
        notification: {
            title: '🧪 Notificación de Prueba',
            body: 'Esta es una notificación de prueba del sistema',
        },
        token: token,
    };
    
    try {
        const response = await messaging.send(message);
        res.status(200).send({ success: true, messageId: response });
    } catch (error) {
        res.status(500).send({ success: false, error: error.message });
    }
});
