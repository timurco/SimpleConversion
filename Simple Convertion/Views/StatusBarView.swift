//
//  StatusBarView.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 14.12.18.
//  Copyright © 2018 TiM. All rights reserved.
//


import Cocoa

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
    
    let video_ext = ["mov","avi","mp4"]
    let audio_ext = ["ogg", "mp3", "aac", "wav", "aif", "aiff", "m4a"]
    let image_ext = ["jpg", "jpeg", "tiff", "png" ]
    
    let progressIndicator = NSProgressIndicator()
    var task = Process()
    
    var progressMenuItem = NSMenuItem()
    var stopMenuItem = NSMenuItem()
    
    var processViewController: ProcessViewController?
    var popoverPopover = NSPopover()
    
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
        popoverPopover.behavior = .semitransient
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
        self.progressIndicator.doubleValue = 0.0
        self.menu?.removeItem(at: 2)
        self.menu?.removeItem(self.progressMenuItem)
        self.menu?.removeItem(self.stopMenuItem)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let w = dirtyRect.size.width
        let h = dirtyRect.size.height
        
        /*let frame = NSRect(x:(w-h)/2, y:2, width: h-4, height: h-4)
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let circlePath = NSBezierPath()
        circlePath.appendArc(withCenter: NSPoint(x: 0, y: 0), radius: (frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
        
        let circleLayer = CAShapeLayer()
        
        circleLayer.path = circlePath
        circleLayer.fillColor = NSColor.clear.cgColor
        circleLayer.strokeColor = color.cgColor
        circleLayer.lineWidth = 5.0;
        
        circleLayer.strokeEnd = 1.0
        circleLayer.frame = frame

        self.addSubview(circleLayer)*/
        
        self.progressIndicator.frame = NSRect(x:(w-h)/2, y:2, width: h-4, height: h-4)
        // ------ appearance

        self.progressIndicator.style = .spinning
        //let hueAdjust = CIFilter(name: "CIHueAdjust", withInputParameters: ["inputAngle": NSNumber(value: 1.7)])!
        //self.progressIndicator.contentFilters = [hueAdjust]
        //self.progressIndicator.layer?.backgroundColor = CGColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        // ------ data
        self.progressIndicator.isIndeterminate = false
        self.progressIndicator.doubleValue = 0
        self.addSubview(self.progressIndicator)
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
            if ext.lowercased() == suffix {
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
            
        } else if (self.image_ext.contains(ext)) {
            // ffmpeg -loop 1 -i "676х468.jpeg" -c:v libx264 -t 5 -pix_fmt yuv420p -crf 20 -preset slow "676х468.mp4"
            
            if (ext == "mp4" || FileManager.default.fileExists(atPath: newfile.appendingPathExtension("mp4").path)) {
                newfile = newfile.deletingLastPathComponent().appendingPathComponent( newfile.lastPathComponent + " copy" )
            }
            task.arguments = [
                "-i", inputFile.lastPathComponent,
                "-loop", "1",
                "-c:v", "libx264",
                "-crf", String(Preferences.shared.crfQuality),
                "-t", String(5),
                "-preset", "slow",
                "-pix_fmt", "yuv420p",
                "-movflags", "+faststart",
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
            
        } else if (self.audio_ext.contains(ext)) {
            
            if (ext == "mp3" || FileManager.default.fileExists(atPath: newfile.appendingPathExtension("mp3").path)) {
                newfile = newfile.deletingLastPathComponent().appendingPathComponent( newfile.lastPathComponent + " copy" )
            }
            
            print("New filename: \(newfile)")
            
            task.arguments = [
                "-i", inputFile.lastPathComponent,
                "-b:a", "128k",
                newfile.appendingPathExtension("mp3").lastPathComponent,
            ]
            
        } else {
            return false
        }
        
        self.progressIndicator.doubleValue = 0.0
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        
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
            
            if let durationMatches = output.groups("Duration: (\\d{2}):(\\d{2}):(\\d{2}).(\\d{2})") {
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
                let progressValue = Double(currentFrame)/Double(duration)*100.0
                self.processViewController?.updateProgress(progressValue)
                self.progressIndicator.doubleValue = progressValue
                self.progressMenuItem.title = "... \(String(Int(progressValue)))%"
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
