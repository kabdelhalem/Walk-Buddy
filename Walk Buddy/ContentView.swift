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

    // Use @AppStorage to persist the emergency contact
    @AppStorage("emergencyContact") var emergencyContact: String = "1234567890"
    
    var body: some View {
        TabView {
            // Panic Mode Screen
            panicModeScreen
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Walk Buddy")
                }
            
            // Settings Screen
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
    
    // The Panic Mode Screen
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

                    // Panic Mode Button
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

    // Toggle flash and panic mode
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
        // Get the default device that supports video capture (usually the back camera)
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            print("Torch is not available on this device")
            return
        }
        
        do {
            try device.lockForConfiguration() // Lock the device configuration for changes
            if on {
                try device.setTorchModeOn(level: 1.0) // Turn on the torch with full brightness
            } else {
                device.torchMode = .off // Turn off the torch
            }
            device.unlockForConfiguration() // Unlock configuration
        } catch {
            print("Torch could not be used: \(error.localizedDescription)") // Handle errors
        }
    }

    func toggleBackgroundColor(on: Bool) {
        backgroundColor = on ? .white : .black
    }
    
    // Panic Mode Functions
    func togglePanicMode() {
        isPanicMode.toggle()

        if isPanicMode {
            // Enable strobe light, play sound, and send message
            print("Panic mode activated")
            startFlashing()
            playAlarmSound()

            // Send basic emergency message
            sendMessage()
        } else {
            print("Panic mode deactivated")
            stopFlashing()
            stopAlarmSound()
        }
    }

    func playAlarmSound() {
        let systemSoundID: SystemSoundID = 1005 // Change to any loud alarm sound ID
        AudioServicesPlaySystemSound(systemSoundID)
    }

    func stopAlarmSound() {
        // Implement stop alarm sound logic
    }

    func sendMessage() {
        // Use the customized emergency contact
        let message = "Emergency! I need help."

        // Prepare the URL with proper URL encoding
        let urlString = "sms:\(emergencyContact)?body=\(message)"
        
        print("Generated URL: \(urlString)")  // Log the generated URL
        
        // URL encoding to handle spaces and special characters
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            // Ensure the device can open the iMessage URL scheme
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

// Settings View for customizing emergency contact
struct SettingsView: View {
    @AppStorage("emergencyContact") var emergencyContact: String = "1234567890"
    @State private var newContact: String = ""
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea() // Ensures the background covers the entire screen

            VStack {
                Text("Emergency Contact Settings")
                    .font(.largeTitle)
                    .foregroundColor(.white) // Set text color to white for visibility
                    .padding()

                TextField("Enter Emergency Contact", text: $newContact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()

                Button(action: {
                    // Update emergency contact
                    if !newContact.isEmpty {
                        emergencyContact = newContact
                    }
                    // Hide the keyboard
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
