//
//  NotificationManager.swift
//  AuraHabits
//
//  Created by José Manuel Jiménez Rodríguez on 24/12/25.
//


import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager() // Singleton
    
    // 1. Pedir permiso
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // 2. Programar notificación
    func scheduleNotification(for habit: Habit) {
        // Primero borramos si ya existía para no duplicar
        removeNotification(for: habit)
        
        guard habit.isReminderOn else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "✨ Momento de tu Aura"
        content.body = "Es hora de: \(habit.title)"
        content.sound = .default
        
        // Extraemos hora y minuto
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: habit.reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Usamos el ID del hábito para identificar la notificación
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // 3. Cancelar notificación (si borramos el hábito o apagamos el recordatorio)
    func removeNotification(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
}
