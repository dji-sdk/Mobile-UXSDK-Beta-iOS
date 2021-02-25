//
//  DUXBetaSpeakerRecordAudioView.h
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
#import "DUXBetaSpeakerRecordButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSpeakerRecordAudioView : UIView

- (instancetype)initWithFrame:(CGRect)frame andMediaSyncer:(DUXBetaSpeakerMediaListSyncer *)syncer;

@property (nonatomic, strong) DUXBetaSpeakerRecordButton* recordButton;

@property (nullable, nonatomic, strong) UIColor *playImmediatelySwitchOnTintColor;
@property (null_resettable, nonatomic, strong) UIColor *playImmediatelySwitchTintColor;
@property (nullable, nonatomic, strong) UIColor *playImmediatelySwitchThumbTintColor;

@property (nullable, nonatomic, strong) UIImage *playImmediatelySwitchOnImage;
@property (nullable, nonatomic, strong) UIImage *playImmediatelySwitchOffImage;

@property (nullable, nonatomic, strong) UIColor *persistSwitchOnTintColor;
@property (null_resettable, nonatomic, strong) UIColor *persistSwitchTintColor;
@property (nullable, nonatomic, strong) UIColor *persistSwitchThumbTintColor;

@property (nullable, nonatomic, strong) UIImage *persistSwitchOnImage;
@property (nullable, nonatomic, strong) UIImage *persistSwitchOffImage;

@property (nonatomic, strong) NSString *playImmediatelyLabelText;
@property (nonatomic, strong) UIColor *playImmediatelyLabelTextColor;
@property (nonatomic, strong) UIFont *playImmediatelyLabelFont;

@property (nonatomic, strong) NSString *persistLabelText;
@property (nonatomic, strong) UIColor *persistLabelTextColor;
@property (nonatomic, strong) UIFont *persistLabelFont;

@property (nonatomic, strong) NSString *persistMessageLabelText;
@property (nonatomic, strong) UIColor *persistMessageLabelTextColor;
@property (nonatomic, strong) UIFont *persistMessageLabelFont;

@property (nonatomic, copy) void (^startNewInstantSessionCallback)(void);
@property (nonatomic, copy) void (^startNewListSessionCallback)(void);

- (void)reset;

@end

NS_ASSUME_NONNULL_END
