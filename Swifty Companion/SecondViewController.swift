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

struct APIData {
    static var token : String?
    static var tokenExpiry : Double?
}

class SecondViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let UID : String = "2f7bd8b5bbd12bba980d6dbb8c97d7e3f07fb72ad11fb3278b14adfb9826d96b"
    let secret : String = "42e1f8736895100e96b167391e9f1006529d1c9a971bd8fb8d44e635c801b9e6"
    let tokenURL : String = "https://api.intra.42.fr/oauth/token"
    let userBaseURL : String = "https://api.intra.42.fr/v2/users/"
    var searchUsername : String = ""
    var token : String?
    var userData : UserDataModel = UserDataModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        validateTokenThenGetData()
        if let url = URL(string: "https://cdn.intra.42.fr/users/small_\(searchUsername).jpg") {
            imageView.contentMode = .scaleAspectFit
            downloadImage(from: url)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func poplulate() {
        nameLabel.text = "Name: \(userData.displayName)"
        userNameLabel.text = "Username: \(userData.userName)"
        emailLabel.text = "Email: \(userData.email)"
        levelLabel.text = "Level: \(userData.level)"
        pointsLabel.text = "Correction Points: \(userData.correctionPoints)"
        walletLabel.text = "Wallet: \(userData.wallet)"
        mobileLabel.text = "Mobile: \(userData.mobile)"
        locationLabel.text = "Location: \(userData.location)"
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func validateTokenThenGetData() {
        if APIData.token != nil {
            let timeInterval : Double = Date().timeIntervalSince1970
            print("timeInterval: " + String(timeInterval))
            print("tokenExpires: " + String(APIData.tokenExpiry!))
            if timeInterval > APIData.tokenExpiry! {
                print("Token expired")
                APIData.token = nil
                getNewToken()
            }
            else {
                getUserInfo(name: searchUsername)
            }
        }
        else {
            getNewToken()
        }
    }
    
    func getNewToken () {
        SVProgressHUD.show(withStatus: "Fetching web token")
        let params : Parameters = ["grant_type" : "client_credentials", "client_id" : UID, "client_secret" : secret]
        Alamofire.request(tokenURL, method: .post, parameters: params).responseJSON {
            response in
            switch response.result {
            case .success:
                let tokenData : JSON = JSON(response.result.value!)
                self.extractToken(json : tokenData)
                self.getUserInfo(name: self.searchUsername)
            case .failure(let error):
                self.userNameLabel.text = "Failed to get token"
                print(error)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func extractToken(json : JSON) {
        if let token = json["access_token"].string, let created = json["created_at"].double, let expires = json["expires_in"].double {
            APIData.token = token
            APIData.tokenExpiry = created + expires
        }
        else {
            userNameLabel.text = "could not refesh token"
            print ("Failed to get new token")
        }
    }
    
    func getUserInfo(name : String) {
        SVProgressHUD.show(withStatus: "Getting user info")
        if let token = APIData.token {
            let header : HTTPHeaders = ["Authorization" : "Bearer \(token)"]
            let finalRequestURL : String = userBaseURL + name
            Alamofire.request(finalRequestURL, method : .get, headers : header).responseJSON {
                response in
                switch response.result {
                case .success:
                    self.extractUserData(data: JSON(response.result.value!))
//                    print(JSON(response.result.value!))
                case .failure(let error):
                    print(error)
                    self.userNameLabel.text = "user info request failed"
                }
            }
        }
        else {
            userNameLabel.text = "Token not validated yet"
        }
        SVProgressHUD.dismiss()
    }
    
    func extractUserData(data : JSON) {
        if let displayName = data["displayname"].string,
            let email = data["email"].string,
            let level = data["cursus_users"][0]["level"].double,
            let location = data["campus"][0]["name"].string,
            let wallet = data["wallet"].int,
            let correctionPoints = data["correction_point"].int
        {
            userData.displayName = displayName
            userData.email = email
            userData.level = String(level)
            userData.location = location
            userData.wallet = String(wallet)
            userData.correctionPoints = String(correctionPoints)
            if let mobile = data["phone"].string {
                userData.mobile = mobile
            }
            else {
                userData.mobile = "unavailable"
            }
            if let pictureURL = data["image_url"].string {
                userData.pictureURL = pictureURL
            }
            else {
                userData.pictureURL = "https://cdn.intra.42.fr/users/small_default.png"
            }
            poplulate()
        }
        else {
            //update hidden status lable here
            print("Failed to extract user data from API respons")
        }
    }
}


















