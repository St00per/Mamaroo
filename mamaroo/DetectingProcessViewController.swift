//
//  DetectingProcessViewController.swift
//  mamaroo
//
//  Created by Kirill Shteffen on 19/02/2019.
//  Copyright © 2019 BlackBricks. All rights reserved.
//

import UIKit
import CoreMotion
import NVActivityIndicatorView
import ARKit

class DetectingProcessViewController: UIViewController {
    
    let motion = CMMotionManager()
    var motionData: [(Double,Double,Double)] = []
    let deviceMotion = CMDeviceMotion()
    let motionFrameReference: CMAttitudeReferenceFrame = CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical
    let kLowPassFilteringFactor: Double = 0.1
    let noiseReduction: Double = 0.05
    var previousLowPassFilteredAccelerationX: Double = 0
    var previousLowPassFilteredAccelerationY: Double = 0
    var previousLowPassFilteredAccelerationZ: Double = 0
    
    var points: [(Double,Double)] = []
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        activityIndicator.startAnimating()
        myDeviceMotion()
        //myAccelerometer()
    }
    

    
    func myAccelerometer() {
        print("Start Accelerometer")
        motion.accelerometerUpdateInterval = 1/100

        motion.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data, error) in
            
            if let trueData =  data {
                //print("\(String(format: "%.2f", trueData.acceleration.x)),\(String(format: "%.2f", trueData.acceleration.y)),\(String(format: "%.2f", trueData.acceleration.z))")
            }
        }
        return
    }
    
    func myGyroscope() {
        print("Start Gyroscope")
        motion.gyroUpdateInterval = 0.5
        motion.startGyroUpdates(to: OperationQueue.current!) {
            (data, error) in
            //print(data as Any)
            if let trueData =  data {
                
                
                print("\(String(format: "%.2f", trueData.rotationRate.x)),\(String(format: "%.2f", trueData.rotationRate.y)),\(String(format: "%.2f", trueData.rotationRate.z))")
            }
        }
        return
    }
    
    func myDeviceMotion() {
        print("Start DeviceMotion")
        motion.deviceMotionUpdateInterval  = 1/100
        //motion.deviceMotion?.attitude.
        //deviceMotion.userAcceleration.
        //motion.attitudeReferenceFrame
        motion.startDeviceMotionUpdates(using:.xMagneticNorthZVertical, to: OperationQueue.current!) {
            (data, error) in
            
            if let trueData =  data {
                let userAcceleration = trueData.userAccelerationInReferenceFrame
                var lowpassFilterAcceleration = CMAcceleration()
                
                
                lowpassFilterAcceleration.x = (userAcceleration.x * self.kLowPassFilteringFactor) + (self.previousLowPassFilteredAccelerationX * (1.0 - self.kLowPassFilteringFactor))
                lowpassFilterAcceleration.y = (userAcceleration.y * self.kLowPassFilteringFactor) + (self.previousLowPassFilteredAccelerationX * (1.0 - self.kLowPassFilteringFactor))
                lowpassFilterAcceleration.z = (userAcceleration.z * self.kLowPassFilteringFactor) + (self.previousLowPassFilteredAccelerationX * (1.0 - self.kLowPassFilteringFactor))
                print("\(String(format: "%.2f", lowpassFilterAcceleration.y)),\(String(format: "%.2f", lowpassFilterAcceleration.z)),\(String(format: "%.2f", lowpassFilterAcceleration.x))")
                if (lowpassFilterAcceleration.z > self.noiseReduction || lowpassFilterAcceleration.x > self.noiseReduction) {
                    self.points.append((lowpassFilterAcceleration.x,lowpassFilterAcceleration.y))
                    
                    //print("\(String(format: "%.2f", trueData.userAcceleration.x)),\(String(format: "%.2f", trueData.userAcceleration.y)),\(String(format: "%.2f", trueData.userAcceleration.z)),\(String(format: "%.2f", trueData.rotationRate.x)),\(String(format: "%.2f", trueData.rotationRate.y)),\(String(format: "%.2f", trueData.rotationRate.z))")
                
               
                    self.previousLowPassFilteredAccelerationX = lowpassFilterAcceleration.x
                    self.previousLowPassFilteredAccelerationY = lowpassFilterAcceleration.y
                    self.previousLowPassFilteredAccelerationZ = lowpassFilterAcceleration.z
                }
//                //pitch)
//
//                //roll)
//                //yaw)
                //print("\(String(format: "%.2f", trueData.attitude.roll)),\(String(format: "%.2f", trueData.attitude.yaw)),\(String(format: "%.2f", trueData.attitude.pitch))")
//                let vectorCalculator = DisplacementVectorCalculator(deviceMotion: self.motion.deviceMotion!)
//                let vector = vectorCalculator.getDisplacementVector(deviceMotion: self.motion.deviceMotion!, timeInterval: 10)
//                print("\(String(format: "%.2f", vector.x)),\(String(format: "%.2f", vector.y)),\(String(format: "%.2f", vector.z))")
            }
        }
        return
    }
   
    func patternCompare(motionData: [(Double,Double,Double)]) {
        
    }
    
    @IBAction func printPoints(_ sender: UIButton) {
        for point in self.points {
            print("\(String(format: "%.2f", point.0)),\(String(format: "%.2f", point.1))")
        }
    }
}

extension CMDeviceMotion {
    
    var userAccelerationInReferenceFrame: CMAcceleration {
        let acc = self.userAcceleration
        let rot = self.attitude.rotationMatrix
        
        var accRef = CMAcceleration()
        accRef.x = acc.x*rot.m11 + acc.y*rot.m12 + acc.z*rot.m13;
        accRef.y = acc.x*rot.m21 + acc.y*rot.m22 + acc.z*rot.m23;
        accRef.z = acc.x*rot.m31 + acc.y*rot.m32 + acc.z*rot.m33;
        
        return accRef;
    }
}
