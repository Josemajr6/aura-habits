import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var selectedDate: Date = Date()
    var currentWeek: [Date] = []
    
    init() {
        fetchCurrentWeek()
    }
    
    // Genera los días de la semana actual
    func fetchCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        
        // Buscamos el inicio de la semana actual
        // startOfWeek dependerá de la región (domingo en US, lunes en EU)
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }
        
        // Generamos los 7 días
        (0..<7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                currentWeek.append(weekday)
            }
        }
    }
    
    // Lógica para marcar/desmarcar en cualquier fecha
    func toggleHabit(_ habit: Habit, context: ModelContext) {
            let calendar = Calendar.current
            
            // Buscamos si ya existe la fecha seleccionada
            if let index = habit.completedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: selectedDate) }) {
                // Si existe, borramos (Desmarcar)
                habit.completedDates.remove(at: index)
            } else {
                // Si no existe, añadimos la fecha seleccionada
                // Esto asegura que guardamos el día que estás mirando, no "ahora mismo"
                habit.completedDates.append(selectedDate)
            }
    }
    
    // Función auxiliar para saber si es el día seleccionado
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
