// users.service.ts
// Handles device token storage for push notifications

import pool from '../../config/db'

// SAVE DEVICE TOKEN
// Updates the user's device_token column
// Called whenever the iOS app registers/refreshes its FCM token
export const saveDeviceToken = async (userId: string, deviceToken: string) => {
    await pool.query(
        `UPDATE users SET device_token = $1 WHERE id = $2`,
        [deviceToken, userId]
    )
}

// GET DEVICE TOKEN
// Used by the messaging system to find where to send a push
export const getDeviceToken = async (userId: string) => {
    const result = await pool.query(
        `SELECT device_token FROM users WHERE id = $1`,
        [userId]
    )
    return result.rows[0]?.device_token || null
}
// GET DEVICE INFO
// Returns device token and full name for a specific user
// Called by our Firebase Cloud Function to send push notifications
export const getDeviceInfo = async (userId: string) => {
    const result = await pool.query(
        `SELECT device_token, full_name FROM users WHERE id = $1`,
        [userId]
    )
    
    if (result.rows.length === 0) return null
    
    return {
        deviceToken: result.rows[0].device_token,
        senderName: result.rows[0].full_name
    }
}