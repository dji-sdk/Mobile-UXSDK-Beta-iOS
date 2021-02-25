//
//  BaseSettings.swift
//  UXSDKSampleApp
//
//  Copyright © 2018-2021 DJI
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
import DJIUXSDK

class SettingTitle: DUXBetaListItemTitleWidget {
    
    override func setupUI() {
        titleFont = UIFont.boldSystemFont(ofSize: 20.0)
        titleColor = .gray
        
        super.setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        trailingMarginConstraint.isActive = false
        trailingMarginConstraint = trailingTitleGuide.rightAnchor.constraint(equalTo: view.rightAnchor)
        trailingMarginConstraint.isActive = true
    }
}

class ListSetting: DUXBetaListItemTitleWidget {
    
    var fpvWidget: DUXBetaFPVWidget?
    var current: Int {
        return 0
    }
    
    override func hasDetailList() -> Bool {
        return true
    }
    
    override func detailListType() -> DUXBetaListType {
        .selectOne
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        trailingMarginConstraint.isActive = false
        trailingMarginConstraint = trailingTitleGuide.rightAnchor.constraint(equalTo: view.rightAnchor)
        trailingMarginConstraint.isActive = true
    }
}
