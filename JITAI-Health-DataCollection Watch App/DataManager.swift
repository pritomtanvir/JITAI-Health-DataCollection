//
//  DataManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/17/23.
//

import Foundation
import WatchKit
import CoreData


//This class holds instances of each manager that collects required data
class DataManager {
    let container = NSPersistentContainer(name: "JITAIStore")
    var data_store: [NSManagedObject] = []
    
    let update_interval: TimeInterval = 1.0/30.0
    
    //data collection objects
    let geoloc_manager = GeoLocationManager() //Contains the current time, location, and weather
    let motion_manager: MotionManager //Contains accelerometer, gyroscope, and magnetometer data
    let health_manager = HealthManager() //Contains heart rate, step count, active energy, and resting energy
    let wk_interface = WKInterfaceDevice()
    
    //Controls the rate at which data is fetched from each manager
    var report_timer: Timer?
    
    
    init() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        } 
        
        motion_manager = MotionManager(update_interval: update_interval)
        report_timer = Timer.scheduledTimer(
            timeInterval: update_interval, target: self,
            selector: #selector(save_data),
            userInfo: nil, repeats: true
        )
        
        wk_interface.isBatteryMonitoringEnabled = true
        
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(read_data), userInfo: nil, repeats: true)
    }
    
    //Fetches current data from each manager for storage
    @objc func save_data(_ timer: Timer) {
        var location: String? = nil
        if let loc = self.geoloc_manager.fetchCurrentLocation() {
            location = String(loc.coordinate.latitude) + " " + String(loc.coordinate.longitude)
        }
        
        let motion = self.motion_manager.getMotionData()
        let acceleration = motion.0.debugDescription//String(format: "x:%.3f y:%.3f z%.3f\n", motion.0?.x ?? 0.0, motion.0?.y ?? 0.0, motion.0?.z ?? 0.0)
        let gyro = motion.1.debugDescription
        let magnet = motion.2.debugDescription
        let date = Date()
        let heart_rate = health_manager.current_hr
        let step_count = health_manager.current_steps
        let active_energy = health_manager.active_energy
        let resting_energy = health_manager.resting_energy
        let battery = wk_interface.batteryLevel
        
        guard let entity = NSEntityDescription.entity(forEntityName: "RawStreamData", in: container.viewContext)
        else{return}
        let datapoint = NSManagedObject(entity: entity, insertInto: container.viewContext)
        datapoint.setValue(date, forKey: "time")
        datapoint.setValue(location, forKey: "location")
        datapoint.setValue(Int(heart_rate), forKey: "heartrate")
        datapoint.setValue(Int(step_count), forKey: "stepcount")
        datapoint.setValue(acceleration, forKey: "acceleration")
        datapoint.setValue(gyro, forKey: "gyro")
        datapoint.setValue(magnet, forKey: "magnetometer")
        datapoint.setValue(battery, forKey: "battery")
        datapoint.setValue(active_energy, forKey: "activeenergy")
        datapoint.setValue(resting_energy, forKey: "restingenergy")
        datapoint.setValue("", forKey: "participantid")
        
        guard container.viewContext.hasChanges else { return }
        do {
            try container.viewContext.save()
        }
        catch let error as NSError {
            print("Error saving data: ", error)
        }
    }
    
    @objc func read_data() {
        let request = NSFetchRequest<RawStreamData>(entityName: "RawStreamData")
        do {
            let result = try container.viewContext.fetch(request)
            for data in result {
                print(data.time?.ISO8601Format())
                
                //remove data from store after reading
                container.viewContext.delete(data)
            }
        }
        catch let error {
            print("Failed to fetch data: ", error)
        }
        
    }
    
}
