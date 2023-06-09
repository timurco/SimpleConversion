//
//  PreferencesController.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 01.04.20.
//  Copyright © 2020 TiM. All rights reserved.
//

import Cocoa

class PreferencesController: NSViewController {
    
    
    @IBOutlet weak var sliderControl: NSSlider!
    @IBOutlet weak var sliderLabel: NSTextField!
    @IBOutlet weak var resolution: NSPopUpButton!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.titlebarAppearsTransparent = true
        view.window?.isMovableByWindowBackground = true
        view.window?.titleVisibility = NSWindow.TitleVisibility.hidden
        view.window?.level = .floating
        view.window?.isOpaque = false
        sliderControl.isContinuous = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        showExistingPrefs()
        
    }
    
    @IBAction func QuitClicked(_ sender: Any) {
        NSApplication.shared.terminate(sender)
    }
    
    @IBAction func ResolutionChange(_ sender: Any) {
        print(resolution.integerValue)
        saveNewPrefs()
    }
    
    @IBAction func SliderChange(_ sender: Any) {
        print(sliderControl.integerValue)
        sliderLabel.integerValue = sliderControl.integerValue
        saveNewPrefs()
    }
    
    func showExistingPrefs() {
        sliderControl.integerValue = Preferences.shared.crfQuality
        sliderLabel.integerValue = sliderControl.integerValue
        resolution.selectItem(withTag: Preferences.shared.resolution)
    }
    
    func saveNewPrefs() {
        Preferences.shared.crfQuality = sliderControl.integerValue
        Preferences.shared.resolution = resolution.selectedTag()
        print("Curent selected resolution: \(Preferences.shared.resolution)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"), object: nil)
    }
    
}
