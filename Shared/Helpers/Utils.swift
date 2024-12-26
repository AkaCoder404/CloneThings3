//
//  Utils.swift
//  CloneThings3
//
//  Created by George Li on 12/24/24.
//

import Foundation

func formatDateToString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月d日"  // "2024年1月2日" format
    formatter.locale = Locale(identifier: "zh_Hans_CN") // Chinese (Simplified) locale
    return formatter.string(from: date)
}

/// Function to calculate whether a Date() is a morning task
func isTodayMorning(_ date: Date) -> Bool {
    let calendar = Calendar.current
    let now = Date()

    // Check if the date is from a previous day
    if calendar.isDate(date, inSameDayAs: now) || date < now {
        // Check the hour to see if it's morning (0-11 AM)
        let hour = calendar.component(.hour, from: date)
        return hour < 12
    }
    return false
}

/// Function to calculate whether a Date() is a night task
func isTodayTonight(_ date: Date) -> Bool {
    let calendar = Calendar.current
    let now = Date()

    // Check if the date is from a previous day
    if calendar.isDate(date, inSameDayAs: now) || date < now {
        // Check the hour to see if it's night (6 PM-11:59 PM)
        let hour = calendar.component(.hour, from: date)
        return hour >= 18
    }
    return false
}

/// Function to determine if the date is tomorrow or the day after tomorrow
func formatSpecialDates(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    // Calculate tomorrow and the day after tomorrow
    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
       let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: now) {
        
        if calendar.isDate(date, inSameDayAs: tomorrow) {
            return "明天"
        } else if calendar.isDate(date, inSameDayAs: dayAfterTomorrow) {
            return "后天"
        }
    }
    
    // If not special cases, return formatted date
    return formatDateToString(date)
}


/// Function to calculate a date
/// 1. If date is within 7 days, give the day of the week
/// 2. If date is more than 1 week, give the day
func formatDateWithinWeek(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    // 1. Calculate the start of *today* and start of the passed-in date.
    let startOfToday = calendar.startOfDay(for: now)
    let startOfDate = calendar.startOfDay(for: date)
    
    // 2. Calculate the difference in days.
    guard let dayDifference = calendar.dateComponents([.day],
                                from: startOfToday,
                                to: startOfDate).day else {
        return formatAsMMDD(date)
    }
    
    // 3. If the date is within [0..6] days from today,
    //    then we show "周一", "周二", etc.
    //    dayDifference == 0 => same day
    //    dayDifference == 1 => tomorrow
    //    ...
    if dayDifference >= 0 && dayDifference < 7 {
        // Sunday = 1, Monday = 2, Tuesday = 3, ..., Saturday = 7
        let weekday = calendar.component(.weekday, from: date)
        
        // Map Sunday->周日(1), Monday->周一(2), ...
        let weekdaySymbols = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        
        // weekday - 1 gives us 0-based index for the array.
        // e.g. Monday = 2 => index 1 => "周一"
        return weekdaySymbols[weekday - 1]
    } else {
        // 4. Otherwise, return "MM/dd"
        return formatAsMMDD(date)
    }
}

// Helper to format a date as "MM/dd".
private func formatAsMMDD(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd"
    return formatter.string(from: date)
}
