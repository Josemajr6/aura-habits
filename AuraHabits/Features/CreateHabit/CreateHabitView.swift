import SwiftUI
import SwiftData
import WidgetKit

struct CreateHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // Estados del formulario
    @State private var title: String = ""
    @State private var selectedColor: String = "7F5AF0"
    @State private var selectedIcon: String = "star.fill"
    
    // Estados para Notificaciones
    @State private var isReminderOn: Bool = false
    @State private var reminderDate: Date = Date()
    
    // Datos visuales
    let colors: [String] = ["7F5AF0", "2CB67D", "E45858", "F2C94C", "3DA9FC", "FF8C42"]
    let icons: [String] = ["star.fill", "flame.fill", "drop.fill", "figure.run", "book.fill", "moon.fill", "heart.fill", "leaf.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                // Nombre
                Section {
                    TextField("Ej. Leer 15 minutos", text: $title)
                } header: {
                    Text("Nombre")
                }
                
                // Apariencia
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle().stroke(Color.primary, lineWidth: selectedColor == hex ? 3 : 0)
                                    )
                                    .onTapGesture { withAnimation { selectedColor = hex } }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColor) : .gray)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.15) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .onTapGesture { withAnimation { selectedIcon = icon } }
                        }
                    }
                    .padding(.vertical, 5)
                } header: {
                    Text("Apariencia")
                }
                
                // Notificaciones
                Section {
                    Toggle("Activar Recordatorio", isOn: $isReminderOn)
                        .tint(Color(hex: selectedColor))
                        .onChange(of: isReminderOn) { _, newValue in
                            if newValue {
                                NotificationManager.shared.requestAuthorization()
                            }
                        }
                    
                    if isReminderOn {
                        DatePicker("Hora", selection: $reminderDate, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Notificaciones")
                }
            }
            .navigationTitle("Nuevo Hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") { saveHabit() }
                        .disabled(title.isEmpty)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveHabit() {
        let newHabit = Habit(
            title: title,
            iconSymbol: selectedIcon,
            hexColor: selectedColor,
            isReminderOn: isReminderOn,
            reminderTime: reminderDate
        )
        
        modelContext.insert(newHabit)
        
        // Programamos notificación
        NotificationManager.shared.scheduleNotification(for: newHabit)
        
        // Actualizar widget cuando se crea
        WidgetCenter.shared.reloadAllTimelines()
        
        dismiss()
    }
}
