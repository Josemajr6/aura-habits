import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let selectedDate: Date
    let onToggle: () -> Void
    
    @State private var confettiCounter = 0
    @State private var isPressing = false // Para el efecto de presión
    
    private var isCompleted: Bool {
        habit.isCompleted(on: selectedDate)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono con animación de escala
            ZStack {
                Circle()
                    .fill(Color(hex: habit.hexColor).opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: habit.iconSymbol)
                    .foregroundStyle(Color(hex: habit.hexColor))
                    .font(.system(size: 20, weight: .semibold))
                    .scaleEffect(isCompleted ? 1.2 : 1.0) // Crece un poco al completarse
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                let streak = habit.calculateStreak()
                Text("Racha actual: \(streak) \(streak == 1 ? "día" : "días")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText(value: Double(streak)))
            }
            
            Spacer()
            
            // Checkbox con Feedback Háptico
            Button(action: {
                handleToggle()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 30))
                    .foregroundStyle(isCompleted ? Color(hex: habit.hexColor) : .gray.opacity(0.3))
                    .contentTransition(.symbolEffect(.replace)) // Animación de iOS 17
            }
            .buttonStyle(.plain)
            .confetti(counter: $confettiCounter)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(isPressing ? 0.02 : 0.05), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isPressing ? 0.98 : 1.0) // Efecto de hundimiento al tocar
        .padding(.horizontal)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation { isPressing = pressing }
        }, perform: {})
    }
    
    // Lógica mejorada con vibración
    private func handleToggle() {
        if !isCompleted {
            // Vibración de "Éxito" (tres toques rápidos)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            confettiCounter += 1
        } else {
            // Vibración ligera para desmarcar
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        // Retraso para que la animación se vea fluida
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onToggle()
        }
    }
}
