//
//  MotionManager.swift
//  JITAI-Health-DataCollection Watch App
//
//  Created by Jack on 3/17/23.
//

import Foundation
import CoreMotion
import WatchKit


class MotionManager: CMMotionManager {
    
    let motion_manager = CMMotionManager()
    let queue = OperationQueue()
    
    override init() {
        if self.motion_manager.isAccelerometerAvailable {
            print("Starting accelerometer")
            self.motion_manager.startAccelerometerUpdates()
        }
        if self.motion_manager.isGyroAvailable {
            print("Starting gyroscope")
            self.motion_manager.startGyroUpdates()
        }
        if self.motion_manager.isMagnetometerAvailable {
            print("Starting magnetometer")
            self.motion_manager.startMagnetometerUpdates()
        }
        
    }
    
    func getMotionData() {
        let accel = self.motion_manager.accelerometerData
        let gyro = self.motion_manager.gyroData
        let magnet = self.motion_manager.magnetometerData
        
        if (accel, gyro, magnet) != (nil, nil, nil) {
            print("Motion data:",(accel, gyro, magnet))
        }
    }
    
    
}
