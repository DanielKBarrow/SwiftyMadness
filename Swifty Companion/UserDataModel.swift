//
//  UserDataModel.swift
//  Swifty Companion
//
//  Created by Patrick RUSSELL on 2018/10/24.
//  Copyright © 2018 Patrick RUSSELL. All rights reserved.
//

import Foundation

class UserDataModel {
    static var userName : String = "Unavailable"
    static var displayName : String = "Unavailable"
    static var email : String = "Unavailable"
    static var mobile : String = "Unavailable"
    static var level : String = "Unavailable"
    static var location : String = "Unavailable"
    static var wallet : String = "Unavailable"
    static var correctionPoints : String = "Unavailable"
    static var pictureURL : String = "Unavailable"
    static var projects : [Project] = []
    static var skills : [Project] = []
    
    static func reset () {
        userName = "Unavailable"
        displayName = "Unavailable"
        email = "Unavailable"
        mobile = "Unavailable"
        level = "Unavailable"
        location = "Unavailable"
        wallet = "Unavailable"
        correctionPoints = "Unavailable"
        pictureURL = "Unavailable"
        projects = []
        skills = []
    }
}
