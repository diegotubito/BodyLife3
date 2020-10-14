//
//  dateExtension.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


import Foundation

struct DateFormat {
    static let fecha = "dd-MM-yyyy"
    static let fechaConHora = "dd-MM-yyyy HH:mm:ss"
    static let fechaConHoraSinSeg = "dd-MM-yyyy HH:mm"
    
    
    static let hora12 = "HH:mm"
    static let hora24 = "HH:mm a"
    static let hora12seg = "HH:mm:ss a"
    static let hora24seg = "HH:mm:ss a"
}

extension Date {
    var timeIntervalSinceReferenceDate : Double {
        return self.timeIntervalSince(DateReference)
    }
    
    var queryByDMY : String {
        return self.toString(formato: "dd-MM-yyyy")
    }
    
    var queryByMY : String {
        return self.toString(formato: "MM-yyyy")
    }
    var queryByY : String {
        return self.toString(formato: "yyyy")
    }
}

extension Date {
    func toString(formato: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formato
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

extension Date {
    mutating func addMonths(valor: Int) {
        let myCalendar = Calendar(identifier: .gregorian)
        self = myCalendar.date(byAdding: .month, value: valor, to: self)!
        
    }
    
    mutating func addDays(valor: Int) {
        let myCalendar = Calendar(identifier: .gregorian)
        self = myCalendar.date(byAdding: .day, value: valor, to: self)!
        
    }
    
    func startDay() -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        return myCalendar.component(.weekday, from: self)
    }
    
    func endDay() -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        
        // Calculate start and end of the current year (or month with `.month`):
        let interval = myCalendar.dateInterval(of: .month, for: self)!
        
        // Compute difference in days:
        let days = myCalendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        return days
    }
   
    var year : Int {
        let calendar = Calendar.current
        let mes = calendar.component(.year, from: self)
        
        return mes
    }
    
    
    
    func desdeHace(numericDates: Bool) -> String {
        
        let str = timeAgoSinceDate(date: self as NSDate, numericDates: numericDates)
        return str
    }
    
    
    var monthName : String {
        let calendar = Calendar.current
        let mes = calendar.component(.month, from: self)
        
        let nombre = Constants.DateConstants.MonthName[mes]?.localized
        
        return nombre ?? "error"
    }
    
    var dayName : String {
        let calendar = Calendar.current
        let dia = calendar.component(.weekday, from: self)
        
        let nombre = Constants.DateConstants.DayName[dia-1].localized
        
        return nombre
    }
}

extension Date {
    func mesesTranscurridos(fecha: Date) -> Int? {
        let calendar : NSCalendar = NSCalendar.current as NSCalendar
        let ageComponents = calendar.components(.month, from: self, to: fecha, options: [])
        let meses = ageComponents.month
        
        return meses
    }
    
    func diasTranscurridos(fecha: Date) -> Int? {
        let calendar : NSCalendar = NSCalendar.current as NSCalendar
        let ageComponents = calendar.components(.day, from: self, to: fecha, options: [])
        let dias = ageComponents.day
        
        return dias
    }
    
    func horasTranscurridas(fecha: Date) -> Int? {
        let calendar : NSCalendar = NSCalendar.current as NSCalendar
        let ageComponents = calendar.components(.hour, from: self, to: fecha, options: [])
        let horas = ageComponents.hour
        
        return horas
    }
    
    func segundosTranscurridos(fecha: Date) -> Int? {
        let calendar : NSCalendar = NSCalendar.current as NSCalendar
        let ageComponents = calendar.components(.second, from: self, to: fecha, options: [])
        let segundos = ageComponents.second
        
        return segundos
    }
}

extension Calendar {
    
    func dayOfWeek(_ date: Date) -> Int {
        var dayOfWeek = self.component(.weekday, from: date) + 1 - self.firstWeekday
        
        if dayOfWeek <= 0 {
            dayOfWeek += 7
        }
        
        return dayOfWeek
    }
    
    func startOfWeek(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(day: -self.dayOfWeek(date) + 1), to: date)!
    }
    
    func endOfWeek(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(day: 6), to: self.startOfWeek(date))!
    }
    
    func startOfMonth(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: date))!
    }
    
    func endOfMonth(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(date))!
    }
    
    func startOfQuarter(_ date: Date) -> Date {
        let quarter = (self.component(.month, from: date) - 1) / 3 + 1
        return self.date(from: DateComponents(year: self.component(.year, from: date), month: (quarter - 1) * 3 + 1))!
    }
    
    func endOfQuarter(_ date: Date) -> Date {
        return self.date(byAdding: DateComponents(month: 3, day: -1), to: self.startOfQuarter(date))!
    }
    
    func startOfYear(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year], from: date))!
    }
    
    func endOfYear(_ date: Date) -> Date {
        return self.date(from: DateComponents(year: self.component(.year, from: date), month: 12, day: 31))!
    }
}

func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = NSDate()
    let earliest = now.earlierDate(date as Date)
    let latest = (earliest == now as Date) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
    
    if (components.year! >= 2) {
        return "hace \(components.year!) años"
    } else if (components.year! >= 1){
        if (numericDates){
            return "hace 1 año"
        } else {
            return "el año pasado"
        }
    } else if (components.month! >= 2) {
        return "hace \(components.month!) meses"
    } else if (components.month! >= 1){
        if (numericDates){
            return "hace 1 mes"
        } else {
            return "El último mes"
        }
    } else if (components.weekOfYear! >= 2) {
        return "hace \(components.weekOfYear!) semanas"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "hace 1 semana"
        } else {
            return "Desde la semana pasada"
        }
    } else if (components.day! >= 2) {
        return "hace \(components.day!) días"
    } else if (components.day! >= 1){
        if (numericDates){
            return "hace 1 día"
        } else {
            return "Ayer"
        }
    } else if (components.hour! >= 2) {
        return "hace \(components.hour!) horas"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "hace 1 hora"
        } else {
            return "1 hora atrás"
        }
    } else if (components.minute! >= 2) {
        return "hace \(components.minute!) minutos"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "hace 1 minuto"
        } else {
            return "Un minuto atrás"
        }
    } else if (components.second! >= 3) {
        return "hace \(components.second!) segundos"
    } else {
        return "Justo ahora"
    }
    
}


extension Date {
    func age() -> Int {
        let calendar : NSCalendar = NSCalendar.current as NSCalendar
        let ageComponents = calendar.components(.year, from: self, to: Date(), options: [])
        let age = ageComponents.year!
        
        return age
    }
}

enum DateFormatterPattern: String {
    case shortDateWithHour = "dd/MM/yyyy HH:mm:ss"
    case shortDate = "dd/MM"
    case longDate = "EEEE, d' de 'MMMM" // viernes, 21 de junio
    case longDateWithTime = "EEEE, d' de 'MMMM, HH:mm'hs" // viernes, 21 de junio, 14:30hs
    case shortDateWithTime = "dd/MM' a las 'HH:mm'hs" // 21/06 a las 14:30hs
    case time = "hh:mm"
    case jsonDate = "yyyy-MM-dd HH:mm:ss" //"2020-04-15 15:55:00"
}

func actualUnixDate() -> Int {
    return Int(Date().timeIntervalSince1970 * 1000)
}

func getFormattedDateFrom(format: String) -> (Date) -> String {
    let formatter = DateFormatter()
    
    return { date in
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
    func stringFromTimeIntervalShort() -> String {
        let time = NSInteger(self)
        
       // let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours > 0 {
            if minutes > 0 {
                if  hours > 9 {
                    return String(format: "%0.2dh %0.2dmin",hours,minutes)
                }
                else {
                    return String(format: "%0.1dh %0.2dmin",hours,minutes)
                }
            }
            else {
                if  hours > 9 {
                    return String(format: "%0.2dh",hours)
                }
                else {
                    return String(format: "%0.1dh",hours)
                }
            }
        }
        else {
            if minutes > 0 {
                return String(format: "%0.2dmin",minutes)
            }
        }
      
        return ""
    }
}

extension Date {
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func addDays(value:Int) -> Date {
        let today = self
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: value, to: today)!
    }
    
    func addHours(value:Int) -> Date {
        let today = self
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: today)!
    }
    
    func isToday() -> Bool {
        let today = Date()
        let calendar = Calendar.current
        let todayMonth = calendar.component(.month, from: today)
        let todayDay = calendar.component(.day, from: today)
        
        let dateMonth = calendar.component(.month, from: self)
        let dateDay = calendar.component(.day, from: self)
        
        return todayDay == dateDay && todayMonth == dateMonth
    }
    
    static var firstHour: Date {
        let date = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: date)
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.day = calendar.component(.day, from: date) - 1
        dateComponents.hour = calendar.component(.hour, from: date)
        dateComponents.minute = 0
        dateComponents.second = 0
        let userCalendar = Calendar.current
        
        return userCalendar.date(from: dateComponents)!
    }
    
    static var midHour: Date {
        let date = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: date)
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.day = calendar.component(.day, from: date) + 1
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        let userCalendar = Calendar.current
        
        return userCalendar.date(from: dateComponents)!
    }
    
    static var lastHour: Date {
        let date = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: date)
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.day = calendar.component(.day, from: date) + 7
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        let userCalendar = Calendar.current
        
        return userCalendar.date(from: dateComponents)!
    }
    
    func previousDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    func nextWeek() -> Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: self)!
    }
    func previousHalfHour() -> Date {
        return Calendar.current.date(byAdding: .minute, value: -30, to: self)!
    }
    func nextHalfHour() -> Date {
        return Calendar.current.date(byAdding: .minute, value: 30, to: self)!
    }
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    func subtracting(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: -minutes, to: self)!
    }
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date().noon)!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date().noon)!
    }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var day: Int {
        return Calendar.current.component(.day,  from: self)
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var stringDate: String {
        return "\(String(self.day).count == 1 ? "0":"")\(self.day)/\(String(self.month).count == 1 ? "0":"")\(self.month)"
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    func toString(with format: DateFormatterPattern) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
    
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
    
}
