// index.ts
// Cloud Function that triggers automatically when a new message
// is added to any conversation's messages subcollection in Firestore
// Sends a push notification to the recipient via FCM

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import { getFirestore } from "firebase-admin/firestore";
import axios from "axios";

// Initialize Firebase Admin SDK
// This gives our Cloud Function admin access to Firestore and FCM
initializeApp();

// URL of your deployed Railway backend
// We call this to look up the recipient's device token from PostgreSQL
const BACKEND_URL = "https://meridian-api-production-3bb7.up.railway.app";

// This function automatically triggers whenever a new document
// is created inside conversations/{conversationId}/messages/{messageId}
export const onNewMessage = onDocumentCreated(
    "conversations/{conversationId}/messages/{messageId}",
    async (event: any) => {
        const snapshot = event.data;
        if (!snapshot) return;

        const messageData = snapshot.data();
        const conversationId = event.params.conversationId;

        // Get the conversation document to find both participants
        const db = getFirestore();
        const conversationDoc = await db
            .collection("conversations")
            .doc(conversationId)
            .get();

        const conversationData = conversationDoc.data();
        if (!conversationData) return;

        const senderId = messageData.senderId;

        // Figure out who the recipient is — the participant who ISN'T the sender
        const participants: string[] = conversationData.participants || [];
        const recipientId = participants.find((id) => id !== senderId);

        if (!recipientId) return;

        try {
            // Call our Railway backend to get the recipient's device token
            // and sender's name for the notification text
            const response = await axios.get(
                `${BACKEND_URL}/users/${recipientId}/device-info`
            );

            const { deviceToken, senderName } = response.data;

            if (!deviceToken) {
                console.log(`No device token for user ${recipientId}`);
                return;
            }

            // Build and send the push notification via FCM
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