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
    @State var is_active: Bool = false //whether or not the data_manager is collecting data
    var data_manager =  DataManager()
    
    @State var participant_id: String = "" //text input string for participant id
    @State var has_participant_id: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Spacer()
            Text("JITAI Health Data Collection");
            Spacer()
            if data_manager.participant_id == nil && has_participant_id == false {
                TextField("Participant ID:", text: $participant_id)
                Button("Save participant id to device", action: save_pid)
            } else if is_active == false {
                Button("Start Collecting", action: start_collecting);
            } else {
                Text("Collecting data...")
                Button("Stop collecting data", action: stop_collecting)
            }
            Spacer()
        }
    }
    
    func start_collecting() {
        is_active = true
        data_manager.start_collecting()
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
