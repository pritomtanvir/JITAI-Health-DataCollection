//
//  JITAI_Health_DataCollectionApp.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/16/23.
//

import SwiftUI
import CoreData
import WatchKit

@main
struct JITAI_Health_DataCollection_Watch_AppApp: App {
    let wk_interface = WKInterfaceDevice()
    
    @State var is_active: Bool = true //whether or not the data_manager is collecting data
    var data_manager =  DataManager()
    
    @State var participant_id: String = "" //text input string for participant id
    @State var has_participant_id: Bool = false
    
    let date_update_timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let time_format = Date.FormatStyle().hour().minute(.twoDigits)
    let date_format = Date.FormatStyle().month(.abbreviated).day()
    @State var date_string = ""
    @State var time_string = ""
        
    var body: some Scene {
        WindowGroup {
            HStack {
                Image("Walkitlogitlogo").resizable().frame(width: 35.0, height: 35.0, alignment: .topLeading).clipShape(Circle())
                Spacer().scaledToFit()
                if wk_interface.isBatteryMonitoringEnabled != true {
                    Text(String(Int(wk_interface.batteryLevel * 100)) + "%").foregroundColor(
                        wk_interface.batteryLevel >= 0.5 ? Color.green : (wk_interface.batteryLevel >= 0.2 ? Color.orange : Color.red)
                    )
                }
            }
            Spacer()
            if data_manager.participant_id == nil && has_participant_id == false {
                TextField("Participant ID:", text: $participant_id)
                Button("Save participant id to device", action: save_pid)
            } else {
                Text(time_string)
                    .font(.title)
                    .onReceive(date_update_timer) { _ in
                    self.time_string = Date().formatted(time_format)
                    self.date_string = Date().formatted(date_format)
                }
                Text(date_string).font(Font.subheadline)
                if is_active == false {
                    //Button("Start Collecting", action: start_collecting)
                } else {
                    //Button("Stop collecting data", action: stop_collecting)
                }
                Spacer()
            }
        }
    }
    
    func start_collecting() {
        is_active = true
        data_manager.start_collecting()
        self.date_string = Date().formatted(date_format)
        self.time_string = Date().formatted(time_format)
    }
    
    func stop_collecting() {
        is_active = false
        data_manager.stop_collecting()
    }
    
    func save_pid() {
        data_manager.save_participant_id(participant_id)
        self.has_participant_id = true
    }
    
}
