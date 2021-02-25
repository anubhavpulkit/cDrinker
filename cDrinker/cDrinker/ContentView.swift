//
//  ContentView.swift
//  cDrinker
//
//  Created by Pully on 02/02/21.
//  Copyright © 2021 catalyst. All rights reserved.
//

import UserNotifications
import SwiftUI

struct Texttitle: View {
    var title: String
    var body: some View{
        Text(title)
            .font(.headline).bold()
            .foregroundColor(.orange)
    }
}

struct ContentView: View {
    
    @State private var wakeUp = Date()
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1.0
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var sleeping = ""
    @State private var sleepingHour = 0
    @State private var sleepingMinute = 0
    
    var body: some View {
        
        NavigationView {
            VStack{
                Form{
                    VStack(alignment: .leading, spacing: 5){
                        Section{
                            Texttitle(title: "When you want to wakeup?")
                            
                            DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(WheelDatePickerStyle())
                        }
                        
                        Section{
                            Texttitle(title: "How much you want to Sleep?")
                            
                            Stepper(value: $sleepAmount, in: 4...12.0, step: 0.25){
                                
                                Text("\(sleepAmount, specifier: "%g") Hours")
                            }.padding()
                        }
                        
                        Section{
                            Texttitle(title: "How much Coffee you want to drink")
                            
                            Stepper(value: $coffeeAmount, in: 1...12, step: 1){
                                if coffeeAmount == 1{
                                    Text("\(coffeeAmount, specifier: "%g") cup")
                                }else{
                                    Text("\(coffeeAmount, specifier: "%g") cups")
                                }
                                
                            }.padding()
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                            
                        }
                    }
                }
                Button(action:{
                    calculateBedTime()
                    // Request permission
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    
                    // Schedule Notification
                    let content = UNMutableNotificationContent()
                    content.title = "Go to bed"
                    content.subtitle = "You have to wake up at .So go to bed so you can complete your y number of hour sleep"
                    content.sound = UNNotificationSound.default
                    
                    var date = DateComponents()
                    date.hour = sleepingHour
                    date.minute = 0
                    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request)
                    
                })  {
                    Text("Calculate").font(.headline).fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(40)
                        .padding(.horizontal, 25)
                    
                }
                Text("Sleep at: \(sleeping)")
                    .font(.headline).bold().foregroundColor(.orange)
                    .padding()
                Spacer()
            }
            .navigationBarTitle("cDrinker", displayMode: .inline)
        }
    }
    func calculateBedTime() {
        
        //connect ML model with swift
        let model = SleepCalculator()
        
        // wakeup time
        // We can then request the hour and minute components, and pass in our wake up date.
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        self.showingAlert = true
        
        do {
            // feed our values into Core ML and see what comes out. This wants the wake time, estimated sleep, and coffee amount values required to make a prediction.
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            //  prediction now contains how much sleep they actually need.
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            sleeping = formatter.string(from: sleepTime)
            
            let index = sleeping.firstIndex(of: ":") ?? sleeping.endIndex
            let beginnig = sleeping[..<index]
            
            sleepingHour = Int(beginnig)!
            print(sleepingHour)
            
            alertTitle = "Your Ideal Bedtime is:"
            alertMessage = sleeping
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was problem in calculating your bedtime"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
