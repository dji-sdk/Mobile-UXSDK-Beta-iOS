//
//  SliderValueSetting.swift
//  UXSDKBetaSampleApp
//
//  MIT License
//  
//  Copyright © 2021 DJI
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

class SliderValueSetting: DUXBetaListItemTitleWidget {
    
    let slider = UISlider()
    let valueLabel = UILabel()
    var onInitialValue: (() -> Float?)?
    var onValueChanged: ((Float) -> ())?

    override func setupUI() {
        super.setupUI()
        
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 17.0)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        slider.minimumValue = 0
        slider.maximumValue = 20
        slider.isContinuous = false
        slider.tintColor = UIColor.green
        if let value = onInitialValue?() {
            slider.setValue(value, animated: false)
        }
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(valueLabel)
        view.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.widthAnchor.constraint(equalToConstant: 100.0),
            slider.heightAnchor.constraint(equalToConstant: 60.0),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            slider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: slider.leadingAnchor, constant: -30.0)
        ])
    }
    
    @objc func sliderValueChanged() {
        // Round slider value so we get a step of 1
        slider.value = round(slider.value)
        
        valueLabel.text = "\(slider.value)"
        onValueChanged?(slider.value)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        trailingMarginConstraint.isActive = false
        trailingMarginConstraint = trailingTitleGuide.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor)
        trailingMarginConstraint.isActive = true
    }
}
