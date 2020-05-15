//
//  LogCenter.swift
//  DJIUXSDK
//
// Copyright © 2018-2020 DJI
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit

protocol LogCenterListener {
    func logCenterContentDidChange()
}

open class LogCenter: NSObject {

    var printLogWhenAdd = true
    var logs = [LogEntry]()
    var listeners = NSMutableArray()
    var listenersLock = NSLock()
    var logLock = NSLock()
    
    var timeStampFormatter : DateFormatter = {
        var timeStampFormatter = DateFormatter()
        
        timeStampFormatter.dateStyle = .medium
        timeStampFormatter.timeStyle = .medium
        timeStampFormatter.locale = NSLocale.current
        
        return timeStampFormatter
    }()
    
    var diskLogFileDirectory : String = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let logDirectory = "\(documentsDirectory)/DebugLogs"
        let fileManager = FileManager.default
        var isDirectory = ObjCBool(false)

        let fileExists = fileManager.fileExists(atPath: logDirectory, isDirectory: &isDirectory)
        
        if fileExists == false || isDirectory.boolValue == false {
            
            do {
                try fileManager.createDirectory(atPath: logDirectory, withIntermediateDirectories: true, attributes: nil);

                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                let fileURL = URL(fileURLWithPath: logDirectory)
//                try fileURL.setResourceValues(resourceValues)
            } catch {
                NSLog("Error creating logDirectory: \(logDirectory)")
            }
        }
        
        return logDirectory
    }()
    
    var diskLogFileName : String = {
        let logFileFormatter = DateFormatter()
        logFileFormatter.dateFormat = "yyy-MM-dd_HH:mm:ssZ"

        let uniqueName = "logFile_\(logFileFormatter.string(from: Date()))"
        return uniqueName
    }()
    
    var diskLogFilePath : String {
        get {
            return "\(self.diskLogFileDirectory)/\(self.diskLogFileName)"
        }
    }
    
    var diskLogSaveTimer : Timer!
    
    static let `default` : LogCenter = {
        let defaultInstance = LogCenter()
        
        return defaultInstance
    }()
    
    override init() {
        super.init()
        self.diskLogSaveTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [unowned self] (timer) in
            self.saveLogToDisk()
        }
    }
    
    
    func saveLogToDisk() {
        
    }
    
    func add(_ logEntry: String) {
        let newEntry = LogEntry()
        newEntry.message = logEntry
        
        if self.printLogWhenAdd {
            NSLog(logEntry)
        }
        
        self.logLock.lock()
        self.logs.append(newEntry)
        self.logLock.unlock()
        
        self.notifyListeners()
    }
    
    func fullLog() -> String {
        if self.logs.count == 0 {
            return ""
        }
        var fullLog = ""
        
        self.logLock.lock()
        for index in 0..<self.logs.count {
            let logEntry = self.logs[index]
            let timeStamp = self.timeStampFormatter.string(from: logEntry.timestamp)
            fullLog.append("\(timeStamp) - \(logEntry.message)\n")
        }
        self.logLock.unlock()
        
        return fullLog
    }
    
    // MARK: - Log listeners
    
    func add(listener: LogCenterListener) {
        self.listenersLock.lock()
        self.listeners.add(listener)
        self.listenersLock.unlock()
    }
    
    func remove(listener: LogCenterListener) {
        self.listenersLock.lock()
        self.listeners.remove(listener)
        self.listenersLock.unlock()
    }
    
    func notifyListeners() {
        for listener in self.listeners as NSArray as! [LogCenterListener] {
            listener.logCenterContentDidChange()
        }
    }
}
