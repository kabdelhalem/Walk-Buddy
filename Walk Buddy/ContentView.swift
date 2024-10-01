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
    @State private var isPanicMode = false
    @State private var flashOn = false
    @State private var timer: Timer?
    @State private var flashSpeed: Double = 0.5
    @State private var backgroundColor: Color = .black
    @State private var shouldFlashScreen = true
    @State private var isLoading = true

    // Use @AppStorage to persist the emergency contact
    @AppStorage("emergencyContact") var emergencyContact: String = "1234567890"
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                TabView {
                    panicModeScreen
                        .tabItem {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Walk Buddy")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
    
    var panicModeScreen: some View {
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
                    // Flash button
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

                    Button(action: togglePanicMode) {
                        Text(isPanicMode ? "Deactivate Panic Mode" : "Activate Panic Mode")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPanicMode ? Color.red : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
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
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            print("Torch is not available on this device")
            return
        }
        
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error.localizedDescription)")
        }
    }

    func toggleBackgroundColor(on: Bool) {
        backgroundColor = on ? .white : .black
    }
    
    func togglePanicMode() {
        isPanicMode.toggle()

        if isPanicMode {
            print("Panic mode activated")
            startFlashing()
            playAlarmSound()

            sendMessage()
        } else {
            print("Panic mode deactivated")
            stopFlashing()
            stopAlarmSound()
        }
    }

    func playAlarmSound() {
        let systemSoundID: SystemSoundID = 1005
        AudioServicesPlaySystemSound(systemSoundID)
    }

    func stopAlarmSound() {
    }

    func sendMessage() {
        let message = "Emergency! I need help."

        let urlString = "sms:\(emergencyContact)?body=\(message)"
        
        print("Generated URL: \(urlString)")
        
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    if success {
                        print("iMessage opened successfully")
                    } else {
                        print("Failed to open iMessage")
                    }
                })
            } else {
                print("iMessage cannot be opened on this device")
            }
        } else {
            print("Invalid URL")
        }
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SettingsView: View {
    @AppStorage("emergencyContact") var emergencyContact: String = "1234567890"
    @State private var newContact: String = ""
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                Text("Emergency Contact Settings")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                TextField("Enter Emergency Contact", text: $newContact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()

                Button(action: {
                    if !newContact.isEmpty {
                        emergencyContact = newContact
                    }
                    UIApplication.shared.hideKeyboard()
                }) {
                    Text("Save Contact")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
