//
//  DUXBetaListPanelWidgetStringsModel.swift
//  UXSDKCore
//
//  MIT License
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

/**
 * DUXBetaListPanelWidgetStringsModel subclasses DUXBetaListPanelWidgetBaseModel to support strings for lists of options.
*/
@objcMembers open class DUXBetaListPanelWidgetStringsModel : DUXBetaListPanelWidgetBaseModel {
    // MARK: - Public Variables
    /// The nuber of strings contained in this model
    dynamic override var count: Int {
        get { return optionStrings.count }
        // No setter as this is a dynamic read only property
    }

    // An array of strings available in this model
    public var optionStrings: [String] = []
    
    /**
     * The method addString appends a new string to the list of strings containd in the model.
     *
     * - Parameter inString: The new string to add to the model strings list.
     */
    open func addString(_ inString: String) {
        var workList = optionStrings
        workList.append(inString)
        optionStrings = workList
    }

    /**
     * The method insertString inserts a new string at a specified position in the existing strings list.
     *
     * - Parameter inString: The new string to add to the strings list.
     * - Parameter: at: - The index to insert the new string into.
     */
    open func insertString(inString: String, at index:Int) {
        var workList = optionStrings
        workList.insert(inString, at: index)
        optionStrings = workList
    }

    /**
     * The method removeString removes the string at the specified index from the strings list.
     *
     * - Parameter atIndex: The index to remove the string from.
     */
    open func removeString(atIndex: Int) {
        var workList = optionStrings
        workList.remove(at: atIndex)
        optionStrings = workList
    }
    
    /**
     * The method removeAllStrings removes all the strings from the string list in the model.
     */
    open func removeAllStrings() {
        optionStrings = [String]()
    }
    
    /**
     * The method optionString returns the string from the specified index.
     *
     * - Parameter at: The index to return the option string from.
     */
    open func optionString(at index: Int) -> String {
        return optionStrings[index]
    }
}

