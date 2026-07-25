package com.chakriya.byaj

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface

/**
 * Creates notification icons with today's BS day number.
 *
 * smallIcon  -> white text on TRANSPARENT background (monochrome).
 *               Android system tints this white, so the day number
 *               appears in the status bar instead of the app icon.
 *
 * largeIcon  -> white text on blue circle.
 *               Shown in the notification shade (expanded view).
 */
object DateIconHelper {

    /** White-on-transparent — used as smallIcon (status bar) */
    fun createSmallDayIcon(dayNumber: Int, useNepali: Boolean): Bitmap {
        val size = 96
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        canvas.drawColor(Color.TRANSPARENT)

        val label = if (useNepali) toNepaliNum(dayNumber) else dayNumber.toString()

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
            // Fill nearly the whole icon — single digit gets ~90%, two digits ~82%
            textSize = if (dayNumber >= 10) size * 0.82f else size * 0.90f
            // Extra stroke to thicken the number so it's visible at small sizes
            style = Paint.Style.FILL_AND_STROKE
            strokeWidth = size * 0.03f
        }

        val bounds = android.graphics.Rect()
        paint.getTextBounds(label, 0, label.length, bounds)
        val x = size / 2f
        val y = size / 2f - bounds.exactCenterY()
        canvas.drawText(label, x, y, paint)
        return bmp
    }

    /** Blue circle with white number — used as largeIcon (notification shade) */
    fun createLargeDayIcon(dayNumber: Int, useNepali: Boolean): Bitmap {
        val size = 192  // larger resolution for the shade icon
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val bg = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#2563EB")
            style = Paint.Style.FILL
        }
        canvas.drawCircle(size / 2f, size / 2f, size / 2f, bg)
        drawDayText(canvas, size, dayNumber, useNepali, Color.WHITE)
        return bmp
    }

    private fun drawDayText(
        canvas: Canvas, size: Int,
        dayNumber: Int, useNepali: Boolean,
        textColor: Int,
    ) {
        val label = if (useNepali) toNepaliNum(dayNumber) else dayNumber.toString()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = textColor
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
            textSize = if (dayNumber >= 10) size * 0.52f else size * 0.62f
            style = Paint.Style.FILL_AND_STROKE
            strokeWidth = size * 0.025f
        }
        val bounds = android.graphics.Rect()
        paint.getTextBounds(label, 0, label.length, bounds)
        val x = size / 2f
        val y = size / 2f - bounds.exactCenterY()
        canvas.drawText(label, x, y, paint)
    }

    val npDigits = charArrayOf('०', '१', '२', '३', '४', '५', '६', '७', '८', '९')

    fun toNepaliNum(n: Int): String =
        n.toString().map { c ->
            if (c.isDigit()) npDigits[c.digitToInt()] else c
        }.joinToString("")
}
