//
//  DUXBetaAlertViewMask.swift
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
 * The object placed under a DUXBetaAlertView instance
 * that allows the user to tap to close the visible alert view.
 * This container expands as wide as the screen of the device.
 */
@objcMembers public class DUXBetaAlertViewMask: UIView {
    
    // MARK: - Public Properties
    
    /// The alert view instane displayed on top.
    public var alertView: DUXBetaAlertView?
    /// The boolean value that controls if the alert view
    /// should close when tapping this container.
    public var shouldDismissAlertOnTap: Bool? = true
    /// The background color of the view.
    public var maskColor: UIColor? {
        didSet {
            backgroundColor = maskColor
        }
    }
    
    // MARK: - Private Properties
    
    fileprivate static let kAnimationKey = "DUXBetaAlertViewMask_kAnimationKey"
    
    // MARK: - Initialization Methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public Methods
    
    public func addShowAnimation() {
        let animationObject = CABasicAnimation(keyPath: "opacity")
        animationObject.fromValue = NSNumber(0)
        animationObject.toValue = NSNumber(1)
        animationObject.duration = alertView?.appearance.animationDuration ?? 0.3
        layer.add(animationObject, forKey: Self.kAnimationKey)
    }
    
    public func addCloseAnimation() {
        let animationObject = CABasicAnimation(keyPath: "opacity")
        animationObject.fromValue = NSNumber(1)
        animationObject.toValue = NSNumber(0)
        animationObject.duration = alertView?.appearance.animationDuration ?? 0.3
        layer.add(animationObject, forKey: Self.kAnimationKey)
    }
    
    public func removeAnimations() {
        layer.removeAllAnimations()
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupUI() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapGestureRecognizer)
        
        backgroundColor = maskColor
    }
    
    @IBAction func onTap() {
        guard let shouldClose = shouldDismissAlertOnTap, shouldClose else { return }
        alertView?.close(withCompletion: alertView?.dissmissCompletion)
    }
}
