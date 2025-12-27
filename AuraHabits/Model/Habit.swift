import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var title: String
    var iconSymbol: String
    var hexColor: String
    var createdAt: Date
    var completedDates: [Date]
    var isReminderOn: Bool
    var reminderTime: Date
    
    // Inicializador
    init(title: String, iconSymbol: String = "star.fill", hexColor: String = "7F5AF0", isReminderOn: Bool = false, reminderTime: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.iconSymbol = iconSymbol
        self.hexColor = hexColor
        self.createdAt = Date()
        self.completedDates = []
        self.isReminderOn = isReminderOn
        self.reminderTime = reminderTime
    }
    
    // Comprobación estricta ignorando horas
    func isCompleted(on date: Date) -> Bool {
        let calendar = Calendar.current
        return completedDates.contains { completedDate in
            calendar.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    // Lógica de Racha a prueba de balas
    func calculateStreak() -> Int {
        let calendar = Calendar.current
        
        // Normalizamos todas las fechas al inicio del día (00:00) y eliminamos duplicados
        let completedDays = Set(completedDates.map { calendar.startOfDay(for: $0) })
        
        if completedDays.isEmpty { return 0 }
        
        // Definimos hitos temporales
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Si no se completó ni hoy ni ayer, la racha es 0
        let lastDate = completedDays.sorted().last!
        if lastDate < yesterday { return 0 }
        
        // Empezamos a contar desde el último día completado hacia atrás
        var streak = 0
        var dateToCheck = lastDate
        
        while completedDays.contains(dateToCheck) {
            streak += 1
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: dateToCheck) else { break }
            dateToCheck = nextDate
        }
        
        return streak
    }
}
