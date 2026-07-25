package com.chakriya.byaj

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.graphics.drawable.IconCompat
import java.util.Calendar

object NepaliDateNotificationService {

    private const val CHANNEL_ID   = "nepali_date_channel"
    private const val CHANNEL_NAME = "Nepali Date"
    const val NOTIF_ID = 1001

    fun show(context: Context) {
        val prefs = context.getSharedPreferences("NepaliDateWidgetPrefs", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("notif_enabled", false)) return
        val useNepali = prefs.getBoolean("use_nepali_language", true)
        postNotification(context, useNepali)
    }

    fun postNotification(context: Context, useNepali: Boolean) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
                as NotificationManager

        // Create channel (no-op on older Android)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW      // silent, no sound/vibration
            ).apply {
                description = "Shows today's Nepali BS date in the status bar"
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
                setSound(null, null)
            }
            manager.createNotificationChannel(channel)
        }

        // Get today's BS date
        val cal = Calendar.getInstance()
        val ad  = NepaliDateConverter.fromGregorian(
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH) + 1,
            cal.get(Calendar.DAY_OF_MONTH)
        )
        val bsDay   = ad[2]
        val bsMonth = ad[1]
        val bsYear  = ad[0]

        val monthsNP = arrayOf("बैशाख","जेठ","असार","साउन","भदौ","असोज",
                               "कार्तिक","मंसिर","पुष","माघ","फाल्गुन","चैत")
        val monthsEN = arrayOf("Baisakh","Jestha","Ashadh","Shrawan","Bhadra","Ashwin",
                               "Kartik","Mangsir","Poush","Magh","Falgun","Chaitra")
        val wdNP = arrayOf("आइतबार","सोमबार","मंगलबार","बुधबार","बिहिबार","शुक्रबार","शनिबार")
        val wdEN = arrayOf("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")
        val wd   = cal.get(Calendar.DAY_OF_WEEK) - 1   // 0 = Sunday

        val adMonths = arrayOf("Jan","Feb","Mar","Apr","May","Jun",
                               "Jul","Aug","Sep","Oct","Nov","Dec")

        val dayStr   = if (useNepali) DateIconHelper.toNepaliNum(bsDay) else bsDay.toString()
        val monthStr = if (useNepali) monthsNP[bsMonth - 1] else monthsEN[bsMonth - 1]
        val yearStr  = if (useNepali) DateIconHelper.toNepaliNum(bsYear) else bsYear.toString()
        val wdStr    = if (useNepali) wdNP[wd] else wdEN[wd]
        val adStr    = "${adMonths[cal.get(Calendar.MONTH)]} ${cal.get(Calendar.DAY_OF_MONTH)}, ${cal.get(Calendar.YEAR)}"
        val suffix   = if (useNepali) "बि.सं." else "BS"

        val title = "$dayStr $monthStr $yearStr $suffix"
        val body  = "$wdStr  •  $adStr AD"

        // ── Icons ────────────────────────────────────────────────────────
        // smallIcon: white-on-transparent bitmap → shown as day number in status bar
        val smallBmp  = DateIconHelper.createSmallDayIcon(bsDay, useNepali)
        // largeIcon: blue circle with number → shown in notification shade
        val largeBmp  = DateIconHelper.createLargeDayIcon(bsDay, useNepali)

        // Tap opens app
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setLargeIcon(largeBmp)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle()
                .setBigContentTitle(title)
                .bigText(body))
            .setOngoing(true)
            .setAutoCancel(false)
            .setShowWhen(false)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)

        // Use bitmap as small icon on API 23+ — renders day number in status bar
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            builder.setSmallIcon(IconCompat.createWithBitmap(smallBmp))
        } else {
            builder.setSmallIcon(R.mipmap.ic_launcher)
        }

        manager.notify(NOTIF_ID, builder.build())
    }

    fun cancel(context: Context) {
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .cancel(NOTIF_ID)
    }
}
