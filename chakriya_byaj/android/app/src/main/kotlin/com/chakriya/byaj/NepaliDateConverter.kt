package com.chakriya.byaj

/**
 * Lightweight AD→BS converter for the home screen widget.
 * Covers BS 2000–2099 (AD 1943–2043).
 * EXACTLY matches the Dart implementation for consistency!
 */
object NepaliDateConverter {

    // BS 2000 Baisakh 1 = April 14, 1943
    private val adEpochYear = 1943
    private val adEpochMonth = 4
    private val adEpochDay = 14

    private val data = arrayOf(
        intArrayOf(30,32,31,32,31,30,30,30,29,30,29,31),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(30,32,31,32,31,30,30,30,29,30,29,31),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,29,31),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,32),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,30,29,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31),
        intArrayOf(31,31,31,32,31,31,29,30,30,29,30,30),
        intArrayOf(31,31,32,31,31,31,30,29,30,29,30,30),
        intArrayOf(31,31,32,32,31,30,30,29,30,29,30,30),
        intArrayOf(31,32,31,32,31,30,30,30,29,29,30,31)
    )

    private fun daysInMonth(bsYear: Int, bsMonth: Int): Int {
        val idx = bsYear - 2000
        if (idx < 0 || idx >= data.size) return 30
        return data[idx][bsMonth - 1]
    }

    private fun daysInYear(bsYear: Int): Int {
        val idx = bsYear - 2000
        if (idx < 0 || idx >= data.size) return 365
        return data[idx].sum()
    }

    /** Returns [bsYear, bsMonth, bsDay] */
    fun fromGregorian(adYear: Int, adMonth: Int, adDay: Int): IntArray {
        // Use java.time to calculate days exactly like Dart does
        val epochDate = java.time.LocalDate.of(adEpochYear, adEpochMonth, adEpochDay)
        val targetDate = java.time.LocalDate.of(adYear, adMonth, adDay)
        var totalDays = java.time.temporal.ChronoUnit.DAYS.between(epochDate, targetDate).toInt()

        var bsYear = 2000
        var bsMonth = 1

        // Exact same loop as Dart
        while (true) {
            val yDays = daysInYear(bsYear)
            if (totalDays < yDays) break
            totalDays -= yDays
            bsYear++
        }
        while (true) {
            val mDays = daysInMonth(bsYear, bsMonth)
            if (totalDays < mDays) break
            totalDays -= mDays
            bsMonth++
        }
        val bsDay = totalDays + 1
        return intArrayOf(bsYear, bsMonth, bsDay)
    }
}
