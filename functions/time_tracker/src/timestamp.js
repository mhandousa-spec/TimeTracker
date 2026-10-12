'use strict';
/**
 * A minimal Firestore-Timestamp look-alike, used ONLY when no real
 * `admin.firestore.Timestamp` is injected (unit tests). Production code always
 * passes `Timestamp.fromMillis` from firebase-admin, so documents carry real
 * Timestamps exactly like the app writes (`Timestamp.fromDate`).
 */
class PlainTimestamp {
  constructor(seconds, nanoseconds) {
    this.seconds = seconds;
    this.nanoseconds = nanoseconds;
    Object.freeze(this);
  }

  static fromMillis(ms) {
    const seconds = Math.floor(ms / 1000);
    const nanoseconds = Math.round((ms - seconds * 1000) * 1e6);
    return new PlainTimestamp(seconds, nanoseconds);
  }

  toMillis() {
    return this.seconds * 1000 + Math.floor(this.nanoseconds / 1e6);
  }

  toDate() {
    return new Date(this.toMillis());
  }

  isEqual(other) {
    return !!other && typeof other.toMillis === 'function' && other.toMillis() === this.toMillis();
  }
}

/** The default `ms → Timestamp` factory. */
const plainTimestamp = (ms) => PlainTimestamp.fromMillis(ms);

module.exports = { PlainTimestamp, plainTimestamp };
