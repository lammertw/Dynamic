//
//  ViewController.swift
//  Dynamic
//
//  Created by Lammert Westerhoff on 03/15/2016.
//  Copyright (c) 2016 Lammert Westerhoff. All rights reserved.
//

import UIKit
import Dynamic

class ViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var resultTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    // MARK: Properties
    let resultString = Dynamic("")
    
    // MARK: Life-cycle methods
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        // Listen for changes of the result string, if so update the UILabel
        resultString.bindAndFire { [unowned self] in
        
            self.resultLabel.text = $0
        
        }
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }

    // MARK: IBAction methods
    @IBAction func textfieldValueChanged(sender: UITextField) {
        
        guard let resultText = resultTextField.text else { return }
        
        resultString.value = resultText
        
    }
    
}

