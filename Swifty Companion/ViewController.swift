//
//  ViewController.swift
//  Swifty Companion
//
//  Created by Patrick RUSSELL on 2018/10/24.
//  Copyright © 2018 Patrick RUSSELL. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var Username: UITextField!
    
    let UID : String = "2f7bd8b5bbd12bba980d6dbb8c97d7e3f07fb72ad11fb3278b14adfb9826d96b"
    let secret : String = "42e1f8736895100e96b167391e9f1006529d1c9a971bd8fb8d44e635c801b9e6"
    let tokenURL : String = "https://api.intra.42.fr/oauth/token"
    //Token request = curl -X POST --data "grant_type=client_credentials&client_id=MY_AWESOME_UID&client_secret=MY_AWESOME_SECRET" https://api.intra.42.fr/oauth/token

    // final url = https://api.intra.42.fr/v2/users/<username>
    // with header = "Authorization: Bearer <YOUR_ACCESS_TOKEN>"
    let userBaseURL : String = "https://api.intra.42.fr/v2/users/"
    var finalUserURL : String = ""
    var token : String?
    var tokenCreatedTime : Double = 0
    var userName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getToken() {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotToSecondScreen" {
            let nextScreen = segue.destination as! SecondViewController
            nextScreen.searchUsername = Username.text!
        }
    }
}

