//
//  Preferences.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 01.04.20.
//  Copyright © 2020 TiM. All rights reserved.
//

import Foundation

class Preferences {
    static let shared = Preferences()
    
    var imageDuration: Int {
        get {
            return UserDefaults.standard.integer(forKey: "imageDuration")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "imageDuration")
        }
    }
    
    var resolution: Int {
        get {
            return UserDefaults.standard.integer(forKey: "resolution")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "resolution")
        }
    }
    
    var crfQuality: Int {
        get {
            return UserDefaults.standard.integer(forKey: "crfQuality")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "crfQuality")
        }
    }
}
