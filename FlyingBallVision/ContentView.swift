//
//  ContentView.swift
//  FlyingBallVision
//
//  Created by Fatom on 2025-10-22.
//

import SwiftUI
import RealityKit
import Combine

struct ContentView: View {
    @State private var cancellable: AnyCancellable?

    var body: some View {
        RealityView { scene in
            // Create a red ball
            let ball = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )

            // Start position: half a meter in front of user
            ball.transform.translation = SIMD3<Float>(0, 0, -0.5)

            // Collision so it interacts with real-world geometry
            ball.generateCollisionShapes(recursive: false)

            // Dynamic physics with friction and bounciness
            let physicsMaterial = PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.8)
            ball.components.set(PhysicsBodyComponent(
                massProperties: .default,
                material: physicsMaterial,
                mode: .dynamic
            ))

            // Initial linear velocity
            ball.components.set(PhysicsMotionComponent(
                linearVelocity: SIMD3<Float>(0.25, 0.2, 0.15),
                angularVelocity: .zero
            ))

            // Add the ball to the scene
            scene.add(ball)

            // Timer to occasionally nudge the ball so motion stays lively
            cancellable = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    guard let motion = ball.components[PhysicsMotionComponent.self] else { return }
                    var linear = motion.linearVelocity

                    // Small random nudge
                    if Bool.random(), Float.random(in: 0...1) > 0.995 {
                        linear += SIMD3<Float>(
                            Float.random(in: -0.03...0.03),
                            Float.random(in: -0.03...0.03),
                            Float.random(in: -0.03...0.03)
                        )

                        ball.components.set(PhysicsMotionComponent(
                            linearVelocity: linear,
                            angularVelocity: motion.angularVelocity
                        ))
                    }
                }

        }
        .edgesIgnoringSafeArea(.all)
        .onDisappear {
            // Cancel timer when view disappears
            cancellable?.cancel()
            cancellable = nil
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}

