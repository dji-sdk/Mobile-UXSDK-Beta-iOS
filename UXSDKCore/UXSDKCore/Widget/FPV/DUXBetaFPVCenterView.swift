//
//  DUXBetaFPVCenterView.swift
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

import UIKit

/**
 *  Displays an icon based control.
*/
@objcMembers public class DUXBetaFPVCenterView: UIImageView {

    /// The image view type enum value that is read and stored into DefaultGlobalPreferences.
    /// Default value .unkwnown
    public var imageType: FPVCenterViewType = DUXBetaSingleton.sharedGlobalPreferences().centerViewType() {
        didSet {
            //Save the current image type to DefaultGlobalPreferences
            DUXBetaSingleton.sharedGlobalPreferences().set(centerViewType: imageType)
            image = imageType.image
        }
    }
    
    /// The color view type enum value that is read and stored into DefaultGlobalPreferences.
    /// Default value .unkwnown
    public var colorType: FPVCenterViewColor = DUXBetaSingleton.sharedGlobalPreferences().centerViewColor() {
        didSet {
            //Save the current color type to DefaultGlobalPreferences
            DUXBetaSingleton.sharedGlobalPreferences().set(centerViewColor: colorType)
            tintColor = colorType.color
        }
    }
    
    /// The color of the center view image.
    public var color: UIColor? = nil {
        didSet {
            if let c = color {
                tintColor = c
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        image = imageType.image
        tintColor = colorType.color
        contentMode = .scaleAspectFit
        backgroundColor = .clear
    }
}

/**
*   The FPVCenterViewType extension to define a computed property that
*   returns the UIImage associated with each enum value.
*/
extension FPVCenterViewType {

    public var image: UIImage? {
        var imageName = ""
        switch self {
            case .Standard:         imageName = "CenterPointCircle"
            case .Cross:            imageName = "CenterPointCross"
            case .NarrowCross:      imageName = "CenterPointNarrowCross"
            case .Frame:            imageName = "CenterPointFrame"
            case .FrameAndCross:    imageName = "CenterPointFrameAndCross"
            case .Square:           imageName = "CenterPointSquare"
            case .SquareAndCross:   imageName = "CenterPointSquareAndCross"
            case .Unknown:          return nil
            default: break
        }
        return UIImage.duxbeta_image(withAssetNamed: imageName).withRenderingMode(.alwaysTemplate)
    }
}

/**
*   The FPVCenterViewColor extension to define a computed property that
*   returns the UIColor associated with each enum value.
*/
extension FPVCenterViewColor {
    
    public var color: UIColor {
        switch self {
            case .Red : return UIColor.uxsdk_fpvCenterPointRed()
            case .Blue: return UIColor.uxsdk_selectedBlue()
            case .White: return UIColor.uxsdk_white()
            case .Green: return UIColor.uxsdk_good()
            case .Black: return UIColor.uxsdk_black()
            case .Yellow: return UIColor.uxsdk_warning()
            default: return UIColor.clear
        }
    }
}
