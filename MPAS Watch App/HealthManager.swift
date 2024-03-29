//
//  HealthManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/20/23.
//

import Foundation
import HealthKit



//Uses healthkit to get heart rate, step count, active energy, and resting energy
class HealthManager {
    let health_store = HKHealthStore()
    
    
    var workout_session: HKWorkoutSession?
    
    let ae_type = HKQuantityType(.activeEnergyBurned) //active energy
    let re_type = HKQuantityType(.basalEnergyBurned) //resting energy
    let hr_type = HKQuantityType(.heartRate) //heart rate type
    let sc_type = HKQuantityType(.stepCount) //step count type
    
    let query_descriptors = [
        HKQueryDescriptor(sampleType: HKQuantityType(.activeEnergyBurned), predicate: nil),
        HKQueryDescriptor(sampleType: HKQuantityType(.basalEnergyBurned), predicate: nil)
    ]
    
    
    var current_hr = 0.0
    var current_steps = 0.0
    var active_energy = 0.0
    var resting_energy = 0.0
    
    //observer to update values whenever they change in the health store
    var observer: HKObserverQuery? = nil
    
    var hr_timer: Timer?
    
    
    init() {
        health_store.enableBackgroundDelivery(for: hr_type, frequency: HKUpdateFrequency(rawValue: 30)!, withCompletion: background_authorization_completed)
        
        observer = HKObserverQuery(queryDescriptors: query_descriptors, updateHandler: observer_update_handler)
        
        
        //request authorization for all data being collected
        if health_store.authorizationStatus(for: hr_type) == HKAuthorizationStatus.sharingAuthorized &&
           health_store.authorizationStatus(for: sc_type) == HKAuthorizationStatus.sharingAuthorized &&
           health_store.authorizationStatus(for: ae_type) == HKAuthorizationStatus.sharingAuthorized &&
           health_store.authorizationStatus(for: re_type) == HKAuthorizationStatus.sharingAuthorized
        {
            start_observer()
            //startWorkout()
        } else {
            health_store.requestAuthorization(
                toShare: [hr_type, sc_type, ae_type, re_type],
                read: [hr_type, sc_type, ae_type, re_type],
                completion: authorization_complete)
        }
        
    }
    
    //Get the average heart rate from the past minute
    func run_hr_sc_query(_ _: Timer) {
        let past_minute = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .second, value: -30, to: Date.now), end: Date.now)
        
        let hr_qd = HKStatisticsQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: hr_type, predicate: past_minute),
            options: .discreteAverage
        )
        Task {
            self.current_hr = try (await hr_qd.result(for: health_store)?
                .averageQuantity()?
                .doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            ) ?? 0.0
            //print("updated hr: ", self.current_hr)
        }
        
        
        let start_of_day = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date.now), end: Date.now)
        
        let sc_qd = HKStatisticsQueryDescriptor(predicate: HKSamplePredicate.quantitySample(type: sc_type, predicate: start_of_day), options: .cumulativeSum)
        
        Task {
            self.current_steps = try (await sc_qd.result(for: health_store))?
                .sumQuantity()?
                .doubleValue(for: .count()) ?? 0.0
            //print("updated steps: ", self.current_steps)
        }
        
    }
    
    
    //Start updates if read and share authorization is granted
    func authorization_complete(_ success: Bool, _ error: Error?) {
        if error != nil {
            print(error ?? "")
            return
        }
        if success == true {
            start_observer()
            //startWorkout()
        }
    }
    
    //unused right now because I cannot enable background health updates
    func background_authorization_completed(_ success: Bool, _ error: Error?) {
        if success == false {
            print("No background updates")
            print(error ?? "")
        }
    }
    
    
    //MARK: Heart rate update observer
    
    //starts updating current_hr
    func start_observer() {
        if observer != nil {
            //print("Starting hr query")
            health_store.execute(observer!)
            hr_timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: run_hr_sc_query)
            hr_timer?.fire()
        }
    }
    
    //Stops updating current_hr
    func stop_observer() {
        if observer != nil {
            health_store.stop(observer!)
            hr_timer?.invalidate()
        }
    }
    
    //Update when a query resolves
    func process_query(_ query: HKSampleQuery, _ results: [HKSample]?, _ error: Error?) {
        guard let samples = results as? [HKQuantitySample] else {
            // Handle any errors here.
            return
        }
        for sample in samples {
            
            //change the correct value depending on the query result
            switch sample.quantityType {
            case HKQuantityType(.activeEnergyBurned):
                self.active_energy = sample.quantity.doubleValue(for: HKUnit.joule())
            case HKQuantityType(.basalEnergyBurned):
                self.resting_energy = sample.quantity.doubleValue(for: HKUnit.joule())
            default:
                ()
            }
        }
    }
    
    //Runs each time a requested sample type changes in the healthkit
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
    
    //MARK: Workout session
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (workout_session != nil) {
            return
        }

        // Configure the workout session. Change these later?
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .play
        workoutConfiguration.locationType = .indoor
        
        do {
            workout_session = try HKWorkoutSession(healthStore: health_store, configuration: workoutConfiguration)
            
            // Start the workout session and device motion updates.
            workout_session!.startActivity(with: Date.now) // Start activity now
            workout_session!.pause() // Pause to keep app in foreground
            
        } catch {
            fatalError("Unable to create the workout session!")
        }
    }

    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (workout_session == nil) {
            print("Session Already Nil")
            return
        }
        
        // Stop the device motion updates and workout session.
        workout_session!.end()

        // Clear the workout session.
        workout_session = nil
    }

}
