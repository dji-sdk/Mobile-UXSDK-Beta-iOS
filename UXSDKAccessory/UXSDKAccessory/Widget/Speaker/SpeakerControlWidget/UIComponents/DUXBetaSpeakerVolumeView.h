//
//  DUXBetaSpeakerVolumeView.h
//  UXSDKAccessory
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

#import <UIKit/UIKit.h>
#import "DUXBetaSpeakerMediaListSyncer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSpeakerVolumeView : UIView

- (instancetype)initWithFrame:(CGRect)frame andMediaSyncer:(DUXBetaSpeakerMediaListSyncer *)syncer;

@property (nonatomic, strong) NSString *titleLabelText;
@property (nonatomic, strong) UIColor *titleLabelTextColor;
@property (nonatomic, strong) UIFont *titleLabelFont;

@property (nonatomic, strong) UIColor *speakerVolumePercentageLabelTextColor;
@property (nonatomic, strong) UIFont *speakerVolumePercentageLabelFont;

@property (nonatomic, strong) UIImage *minimumVolumeSliderTrackImage;
@property (nonatomic, strong) UIImage *maximumVolumeSliderTrackImage;
@property (nonatomic, strong) UIImage *volumeSliderThumbImage;

@property (nonatomic, strong) UIColor *minimumVolumeSliderTintColor;
@property (nonatomic, strong) UIColor *maximumVolumeSliderTintColor;
@property (nonatomic, strong) UIColor *volumeSliderThumbTintColor;

@end

NS_ASSUME_NONNULL_END
