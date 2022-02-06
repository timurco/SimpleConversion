//
//  PopoverViewController.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 02.04.20.
//  Copyright © 2020 TiM. All rights reserved.
//

import Cocoa

class PopoverViewController: NSTabViewController {
    // Resizing window to view controller size in storyboard:
    // https://stackoverflow.com/a/48869175
    private lazy var tabViewSizes: [String : NSSize] = [:]
    
    override func viewDidLoad() {
        // Add size of first tab to tabViewSizes
        if let viewController = self.tabViewItems.first?.viewController, let title = viewController.title {
            tabViewSizes[title] = viewController.view.frame.size
        }
        super.viewDidLoad()
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        print(tabView)// returns <NSTabView: 0x101e17a10> but what to do with it ?
    }
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        dump(tabViewItem)
    }
    
    override func transition(from fromViewController: NSViewController, to toViewController: NSViewController, options: NSViewController.TransitionOptions, completionHandler completion: (() -> Void)?) {
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            self.updateWindowFrameAnimated(viewController: toViewController)
            super.transition(from: fromViewController, to: toViewController, options: [.crossfade, .allowUserInteraction], completionHandler: completion)
        }, completionHandler: nil)
    }
    
    func updateWindowFrameAnimated(viewController: NSViewController) {
        
        guard let title = viewController.title, let window = view.window else {
            return
        }
        
        let contentSize: NSSize
        
        if tabViewSizes.keys.contains(title) {
            contentSize = tabViewSizes[title]!
        }
        else {
            contentSize = viewController.view.frame.size
            tabViewSizes[title] = contentSize
        }
        
        let newWindowSize = window.frameRect(forContentRect: NSRect(origin: NSPoint.zero, size: contentSize)).size
        print(newWindowSize)
        var frame = window.frame
        frame.origin.y += frame.height
        frame.origin.y -= newWindowSize.height
        frame.size = newWindowSize
        window.animator().setFrame(frame, display: false)
    }
}
