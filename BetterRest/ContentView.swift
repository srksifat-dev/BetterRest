//
//  ContentView.swift
//  BetterRest
//
//  Created by Md. Shoibur Rahman Khan Sifat on 10/2/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeUp
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeUp: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components)!
    }
    var body: some View {
        NavigationStack {
            
            Form{
                    VStack(alignment: .leading,spacing: 0){
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp,displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    VStack(alignment: .leading,spacing: 0){
                        Text("Desire amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted(.number))",value: $sleepAmount, in: 4...12,step: 0.25)
                    }
                    VStack(alignment: .leading,spacing: 0){
                        
                        Text("Daily coffee intake")
                            .font(.headline)
                        Stepper("^[\(coffeeAmount) cup](inflect:true)",value: $coffeeAmount, in: 0...10,step: 1)
                    }
                HStack(alignment: .center){
                    Button("Calculate Bedtime"){
                        calculateBedtime()
                    }
                    
                }
                    
                
            }
            .navigationTitle("BetterRest")
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertTitle,isPresented: $showingAlert){
                Button("OK"){
                    
                }
            }message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepTime.formatted(date:.omitted,time: .shortened)
        }catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an error calculating your bedtime."
        }
        showingAlert = true
    }
}

//#Preview {
//    ContentView()
//}
