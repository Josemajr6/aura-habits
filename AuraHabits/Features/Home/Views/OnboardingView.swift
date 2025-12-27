import SwiftUI

struct OnboardingView: View {
    // Variable persistente para saber si ya completó el tutorial
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    // Estado de la página actual
    @State private var currentPage = 0
    
    // Estados para animaciones
    @State private var isAnimating = false
    
    // Colores base para las transiciones de fondo
    let pageColors: [Color] = [
        Color(hex: "7F5AF0"),
        Color.blue,
        Color.orange
    ]
    
    var body: some View {
        ZStack {
            // 1. FONDO ANIMADO "LAVALAMP"
            // Cambia de color suavemente según la página
            GeometryReader { proxy in
                let size = proxy.size
                
                ZStack {
                    // Blob 1: Color principal
                    Circle()
                        .fill(pageColors[currentPage].gradient)
                        .frame(width: size.width * 1.5, height: size.width * 1.5)
                        .offset(x: isAnimating ? -100 : 100, y: isAnimating ? -150 : -50)
                        .blur(radius: 80)
                    
                    // Blob 2: Color secundario (blanco/brillo)
                    Circle()
                        .fill(.white.opacity(0.4))
                        .frame(width: size.width, height: size.width)
                        .offset(x: isAnimating ? 150 : -50, y: isAnimating ? 100 : 250)
                        .blur(radius: 60)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemBackground)) // Fondo base
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: isAnimating)
            .animation(.smooth(duration: 0.6), value: currentPage) // Transición de color al cambiar página
            
            // 2. CONTENIDO PRINCIPAL
            VStack(spacing: 0) {
                // ÁREA SUPERIOR: ICONOS FLOTANTES
                TabView(selection: $currentPage) {
                    OnboardingPageContent(
                        image: "sparkles",
                        title: "Bienvenido a Aura",
                        subtitle: "Tu espacio sagrado para construir la mejor versión de ti mismo."
                    )
                    .tag(0)
                    
                    OnboardingPageContent(
                        image: "checklist",
                        title: "Crea Hábitos",
                        subtitle: "Define tus metas diarias con estilo. Desde leer 10 minutos hasta beber agua."
                    )
                    .tag(1)
                    
                    OnboardingPageContent(
                        image: "chart.bar.xaxis",
                        title: "Visualiza tu Éxito",
                        subtitle: "Analiza tu rendimiento y celebra cada racha con gráficas detalladas."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Ocultamos los puntos por defecto
                .frame(height: 500) // Altura fija para la parte visual
                
                Spacer()
                
                // Estilos
                VStack(spacing: 25) {
                    // Indicadores de página personalizados
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Capsule()
                                .fill(currentPage == index ? pageColors[currentPage] : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 20 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Botón Principal
                    Button(action: nextAction) {
                        Text(currentPage == 2 ? "Comenzar Aventura" : "Siguiente")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [pageColors[currentPage], pageColors[currentPage].opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: pageColors[currentPage].opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle()) // Efecto de rebote al pulsar
                }
                .padding(30)
                .background(.ultraThinMaterial) // EFECTO CRISTAL
                .clipShape(RoundedRectangle(cornerRadius: 35, style: .continuous))
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Inicia la animación de los blobs de fondo
            isAnimating = true
        }
    }
    
    // Lógica del botón
    private func nextAction() {
        // Haptic Feedback (Vibración suave)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if currentPage < 2 {
                currentPage += 1
            } else {
                hasSeenOnboarding = true
            }
        }
    }
}


struct OnboardingPageContent: View {
    let image: String
    let title: String
    let subtitle: String
    
    @State private var isFloating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icono con efecto Aura y flotación
            ZStack {
                // Brillo detrás
                Circle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)
                
                Image(systemName: image)
                    .font(.system(size: 100))
                    .foregroundStyle(.primary.opacity(0.8))
                    .symbolEffect(.bounce, options: .nonRepeating, value: isFloating)
            }
            .offset(y: isFloating ? -10 : 10) // Animación de flotar arriba/abajo
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
            
            // Textos
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
        }
    }
}

// Estilo de botón con rebote
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Vista previa
#Preview {
    OnboardingView()
}
