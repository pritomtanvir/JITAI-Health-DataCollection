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
        motion_manager.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        if motion_manager.isAccelerometerAvailable {
            print("Starting accelerometer")
            motion_manager.accelerometerUpdateInterval = interval
            motion_manager.startAccelerometerUpdates()
        }
        if motion_manager.isGyroAvailable {
            print("Starting gyroscope")
            motion_manager.gyroUpdateInterval = interval
            motion_manager.startGyroUpdates()
        }
        if motion_manager.isMagnetometerAvailable {
            print("Starting magnetometer")
            motion_manager.magnetometerUpdateInterval = interval
            motion_manager.startMagnetometerUpdates()
        }
    }
    
    func getMotionData() -> (CMAccelerometerData?, CMGyroData?, CMMagnetometerData?) {
        let accel = self.motion_manager.accelerometerData
        let gyro = self.motion_manager.gyroData
        let magnet = self.motion_manager.magnetometerData
        return (accel, gyro, magnet)
    }
    
    
}
