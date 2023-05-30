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
  
  let videoExtensions = ["mov", "avi", "mp4", "webm"]
  let audioExtensions = ["ogg", "mp3", "aac", "wav", "aif", "aiff", "m4a"]
  let imageExtensions = ["jpg", "jpeg", "tiff", "png", "psd"]
  
  let progressIndicator = NSProgressIndicator()
  var task = Process()
  
  var progressMenuItem = NSMenuItem()
  var stopMenuItem = NSMenuItem()
  
  var processViewController: ProcessViewController?
  var popoverPopover = NSPopover()
  var progress: CGFloat = 0.0
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    wantsLayer = true
    registerForDraggedTypes([NSPasteboard.PasteboardType.backwardsCompatibleFileURL])
    
    progressMenuItem.title = "..."
    progressMenuItem.action = #selector(showProcessPopover(_:))
    stopMenuItem.title = "Terminate"
    stopMenuItem.action = #selector(terminateProcess(_:))
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    processViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ProcessViewController")) as? ProcessViewController
    popoverPopover.contentViewController = processViewController
  }
  
  @objc func terminateProcess(_ sender: Any) {
    processViewController?.terminate()
  }
  
  @objc func showProcessPopover(_ sender: Any) {
    popoverPopover.show(relativeTo: bounds, of: self, preferredEdge: .maxY)
  }
  
  func startConverting() {
    task = Process()
    popoverPopover.show(relativeTo: bounds, of: self, preferredEdge: .maxY)
    processViewController?.start(with: task)
    
    progressMenuItem.title = "..."
    if let menu = menu {
      if menu.item(at: 0) != progressMenuItem {
        progressMenuItem.isEnabled = true
        stopMenuItem.isEnabled = true
        menu.insertItem(progressMenuItem, at: 0)
        menu.insertItem(stopMenuItem, at: 1)
        menu.insertItem(NSMenuItem.separator(), at: 2)
      }
    }
  }
  
  func endConverting() {
    popoverPopover.close()
    progress = 0.0
    progressIndicator.doubleValue = 0.0
    menu?.removeItem(at: 2)
    menu?.removeItem(progressMenuItem)
    menu?.removeItem(stopMenuItem)
    needsDisplay = true
    layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    let circleLayer = createRingLayer(dirtyRect)
    layer?.addSublayer(circleLayer)
    
    progressIndicator.frame = frame
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if checkExtension(sender) {
      return .copy
    } else {
      return NSDragOperation()
    }
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    if task.isRunning {
      print("TASK ALREADY RUNNING")
      return false
    }
    startConverting()
    
    guard let pasteboard = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let inputFilePath = pasteboard[0] as? String
    else { return false }
    
    let inputFile = URL(fileURLWithPath: inputFilePath)
    let ext = inputFile.pathExtension.lowercased()
    var newFile = inputFile.deletingPathExtension()
    
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
    
    if videoExtensions.contains(ext) {
      if ext == "mp4" || FileManager.default.fileExists(atPath: newFile.appendingPathExtension("mp4").path) {
        newFile = newFile.deletingLastPathComponent().appendingPathComponent(newFile.lastPathComponent + " copy")
      }
      
      print("New filename: \(newFile)")
      
      task.arguments = [
        "-i", inputFile.lastPathComponent,
        "-c:v", "libx264",
        "-preset", "slow",
        "-profile:v", "high",
        "-crf", String(Preferences.shared.crfQuality),
        "-coder", "1",
        "-pix_fmt", "yuv420p",
        "-movflags", "+faststart",
        "-vf", "colorspace=all=bt709:iall=bt601-6-625:fast=1",
        "-colorspace", "1",
        "-color_primaries", "1",
        "-color_trc", "1",
        "-y"
      ]
      
      if Preferences.shared.resolution != 0 {
        task.arguments?.append(contentsOf: [
          "-s", "hd\(String(Preferences.shared.resolution))",
        ])
      }
      
      task.arguments?.append(contentsOf: [
        "-g", "30",
        "-bf", "2",
        "-c:a", "aac",
        "-b:a", "384k",
        "-profile:a", "aac_low",
        newFile.appendingPathExtension("mp4").lastPathComponent
      ])
      
    } else if imageExtensions.contains(ext), askDuration() {
      if ext == "mp4" || FileManager.default.fileExists(atPath: newFile.appendingPathExtension("mp4").path) {
        newFile = newFile.deletingLastPathComponent().appendingPathComponent(newFile.lastPathComponent + " copy")
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
        "-vf", "colorspace=all=bt709:iall=bt601-6-625:fast=1",
        "-colorspace", "1",
        "-color_primaries", "1",
        "-color_trc", "1",
        newFile.appendingPathExtension("mp4").lastPathComponent
      ]
      
      if Preferences.shared.resolution != 0 {
        task.arguments?.append(contentsOf: [
          "-s", "hd\(String(Preferences.shared.resolution))",
        ])
      }
      
    } else if audioExtensions.contains(ext) {
      if ext == "mp3" || FileManager.default.fileExists(atPath: newFile.appendingPathExtension("mp3").path) {
        newFile = newFile.deletingLastPathComponent().appendingPathComponent(newFile.lastPathComponent + " copy")
      }
      
      print("New filename: \(newFile)")
      
      task.arguments = [
        "-i", inputFile.lastPathComponent,
        "-b:a", "128k",
        newFile.appendingPathExtension("mp3").lastPathComponent,
        "-y"
      ]
      
    } else {
      return false
    }
    
    progress = 0.0
    progressIndicator.doubleValue = 0.0
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    
    pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    
    var duration: Int = 0
    
    NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: pipe.fileHandleForReading, queue: nil) { notification in
      guard let fileHandleForReading = notification.object as? FileHandle else {
        return
      }
      
      guard case let availableData = fileHandleForReading.availableData, availableData.count != 0 else {
        print("STOP CONVERTING")
        self.endConverting()
        return
      }
      
      let output = String(data: availableData, encoding: .utf8) ?? ""
      
      if self.imageExtensions.contains(ext) {
        duration = Int(Preferences.shared.imageDuration) * 100 // seconds
      } else if let durationMatches = output.groups("Duration: (\\d{2}):(\\d{2}):(\\d{2}).(\\d{2})") {
        print("Video duration: \(durationMatches[0])")
        duration = Int(durationMatches[0][4])! // milliseconds
        duration += Int(durationMatches[0][3])! * 100 // seconds
        duration += Int(durationMatches[0][2])! * 100 * 60 // minutes
        duration += Int(durationMatches[0][1])! * 100 * 60 * 60 // hours
      }
      
      if let frameMatches = output.groups("time=(\\d{2}):(\\d{2}):(\\d{2}).(\\d{2})") {
        print("Current frame: \(frameMatches[0])")
        var currentFrame = Int(frameMatches[0][4])! // milliseconds
        currentFrame += Int(frameMatches[0][3])! * 100 // seconds
        currentFrame += Int(frameMatches[0][2])! * 100 * 60 // minutes
        currentFrame += Int(frameMatches[0][1])! * 100 * 60 * 60 // hours
        self.progress = CGFloat(currentFrame) / CGFloat(duration)
        self.processViewController?.updateProgress(self.progress)
        self.needsDisplay = true
        print("progress \(self.progress)")
        self.needsDisplay = true
      }
      
      self.processViewController?.updateInfo(output)
      
      fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
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
  
  private func createRingLayer(_ frame: NSRect) -> CAShapeLayer {
    var path = CGMutablePath()
    let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
    let radius: CGFloat = frame.height / 2 - 4
    let progressColor = NSColor(
      red: (1.0 - progress) * 0.890 + progress * 0.412,
      green: (1.0 - progress) * 0.239 + progress * 0.788,
      blue: (1.0 - progress) * 0.153 + progress * 0.204,
      alpha: 1.0
    )
    
    let base = CAShapeLayer()
    
    let main = CAShapeLayer()
    main.frame = frame
    main.fillColor = nil
    main.lineWidth = 2
    main.fillColor = progress == 0 || progress == 1.0 ? NSColor.darkGray.cgColor : progressColor.cgColor
    path = CGMutablePath()
    path.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
    path.closeSubpath()
    main.path = path
    base.addSublayer(main)
    
    let circle_bg = CAShapeLayer()
    circle_bg.frame = frame
    circle_bg.fillColor = nil
    circle_bg.strokeColor = NSColor.lightGray.cgColor
    circle_bg.lineWidth = 1.5
    path = CGMutablePath()
    path.addArc(center: center, radius: radius + 2, startAngle: .pi / 2, endAngle: .pi / 2 + .pi * 2 * (1 - progress), clockwise: false)
    circle_bg.path = path
    base.addSublayer(circle_bg)
    
    if (progress > 0 && progress < 1) {
      let textLayer = CATextLayer()
      textLayer.frame = frame
      textLayer.fontSize = 8
      textLayer.position = CGPoint(x: center.x, y: center.y - 6 )
      textLayer.alignmentMode = kCAAlignmentCenter;
      textLayer.string = String(Int(round(progress*100)))
      textLayer.foregroundColor = NSColor.black.cgColor
      textLayer.backgroundColor = NSColor.clear.cgColor
      base.addSublayer(textLayer)
      
      let circle_fg = CAShapeLayer()
      circle_fg.frame = frame
      circle_fg.fillColor = nil
      circle_fg.strokeColor = progressColor.cgColor
      circle_fg.lineWidth = 2
      path = CGMutablePath()
      path.addArc(center: center, radius: radius + 2,
                  startAngle: .pi / 2,
                  endAngle: .pi / 2 + .pi * 2 * (1 - progress),
                  clockwise: true)
      circle_fg.path = path
      base.addSublayer(circle_fg)
    }
    
    return base
  }
  
  fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
    guard let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let path = board[0] as? String
    else { return false }
    
    let suffix = URL(fileURLWithPath: path).pathExtension
    for ext in videoExtensions + audioExtensions + imageExtensions {
      if ext.lowercased() == suffix.lowercased() {
        return true
      }
    }
    return false
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
