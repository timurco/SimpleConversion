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
    
    var resolution: Int {
        get {
            if let resolution:Int = UserDefaults.standard.integer(forKey: "resolution") {
                return resolution
            } else {
                return 0
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "resolution")
        }
    }
    
    var crfQuality: Int {
        get {
            if let crfQuality:Int = UserDefaults.standard.integer(forKey: "crfQuality") {
                return crfQuality
            } else {
                return 23
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "crfQuality")
        }
    }
}
