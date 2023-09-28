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
    var data_buffer: [CMAccelerometerData?] = []
    let read_timer: Timer? = nil
    let queue = OperationQueue()
    
    init(update_interval interval: TimeInterval) {
        
        
        if motion_manager.isAccelerometerAvailable {
            //THIS GIVES RAW ACCELERATION DATA
            //Using device motion updates gives user acceleration instead of raw acceleration
            print("Starting accelerometer updates")
            motion_manager.accelerometerUpdateInterval = 1.0/10.0
            motion_manager.startAccelerometerUpdates()
            //Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(accelUpdateHandler), userInfo: nil, repeats: true);
            motion_manager.startAccelerometerUpdates(to: queue, withHandler: accelUpdateHandler)
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
    
    func getAccelBuffer() -> String {
        //print("processing accelerometer buffer")
        var strs: [String] = []
        for d in self.data_buffer {
            let s = String(format: "x:%.3f y:%.3f z:%.3f", d?.acceleration.x ?? Double.nan, d?.acceleration.y ?? Double.nan, d?.acceleration.z ?? Double.nan)
            strs.append(s)
        }
        self.data_buffer.removeAll(keepingCapacity: true)
        //print(strs.joined(separator: ";"))
        return strs.joined(separator: ";")
    }
    
    @objc func accelUpdateHandler(_ data: CMAccelerometerData?, _ err: Error?) {
        self.data_buffer.append(data)
    }
}
