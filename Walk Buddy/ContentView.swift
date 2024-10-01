//
//  ContentView.swift
//  Walk Buddy
//
//  Created by Kareem Abdelhalem on 9/30/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isFlashing = false
    @State private var flashOn = false
    @State private var timer: Timer?
    @State private var flashSpeed: Double = 0.5
    @State private var backgroundColor: Color = .black
    @State private var shouldFlashScreen = true

    var body: some View {
        ZStack {
            if shouldFlashScreen {
                backgroundColor
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }

            VStack {
                VStack {
                    Button(action: toggleFlash) {
                        Text(isFlashing ? "Stop Flashing" : "Start Flashing")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(isFlashing ? Color.red : Color.green)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .scaleEffect(isFlashing ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isFlashing)
                    }
                    .padding()

                    VStack(spacing: 10) {
                        Text("Flash Speed: \(String(format: "%.2f", flashSpeed))s")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Slider(value: $flashSpeed, in: 0.1...2.0, step: 0.1)
                            .padding()
                            .accentColor(.yellow)
                            .onChange(of: flashSpeed) {
                                if isFlashing {
                                    startFlashing()
                                }
                            }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .shadow(radius: 5)

                    Toggle(isOn: $shouldFlashScreen) {
                        Text("Enable Screen Flashing")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .background(Color.black)
                .cornerRadius(15)
                .padding()
            }
        }
    }

    func toggleFlash() {
            isFlashing.toggle()
            
            if isFlashing {
                startFlashing()
            } else {
                stopFlashing()
            }
        }

        func startFlashing() {
            timer?.invalidate()

            timer = Timer.scheduledTimer(withTimeInterval: flashSpeed, repeats: true) { _ in
                toggleFlashlight()
            }
        }

        func stopFlashing() {
            timer?.invalidate()
            timer = nil
            toggleTorch(on: false)
            backgroundColor = .black

        }

        func toggleFlashlight() {
            flashOn.toggle()
            toggleTorch(on: flashOn)
            toggleBackgroundColor(on: flashOn)
        }

        func toggleTorch(on: Bool) {
            guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
            
            do {
                try device.lockForConfiguration()
                if on {
                    try device.setTorchModeOn(level: 1.0)
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }
    
    func toggleBackgroundColor(on: Bool) {
            backgroundColor = on ? .white : .black
        }
}

#Preview {
    ContentView()
}
