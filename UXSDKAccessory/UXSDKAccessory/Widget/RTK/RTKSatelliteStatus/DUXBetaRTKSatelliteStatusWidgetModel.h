//
//  DUXBetaRTKSatelliteStatusWidgetModel.h
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

#import <UXSDKCore/DUXBetaBaseWidgetModel.h>

typedef NS_ENUM(NSUInteger, DUXBetaRTKConnectionStatus) {
    DUXBetaRTKConnectionStatusInUse = 0,
    DUXBetaRTKConnectionStatusNotInUse = 1,
    DUXBetaRTKConnectionStatusDisconnected = 2,
};

typedef NS_ENUM(NSUInteger, DUXBetaRTKSignal) {
    DUXBetaRTKSignalBaseStation = 0,
    DUXBetaRTKSignalDRTK2 = 1,
    DUXBetaRTKSignalNetworkRTK = 2,
    DUXBetaRTKSignalCustomNetwork = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaRTKSatelliteStatusWidgetModel : DUXBetaBaseWidgetModel <DJIRTKDelegate>

@property (assign, nonatomic, readonly) BOOL rtkSupported;

@property (assign, nonatomic, readonly) BOOL rtkInUse;

@property (assign, nonatomic, readonly) BOOL rtkEnabled;

@property (assign, nonatomic, readonly) DUXBetaRTKConnectionStatus rtkConnectionStatus;

@property (assign, nonatomic, readonly) DUXBetaRTKSignal rtkSignal;

@property (assign, nonatomic, readonly) DJIRTKNetworkServiceState *networkServiceState;

@property (assign, nonatomic, readonly) BOOL isHeadingValid;

@property (assign, nonatomic, readonly) NSUInteger locationState;

@property (strong, nonatomic, readonly) NSString *modelName;

@property (strong, nonatomic, readonly) DJIRTKState *rtkState;

@end

NS_ASSUME_NONNULL_END
