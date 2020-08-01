//
//  DUXBetaAlertLayoutController.swift
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

/**
 * This class is responsible with controlling the position of the alert view on screen
 * also factoring in the keyboard appearance.
*/
@objcMembers public class DUXBetaAlertLayoutController: NSObject {
    
    /// The alert view used by this layout instance.
    public var alert: DUXBetaAlertView?
    
    // MARK: - Private Methods
    
    fileprivate var isKeyboardVisible = false
    
    fileprivate var keyboardFrame = CGRect.zero
    fileprivate var keyboardAnimationDureation: Double = 0.0
    fileprivate var keyboardAnimationOptions: UIView.AnimationOptions = .curveEaseIn
    
    fileprivate var keyboardYOffset: CGFloat {
        if isKeyboardVisible {
            return -keyboardFrame.height
        }
        return 0.0
    }
    
    // MARK: - Initialization Method
    
    public override init() {
        super.init()
        
        bindKeyboardObservers()
    }
    
    // MARK: - Public Methods
    
    /**
     * This method is responsible for creating the center X and Y layout constraints
     * needed to position the alert in the parent view.
     *
     * - Parameters:
     *      - alertView: The alert view instance to be positioned.
     *      - containerView: The parent view instance of the given alert.
     */
    public func layout(alertView: DUXBetaAlertView?, inView containerView: UIView?) {
        alert = alertView
        
        guard let alertView = alertView else { return }
        guard let containerView = containerView else { return }
        
        alertView.centerXConstraint?.isActive = false
        alertView.centerYConstraint?.isActive = false
        alertView.centerXConstraint = alertView.view.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        alertView.centerYConstraint = alertView.view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: keyboardYOffset)
        NSLayoutConstraint.activate([alertView.centerXConstraint!, alertView.centerYConstraint!])
        alertView.view.layoutIfNeeded()
    }
    
    // MARK: - Private Methods
    
    fileprivate func bindKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardVisible = true
        
        if let value = ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]) as AnyObject?)?.cgRectValue {
            keyboardFrame = value
        }
        
        if let value = ((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]) as AnyObject?)?.doubleValue {
            keyboardAnimationDureation = value
        }
        
        if let value = ((notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]) as AnyObject?)?.unsignedIntegerValue {
            keyboardAnimationOptions = UIView.AnimationOptions(rawValue: value)
        }
        
        internalLayout()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboardVisible = false
        internalLayout()
    }
    
    fileprivate func internalLayout() {
        UIView.animate(withDuration: keyboardAnimationDureation,
                       delay: 0,
                       options: keyboardAnimationOptions,
                       animations: { [weak self] in
            self?.alert?.centerYConstraint?.constant = self?.keyboardYOffset ?? 0.0
        }, completion: nil)
    }
}
