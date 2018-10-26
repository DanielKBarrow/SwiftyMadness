//
//  ViewController.swift
//  Swifty Companion
//
//  Created by Patrick RUSSELL on 2018/10/24.
//  Copyright © 2018 Patrick RUSSELL. All rights reserved.
//

import UIKit

var searchUserName : String?

class ViewController: UIViewController {
    
    @IBOutlet weak var Username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func getToken() {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchUserName = Username.text!.lowercased()
    }
}

