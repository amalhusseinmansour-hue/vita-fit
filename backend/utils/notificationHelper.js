const admin = require('firebase-admin');
const { Notification, User } = require('../models');

// Initialize Firebase Admin (only if not already initialized)
let firebaseInitialized = false;

const initializeFirebase = () => {
  if (firebaseInitialized) return;

  try {
    // Check if service account is available
    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
      ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
      : null;

    if (serviceAccount) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      firebaseInitialized = true;
      console.log('Firebase Admin initialized successfully');
    } else {
      console.log('Firebase Admin not configured - push notifications disabled');
    }
  } catch (error) {
    console.log('Firebase Admin initialization failed:', error.message);
  }
};

// Initialize on module load
initializeFirebase();

/**
 * Send push notification via FCM
 */
const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  if (!firebaseInitialized || !fcmToken) return false;

  try {
    const message = {
      token: fcmToken,
      notification: {
        title,
        body
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'vitafit_channel'
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      }
    };

    await admin.messaging().send(message);
    return true;
  } catch (error) {
    console.log('Push notification failed:', error.message);
    return false;
  }
};

/**
 * Send notification to a specific user (saves to DB + sends push)
 */
const sendNotificationToUser = async (userId, { title, title_ar, body, body_ar, type = 'system', data = {} }) => {
  try {
    // Save to database
    await Notification.create({
      user_id: userId,
      title,
      title_ar,
      body,
      body_ar,
      type,
      data
    });

    // Get user's FCM token and send push
    const user = await User.findByPk(userId, { attributes: ['fcm_token'] });
    if (user?.fcm_token) {
      await sendPushNotification(user.fcm_token, title_ar || title, body_ar || body, data);
    }

    return true;
  } catch (error) {
    console.error('Error sending notification to user:', error);
    return false;
  }
};

/**
 * Send notification to all admins
 */
const sendNotificationToAdmins = async ({ title, title_ar, body, body_ar, type = 'system', data = {} }) => {
  try {
    // Find all admins
    const admins = await User.findAll({
      where: { role: ['admin', 'super_admin'] },
      attributes: ['id', 'fcm_token']
    });

    // Create notifications for all admins
    const notifications = admins.map(admin => ({
      user_id: admin.id,
      title,
      title_ar,
      body,
      body_ar,
      type,
      data
    }));

    await Notification.bulkCreate(notifications);

    // Send push notifications
    for (const adminUser of admins) {
      if (adminUser.fcm_token) {
        await sendPushNotification(adminUser.fcm_token, title_ar || title, body_ar || body, data);
      }
    }

    return true;
  } catch (error) {
    console.error('Error sending notification to admins:', error);
    return false;
  }
};

/**
 * Send notification to a trainer
 */
const sendNotificationToTrainer = async (trainerId, { title, title_ar, body, body_ar, type = 'system', data = {} }) => {
  try {
    const { Trainer } = require('../models');

    // Get trainer's user_id
    const trainer = await Trainer.findByPk(trainerId, {
      include: [{ model: User, attributes: ['id', 'fcm_token'] }]
    });

    if (!trainer?.user) return false;

    // Save to database
    await Notification.create({
      user_id: trainer.user.id,
      title,
      title_ar,
      body,
      body_ar,
      type,
      data
    });

    // Send push notification
    if (trainer.user.fcm_token) {
      await sendPushNotification(trainer.user.fcm_token, title_ar || title, body_ar || body, data);
    }

    return true;
  } catch (error) {
    console.error('Error sending notification to trainer:', error);
    return false;
  }
};

/**
 * Notification types for different events
 */
const NotificationTypes = {
  NEW_REGISTRATION: 'new_registration',
  TRAINER_SELECTED: 'trainer_selected',
  NEW_SUBSCRIPTION: 'subscription',
  ORDER: 'order',
  SESSION: 'session',
  SYSTEM: 'system'
};

module.exports = {
  sendNotificationToUser,
  sendNotificationToAdmins,
  sendNotificationToTrainer,
  sendPushNotification,
  NotificationTypes
};
