//
//  DUXBetaHistogramWidgetModel.m
//  UXSDKVisualCamera
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

#import "DUXBetaHistogramWidgetModel.h"


@interface DUXBetaHistogramWidgetModel ()

@property (strong, nonatomic) NSArray<NSNumber *> *histogramData;
@property (assign, nonatomic) BOOL isHistogramEnabled;

@end

@implementation DUXBetaHistogramWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.histogramData = nil;
        self.isHistogramEnabled = YES;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJICameraKey keyWithParam:DJICameraParamVideoHistogramGraph],histogramData);
    BindSDKKey([DJICameraKey keyWithParam:DJICameraParamVideoHistogramEnabled], isHistogramEnabled);
}

- (void)inCleanup {
    UnBindSDK;
}

- (void)enableHistogramWithCompletionBlock:(HistogramActionCompletionBlock)block {
    [[DJISDKManager keyManager] setValue:@(YES) forKey:[DJICameraKey keyWithParam:DJICameraParamVideoHistogramEnabled] withCompletion:^(NSError * _Nullable error) {
        block(error);
    }];
}

- (void)disableHistogramWithCompletionBlock:(HistogramActionCompletionBlock)block {
    [[DJISDKManager keyManager] setValue:@(NO) forKey:[DJICameraKey keyWithParam:DJICameraParamVideoHistogramEnabled] withCompletion:^(NSError * _Nullable error) {
        block(error);
    }];
}

@end
