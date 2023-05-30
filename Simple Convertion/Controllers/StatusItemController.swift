//
//  StatusItemController.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 14.12.18.
//  Copyright © 2018 TiM. All rights reserved.
//
import Cocoa


class StatusItemController: NSObject, NSMenuDelegate {
  
    let statusBarWidth: CGFloat = 20
    let statusBarHeight: CGFloat = NSStatusBar.system.thickness
    
    var statusItem: NSStatusItem!
    var statusBar: StatusBarView!
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    override func awakeFromNib() {
        let systemStatusBar = NSStatusBar.system
        statusItem = systemStatusBar.statusItem(withLength: self.statusBarWidth)
        
        statusBar = StatusBarView(frame:NSRect(x: 0, y: 0, width: self.statusBarWidth, height: statusBarHeight))
      
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showPopover)
        //statusItem.highlightMode = true
        //statusBar.menu = statusMenu
        //statusMenu.delegate = self
        //statusItem.menu = statusMenu
        statusItem.button?.addSubview(statusBar)
    }
    
    @objc func showPopover() {        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SettingsViewController")) as? SettingsViewController else {
            fatalError("Unable to find SettingsViewController")
        }
    
        guard let button = statusItem.button else {
            fatalError("Couldn't find status item button")
        }
    
        let popoverView = NSPopover()
        popoverView.contentViewController = viewcontroller
        popoverView.behavior = .transient
        popoverView.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        statusBar.popoverPopover.close()
    }
    
    @IBAction func Quit(_ sender: Any) {
        NSApplication.shared.terminate(sender)
    }
    
    @IBAction func showSettings(_ sender: Any) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ViewController")) as? PreferencesController else {
            fatalError("Why cant i find PreferencesController? - Check Main.storyboard")
        }
        
        guard let button = statusItem.button else {
            fatalError("Couldn't find status item button")
        }
        
        let popoverView = NSPopover()
        popoverView.contentViewController = viewcontroller
        popoverView.behavior = .transient
        popoverView.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }
}
