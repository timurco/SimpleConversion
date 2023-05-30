//
//  StatusBarView.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 14.12.18.
//  Copyright © 2018 TiM. All rights reserved.
//


import Cocoa
import CoreGraphics

extension NSPasteboard.PasteboardType {
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.fileURL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
        }
    } ()
}

class StatusBarView: NSView {
    var filePath: String?
    
    let video_ext = ["mov","avi","mp4", "webm"]
    let audio_ext = ["ogg", "mp3", "aac", "wav", "aif", "aiff", "m4a"]
    let image_ext = ["jpg", "jpeg", "tiff", "png", "psd" ]
    
    let progressIndicator = NSProgressIndicator()
    var task = Process()
    
    var progressMenuItem = NSMenuItem()
    var stopMenuItem = NSMenuItem()
    
    var processViewController: ProcessViewController?
    var popoverPopover = NSPopover()
    var progress = CGFloat(0);
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        /*self.layer?.cornerRadius = 2
        self.layer?.masksToBounds = true
        self.layer?.borderWidth = 1
        self.layer?.borderColor = CGColor(gray: 0.3, alpha: 1.0)
        self.layer?.backgroundColor = CGColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)*/
        registerForDraggedTypes([NSPasteboard.PasteboardType.backwardsCompatibleFileURL])
        
        progressMenuItem.title = "..."
        progressMenuItem.action = #selector(StatusBarView.showProcessPopover(_:))
        stopMenuItem.title = "Terminate"
        stopMenuItem.action = #selector(StatusBarView.terminateProcess(_:))
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        processViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ProcessViewController")) as? ProcessViewController
        popoverPopover.contentViewController = processViewController
        //popoverPopover.behavior = .semitransient
    }
    
    @objc public func terminateProcess(_ sender: Any) {
        processViewController?.terminate()
    }
    
    @objc public func showProcessPopover(_ sender: Any) {
        popoverPopover.show(relativeTo: self.bounds, of: self, preferredEdge: .maxY)
    }
    
    func startConverting() {
        task = Process()
        popoverPopover.show(relativeTo: self.bounds, of: self, preferredEdge: .maxY)
        processViewController?.start(with: task)
        
        self.progressMenuItem.title = "..."
        if (self.menu?.item(at: 0) != self.progressMenuItem) {
            self.progressMenuItem.isEnabled = true
            self.stopMenuItem.isEnabled = true
            self.menu?.insertItem(self.progressMenuItem, at: 0)
            self.menu?.insertItem(self.stopMenuItem, at: 1)
            self.menu?.insertItem(NSMenuItem.separator(), at: 2)
        }
    }
    
    func endConverting() {
        popoverPopover.close()
        self.progress = 0.0
        self.progressIndicator.doubleValue = 0.0
        self.menu?.removeItem(at: 2)
        self.menu?.removeItem(self.progressMenuItem)
        self.menu?.removeItem(self.stopMenuItem)
        self.needsDisplay = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func Ring(_ frame: NSRect) -> CAShapeLayer {
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius: CGFloat = frame.width/2-3
        let ringWidth: CGFloat = 2

        let base = CAShapeLayer()
        
        
        
        let disc = CAShapeLayer()
        disc.frame = frame
        let r:CGFloat  = (1.0 - progress) * 1   + progress * 0
        let g:CGFloat = (1.0 - progress) * 0 + progress * 1
        let b:CGFloat  = (1.0 - progress) * 0  + progress * 0
        
        disc.fillColor = NSColor(red: r, green: g, blue: b, alpha: 1.0).cgColor
        disc.strokeColor = nil
        let ringPath = CGMutablePath()
        //ringPath.addArc(center: center, radius: radius + ringWidth / 2 + slop, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        ringPath.addArc(center: center, radius: radius + ringWidth/2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        ringPath.closeSubpath()
        disc.path = ringPath
        base.addSublayer(disc)

        let wedge = CAShapeLayer()
        wedge.frame = frame
        wedge.fillColor = progress>0 ? NSColor.darkGray.cgColor : NSColor(red: 0.36, green: 0.7, blue: 0.5, alpha: 1).cgColor
        wedge.strokeColor = nil
        let wedgePath = CGMutablePath()
        wedgePath.move(to: center)
        wedgePath.addArc(center: center, radius: radius + ringWidth / 2, startAngle: .pi/2, endAngle: .pi/2 + .pi*2*(1-progress), clockwise: false)
        wedgePath.closeSubpath()
        wedge.path = wedgePath
        base.addSublayer(wedge)
//
        if progress>0 {
            let mask = CAShapeLayer()
            mask.frame = frame
            mask.fillColor = nil
            mask.strokeColor = NSColor.white.cgColor
            mask.lineWidth = ringWidth
            let maskPath = CGMutablePath()
            maskPath.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            maskPath.closeSubpath()
            mask.path = maskPath
            
            base.mask = mask
        }
        
        return base
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let w = dirtyRect.size.width
        let h = dirtyRect.size.height
        
        let frame = NSRect(x:(w-h)/2, y:2, width: h-4, height: h-4);
        let circleLayer = Ring(frame)
        self.layer?.addSublayer(circleLayer)
        
        self.progressIndicator.frame = NSRect(x:(w-h)/2, y:2, width: h-4, height: h-4)
        // ------ appearance

//        self.progressIndicator.style = .spinning
        //let hueAdjust = CIFilter(name: "CIHueAdjust", withInputParameters: ["inputAngle": NSNumber(value: 1.7)])!
        //self.progressIndicator.contentFilters = [hueAdjust]
        //self.progressIndicator.layer?.backgroundColor = CGColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        // ------ data
//        self.progressIndicator.isIndeterminate = false
//        self.progressIndicator.doubleValue = 0
//        self.addSubview(self.progressIndicator)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            //self.layer?.backgroundColor = NSColor.blue.cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }
        
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in (self.video_ext + self.audio_ext + self.image_ext) {
            if ext.lowercased() == suffix.lowercased() {
                return true
            }
        }
        return false
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        //self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        //self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if (task.isRunning) {
            print("TASK ALREADY RUNNING")
            return false
        }
        startConverting()
        
        guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let inputFilePath = pasteboard[0] as? String
            else { return false }
        
        let inputFile = URL(fileURLWithPath: inputFilePath)
        let ext = inputFile.pathExtension.lowercased()
        var newfile = inputFile.deletingPathExtension()
        //=================================================================================
        //==========================  FFMPEG Bundle  ======================================
        //=================================================================================
        task.launchPath = Bundle.main.path(forResource: "ffmpeg", ofType: "")
        task.currentDirectoryPath = inputFile.deletingLastPathComponent().path

        print("Current extension: \(ext)")
        
        func askDuration() -> Bool {
            let alert = NSAlert()
            
            
            let textfield = NSTextField(frame: NSRect(x: 00.0, y: 0.0, width: 100.0, height: 24.0))
            textfield.integerValue = Preferences.shared.imageDuration
            alert.accessoryView = textfield
            
            alert.messageText = "Converting images to video"
            alert.informativeText = "Please describe duration in seconds:"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                Preferences.shared.imageDuration = textfield.integerValue
                NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"), object: nil)
                print(textfield.integerValue)
                return true
            } else {
                return false
            }
        }
        
        if (self.video_ext.contains(ext)) {
            if (ext == "mp4" || FileManager.default.fileExists(atPath: newfile.appendingPathExtension("mp4").path)) {
                newfile = newfile.deletingLastPathComponent().appendingPathComponent( newfile.lastPathComponent + " copy" )
            }
            print("New filename: \(newfile)")
            //https://www.virag.si/2015/06/encoding-videos-for-youtube-with-ffmpeg/
            task.arguments = [
                "-i", inputFile.lastPathComponent,
                "-c:v", "libx264",
                "-preset", "slow",
                "-profile:v", "high",
                "-crf", String(Preferences.shared.crfQuality),
                "-coder", "1",
                "-pix_fmt", "yuv420p",
                "-movflags", "+faststart",
                // Color profiles
                "-vf", "colorspace=all=bt709:iall=bt601-6-625:fast=1",
                "-colorspace", "1", "-color_primaries", "1", "-color_trc", "1",
                "-y"
            ]
            if Preferences.shared.resolution != 0 {
                task.arguments? += [
                    "-s","hd\(String(Preferences.shared.resolution))",
                ]
            }
            task.arguments? += [
                "-g","30",
                "-bf","2",
                "-c:a","aac",
                "-b:a","384k",
                "-profile:a","aac_low",
                newfile.appendingPathExtension("mp4").lastPathComponent
            ]
            
        } else if (self.image_ext.contains(ext) && askDuration()) {
            if (ext == "mp4" || FileManager.default.fileExists(atPath: newfile.appendingPathExtension("mp4").path)) {
                newfile = newfile.deletingLastPathComponent().appendingPathComponent( newfile.lastPathComponent + " copy" )
            }
            task.arguments = [
                "-loop", "1",
                "-i", inputFile.lastPathComponent,
                "-c:v", "libx264",
                "-t", String(Preferences.shared.imageDuration),
                "-pix_fmt", "yuv420p",
                "-crf", String(Preferences.shared.crfQuality),
                "-preset", "slow",
                "-y",
                // Color profiles
                "-vf", "colorspace=all=bt709:iall=bt601-6-625:fast=1",
                "-colorspace", "1", "-color_primaries", "1", "-color_trc", "1",
                //"-color_trc", "iec61966_2_1",
//                "-vf", "colorspace=all=bt709:trc=srgb:format=yuv422p",
                newfile.appendingPathExtension("mp4").lastPathComponent
            ]
            
            if Preferences.shared.resolution != 0 {
                task.arguments? += [
                    "-s","hd\(String(Preferences.shared.resolution))",
                ]
            }
            
        } else if (self.audio_ext.contains(ext)) {
            
            if (ext == "mp3" || FileManager.default.fileExists(atPath: newfile.appendingPathExtension("mp3").path)) {
                newfile = newfile.deletingLastPathComponent().appendingPathComponent( newfile.lastPathComponent + " copy" )
            }
            
            print("New filename: \(newfile)")
            
            task.arguments = [
                "-i", inputFile.lastPathComponent,
                "-b:a", "128k",
                newfile.appendingPathExtension("mp3").lastPathComponent,
                "-y"
            ]
            
        } else {
            return false
        }
        
        self.progress = 0.0
        self.progressIndicator.doubleValue = 0.0
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        //print(task.arguments)
        print("Start")
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        var duration:Int = 0;
        
        NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) { notification in
            guard let fileHandleForReading = notification.object as? FileHandle else {
                return
            }
            
            guard case let availableData = fileHandleForReading.availableData, availableData.count != 0 else {
                print("STOP CONVERTING")
                self.endConverting()
                return
            }
            
            let output = String(data: availableData, encoding: .utf8) ?? ""
            
            if self.image_ext.contains(ext) {
                duration = Int(Preferences.shared.imageDuration)*100 //seconds
            } else if let durationMatches = output.groups("Duration: (\\d{2}):(\\d{2}):(\\d{2}).(\\d{2})") {
                print("Video duration: \(durationMatches[0])")
                duration = Int(durationMatches[0][4])! //millis
                duration += Int(durationMatches[0][3])!*100 //seconds
                duration += Int(durationMatches[0][2])!*100*60 //minutes
                duration += Int(durationMatches[0][1])!*100*60*60 //hours
            }
            
            if let frameMatches = output.groups("time=(\\d{2}):(\\d{2}):(\\d{2}).(\\d{2})") {
                print("Current frame: \(frameMatches[0])")
                var currentFrame = Int(frameMatches[0][4])! //millis
                currentFrame += Int(frameMatches[0][3])!*100 //seconds
                currentFrame += Int(frameMatches[0][2])!*100*60 //minutes
                currentFrame += Int(frameMatches[0][1])!*100*60*60 //hours
                self.progress = Double(currentFrame)/Double(duration)
                self.processViewController?.updateProgress(self.progress)
//                self.progressIndicator.doubleValue = progressValue
                print("progress \(self.progress)")
                self.needsDisplay = true
                print(self.progress)
                //self.progressMenuItem.title = "... \(String(Int(self.progress)))%"
            }
            self.processViewController?.updateInfo(output)
            //print(String(output.count) + " - " + output)
            //-----------------
            fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        
        //NotificationCenter.default.post(name: .NSFileHandleDataAvailable, object: nil)
        NotificationQueue.default.enqueue(Notification(name: .NSFileHandleDataAvailable), postingStyle: .whenIdle)
        
        print("done")
        return true
    }
    
    @objc func showAlert(text: String) {
        let alert = NSAlert()
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}

extension String {
    func matches(_ regex: String) -> [String]? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            if results.count>0 {
                return results.map {
                    String(self[Range($0.range, in: self)!])
                }
            } else {
                return nil
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
    }
    func groups(_ regexPattern: String) -> [[String]]? {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            if matches.count>0 {
                return matches.map { match in
                    return (0..<match.numberOfRanges).map {
                        let rangeBounds = match.range(at: $0)
                        guard let range = Range(rangeBounds, in: text) else {
                            return ""
                        }
                        return String(text[range])
                    }
                }
            } else {
                return nil
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
    }
}
