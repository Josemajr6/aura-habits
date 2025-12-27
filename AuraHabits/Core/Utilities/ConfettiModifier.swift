//
//  ConfettiModifier.swift
//  AuraHabits
//
//  Created by José Manuel Jiménez Rodríguez on 24/12/25.
//


import SwiftUI

struct ConfettiModifier: ViewModifier {
    @Binding var counter: Int
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if counter > 0 {
                ForEach(0..<20, id: \.self) { _ in
                    ConfettiParticle()
                }
            }
        }
    }
}

struct ConfettiParticle: View {
    @State private var location = CGPoint(x: 0.5, y: 0.5)
    @State private var opacity: Double = 1.0
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        Circle()
            .fill(colors.randomElement()!)
            .frame(width: 8, height: 8)
            .modifier(ParticlesGeometryEffect(time: 1.0))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                }
            }
    }
}

struct ParticlesGeometryEffect: GeometryEffect {
    var time: Double
    var speed = Double.random(in: 50...200)
    var direction = Double.random(in: -Double.pi...Double.pi)
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation = CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}

// Extensión para usarlo fácil
extension View {
    func confetti(counter: Binding<Int>) -> some View {
        self.modifier(ConfettiModifier(counter: counter))
    }
}