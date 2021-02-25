//
//  DUXBetaGimbalPitchWidgetState.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaGimbalPitchWidgetState : NSObject

//Doc key TODO: DUXBetaGimbalPitchWidgetState_initWithMaxPitch:minPitch:currentPitchValue
/*
 * Used to initialize the object with the maxPitch minPitch and currentPitchValue.
 */
- (instancetype)initWithMaxPitch:(NSInteger)maxPitch minPitch:(NSInteger)minPitch currentPitchValue:(NSInteger)currentPitchValue;

//Doc key TODO: DUXBetaGimbalPitchWidgetState_maxPitch
/*
 * The current maximum pitch of the gimbal.
 */
@property (readonly, nonatomic) NSInteger maxPitch;

//Doc key TODO: DUXBetaGimbalPitchWidgetState_minPitch
/*
 * The current minimum pitch of the gimbal.
 */
@property (readonly, nonatomic) NSInteger minPitch;

//Doc key TODO: DUXBetaGimbalPitchWidgetState_currentPitchValue
/*
 * The current pitch of the gimbal.
 */
@property (readonly, nonatomic) NSInteger currentPitchValue;

@end

NS_ASSUME_NONNULL_END
