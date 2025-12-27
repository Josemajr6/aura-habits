import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    //  Leemos la variable del Onboarding
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]
    
    var body: some View {
        // Si ya vio el tutorial, mostramos la App. Si no, el Onboarding.
        if hasSeenOnboarding {
            MainAppView()
                .transition(.opacity)
        } else {
            OnboardingView()
        }
    }
    
    // Vista principal con Pestañas
    @ViewBuilder
    func MainAppView() -> some View {
        TabView {
            // Hábitos
            HabitListView(habits: habits, modelContext: modelContext)
                .tabItem {
                    Label("Hábitos", systemImage: "checklist")
                }
            
            // Estadísticas
            StatsView(habits: habits)
                .tabItem {
                    Label("Progreso", systemImage: "chart.bar.xaxis")
                }
        }
        .tint(Color(hex: "7F5AF0"))
        .preferredColorScheme(.none) // Permite que el sistema decida (Auto Dark Mode)
    }
}

// SUBVISTA DE LA LISTA DE HÁBITOS (Para mantener orden)
struct HabitListView: View {
    var habits: [Habit]
    var modelContext: ModelContext
    
    @State private var viewModel = HomeViewModel()
    @State private var showCreateSheet = false
    
    private var dateHeaderTitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(viewModel.selectedDate) {
            return "Hoy"
        } else if calendar.isDateInYesterday(viewModel.selectedDate) {
            return "Ayer"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE d"
            formatter.locale = Locale(identifier: "es_ES")
            return formatter.string(from: viewModel.selectedDate).capitalized
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        NotificationManager.shared.removeNotification(for: habit)
        withAnimation {
            modelContext.delete(habit)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    WeeklyCalendarView(viewModel: viewModel)
                        .padding(.top)
                    
                    HStack {
                        Text(dateHeaderTitle)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if habits.isEmpty {
                        ContentUnavailableView(
                            "Tu aura está vacía",
                            systemImage: "sparkles",
                            description: Text("Crea tu primer hábito pulsando el +")
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCardView(
                                    habit: habit,
                                    selectedDate: viewModel.selectedDate
                                ) {
                                    viewModel.toggleHabit(habit, context: modelContext)
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteHabit(habit)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .id(viewModel.selectedDate)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Aura Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color(hex: "7F5AF0"))
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateHabitView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}
