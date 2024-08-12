const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require("moment");

admin.initializeApp();

exports.sendAppointmentReminder = functions.pubsub.schedule(
    "every 1 minutes").onRun(async (context) => {
  const now = moment();
  const oneHourFromNow = now.add(1, "hour").toDate();

  const appointmentsSnapshot = await admin.firestore()
      .collection("appointments")
      .where("appointmentDateTime", "<=", oneHourFromNow)
      .where("appointmentDateTime", ">=", now.toDate())
      .get();

  const messages = [];

  appointmentsSnapshot.forEach((doc) => {
    const appointmentData = doc.data();
    const tokens = appointmentData.fcmTokens; // FCM tokens stored in Firestore

    messages.push({
      tokens,
      notification: {
        title: "Appointment Reminder",
        body: `Your appointment for ${
          appointmentData.service} is coming up in one hour.`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        appointmentId: doc.id,
      },
    });
  });

  if (messages.length > 0) {
    try {
      await admin.messaging().sendAll(messages);
      console.log("Notifications sent successfully");
    } catch (error) {
      console.error("Error sending notifications:", error);
    }
  }
});
