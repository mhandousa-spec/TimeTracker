'use strict';
/**
 * Knowticed Plus — Time Tracker server notifications (firebase-functions v2).
 * Thin wrappers only; every decision lives in src/rules (pure, unit-tested)
 * and the orchestration in src/runner.js.
 *
 *   ttScheduler          every 5 minutes — break / pause limits, auto
 *                        check-out, missed check-in / check-out, shift start
 *                        / end reminders, daily pending-approvals reminder,
 *                        Attendance.Alerts records.
 *   ttPendingApprovals   Demo/{companyId}/Modules/time_tracker/Requests/{id}
 *                        written → pending_approvals with the REAL count.
 *
 * Deploy (never from CI without Moataz's go): see README.md.
 */

const admin = require('firebase-admin');
const { setGlobalOptions } = require('firebase-functions/v2');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');

const config = require('./config');
const { createRunner } = require('./runner');

admin.initializeApp();
setGlobalOptions({ region: config.REGION });

let runner = null;
function getRunner() {
  if (runner === null) {
    runner = createRunner({
      db: admin.firestore(),
      toTimestamp: (ms) => admin.firestore.Timestamp.fromMillis(ms),
      messaging: admin.messaging(),
      logger,
      config,
    });
  }
  return runner;
}

exports.ttScheduler = onSchedule(
  {
    schedule: 'every 5 minutes',
    timeZone: 'Etc/UTC', // the rules use each location's own zone
    timeoutSeconds: 540,
    memory: '512MiB',
    maxInstances: 1, // one sweep at a time (markers make overlaps harmless anyway)
    retryCount: 0, // the next run 5 minutes later is the retry
  },
  async () => {
    await getRunner().runScheduler();
  },
);

exports.ttPendingApprovals = onDocumentWritten(
  {
    document: 'Demo/{companyId}/Modules/time_tracker/Requests/{requestId}',
    timeoutSeconds: 120,
    memory: '256MiB',
  },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const before = change.before && change.before.exists ? change.before.data() : null;
    const after = change.after && change.after.exists ? change.after.data() : null;
    const report = await getRunner().onRequestWritten({
      cid: event.params.companyId,
      requestId: event.params.requestId,
      before,
      after,
      eventTimeMs: Date.parse(event.time),
    });
    logger.debug('[time_tracker] pending_approvals', report);
  },
);
