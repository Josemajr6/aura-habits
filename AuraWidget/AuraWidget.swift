import WidgetKit
import SwiftUI
import SwiftData

struct SimpleEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
    let totalCount: Int
}

// --- TRUCO SENIOR: Base de datos estática para evitar desconexiones ---
@MainActor
struct WidgetDataHandler {
    static let sharedContainer: ModelContainer = {
        let groupID = "group.com.AuraHabits"
        
        // Intenta buscar la ruta compartida
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
             // Fallback de seguridad en memoria si falla
             return try! ModelContainer(for: Habit.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
        
        let databaseURL = url.appendingPathComponent("default.store")
        let config = ModelConfiguration(url: databaseURL)
        
        do {
            return try ModelContainer(for: Habit.self, configurations: config)
        } catch {
            print("❌ Error crítico en Widget: \(error)")
            return try! ModelContainer(for: Habit.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
    }()
}
// ---------------------------------------------------------------------

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), habits: [], totalCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), habits: [], totalCount: 0))
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var habits: [Habit] = []
        
        // USAMOS EL CONTENEDOR ESTÁTICO (No crea uno nuevo cada vez)
        let container = WidgetDataHandler.sharedContainer
        
        do {
            // Ordenamos por fecha de creación
            let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
            habits = try container.mainContext.fetch(descriptor)
        } catch {
            print("Widget Fetch Error: \(error)")
        }
        
        // Mostramos los 3 primeros
        let displayHabits = Array(habits.prefix(3))
        let entry = SimpleEntry(date: Date(), habits: displayHabits, totalCount: habits.count)

        // Política .never porque la App fuerza la recarga al guardar
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct AuraWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles").foregroundStyle(.purple)
                Text("Tu Aura").font(.caption).bold().foregroundStyle(.secondary)
                Spacer()
                Text(Date().formatted(.dateTime.weekday().day()))
                    .font(.caption2).foregroundStyle(.tertiary)
            }
            
            if entry.habits.isEmpty {
                Text("Sin hábitos activos").font(.caption).foregroundStyle(.secondary)
            } else {
                VStack(spacing: 6) {
                    ForEach(entry.habits) { habit in
                        HStack {
                            Image(systemName: habit.iconSymbol)
                                .font(.caption2)
                                .foregroundStyle(Color(hex: habit.hexColor))
                                .frame(width: 16)
                            
                            Text(habit.title)
                                .font(.caption)
                                .lineLimit(1)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if habit.isCompleted(on: Date()) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: habit.hexColor))
                                    .font(.caption)
                            } else {
                                Circle().stroke(.secondary.opacity(0.3), lineWidth: 1)
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                }
            }
            
            if entry.totalCount > 3 {
                Spacer()
                Text("+\(entry.totalCount - 3) más...")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(for: .widget) { Color(uiColor: .systemBackground) }
        // Pasamos el contenedor a la vista también para evitar fallos de renderizado
        .modelContainer(WidgetDataHandler.sharedContainer)
    }
}

struct AuraWidget: Widget {
    let kind: String = "AuraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AuraWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Resumen Diario")
        .description("Mira el progreso de tu aura.")
        // 👇 ESTO ARREGLA EL ERROR DEL SIMULADOR (Code=3)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
