//
//  SecondViewController.swift
//  Swifty Companion
//
//  Created by Patrick RUSSELL on 2018/10/24.
//  Copyright © 2018 Patrick RUSSELL. All rights reserved.
//

//  Token request = curl -X POST --data "grant_type=client_credentials&client_id=MY_AWESOME_UID&client_secret=MY_AWESOME_SECRET" https://api.intra.42.fr/oauth/token
//  final url = https://api.intra.42.fr/v2/users/<username>
//  with header = "Authorization: Bearer <YOUR_ACCESS_TOKEN>"

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class APIData {
    static var token : String?
    static var tokenExpiry : Double?
}

class SecondViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    let UID : String = "2f7bd8b5bbd12bba980d6dbb8c97d7e3f07fb72ad11fb3278b14adfb9826d96b"
    let secret : String = "42e1f8736895100e96b167391e9f1006529d1c9a971bd8fb8d44e635c801b9e6"
    let tokenURL : String = "https://api.intra.42.fr/oauth/token"
    let userBaseURL : String = "https://api.intra.42.fr/v2/users/"
    var searchUsername : String = ""
    var finalUserURL : String = ""
    var token : String?
    var tokenCreatedTime : Double = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = searchUsername
        if let tok = APIData.token {
            print(tok)
        }
        else {
            print ("no token")
        }
        getNewToken()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNewToken () {
        SVProgressHUD.show(withStatus: "Fetching web token")
        let params : Parameters = ["grant_type" : "client_credentials", "client_id" : UID, "client_secret" : secret]
        Alamofire.request(tokenURL, method: .post, parameters: params).responseJSON{
            response in
            switch response.result {
            case .success:
                let tokenData : JSON = JSON(response.result.value!)
                self.extractToken(json : tokenData)
                SVProgressHUD.dismiss()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func extractToken(json : JSON) {
        if let tok = json["access_token"].string {
            let created = json["created_at"].doubleValue
            let expires = json["expires"].doubleValue
            APIData.token = tok
            APIData.tokenExpiry = created + expires
            print(APIData.tokenExpiry!)
        }
        else {
            userName.text = "could not refesh token"
            print ("Failed to get new token")
        }
    }
    
}
