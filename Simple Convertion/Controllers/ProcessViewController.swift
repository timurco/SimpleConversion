//
//  ProcessViewController.swift
//  Simple Convertion
//
//  Created by Tim Constantinov on 14.12.18.
//  Copyright © 2018 TiM. All rights reserved.
//

import Cocoa

class ProcessViewController: NSViewController {
    
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var convertTask: Process?
    var isTerminating = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    public func start(with: Process) {
        isTerminating = false
        convertTask = with
        progressBar.isIndeterminate = true
    }
    
    public func terminate() {
        progressBar.isIndeterminate = true
        updateInfo("Terminating...")
        isTerminating = true
        convertTask?.terminate()
    }
    
    @IBAction func terminateButton(_ sender: Any) {
        self.terminate()
    }
    
    public func updateInfo(_ value: String) {
        if !isTerminating {
            infoLabel.stringValue = value
        }
    }
    
    public func updateProgress(_ progress: Double) {
        if (!isTerminating) {
            progressBar.isIndeterminate = false
            progressBar.doubleValue =  Double(progress * 100)
        }
    }
    
}
