//
//  myAlert.swift
//  my Virtual Tourist
//
//  Created by Raafat Ali on 06/02/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import Foundation
import UIKit

struct myAlert {
    
    static func AlertMsg(on vc: UIViewController, with message: String) {
        let alert = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      
    }
    
//    static func AlertMsg2(on vc: UIViewController, with message: String , completionHandlerForAlert: @escaping ( _ action: UIAlertAction?) -> Void) {
//        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: completionHandlerForAlert))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//
//        DispatchQueue.main.async { vc.present(alert, animated: true) }
//    }
//
    
    
    
}
