import {setGlobalOptions} from "firebase-functions";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getMessaging} from "firebase-admin/messaging";
import {getFirestore} from "firebase-admin/firestore";
import axios from "axios";

setGlobalOptions({maxInstances: 10});

initializeApp();

const BACKEND_URL = "https://meridian-api-production-3bb7.up.railway.app";

export const onNewMessage = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event: any) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const messageData = snapshot.data();
    const conversationId = event.params.conversationId;

    const db = getFirestore();
    const conversationDoc = await db
      .collection("conversations")
      .doc(conversationId)
      .get();

    const conversationData = conversationDoc.data();
    if (!conversationData) return;

    const senderId = messageData.senderId;
    const participants: string[] = conversationData.participants || [];
    const recipientId = participants.find((id) => id !== senderId);

    if (!recipientId) return;

    try {
      const response = await axios.get(
        `${BACKEND_URL}/users/${recipientId}/device-info`
      );

      const {deviceToken, senderName} = response.data;

      if (!deviceToken) {
        console.log(`No device token for user ${recipientId}`);
        return;
      }

      const message = {
        token: deviceToken,
        notification: {
          title: senderName || "New Message",
          body: messageData.text || "You have a new message",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      await getMessaging().send(message);
      console.log(`Push notification sent to ${recipientId}`);
    } catch (error) {
      console.error("Error sending push notification:", error);
    }
  }
);
