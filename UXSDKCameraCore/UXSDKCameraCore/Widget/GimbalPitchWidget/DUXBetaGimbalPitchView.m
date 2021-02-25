//
//  DUXBetaGimbalPitchView.m
//  UXSDKCameraCore
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

#import "DUXBetaGimbalPitchView.h"

@interface DUXBetaGimbalPitchView()

@end

@implementation DUXBetaGimbalPitchView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.pitchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:self.pitchLabel];
    self.pitchLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pitchLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.pitchLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.pitchLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.pitchLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    self.pitchLabel.font = [UIFont systemFontOfSize:10.0f];
    self.pitchLabel.textColor = [UIColor blackColor];
    self.pitchLabel.text = @"0";
    self.pitchLabel.backgroundColor = [UIColor whiteColor];
    self.pitchLabel.layer.cornerRadius = 4.0f;
    self.pitchLabel.textAlignment = NSTextAlignmentCenter;
    self.pitchLabel.layer.masksToBounds = YES;
}

@end
