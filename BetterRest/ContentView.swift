//
//  ContentView.swift
//  BetterRest
//
//  Created by MaćKo on 01/04/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0

        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }

                Section("Daily coffee intake") {
//                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)

                    Picker("Daily coffee intake", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                }

                let (title, message) = calculateBedtime()
                Section(title) {
                    Text(message)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                }
            }
            .navigationTitle("BetterRest")
        }
    }

    func calculateBedtime() -> (title: String, message: String) {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 3600
            let minuteInSeconds = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Int64(hourInSeconds + minuteInSeconds), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep

            return (title: "Your ideal bedtime is...", message: sleepTime.formatted(date: .omitted, time: .shortened))
        } catch {
            return (title: "Error", message: "Sorry, there was a problem calculating your bedtime.")
        }
    }
}

#Preview {
    ContentView()
}
