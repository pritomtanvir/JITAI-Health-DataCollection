//
//  JITAI_Health_DataCollectionApp.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/16/23.
//

import SwiftUI
import CoreData

@main
struct JITAI_Health_DataCollection_Watch_AppApp: App {
    @State var is_active: Bool = false
    var data_manager =  DataManager()
    
    var body: some Scene {
        WindowGroup {
            Spacer()
            Text("JITAI Health Data Collection");
            Spacer()
            if is_active == false {
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
    
}
