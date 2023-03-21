//
//  DataManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/17/23.
//

import Foundation


//This class holds instances of each manager that collects required data
class DataManager {
    
    let update_interval: TimeInterval = 1
    
    //data collection objects
    let geoloc_manager = GeoLocationManager()
    let motion_manager: MotionManager
    let health_manager = HealthManager()
    
    //Controls the rate at which data is fetched from each manager
    var report_timer: Timer?
    
    
    init() {
        motion_manager = MotionManager(update_interval: update_interval)
        report_timer = Timer.scheduledTimer(
            timeInterval: update_interval, target: self,
            selector: #selector(fetch_data),
            userInfo: nil, repeats: true
        )
    }
    
    //Fetches current data from each manager for storage
    @objc func fetch_data(_ timer: Timer) {
        let loc = self.geoloc_manager.fetchCurrentLocation()!
        let motion = self.motion_manager.getMotionData().0?.acceleration
        
        var output = "\n\n\n\n\n\n\n\n\n\n\n"
        fflush(stdout)
        
        output += "Location: " + String(loc.coordinate.latitude) + " " + String(loc.coordinate.longitude) + "\n"
        output += String(format: "Accelerometer: x:%.3f y:%.3f z%.3f\n", motion?.x ?? 0.0, motion?.y ?? 0.0, motion?.z ?? 0.0)
        output += "Heart rate: " + String(health_manager.current_hr) + "\n"
        output += "Step count: " + String(health_manager.current_steps) + "\n"
        output += "Active energy: " + String(health_manager.active_energy) + "\n"
        output += "Resting energy: " + String(health_manager.resting_energy) + "\n"
        
        print(output)
        
    }
}
