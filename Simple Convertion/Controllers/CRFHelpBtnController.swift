//
//  CRFHelpBtnController.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 01.04.20.
//  Copyright © 2020 TiM. All rights reserved.
//

import Cocoa

class CRFHelpBtnController: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func awakeFromNib() {
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseMoved], owner: self, userInfo: nil))
    }
    
    override func resetCursorRects() {
        self.discardCursorRects()
        self.addCursorRect(self.bounds, cursor: .arrow)
    }
    
    override func mouseMoved(with theEvent: NSEvent) {
        NSCursor.pointingHand.set()
    }

    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let url = URL(string: "https://trac.ffmpeg.org/wiki/Encode/H.264")!
        NSWorkspace.shared.open(url)
    }
    
}
