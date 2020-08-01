//
//  DUXBetaBindings.swift
//  DJIUXSDKCore
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

/**
 DUXBetaSwiftBindings - This is an extension that allows the developer to bind the the SDK keys observe changes. It allows writting widgets
 and models in Swift. These are the same functionality as the binding macros written in Objective-C (see
 NSObject+DUXBetaRKVOExtension.h) with one small change.
 When using bindRKVOModel to bind paths, all paths are put into a comma separated list inside a string. This list will
 then be decomposed in the binding extension. This is due to the inability to create a vardic list with multiple KeyPath elements.
 
 In general, where the Objective-C macros do inline replacement of property names, those property names need to be put into
 strings to pass as arguments in Swift.
 
 Any property to be observed or modified in Swift needs to be marked as dynamic.
 Also, any property to be observed from Swift which may be nil, MUST have a strong/weak designation if it is in Objective-C code
 to allow for proper treatment as an optional if needed.
 */

import Foundation

protocol DUXBetaSwiftBindings {
    
    func bindRKVOModel(_ target: NSObject, _ selector: Selector, _ observedKeyPaths: String...)
    func bindRKVOModel(_ target: NSObject, _ selector: Selector, _ observedKeyPaths: String)
    func bindRKVOModel(_ target: NSObject, _ selector: Selector, _ observedKeyPaths: [String])
    func unbindRKVOModel(_ target: NSObject)
    func bindSDKKey(_ key: DJIKey, _ property: String )
    func checkSDKBindPropertyIsValid(_ propertyName: String)
    func unbindSDK(_ target: NSObject)
}

extension NSObject: DUXBetaSwiftBindings {
    
    open func bindRKVOModel(_ target: NSObject, _ selector: Selector, _ observedKeyPaths: String...) {
        bindRKVOModel(target, selector, observedKeyPaths)
    }
    
    open func bindRKVOModel(_ target: NSObject, _ selector: Selector, _ observedKeyPaths: String) {
        let keysArray = observedKeyPaths.components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespaces) })
        bindRKVOModel(target, selector, keysArray)
    }
    
    open func bindRKVOModel(_ target: NSObject, _ selector: Selector, _ keyPaths: [String]) {
        for keyPath in keyPaths {
            duxbeta_bindRKVO(withTarget: target, selector: selector, property: keyPath)
        }
    }
    
    open func unbindRKVOModel(_ target: NSObject) {
        target.duxbeta_unBindRKVO()
    }
    
    open func bindSDKKey(_ key: DJIKey, _ property: String ) {
        self.duxbeta_bindSDKKey(key, propertyName: property)
    }
    
    open func checkSDKBindPropertyIsValid(_ propertyName: String) {
        self.duxbeta_checkSDKBindPropertyIsValid(propertyName)
    }
    
    open func unbindSDK(_ target: NSObject) {
        target.duxbeta_unBindSDK()
    }
}

extension KeyPath where Root: NSObject {
    public var toString: String {
        return NSExpression(forKeyPath: self).keyPath
    }
}
