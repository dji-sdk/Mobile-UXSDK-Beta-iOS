//
//  DUXBetaSpeakerMediaListSyncer.h
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
#import "DUXBetaSpeakerMediaModel.h"
#import <UXSDKCore/DUXBetaBaseWidgetModel.h>

typedef NS_ENUM(NSUInteger, DUXBetaSpeakerMediaListSyncerState) {
    DUXBetaSpeakerMediaListSyncerStateIdle,
    DUXBetaSpeakerMediaListSyncerStateUpToDate,
    DUXBetaSpeakerMediaListSyncerStateLoading,
    DUXBetaSpeakerMediaListSyncerStateError
};

@interface DUXBetaSpeakerMediaListSyncer : DUXBetaBaseWidgetModel

// For RKVO
@property (nonatomic, assign, readonly) DUXBetaSpeakerMediaListSyncerState state;
@property (nonatomic, strong, readonly) DJIParamCapabilityMinMax *volumeRange;
@property (nonatomic, assign, readonly) NSUInteger volume;
@property (nonatomic, assign, readonly) BOOL isConnected;

// Models
@property (nonatomic, strong, readonly) NSArray<DUXBetaSpeakerMediaModel*>* modelList;
@property (nonatomic, assign, readonly) DJISpeakerPlayMode currentPlayMode;
@property (nonatomic, assign, readonly) NSInteger currentPlayingIndex;

- (void)setSpeakerVolumePercentage:(float)volume completion:(void(^)(NSError *))completion;
- (void)deleteFileWithIndex:(NSUInteger)index completion:(void(^)(NSError *))completion;
- (void)renameFileWithIndex:(NSUInteger)index name:(NSString *)newName completion:(void(^)(NSError *))completion;
- (void)playFileWithIndex:(NSUInteger)index completion:(void(^)(NSError *))completion;
- (void)stopPlayFileWithIndex:(NSUInteger)index completion:(void(^)(NSError *))completion;
- (void)setPlayMode:(DJISpeakerPlayMode)playMode completion:(void(^)(NSError *))completion;
- (void)refreshFileListAndPlayLatestFileOnce;

@end
