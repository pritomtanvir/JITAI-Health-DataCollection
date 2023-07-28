//
//  MotionManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/17/23.
//

import Foundation
import CoreMotion
import WatchKit


class MotionManager {
    
    let motion_manager = CMMotionManager()
    
    init(update_interval interval: TimeInterval) {
        
        if motion_manager.isAccelerometerAvailable {
            //THIS GIVES RAW ACCELERATION DATA
            //Using device motion updates gives user acceleration instead of raw acceleration
            print("Starting accelerometer updates")
            motion_manager.accelerometerUpdateInterval = interval
            motion_manager.startAccelerometerUpdates()
        }
        /*
        if motion_manager.isGyroAvailable {
            print("Starting gyroscope updates")
            motion_manager.gyroUpdateInterval = interval
            motion_manager.startGyroUpdates()
        }
        if motion_manager.isMagnetometerAvailable {
            print("Starting magnetometer updates")
            motion_manager.magnetometerUpdateInterval = interval
            motion_manager.startMagnetometerUpdates()
        }
        */
    }
    
    //Returns a tuple of (acceleration?, gyro?, magnetometer?)
    func getMotionData() -> (CMAccelerometerData?, CMGyroData?, CMMagnetometerData?) {
        let accel = self.motion_manager.accelerometerData
        //let gyro = self.motion_manager.gyroData
        //let magnet = self.motion_manager.magnetometerData
        return (accel, Optional.none, Optional.none)
    }
}
