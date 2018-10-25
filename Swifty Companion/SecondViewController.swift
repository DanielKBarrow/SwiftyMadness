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

struct Project {
    var name : String = "default"
    var percent : String = "-1"
}

class SecondViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
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
    var token : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        validateTokenThenGetData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func poplulate() {
        if let url = URL(string: UserDataModel.pictureURL) {
            imageView.contentMode = .scaleAspectFit
            downloadImage(from: url)
        }
        nameLabel.text = "Name: \(UserDataModel.displayName)"
        userNameLabel.text = "Username: \(UserDataModel.userName)"
        emailLabel.text = "Email: \(UserDataModel.email)"
        levelLabel.text = "Level: \(UserDataModel.level)"
        pointsLabel.text = "Correction Points: \(UserDataModel.correctionPoints)"
        walletLabel.text = "Wallet: \(UserDataModel.wallet)"
        mobileLabel.text = "Mobile: \(UserDataModel.mobile)"
        locationLabel.text = "Location: \(UserDataModel.location)"
        SVProgressHUD.dismiss()
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
                getUserInfo(name: searchUserName!)
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
                self.getUserInfo(name: searchUserName!)
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
                case .failure(let error):
                    print(error)
                    self.userNameLabel.text = "user info request failed"
                }
            }
        }
        else {
            userNameLabel.text = "Token not validated yet"
        }
    }
    
    func parseProjectInfo(data : JSON) -> Project {
        var project : Project = Project()
        if let name = data["project"]["slug"].string , let percentage = data["final_mark"].int {
            project.name = name
            project.percent = String(percentage)
        }
        return project
    }
    
    func extractUserData(data : JSON) {
        UserDataModel.userName = searchUserName!
        if let displayName = data["displayname"].string, let email = data["email"].string, let level = data["cursus_users"][0]["level"].double,
        let location = data["campus"][0]["name"].string,let wallet = data["wallet"].int,let correctionPoints = data["correction_point"].int
        {
            UserDataModel.displayName = displayName
            UserDataModel.emaihow l = email
            UserDataModel.level = String(level)
            UserDataModel.location = location
            UserDataModel.wallet = String(wallet)
            UserDataModel.correctionPoints = String(correctionPoints)
            if let mobile = data["phone"].string { UserDataModel.mobile = mobile }
            if let image = data["image_url"].string {
                if image == "https://cdn.intra.42.fr/users/default.png" {
                    UserDataModel.pictureURL = "https://cdn.intra.42.fr/users/small_default.png"
                }
                else {
                    UserDataModel.pictureURL = "https://cdn.intra.42.fr/users/small_\(searchUserName!).jpg"
                }
            }
            else {
                UserDataModel.pictureURL = "https://cdn.intra.42.fr/users/small_default.png"
            }
        }
        else {
            //update hidden status lable here
            print("Failed to extract user data from API respons")
        }
        poplulate()
    }
}


















