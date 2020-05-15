//
//  DUXListPanelWidgetStringsModel.swift
//  DJIUXSDKWidgets
//
//  Copyright © 2018-2020 DJI
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

@objc open class DUXListPanelWidgetStringsModel : DUXListPanelWidgetBaseModel {
    
    @objc dynamic override var count: Int {
        get { return optionStrings.count }
        // No setter as this is a dynamic read only property
    }
    public var optionStrings: [String] = []
    
    @objc func setOptionStrings(_ stringList: [String]) {
        optionStrings = stringList
    }
    @objc func addString(_ inString: String) {
        var workList = self.optionStrings
        workList.append(inString)
        self.optionStrings = workList
    }
    @objc func insertString(inString: String, at index:Int) {
        var workList = self.optionStrings
        workList.insert(inString, at: index)
        self.optionStrings = workList
    }

    @objc func removeString(atIndex: Int) {
        var workList = self.optionStrings
        workList.remove(at: atIndex)
        self.optionStrings = workList
    }
    
    @objc func removeAllStrings() {
        self.optionStrings = [String]()
    }
    
    @objc func optionString(at index: Int) -> String {
        return optionStrings[index]
    }
}

