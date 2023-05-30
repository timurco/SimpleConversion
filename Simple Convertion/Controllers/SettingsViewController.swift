//
//  SettingsViewController.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 02.04.20.
//  Copyright © 2020 TiM. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var resolution: NSSegmentedControl!
    @IBOutlet weak var sliderControl: NSSlider!
    @IBOutlet weak var sliderLabel: NSTextField!
    
    func showExistingPrefs() {
        sliderControl.integerValue = Preferences.shared.crfQuality
        sliderLabel.integerValue = sliderControl.integerValue
        resolution.selectSegment(withTag: Preferences.shared.resolution)
    }
    func saveNewPrefs() {
        Preferences.shared.crfQuality = sliderControl.integerValue
        Preferences.shared.resolution = [0,480,720,1080][resolution.selectedSegment]
        print("Curent selected resolution: \(Preferences.shared.resolution)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"), object: nil)
    }
    
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
    
    @IBAction func QuitButton(_ sender: Any) {
        NSApplication.shared.terminate(sender)
    }
    
    @IBAction func SliderChange(_ sender: Any) {
        sliderLabel.integerValue = sliderControl.integerValue
        saveNewPrefs()
    }
    
    
    @IBAction func ResolutionChange(_ sender: Any) {
        saveNewPrefs()
    }
}
