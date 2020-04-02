//
//  StatusItemController.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 14.12.18.
//  Copyright © 2018 TiM. All rights reserved.
//
import Cocoa


class StatusItemController: NSObject, NSMenuDelegate {
    
    var statusItem: NSStatusItem!
    var statusBar = StatusBarView(frame:NSRect(x: 0, y: 0, width: 24, height: 22))
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    override func awakeFromNib() {
        statusItem = NSStatusBar.system.statusItem(withLength: 24.0)
        statusItem.highlightMode = true
        statusBar.menu = statusMenu
        statusMenu.delegate = self
        //statusItem.menu = statusMenu
        statusItem.button?.addSubview(statusBar)
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
