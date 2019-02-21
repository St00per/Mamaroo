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
    let noiseReduction: Double = 0.02
    var previousLowPassFilteredAccelerationX: Double = 0
    var previousLowPassFilteredAccelerationY: Double = 0
    var previousLowPassFilteredAccelerationZ: Double = 0
    
    var previousVelocityX: Double = 0
    var previousVelocityY: Double = 0
    var previousVelocityZ: Double = 0
    
    var previousDistanceX: Double = 0
    var previousDistanceY: Double = 0
    var previousDistanceZ: Double = 0
    
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
        motion.startDeviceMotionUpdates(using:.xMagneticNorthZVertical, to: OperationQueue.current!) {
            (data, error) in
            
            if let trueData =  data {
                let userAcceleration = trueData.userAccelerationInReferenceFrame
                var lowpassFilterAcceleration = CMAcceleration()
                let time = self.motion.deviceMotionUpdateInterval
                
                lowpassFilterAcceleration.x = (userAcceleration().x * self.kLowPassFilteringFactor) + (self.previousLowPassFilteredAccelerationX * (1.0 - self.kLowPassFilteringFactor))
                lowpassFilterAcceleration.y = (userAcceleration().y * self.kLowPassFilteringFactor) + (self.previousLowPassFilteredAccelerationX * (1.0 - self.kLowPassFilteringFactor))
                lowpassFilterAcceleration.z = (userAcceleration().z * self.kLowPassFilteringFactor) + (self.previousLowPassFilteredAccelerationX * (1.0 - self.kLowPassFilteringFactor))
                if (userAcceleration().x > self.noiseReduction || userAcceleration().y > self.noiseReduction || userAcceleration().z > self.noiseReduction) {
                self.previousLowPassFilteredAccelerationX = lowpassFilterAcceleration.x
                self.previousLowPassFilteredAccelerationY = lowpassFilterAcceleration.y
                self.previousLowPassFilteredAccelerationZ = lowpassFilterAcceleration.z
                
                    let velocityX = self.previousVelocityX + (userAcceleration().x * time)
                    let velocityY = self.previousVelocityY + (userAcceleration().y * time)
                    let velocityZ = self.previousVelocityZ + (userAcceleration().z * time)
                
                    let distanceX = self.previousVelocityX * time + ((userAcceleration().x * time * time)/2)
                    let distanceY = self.previousVelocityY * time + ((userAcceleration().y * time * time)/2)
                    let distanceZ = self.previousVelocityZ * time + ((userAcceleration().z * time * time)/2)
                
                self.previousVelocityX = velocityX
                self.previousVelocityY = velocityY
                self.previousVelocityZ = velocityZ
                    
                self.previousDistanceX += distanceX
                self.previousDistanceY += distanceY
                self.previousDistanceZ += distanceZ
                
                    self.points.append((self.previousDistanceX, self.previousDistanceZ))
                    
                    print("\(String(format: "%.2f", self.previousDistanceX)),\(String(format: "%.2f", self.previousDistanceY)),\(String(format: "%.2f", self.previousDistanceZ))")
                }
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
    
    func userAccelerationInReferenceFrame() -> CMAcceleration {
        
        let origin = userAcceleration
        let rotation = attitude.rotationMatrix
        let matrix = rotation.inverse()
        
        var result = CMAcceleration()
        result.x = origin.x * matrix.m11 + origin.y * matrix.m12 + origin.z * matrix.m13;
        result.y = origin.x * matrix.m21 + origin.y * matrix.m22 + origin.z * matrix.m23;
        result.z = origin.x * matrix.m31 + origin.y * matrix.m32 + origin.z * matrix.m33;
        
        return result
    }
    
    func gravityInReferenceFrame() -> CMAcceleration {
        
        let origin = self.gravity
        let rotation = attitude.rotationMatrix
        let matrix = rotation.inverse()
        
        var result = CMAcceleration()
        result.x = origin.x * matrix.m11 + origin.y * matrix.m12 + origin.z * matrix.m13;
        result.y = origin.x * matrix.m21 + origin.y * matrix.m22 + origin.z * matrix.m23;
        result.z = origin.x * matrix.m31 + origin.y * matrix.m32 + origin.z * matrix.m33;
        
        return result
    }
}

extension CMRotationMatrix {
    
    func inverse() -> CMRotationMatrix {
        
        let matrix = GLKMatrix3Make(Float(m11), Float(m12), Float(m13), Float(m21), Float(m22), Float(m23), Float(m31), Float(m32), Float(m33))
        let invert = GLKMatrix3Invert(matrix, nil)
        
        return CMRotationMatrix(m11: Double(invert.m00), m12: Double(invert.m01), m13: Double(invert.m02),
                                m21: Double(invert.m10), m22: Double(invert.m11), m23: Double(invert.m12),
                                m31: Double(invert.m20), m32: Double(invert.m21), m33: Double(invert.m22))
        
    }
    
}
