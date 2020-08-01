//
//  DUXBetaWarningMessage.h
//  DJIUXSDK
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


typedef NS_ENUM(NSInteger, DUXBetaWarningMessageLevel) {
        DUXBetaWarningMessageLevelNotify,
        DUXBetaWarningMessageLevelWarning,
        DUXBetaWarningMessageLevelDangerous,
        DUXBetaWarningMessageLevelUnknown
};

typedef NS_ENUM(NSInteger, DUXBetaWarningMessageType) {
        DUXBetaWarningMessageTypeAutoDisappear,
        DUXBetaWarningMessageTypePush,
        DUXBetaWarningMessageTypePinned,
        DUXBetaWarningMessageTypePinnedNotClose
};

typedef NS_ENUM(NSInteger, DUXBetaWarningMessageAction) {
        DUXBetaWarningMessageActionInsert,
        DUXBetaWarningMessageActionRemove,
        DUXBetaWarningMessageActionUnknown
};

typedef NS_ENUM(NSInteger, DUXBetaWarningMessageWarningType) {
        DUXBetaWarningMessageWarningTypeAir1860,
        DUXBetaWarningMessageWarningTypeBattery,
        DUXBetaWarningMessageWarningTypeCamera,
        DUXBetaWarningMessageWarningTypeCenterBoard,
        DUXBetaWarningMessageWarningTypeOsd,
        DUXBetaWarningMessageWarningTypeFlightController,
        DUXBetaWarningMessageWarningTypeGimbal,
        DUXBetaWarningMessageWarningTypeLightBridge,
        DUXBetaWarningMessageWarningTypeRemoteController,
        DUXBetaWarningMessageWarningTypeVision,
        DUXBetaWarningMessageWarningTypeFlightRecord,
        DUXBetaWarningMessageWarningTypeFlySafe,
        DUXBetaWarningMessageWarningTypeRTK,
        DUXBetaWarningMessageWarningTypeLTE,
        DUXBetaWarningMessageWarningTypeOther
};

@class DUXBetaImmutableWarningMessage;


NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaWarningMessage : NSObject

@property (assign, nonatomic) NSUInteger *code;
@property (assign, nonatomic) NSUInteger *subCode;
@property (assign, nonatomic) NSUInteger *componentIndex;
@property (copy, nonatomic) NSString *reason;
@property (copy, nonatomic) NSString *solution;
@property (assign, nonatomic) enum DUXBetaWarningMessageLevel level;
@property (assign, nonatomic) enum DUXBetaWarningMessageWarningType type;
@property (assign, nonatomic) enum DUXBetaWarningMessageAction action;
@property (assign, nonatomic) NSUInteger *showDuration;

- (instancetype)init;

- (DUXBetaImmutableWarningMessage *)copy;

@end

@interface DUXBetaImmutableWarningMessage : NSObject

@property (assign, nonatomic, readonly) NSUInteger *code;
@property (assign, nonatomic, readonly) NSUInteger *subCode;
@property (assign, nonatomic, readonly) NSUInteger *componentIndex;
@property (copy, nonatomic, readonly) NSString *reason;
@property (copy, nonatomic, readonly) NSString *solution;
@property (assign, nonatomic, readonly) enum DUXBetaWarningMessageLevel level;
@property (assign, nonatomic, readonly) enum DUXBetaWarningMessageWarningType type;
@property (assign, nonatomic, readonly) enum DUXBetaWarningMessageAction action;
@property (assign, nonatomic, readonly) NSUInteger *showDuration;

- (instancetype)initWithMutableMessage:(DUXBetaImmutableWarningMessage *)message;

- (DUXBetaWarningMessage *)mutableCopy;

@end

NS_ASSUME_NONNULL_END
