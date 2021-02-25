//
//  DUXBetaSpeakerBottomBar.m
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

#import "DUXBetaSpeakerBottomBar.h"

@interface DUXBetaSpeakerBottomBar ()

@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation DUXBetaSpeakerBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _exitButtonTextColor = [UIColor colorWithRed:16.0/255.0 green:136.0/255.0 blue:242.0/255.0 alpha:1.0];
        _exitButtonFont = [UIFont boldSystemFontOfSize:15.0f];
        
        _hideButtonTextColor = [UIColor whiteColor];
        _hideButtonFont = [UIFont boldSystemFontOfSize:15.0f];
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.clipsToBounds = YES;
    
    self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.exitButton setTitle: NSLocalizedString(@"Exit", @"Speaker Panel Exit Text") forState:UIControlStateNormal];
    [self.exitButton setTitleColor:self.exitButtonTextColor forState:UIControlStateNormal];
    [self.exitButton addTarget:self action:@selector(clickedExitButton) forControlEvents:UIControlEventTouchUpInside];
    self.exitButton.titleLabel.font = self.exitButtonFont;
    [self addSubview:self.exitButton];
    
    self.hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hideButton setTitle:NSLocalizedString(@"Hide", @"Speaker Panel Hide Text") forState:UIControlStateNormal];
    [self.hideButton setTitleColor:self.hideButtonTextColor forState:UIControlStateNormal];
    [self.hideButton addTarget:self action:@selector(clickedHideButton) forControlEvents:UIControlEventTouchUpInside];
    self.hideButton.titleLabel.font = self.hideButtonFont;
    [self addSubview:self.hideButton];
    
    UIView* horiLine = [[UIView alloc] initWithFrame:CGRectZero];
    horiLine.backgroundColor = [UIColor colorWithWhite:180.0/255.0 alpha:0.3];
    [self addSubview:horiLine];
    
    UIView* verLine = [[UIView alloc] initWithFrame:CGRectZero];
    verLine.backgroundColor = [UIColor colorWithWhite:180.0/255.0 alpha:0.3];
    [self addSubview:verLine];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.exitButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.hideButton.translatesAutoresizingMaskIntoConstraints = NO;
    horiLine.translatesAutoresizingMaskIntoConstraints = NO;
    verLine.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.exitButton.topAnchor constraintEqualToAnchor:horiLine.bottomAnchor].active = YES;
    [self.exitButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.exitButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.exitButton.trailingAnchor constraintEqualToAnchor:verLine.leadingAnchor].active = YES;
    
    [self.hideButton.topAnchor constraintEqualToAnchor:horiLine.bottomAnchor].active = YES;
    [self.hideButton.leadingAnchor constraintEqualToAnchor:verLine.trailingAnchor].active = YES;
    [self.hideButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.hideButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    [self.exitButton.widthAnchor constraintEqualToAnchor:self.hideButton.widthAnchor].active = YES;
    
    [horiLine.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [horiLine.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [horiLine.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [horiLine.heightAnchor constraintLessThanOrEqualToConstant:2].active = YES;
    
    [verLine.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [verLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [verLine.widthAnchor constraintEqualToConstant:2].active = YES;
    
    self.heightConstraint = [self.heightAnchor constraintEqualToConstant:0];
    self.heightConstraint.active = YES;
    
    self.state = DUXBetaSpeakerBottomBarStateExitAndHide;
}

- (void)setState:(DUXBetaSpeakerBottomBarState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [self updateButtons];
}

- (void)updateButtons {
    switch (self.state) {
        case DUXBetaSpeakerBottomBarStateExitAndHide: {
            self.heightConstraint.constant = 0;
            [self.exitButton setTitle: NSLocalizedString(@"Exit", @"Speaker Panel Exit Text") forState:UIControlStateNormal];
            [self.exitButton setTitleColor:self.exitButtonTextColor forState:UIControlStateNormal];
            
            [self.hideButton setTitle:NSLocalizedString(@"Hide", @"Speaker Panel Hide Text") forState:UIControlStateNormal];
            [self.hideButton setTitleColor:self.hideButtonTextColor forState:UIControlStateNormal];
        }
            break;
        case DUXBetaSpeakerBottomBarStateCancelAndUploadAgain: {
            self.heightConstraint.constant = 50;
            [self.exitButton setTitle:NSLocalizedString(@"Cancel Upload", @"Speaker Panel Cancel Upload Text") forState:UIControlStateNormal];
            [self.hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [self.hideButton setTitle:NSLocalizedString(@"Upload Again", @"Speaker Panel Upload Again Text") forState:UIControlStateNormal];
            [self.exitButton setTitleColor:[UIColor colorWithRed:16.0/255.0 green:136.0/255.0 blue:242.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
    }
    [self setNeedsLayout];
}

- (void)clickedExitButton {
    if (self.state == DUXBetaSpeakerBottomBarStateCancelAndUploadAgain && self.cancelUploadButtonAction) {
        self.cancelUploadButtonAction();
    }
}

- (void)clickedHideButton {
    if (self.state == DUXBetaSpeakerBottomBarStateCancelAndUploadAgain && self.uploadAgainButtonAction) {
        self.uploadAgainButtonAction();
    }
}

@end
