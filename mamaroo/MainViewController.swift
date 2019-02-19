//
//  MainViewController.swift
//  
//
//  Created by Kirill Shteffen on 19/02/2019.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func showPatternDetection(_ sender: UIButton) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "DetectingProcess", bundle: nil)
        guard let desVC = mainStoryboard.instantiateViewController(withIdentifier: "DetectingProcessViewController") as? DetectingProcessViewController else {
            return
        }
        show(desVC, sender: nil)
    }
    
}
