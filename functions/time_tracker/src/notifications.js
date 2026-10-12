'use strict';
/**
 * The in-app notification document and the FCM push, exactly as the app
 * writes them (`NotificationModelSystem.toMap` + `NotificationServiceApp.
 * sendNotification`):
 *   Demo/{cid}/Notifications/{autoId} = {
 *     title, body (EN), title_ar, body_ar, Name_of_module: 'time_tracker',
 *     Sender_Email, Reciver_Email (lower-cased, sic), name_of_page, Pin: false,
 *     timestamp (epoch ms), isRead: false, isClean: false,
 *     Request_Id (only when set), Is_Reminder (pending_approvals only — NEW)
 *   }
 * Push: topic = the receiver's email sanitised (`sanitizeEmailForTopic`),
 * English text (the push is built before the device language is known).
 */

const { MODULE_KEY } = require('./config');
const { norm } = require('./fields');

/** `NotificationServiceApp.sanitizeEmailForTopic`. */
function topicForEmail(email) {
  return String(email || '')
    .trim()
    .toLowerCase()
    .replace(/@/g, '_at_')
    .replace(/\./g, '_dot_')
    .replace(/\+/g, '_plus_')
    .replace(/ /g, '_');
}

function notificationDoc({ rendered, senderEmail, receiverEmail, pageKey, nowMs, requestId = '', isReminder }) {
  const doc = {
    title: rendered.title,
    body: rendered.body,
    title_ar: rendered.title_ar,
    body_ar: rendered.body_ar,
    Name_of_module: MODULE_KEY,
    Sender_Email: norm(senderEmail),
    Reciver_Email: norm(receiverEmail),
    name_of_page: pageKey,
    Pin: false,
    timestamp: Math.trunc(nowMs),
    isRead: false,
    isClean: false,
  };
  if (String(requestId || '').trim() !== '') doc.Request_Id = String(requestId).trim();
  if (typeof isReminder === 'boolean') doc.Is_Reminder = isReminder;
  return doc;
}

function pushMessage({ rendered, receiverEmail, pageKey }) {
  return {
    topic: topicForEmail(receiverEmail),
    notification: { title: rendered.title, body: rendered.body },
    data: { route: MODULE_KEY, module: MODULE_KEY, name_of_page: pageKey },
  };
}

module.exports = { topicForEmail, notificationDoc, pushMessage };
