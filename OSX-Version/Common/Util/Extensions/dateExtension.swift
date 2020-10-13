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
    var day : Int {
        let calendar = Calendar.current
        let dia = calendar.component(.day, from: self)
        
        return dia
    }
    var month : Int {
        let calendar = Calendar.current
        let mes = calendar.component(.month, from: self)
        
        return mes
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

func calcularEdad( Nacimiento: Date) -> Int{
    let hoy = Date()
    
    let calendar : NSCalendar = NSCalendar.current as NSCalendar
    let ageComponents = calendar.components(.year, from: Nacimiento, to: hoy, options: [])
    let age = ageComponents.year!
    
    return age
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
