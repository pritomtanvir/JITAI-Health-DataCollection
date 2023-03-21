//
//  HealthManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/20/23.
//

import Foundation
import HealthKit


class HealthManager {
    let health_store = HKHealthStore()
    
    let ae_type = HKQuantityType(.activeEnergyBurned) //active energy
    let re_type = HKQuantityType(.basalEnergyBurned) //resting energy
    let hr_type = HKQuantityType(.heartRate) //heart rate
    let sc_type = HKQuantityType(.stepCount) //step count
    
    let query_descriptors = [
        HKQueryDescriptor(sampleType: HKQuantityType(.heartRate), predicate: nil),
        HKQueryDescriptor(sampleType: HKQuantityType(.stepCount), predicate: nil),
        HKQueryDescriptor(sampleType: HKQuantityType(.activeEnergyBurned), predicate: nil),
        HKQueryDescriptor(sampleType: HKQuantityType(.basalEnergyBurned), predicate: nil)
    ]
    //ALSO NEED TO GET SITTING TIME
    
    
    var current_hr = 0.0
    var current_steps = 0.0
    var active_energy = 0.0
    var resting_energy = 0.0
    
    //observer to update values whenever they change in the health store
    var observer: HKObserverQuery? = nil
    
    init() {
        //health_store.enableBackgroundDelivery(for: hr_type, frequency: HKUpdateFrequency(rawValue: 1).unsafelyUnwrapped, withCompletion: background_authorization_completed)
        
        observer = HKObserverQuery(queryDescriptors: query_descriptors, updateHandler: observer_update_handler)
        
        //request authorization for all data being collected
        if health_store.authorizationStatus(for: hr_type) == HKAuthorizationStatus.sharingAuthorized &&
           health_store.authorizationStatus(for: sc_type) == HKAuthorizationStatus.sharingAuthorized &&
           health_store.authorizationStatus(for: ae_type) == HKAuthorizationStatus.sharingAuthorized &&
           health_store.authorizationStatus(for: re_type) == HKAuthorizationStatus.sharingAuthorized
        {
            start_hr_observer()
        } else {
            health_store.requestAuthorization(
                toShare: [hr_type, sc_type, ae_type, re_type],
                read: [hr_type, sc_type, ae_type, re_type],
                completion: authorization_complete)
        }
        
    }
    
    
    //Start heart rate updates if authorization is granted
    func authorization_complete(_ success: Bool, _ error: Error?) {
        if error != nil {
            print(error ?? "")
            return
        }
        if success == true {
            start_hr_observer()
        }
    }
    
    func background_authorization_completed(_ success: Bool, _ error: Error?) {
        if success == false {
            print("No background updates")
            print(error ?? "")
        }
    }
    
    
    //MARK: Heart rate update observer
    
    //starts updating current_hr
    func start_hr_observer() {
        if observer != nil {
            print("Starting hr query")
            health_store.execute(observer!)
        }
    }
    
    //Stops updating current_hr
    func stop_hr_observer() {
        if observer != nil {
            health_store.stop(observer!)
        }
    }
    
    //Update current_hr when a query resolves
    func process_query(_ query: HKSampleQuery, _ results: [HKSample]?, _ error: Error?) {
        guard let samples = results as? [HKQuantitySample] else {
            // Handle any errors here.
            return
        }
        for sample in samples {
            
            //change the correct value depending on the query result
            switch sample.quantityType {
            case HKQuantityType(.heartRate):
                self.current_hr = sample.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
            case HKQuantityType(.stepCount):
                self.current_steps = sample.quantity.doubleValue(for: HKUnit.count())
            case HKQuantityType(.activeEnergyBurned):
                self.active_energy = sample.quantity.doubleValue(for: HKUnit.joule())
            case HKQuantityType(.basalEnergyBurned):
                self.resting_energy = sample.quantity.doubleValue(for: HKUnit.joule())
            default:
                ()
            }
        }
    }
    
    func observer_update_handler(
        _ query: HKObserverQuery,
        _ types: Set<HKSampleType>?,
        _ handler: HKObserverQueryCompletionHandler,
        _ error: Error?
    ) {
        if let error = error {
            print(error)
            return
        }
        if types != nil {
            for t in types! {
                //create and execute a query for each type that changed
                let query = HKSampleQuery(sampleType: t, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil, resultsHandler: process_query)
                health_store.execute(query)
            }
        }
        handler()
    }

}
