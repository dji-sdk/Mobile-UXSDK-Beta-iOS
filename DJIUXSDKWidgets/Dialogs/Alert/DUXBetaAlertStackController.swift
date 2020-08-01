//
//  DUXBetaAlertStackController.swift
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

/**
 * This class keeps track of the visible alerts currently displayed on screen.
*/
@objcMembers public class DUXBetaAlertStackController: NSObject {
    
    // MARK: Public Class Property
    
    /// The singleton instance to be used by an alert view.
    public static var defaultStack: DUXBetaAlertStackController {
        return self.instance
    }
    
    // MARK: Public Property
    
    /// The alert instance that is currenlty visible on screen.
    public var topAlert: DUXBetaAlertView? {
        return stack.last
    }
    
    // MARK: Private Properties
    
    fileprivate var stack: [DUXBetaAlertView] = []
    fileprivate static let instance = DUXBetaAlertStackController()
    
    // MARK: Public Methods
    
    /**
     * This method is reposnsible for verifying if an alert was already displayed.
     *
     * - Parameters:
     *      - alertView: The alert view instance that needs to be verified.
     *
     * - Returns: A boolean value indicating if the alert view is already displayed
     */
    public func contains(alertView: DUXBetaAlertView) -> Bool {
        if topAlert == alertView { return true }
        return stack.contains(alertView)
    }
    
    /**
     * This method adds the alert view to the list of alerts already on screen.
     *
     * - Parameters:
     *      -   alertView: The alert view that is visibile.
     */
    public func push(alertView: DUXBetaAlertView) {
        guard contains(alertView: alertView) == false else { return }
        stack.append(alertView)
    }
    
    /**
     * This methods removes the visible alert from the list of alerts already on screen.
     *
     * - Returns: The alert view that was top-most on screen.
     */
    @discardableResult
    public func pop() -> DUXBetaAlertView {
        return stack.removeLast()
    }
    
    /**
     * This method is responsible for closing the currenlty displayed alert view and it removes
     * all the refrences to any alert view that were previsoulsy displayed.
     */
    public func clear() {
        topAlert?.close()
        stack.removeAll()
    }
}
