//
//  ContentView.swift
//  cDrinker
//
//  Created by Pully on 02/02/21.
//  Copyright © 2021 catalyst. All rights reserved.
//

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
    var body: some View {

    NavigationView {
        VStack{
            Texttitle(title: "When you want to wakeup?")
           
            DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
            .labelsHidden()

            Texttitle(title: "How much you want to Sleep?")
            
            Stepper(value: $sleepAmount, in: 4...12.0, step: 0.25){
                
                Text("\(sleepAmount, specifier: "%g") Hours")
            }.padding()
            
            Texttitle(title: "How much Coffee you want to drink")
            
            Stepper(value: $coffeeAmount, in: 1...8, step: 1){
                if coffeeAmount == 1{
                    Text("\(coffeeAmount, specifier: "%g") cup")
                }else{
                   Text("\(coffeeAmount, specifier: "%g") cups")
                }
            }.padding()
      }
        .navigationBarTitle("cDrinker", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: calculateBedTime) {
                Text("Calculate")
            }
        )

        }
  }
    func calculateBedTime() {
        print("Button is pushed")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
