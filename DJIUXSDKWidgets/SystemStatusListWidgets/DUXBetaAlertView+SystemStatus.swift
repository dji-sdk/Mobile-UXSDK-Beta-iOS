//
//  DUXBetaAlertView+SystemStatus.swift
//  DJIUXSDKWidgets
//
//  MIT License
//  
//  Copyright © 2020 DJI
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
 * Extension that adds convenience methods for creating alerts
 * used to display messages in the System Status List Item Widgets.
 */
public extension DUXBetaAlertView {
    
    /// The alert appearance specific to the system status list item widgets.
    @objc static var systemAlertAppearance: DUXBetaAlertViewAppearance {
        let appearance = DUXBetaAlertViewAppearance()
        appearance.backgroundColor = .duxbeta_black()
        appearance.headerLayoutType = .horizontal
        appearance.headerLayoutSpacing = 10.0
        appearance.alertLayoutSpacing = 10.0
        appearance.shouldDismissOnTap = true
        return appearance
    }
    
    /**
     * This method is creating an alert having a warning icon.
     *
     * - Parameters:
     *      - title: The title of the alert.
     *      - message: The message displayed by the alert.
     *      - heightScale: The height scale factor used to compute the actual height of the alert.
     *
     * - Returns: A custom alert view instance displaying the warning icon.
     */
    @objc static func warningAlert(title: String, message: String, heightScale: DUXBetaAlertViewHeightScale = .medium) -> DUXBetaAlertView {
        let alert = DUXBetaAlertView.defaultAlert(title: title, message: message, heightScale: heightScale)
        alert.image = UIImage.duxbeta_image(withAssetNamed: "WarningIcon")
        alert.appearance.imageTintColor = .duxbeta_alertWarning()
        return alert
    }
    
    /**
     * This method is creating an alert having a success icon.
     *
     * - Parameters:
     *      - title: The title of the alert.
     *      - message: The message displayed by the alert.
     *      - heightScale: The height scale factor used to compute the actual height of the alert.
     *
     * - Returns: A custom alert view instance displaying the warning icon.
     */
    @objc static func successAlert(title: String, message: String, heightScale: DUXBetaAlertViewHeightScale = .medium) -> DUXBetaAlertView {
        let alert = DUXBetaAlertView.defaultAlert(title: title, message: message, heightScale: heightScale)
        alert.image = UIImage.duxbeta_image(withAssetNamed: "SuccessIcon")
        alert.appearance.imageTintColor = .duxbeta_success()
        return alert
    }
    /**
     * This method is creating an alert having an error icon.
     *
     * - Parameters:
     *      - title: The title of the alert.
     *      - message: The message displayed by the alert.
     *      - heightScale: The height scale factor used to compute the actual height of the alert.
     *
     * - Returns: A custom alert view instance displaying the warning icon.
     */
    @objc static func failAlert(title: String, message: String, heightScale: DUXBetaAlertViewHeightScale = .medium) -> DUXBetaAlertView {
        let alert = DUXBetaAlertView.defaultAlert(title: title, message: message, heightScale: heightScale)
        alert.image = UIImage.duxbeta_image(withAssetNamed: "ErrorIcon")
        alert.appearance.imageTintColor = .duxbeta_danger()
        return alert
    }
    
    // MARK: - Private Methods
    
    fileprivate static func defaultAlert(title: String, message: String, heightScale: DUXBetaAlertViewHeightScale = .medium) -> DUXBetaAlertView {
        let alert = DUXBetaAlertView()
        alert.appearance.heightScale = heightScale
        alert.titleText = title
        alert.message = message
        return alert
    }
}
