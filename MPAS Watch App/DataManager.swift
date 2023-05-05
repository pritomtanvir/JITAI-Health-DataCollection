//
//  DataManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/17/23.
//

import Foundation
import WatchKit
import CoreData
import Network


//This class holds instances of each manager that collects required data
class DataManager {
    let container = NSPersistentContainer(name: "JITAIStore")
    
    //data collection objects
    let geoloc_manager = GeoLocationManager() //Contains the current time, location, and weather
    let motion_manager: MotionManager //Contains accelerometer, gyroscope, and magnetometer data
    let health_manager = HealthManager() //Contains heart rate, step count, active energy, and resting energy
    let wk_interface = WKInterfaceDevice()
    
    let upload_manager = UploadManager()
    let connection_monitor = NWPathMonitor();
    
    //Controls the rate at which data is fetched from each manager
    let read_interval: TimeInterval = 1.0/5.0
    var read_timer: Timer?
    
    //Controls the rate at which data is fetched from the store and sent to the server
    let report_interval: TimeInterval = 1.0
    var report_timer: Timer?
    
    
    init() {
        wk_interface.isBatteryMonitoringEnabled = true
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        } 
        
        motion_manager = MotionManager(update_interval: read_interval)
        
        connection_monitor.pathUpdateHandler = network_change;
        connection_monitor.start(queue: DispatchQueue(label: "Network Monitor"))
    }
    
    func network_change(_ path: NWPath) {
        if path.status == .satisfied {
            print("Start sending to server");
            report_timer = Timer.scheduledTimer(
                timeInterval: report_interval,
                target: self,
                selector: #selector(send_data),
                userInfo: nil,
                repeats: true
            )
        } else {
            report_timer = nil;
            print("Stop sending to server");
        }
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
        let date = String(Date().debugDescription)
        let heart_rate = health_manager.current_hr
        let step_count = health_manager.current_steps
        let active_energy = health_manager.active_energy
        let resting_energy = health_manager.resting_energy
        let battery = wk_interface.batteryLevel
        
        guard let entity = NSEntityDescription.entity(forEntityName: "StreamData", in: container.viewContext)
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
    
    @objc func send_data() {
        let request = NSFetchRequest<StreamData>(entityName: "StreamData");
        
        var data_array: [[String : Any]] = [];
        
        do {
            let result = try container.viewContext.fetch(request);
            for data in result {
                let data_dict = data.dictionaryWithValues(forKeys: ["time", "stepcount", "restingenergy", "participantid", "magnetometer", "location", "heartrate", "gyro", "battery", "activeenergy", "acceleration"])
                
                data_array.append(data_dict);
                
                //remove data from store after reading
                container.viewContext.delete(data);
            }
        }
        catch let error {
            print("Failed to fetch data: ", error)
        }
        
        if(data_array.isEmpty == false) {
            //upload data to the server after emptying the store
            print("sending data")
            upload_manager.upload_data(data_array)
        } else {
            print("empty data array")
        }
    }
    
    
    func start_collecting() {
        print("Starting data collection")
        
        read_timer = Timer.scheduledTimer(
            timeInterval: read_interval,
            target: self,
            selector: #selector(save_data),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stop_collecting() {
        print("Stopping data collection")
        read_timer = nil
    }
    
}

