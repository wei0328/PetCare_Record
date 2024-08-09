const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendReminderNotification = functions.firestore
  .document("Reminders/{userId}/PetReminders/{petId}")
  .onWrite((change, context) => {
    const data = change.after.data();
    const reminders = data.reminders;

    const tokens = [];

    reminders.forEach((reminder) => {
      const payload = {
        notification: {
          title: `${reminder.type} Reminder`,
          body: `It's time for your pet's ${reminder.type}`,
        },
      };

      tokens.forEach((token) => {
        admin.messaging().sendToDevice(token, payload);
      });
    });

    return null;
  });
