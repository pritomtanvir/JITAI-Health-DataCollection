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
class DataManager: NSObject, WKExtendedRuntimeSessionDelegate {
    let container = NSPersistentContainer(name: "JITAIStore")
    
    var participant_id: String? = UserDefaults.standard.string(forKey: "ParticipantID")
    
    //data collection objects
    let geoloc_manager = GeoLocationManager() //Contains the current time, location, and weather
    let motion_manager: MotionManager //Contains accelerometer, gyroscope, and magnetometer data
    let health_manager = HealthManager() //Contains heart rate, step count, active energy, and resting energy
    let wk_interface = WKInterfaceDevice()
    
    let upload_manager = UploadManager()
    let connection_monitor = NWPathMonitor();
    
    //Controls the rate at which data is fetched from each manager
    let read_interval: TimeInterval = 1.0 //read data once per second
    var read_timer: Timer?
    
    //Controls the rate at which data is fetched from the store and sent to the server
    let report_interval: TimeInterval = 7200.0 //two hours between attempted sends
    var report_timer: Timer?
    
    var extended_session = WKExtendedRuntimeSession()

    
    override init() {
        motion_manager = MotionManager(update_interval: read_interval)
        
        super.init()
        extended_session.delegate = self
        wk_interface.isBatteryMonitoringEnabled = true
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        } 
                
        report_timer = Timer.scheduledTimer(
            timeInterval: report_interval,
            target: self,
            selector: #selector(send_data),
            userInfo: nil,
            repeats: true
        )
        
        self.start_collecting()
    }
    
    
    //Fetches current data from each manager for storage
    @objc func save_data(_ timer: Timer) {
        if wk_interface.batteryState == .charging || self.participant_id == nil {
            return
        }
        //print("Saving data")
        
        var location: String? = nil
        if let loc = self.geoloc_manager.fetchCurrentLocation() {
            location = String(loc.coordinate.latitude) + " " + String(loc.coordinate.longitude)
        }
        
        //let motion = self.motion_manager.getMotionData()
        let acceleration = self.motion_manager.getAccelBuffer()
        let gyro = "x:nil y:nil z:nil";
        let magnet = "x:nil y:nil z:nil";
        
        
        //getting the time
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = Date.init().timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        let time = Date(timeIntervalSince1970: timezoneEpochOffset)
        let format = DateFormatter(); format.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        let currentTime = format.string(from: time)
        
        let heart_rate = health_manager.current_hr
        let step_count = health_manager.current_steps
        let active_energy = health_manager.active_energy
        let resting_energy = health_manager.resting_energy
        let battery = wk_interface.batteryLevel
        
        guard let entity = NSEntityDescription.entity(forEntityName: "DataPoint", in: container.viewContext)
        else{return}
        let datapoint = NSManagedObject(entity: entity, insertInto: container.viewContext)
        datapoint.setValue(currentTime, forKey: "time")
        datapoint.setValue(location, forKey: "location")
        datapoint.setValue(Int(heart_rate), forKey: "heartrate")
        datapoint.setValue(Int(step_count), forKey: "stepcount")
        datapoint.setValue(acceleration, forKey: "acceleration")
        datapoint.setValue(gyro, forKey: "gyro")
        datapoint.setValue(magnet, forKey: "magnetometer")
        datapoint.setValue(battery, forKey: "battery")
        datapoint.setValue(active_energy, forKey: "activeenergy")
        datapoint.setValue(resting_energy, forKey: "restingenergy")
        datapoint.setValue(participant_id ?? "pid_error", forKey: "participantid")
        datapoint.setValue(0, forKey: "sittingtime")
        
        guard container.viewContext.hasChanges else { return }
        do {
            try container.viewContext.save()
        }
        catch let error as NSError {
            print("Error saving data: ", error)
        }
    }
    
    @objc func send_data() {
        //Do not attempt another upload if the previous hasnt resolved yet
        if(upload_manager.prev_completed == false) {return;}
        
        let request = NSFetchRequest<DataPoint>(entityName: "DataPoint");
        
        var data_array: [[String : Any]] = [];
        
        do {
            let result = try container.viewContext.fetch(request);
            for data in result {
                let data_dict = data.dictionaryWithValues(forKeys: ["time", "stepcount", "restingenergy", "participantid", "magnetometer", "location", "heartrate", "gyro", "battery", "activeenergy", "acceleration", "sittingtime"])
                
                data_array.append(data_dict);
                
                //remove data from store after reading
                container.viewContext.delete(data);
            }
        }
        catch let error {
            print("Failed to fetch data: ", error)
        }
        
        if(data_array.isEmpty == false) {
            upload_manager.upload_data(data_array)
        }
    }
    
    
    func start_collecting() {
        print("Starting data collection")
        if(read_timer == nil) {
            read_timer = Timer.scheduledTimer(
                timeInterval: read_interval,
                target: self,
                selector: #selector(save_data),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    func stop_collecting() {
        print("Stopping data collection")
        read_timer?.invalidate()
        read_timer = nil
    }
    
    //Saves the input string to the persistent container as a ParticipantID
    func save_participant_id(_ id: String) {
        self.participant_id = id
        UserDefaults.standard.set(id, forKey: "ParticipantID")
    }
    
    
    //MARK: Extended runtime session delegate functions
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Started extended runtime session")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Stopping extended runtime session")
    }
        
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        print("Stopped extended runtime session")
    }
    
}

