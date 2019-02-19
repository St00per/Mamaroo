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

class DetectingProcessViewController: UIViewController {
    
    var motion = CMMotionManager()
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        activityIndicator.startAnimating()
        myDeviceMotion()
    }

    func myDeviceMotion() {
        print("Start DeviceMotion")
        motion.deviceMotionUpdateInterval  = 0.01
        motion.startDeviceMotionUpdates(to: OperationQueue.current!) {
            (data, error) in
            //print(data as Any)
            if let trueData =  data {
                
                self.view.reloadInputViews()
                //self.xDevi!.text = String(format: "x (pitch): %.2f", trueData.attitude.pitch)
                
                //self.yDevi!.text = String(format: "y (pitch): %.2f", trueData.attitude.roll)
                //self.zDevi!.text = String(format: "z (pitch): %.2f", trueData.attitude.yaw)
                print("\(String(format: "%.2f", trueData.attitude.roll)),\(String(format: "%.2f", trueData.attitude.yaw)),\(String(format: "%.2f", trueData.attitude.pitch))")
            }
        }
        return
    }
    
}
