import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    var habits: [Habit]
    
    // Propiedad para capturar la vista y compartirla
    @State private var chartImage: Image?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rendimiento")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                Text("Últimos 7 días")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            
                            // BOTÓN DE COMPARTIR
                            ShareLink(item: renderImage(), preview: SharePreview("Mis Logros en Aura", image: renderImage())) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(Color(hex: "7F5AF0"))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Chart {
                            ForEach(getLast7Days(), id: \.date) { item in
                                // Área sombreada debajo de la línea
                                AreaMark(
                                    x: .value("Día", item.dayName),
                                    y: .value("Completados", item.count)
                                )
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [Color(hex: "7F5AF0").opacity(0.4), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom) // Curvas suaves
                                
                                // Línea principal
                                LineMark(
                                    x: .value("Día", item.dayName),
                                    y: .value("Completados", item.count)
                                )
                                .foregroundStyle(Color(hex: "7F5AF0"))
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                                .interpolationMethod(.catmullRom)
                                
                                // Puntos destacados
                                PointMark(
                                    x: .value("Día", item.dayName),
                                    y: .value("Completados", item.count)
                                )
                                .foregroundStyle(.white)
                                .symbolSize(60)
                                .annotation(position: .top) {
                                    if item.count > 0 {
                                        Text("\(item.count)")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .padding(5)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                        .frame(height: 250)
                        .chartYAxis(.hidden) // Limpiamos ejes para look minimalista
                        .chartXAxis {
                            AxisMarks { value in
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                        }
                    }
                    .padding(25)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.1), lineWidth: 1))
                    
                    // TARJETAS DE ESTADÍSTICAS MEJORADAS
                    HStack(spacing: 15) {
                        ModernStatCard(
                            title: "Total",
                            value: "\(totalCompletions)",
                            icon: "checkmark.seal.fill",
                            topColor: .blue
                        )
                        
                        ModernStatCard(
                            title: "Racha",
                            value: "\(bestStreak)",
                            unit: "días",
                            icon: "flame.fill",
                            topColor: .orange
                        )
                    }
                    
                    // TARJETA DE "CONSEJO DEL DÍA"
                    HStack(spacing: 15) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("Mantener una racha de 3 días aumenta un 40% la probabilidad de éxito.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding()
            }
            .navigationTitle("Tu Progreso")
            .background(
                ZStack {
                    Color(uiColor: .systemGroupedBackground)
                    // Orbes de color estéticos
                    Circle()
                        .fill(Color(hex: "7F5AF0").opacity(0.1))
                        .frame(width: 400)
                        .offset(x: -150, y: -200)
                        .blur(radius: 100)
                }
                .ignoresSafeArea()
            )
        }
    }
    
    // LÓGICA DE DATOS
    struct DailyData {
        let date: Date
        let dayName: String
        let count: Int
    }
    
    func getLast7Days() -> [DailyData] {
        let calendar = Calendar.current
        return (0...6).reversed().map { i in
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let count = habits.filter { $0.isCompleted(on: date) }.count
            let dayName = date.format("EEEEE")
            return DailyData(date: date, dayName: dayName, count: count)
        }
    }
    
    var totalCompletions: Int { habits.reduce(0) { $0 + $1.completedDates.count } }
    var bestStreak: Int { habits.map { $0.calculateStreak() }.max() ?? 0 }

    // FUNCIÓN PARA GENERAR IMAGEN DE COMPARTIR
    @MainActor
    func renderImage() -> Image {
        let renderer = ImageRenderer(content: ShareCardView(total: totalCompletions, streak: bestStreak))
        renderer.scale = 3.0 // Alta resolución
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }
}

// COMPONENTE DE TARJETA ESTADÍSTICA
struct ModernStatCard: View {
    let title: String
    let value: String
    var unit: String = ""
    let icon: String
    let topColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 45, height: 45)
                .background(topColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 6)
                    }
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(.white.opacity(0.1), lineWidth: 1))
    }
}

// VISTA QUE SE CONVIERTE EN IMAGEN PARA COMPARTIR
struct ShareCardView: View {
    let total: Int
    let streak: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(Color(hex: "7F5AF0"))
            
            Text("MI PROGRESO EN AURA")
                .font(.system(size: 12, weight: .black))
                .tracking(2)
            
            HStack(spacing: 40) {
                VStack {
                    Text("\(total)").font(.system(size: 40, weight: .bold))
                    Text("TOTAL").font(.caption2).bold()
                }
                VStack {
                    Text("\(streak)").font(.system(size: 40, weight: .bold))
                    Text("RACHA").font(.caption2).bold()
                }
            }
        }
        .padding(40)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .frame(width: 300, height: 300)
    }
}
