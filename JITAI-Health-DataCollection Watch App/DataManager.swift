//
//  DataManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/17/23.
//

import Foundation

class DataManager {
    let geoloc_manager = GeoLocationManager()
    let motion_manager = MotionManager()
    
    var report_timer: Timer?
    
    
    init() {
        report_timer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(report_data),
            userInfo: nil, repeats: true
        )
    }
    
    
    @objc func report_data(_ timer: Timer) {
        self.geoloc_manager.writeLocationData()
        
        self.motion_manager.getMotionData()
        
    }
}
