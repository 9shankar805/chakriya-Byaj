package com.chakriya.byaj

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.util.Calendar

class NepaliDateWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences("NepaliDateWidgetPrefs", Context.MODE_PRIVATE)
            val useNepali = prefs.getBoolean("use_nepali_language", true)

            val cal = Calendar.getInstance()
            val ad = NepaliDateConverter.fromGregorian(
                cal.get(Calendar.YEAR),
                cal.get(Calendar.MONTH) + 1,
                cal.get(Calendar.DAY_OF_MONTH)
            )

            val dayStr   = if (useNepali) toNepaliNum(ad[2]) else ad[2].toString()
            val monthIdx = ad[1] - 1
            val yearStr  = if (useNepali) toNepaliNum(ad[0]) else ad[0].toString()

            val monthsNP = arrayOf("बैशाख","जेठ","असार","साउन","भदौ","असोज",
                                   "कार्तिक","मंसिर","पुष","माघ","फाल्गुन","चैत")
            val monthsEN = arrayOf("Baisakh","Jestha","Ashadh","Shrawan","Bhadra","Ashwin",
                                   "Kartik","Mangsir","Poush","Magh","Falgun","Chaitra")
            val monthStr = if (useNepali) monthsNP[monthIdx] else monthsEN[monthIdx]

            // Weekday 0=Sun..6=Sat
            val wd = cal.get(Calendar.DAY_OF_WEEK) - 1
            val wdNP = arrayOf("आइतबार","सोमबार","मंगलबार","बुधबार","बिहिबार","शुक्रबार","शनिबार")
            val wdEN = arrayOf("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")
            val weekdayStr = if (useNepali) wdNP[wd] else wdEN[wd]

            val adMonths = arrayOf("Jan","Feb","Mar","Apr","May","Jun",
                                   "Jul","Aug","Sep","Oct","Nov","Dec")
            val adStr = "${adMonths[cal.get(Calendar.MONTH)]} ${cal.get(Calendar.DAY_OF_MONTH)}, ${cal.get(Calendar.YEAR)} AD"

            val views = RemoteViews(context.packageName, R.layout.nepali_date_widget)
            views.setTextViewText(R.id.widget_bs_day, dayStr)
            views.setTextViewText(R.id.widget_bs_month_year, "$monthStr $yearStr")
            views.setTextViewText(R.id.widget_bs_weekday, weekdayStr)
            views.setTextViewText(R.id.widget_ad_date, adStr)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = android.app.PendingIntent.getActivity(
                context, 0, intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_bs_day, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun toNepaliNum(n: Int): String {
            val digits = charArrayOf('०','१','२','३','४','५','६','७','८','९')
            return n.toString().map { c ->
                if (c.isDigit()) digits[c.digitToInt()] else c
            }.joinToString("")
        }
    }
}

// ── Boot receiver — restore widget after reboot ──────────────────────────────
class BootReceiver : android.content.BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val mgr = AppWidgetManager.getInstance(context)
            val provider = android.content.ComponentName(context, NepaliDateWidgetProvider::class.java)
            val ids = mgr.getAppWidgetIds(provider)
            for (id in ids) {
                NepaliDateWidgetProvider.updateWidget(context, mgr, id)
            }
        }
    }
}
