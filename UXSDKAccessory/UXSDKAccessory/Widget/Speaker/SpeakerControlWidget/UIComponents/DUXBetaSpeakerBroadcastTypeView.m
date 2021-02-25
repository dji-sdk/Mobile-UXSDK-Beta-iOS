//
//  DUXBetaSpeakerBroadcastTypeView.m
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

#import "DUXBetaSpeakerBroadcastTypeView.h"

@interface DUXBetaSpeakerBroadcastTypeView ()

@property (nonatomic, strong) UISegmentedControl* segmentedControl;

@end

@implementation DUXBetaSpeakerBroadcastTypeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray* items = @[NSLocalizedString(@"Record Audio", @"Speaker Panel Record Audio Text"), NSLocalizedString(@"Play Recorded Audio", @"Speaker Panel Play Recorded Audio Text")];
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        _segmentControlTintColor = [UIColor whiteColor];
        self.segmentedControl.tintColor = self.segmentControlTintColor;
        [self.segmentedControl setSelectedSegmentIndex:0];
        [self.segmentedControl addTarget:self action:@selector(didSelectedIndex:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.segmentedControl];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.segmentedControl.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
        [self.segmentedControl.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10].active = YES;
        [self.segmentedControl.topAnchor constraintEqualToAnchor:self.topAnchor constant:10].active = YES;
        [self.segmentedControl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10].active = YES;
    }
    return self;
}

- (void)didSelectedIndex:(id)sender {
    if (self.didSelectTypeCallback) {
        self.didSelectTypeCallback(self.segmentedControl.selectedSegmentIndex);
    }
}

- (void)setSegmentControlTintColor:(UIColor *)segmentControlTintColor {
    _segmentControlTintColor = segmentControlTintColor;
    self.segmentedControl.tintColor = segmentControlTintColor;
}

@end
