//
//  DUXBetaSpeakerUploadSession.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DUXBetaSpeakerUploadSessionState) {
    DUXBetaSpeakerUploadSessionStateIdle,
    DUXBetaSpeakerUploadSessionStateRecordingAndUpdating,
    DUXBetaSpeakerUploadSessionStateRecordingSuccessFinished,
    DUXBetaSpeakerUploadSessionStateRecordingFailureFinished,
    DUXBetaSpeakerUploadSessionStateUpdating,
    DUXBetaSpeakerUploadSessionStateCancelled,
    DUXBetaSpeakerUploadSessionStateUpdatingSuccess,
    DUXBetaSpeakerUploadSessionStateUpdatingFailed
};

typedef NS_ENUM(NSUInteger, DUXBetaSpeakerUploadSessionType) {
    DUXBetaSpeakerUploadSessionTypeInstant,
    DUXBetaSpeakerUploadSessionTypeSaveToPlayList,
};

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSpeakerUploadSession : NSObject

+ (instancetype)instantUploadSession;

+ (instancetype)listUploadSession;

@property (nonatomic, assign, readonly) DUXBetaSpeakerUploadSessionState state;

@property (nonatomic, assign, readonly) DUXBetaSpeakerUploadSessionType type;
@property (nonatomic, copy) void (^playingFinishCallback)(void);

+ (void)requestMicrophoneAuthorizationWithResults:(void(^)(BOOL isSuccess))results;

// Recording and updating
- (void)startRecordingAndUploadingWithBlock:(void(^)(NSUInteger sendSize,NSUInteger totalSize))updateBlock completion:(void(^)(NSError* error))completion;
- (void)stopRecording;
- (void)cancelUpdating;

// Cancel
- (void)cancelAllOperations;

@end

NS_ASSUME_NONNULL_END
