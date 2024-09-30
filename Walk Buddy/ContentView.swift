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
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                            .background(isFlashing ? Color.red : Color.green)
                            .cornerRadius(10)
                    }
                    .padding()

                    VStack {
                        Text("Flash Speed: \(String(format: "%.2f", flashSpeed))s")
                            .padding(.top, 20)
                            .foregroundColor(.white)  // Keep text white on black background
                        
                        Slider(value: $flashSpeed, in: 0.1...2.0, step: 0.1)
                            .padding()
                    }

                    Toggle(isOn: $shouldFlashScreen) {
                        Text("Enable Screen Flashing")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding(.all, 20)
                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
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
