import SwiftUI

struct WeeklyCalendarView: View {
    // Enlazamos con el ViewModel para leer/escribir la fecha seleccionada
    @Bindable var viewModel: HomeViewModel
    
    // Namespace para la animación suave de selección (el círculo que se mueve)
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(viewModel.currentWeek, id: \.self) { date in
                let isSelected = viewModel.isSameDate(date, viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                
                VStack(spacing: 6) {
                    // Día de la semana (LUN, MAR...)
                    Text(date.format("E"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(isSelected ? .white : .secondary)
                    
                    // Número del día (24)
                    Text(date.format("d"))
                        .font(.system(size: 16))
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundStyle(isSelected ? .white : (isToday ? .primary : .secondary))
                }
                .frame(width: 45, height: 75)
                .background {
                    // Fondo animado
                    if isSelected {
                        Capsule()
                            .fill(Color(hex: "7F5AF0")) // Tu color principal
                            .matchedGeometryEffect(id: "Shape", in: animation)
                            .shadow(color: Color(hex: "7F5AF0").opacity(0.3), radius: 5, x: 0, y: 5)
                    } else {
                        // Fondo sutil para días no seleccionados
                        Capsule()
                            .fill(.ultraThinMaterial)
                    }
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// Extensión rápida para formatear fechas aquí mismo (para mantener limpio el código)
extension Date {
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current // Usa el idioma del dispositivo
        return formatter.string(from: self).uppercased()
    }
}

#Preview {
    WeeklyCalendarView(viewModel: HomeViewModel())
}
