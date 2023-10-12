//
//  AlertHelper.swift
//  Rijksmuseum
//
//  Created by Andrei on 12/10/2023.
//

import UIKit

class AlertHelper {
    
    static func showAlert(title: String?, message: String?, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: RStrings.commonOk, style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlertWithAction(title: String?, message: String?, actionTitle: String, from viewController: UIViewController, actionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let customAction = UIAlertAction(title: actionTitle, style: .default) { (_) in
            actionHandler()
        }
        
        alertController.addAction(customAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
