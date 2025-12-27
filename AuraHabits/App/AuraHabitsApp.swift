import SwiftUI
import SwiftData

@main
struct AuraHabitsApp: App {
    // Guardamos el contenedor en una propiedad para que no se borre
    let container: ModelContainer
    
    init() {
        let groupID = "group.com.AuraHabits"
        
        // Buscamos la carpeta compartida
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            fatalError("❌ No se encontró el App Group. Revisa 'Signing & Capabilities'.")
        }
        
        let databaseURL = url.appendingPathComponent("default.store")
        let config = ModelConfiguration(url: databaseURL)
        
        do {
            // Inicializamos el contenedor
            container = try ModelContainer(for: Habit.self, configurations: config)
        } catch {
            fatalError("❌ Error iniciando base de datos: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
