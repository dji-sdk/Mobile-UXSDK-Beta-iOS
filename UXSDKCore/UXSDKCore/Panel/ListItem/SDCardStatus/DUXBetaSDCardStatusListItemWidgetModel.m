//
//  DUXBetaSDCardStatusListItemWidgetModel.m
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

#import "DUXBetaSDCardStatusListItemWidgetModel.h"

@interface DUXBetaSDCardStatusListItemWidgetModel ()

@property (nonatomic, readwrite) DJICameraSDCardOperationState sdOperationState;
@property (nonatomic, readwrite) NSInteger  freeStorageInMB;
@property (nonatomic, readwrite) BOOL       isSDCardInserted;
@property (nonatomic, readwrite) NSError    *formatError;

@end

@implementation DUXBetaSDCardStatusListItemWidgetModel

- (void)inSetup {
    [self bindKeys];
}

- (void)bindKeys {
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamSDCardRemainingSpaceInMB], freeStorageInMB);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamSDCardIsInserted], isSDCardInserted);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamSDCardOperationState], sdOperationState);
}

- (void)inCleanup {
    UnBindSDK;
}

- (void)setPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    if (_preferredCameraIndex != preferredCameraIndex) {
        [self bindKeys];
    }
}

- (NSString *)formatErrorDescription {
    if (self.formatError != nil) {
        return [NSString stringWithFormat:@"\n%@", self.formatError.localizedDescription];
    }
    
    return @"";
}


- (void)formatSDCard {
    __weak DUXBetaSDCardStatusListItemWidgetModel *weakSelf = self;
     DJICameraKey *cameraKey = [DJICameraKey keyWithIndex:_preferredCameraIndex andParam:DJICameraParamFormatStorage];

     [[DJISDKManager keyManager] performActionForKey:cameraKey
                                       withArguments:@[@(DJICameraStorageLocationSDCard)]
                                       andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
         // This completion is only for the performAction method, not for the results of the format action. It will
         // not report when formating is completed, only if there are paraeter errors with this call.
         __strong DUXBetaSDCardStatusListItemWidgetModel *strongSelf = weakSelf;

         strongSelf.formatError = error;
         if (error != nil) {
             strongSelf.sdCardFormatError = YES;
         } else {
             strongSelf.sdCardFormatError = NO;
         }
     }];

}

@end
