//
//  DUXBetaSpeakerMediaListSyncer.m
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

#import "DUXBetaSpeakerMediaListSyncer.h"


NSString * _Nonnull const DUXBetaSpeakerMediaSyncerErrorDomain = @"com.dji.uxsdk.speaker.mediasyncer";

#define duxbeta_SPEAKER_MEDIA_SYNCER_ERROR_CODE (245)

@interface DUXBetaSpeakerMediaListSyncer ()

@property (nonatomic, weak) DJISpeaker* speaker;
@property (nonatomic, assign, readwrite) BOOL isConnected;
@property (nonatomic, strong, readwrite) DJIParamCapabilityMinMax *volumeRange;
@property (nonatomic, assign, readwrite) NSUInteger volume;
@property (nonatomic, strong, readwrite) NSArray<DUXBetaSpeakerMediaModel*>* modelList;
@property (nonatomic, assign, readwrite) DUXBetaSpeakerMediaListSyncerState state;

@property (nonatomic, assign, readwrite) DJIMediaFileListState speakerFileListState;
@property (nonatomic, assign, readwrite) DJISpeakerState *speakerState;

@property (nonatomic, assign) BOOL isAfterRenaming;

@end

@implementation DUXBetaSpeakerMediaListSyncer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isAfterRenaming = NO;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpeakerSubComponent subComponentIndex:0 andParam:DJIAccessoryParamIsConnected], isConnected);
    BindSDKKey([DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpeakerSubComponent subComponentIndex:0 andParam:DJIAccessoryParamVolumeRange], volumeRange);
    BindSDKKey([DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpeakerSubComponent subComponentIndex:0 andParam:DJIAccessoryParamVolume], volume);
}

- (void)inCleanup {
    UnBindSDK;
}

- (void)setIsConnected:(BOOL)isConnected {
    _isConnected = isConnected;
    if (!_isConnected) {
        [self setIdleState];
    } else {
        __weak typeof(self) target = self;
        [self.speaker refreshFileListWithCompletion:^(NSError * _Nullable error) {
            target.speakerFileListState = target.speaker.fileListState;
        }];
    }
}

- (void)setSpeakerFileListState:(DJIMediaFileListState)speakerFileListState {
    _speakerFileListState = speakerFileListState;
    [self syncFileListState];
}

- (DJISpeaker *)speaker {
    if (_speaker) {
        return _speaker;
    }
    DJIAircraft *aircraft = (DJIAircraft *)[DJISDKManager product];
    DJISpeaker* speaker = aircraft.accessoryAggregation.speaker;
    if (_speaker != speaker) {
        [_speaker removeFileListStateListener:self];
        [_speaker removeSpeakerStateListener:self];
        _speaker = speaker;
    }
    if (!_speaker) {
        [self setIdleState];
    } else {
        __weak typeof(self) target = self;
        [_speaker addFileListStateListener:self
                                 withQueue:dispatch_get_main_queue()
                                  andBlock:^(DJIMediaFileListState state) {
                                      target.speakerFileListState = state;
                                  }];
        [self.speaker addSpeakerStateListener:self
                                    withQueue:dispatch_get_main_queue()
                                     andBlock:^(DJISpeakerState * _Nonnull state) {
                                         target.speakerState = state;
                                     }];
        self.speakerFileListState = self.speaker.fileListState;
    }
    return _speaker;
}

- (void)setIdleState {
    self.speakerState = nil;
    self.speakerFileListState = DJIMediaFileListStateUnknown;
    self.modelList = nil;
    self.state = DUXBetaSpeakerMediaListSyncerStateIdle;
}

- (void)syncFileListState {
    switch (self.speakerFileListState) {
        case DJIMediaFileListStateIncomplete:
        case DJIMediaFileListStateReset: {
            self.state = DUXBetaSpeakerMediaListSyncerStateLoading;
            __weak typeof(self) target = self;
            [self.speaker refreshFileListWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    target.state = DUXBetaSpeakerMediaListSyncerStateError;
                }
            }];
        }
            break;
        case DJIMediaFileListStateUpToDate: {
            self.state = DUXBetaSpeakerMediaListSyncerStateUpToDate;
            self.modelList = [self setupMediaModelsWithMediaFiles:self.speaker.fileListSnapshot];
        }
            break;
        case DJIMediaFileListStateDeleting:
        case DJIMediaFileListStateRenaming:
        case DJIMediaFileListStateSyncing: {
            self.state = DUXBetaSpeakerMediaListSyncerStateLoading;
        }
            break;
        case DJIMediaFileListStateUnknown: {
            self.state = DUXBetaSpeakerMediaListSyncerStateError;
        }
            break;
    }
}

- (NSArray<DUXBetaSpeakerMediaModel *>*)setupMediaModelsWithMediaFiles:(NSArray<DJIAudioMediaFile *>*)mediaFiles {
    if (!mediaFiles) { return @[]; }
    
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    NSArray* reversedArray = [[mediaFiles reverseObjectEnumerator] allObjects];
    NSUInteger displayIndex = 1;
    
    for (NSUInteger i = 0; i < reversedArray.count; i ++) {
        DJIAudioMediaFile* audioFile = reversedArray[i];
        DUXBetaSpeakerMediaModel* model = [[DUXBetaSpeakerMediaModel alloc] initWithMediaFile:audioFile displayIndex:displayIndex];
        [tmp addObject:model];
        displayIndex ++;
    }
    
    for (DUXBetaSpeakerMediaModel* model in tmp) {
        model.playMode = _speakerState.playingMode;
        if (model.fileIndex == self.speakerState.playingIndex) {
            model.isPlaying = YES;
        } else {
            model.isPlaying = NO;
        }
    }
    return tmp;
}

- (void)setSpeakerState:(DJISpeakerState *)speakerState {
    if (_speakerState == speakerState) { return; }
    _speakerState = speakerState;
    for (DUXBetaSpeakerMediaModel* model in self.modelList) {
        if (model.fileIndex == _speakerState.playingIndex) {
            model.isPlaying = YES;
        } else {
            model.isPlaying = NO;
        }
        model.playMode = _speakerState.playingMode;
    }
}

- (void)setSpeakerVolumePercentage:(float)volume completion:(void(^)(NSError *))completion {
     [[DJISDKManager keyManager] setValue:@(volume) forKey:[DJIAccessoryKey keyWithIndex:0 subComponent:DJIAccessoryParamSpeakerSubComponent subComponentIndex:0 andParam:DJIAccessoryParamVolume] withCompletion:^(NSError * _Nullable error) {
         completion(error);
     }];
}

- (void)deleteFileWithIndex:(NSUInteger)index completion:(void(^)(NSError *))completion {
    [self.speaker deleteFiles:@[@(index)] withCompletion:^(NSArray<NSNumber *> * _Nonnull failedFiles, NSError * _Nullable error) {
        if (completion) { completion(error); }
    }];
}

- (void)renameFileWithIndex:(NSUInteger)index name:(NSString *)newName completion:(void(^)(NSError *))completion {
    if (newName.length > 20) {
        if (completion) { completion([self errorWithDescription:NSLocalizedString(@"The name is too long.", nil)]); }
        return;
    }
    [self.speaker rename:newName index:index withCompletion:completion];
}

- (void)playFileWithIndex:(NSUInteger)index completion:(void(^)(NSError *))completion {
    if (self.speakerState.playingIndex != -1) {
        __weak typeof(self) target = self;
        [self.speaker stopAudioPlayWithCompletion:^(NSError * _Nullable error) {
            [target.speaker play:index withCompletion:completion];
        }];
    } else {
        [self.speaker play:index withCompletion:completion];
    }
}

- (void)stopPlayFileWithIndex:(NSUInteger)index completion:(void(^)(NSError *))completion {
    [self.speaker stopAudioPlayWithCompletion:completion];
}

- (void)setPlayMode:(DJISpeakerPlayMode)playMode completion:(void(^)(NSError *))completion {
    [self.speaker setPlayMode:playMode withCompletion:completion];
}

- (NSError *)errorWithDescription:(NSString *)description {
    if (description == nil) {
        description = NSLocalizedString(@"Unknown error", nil);
    }
    return [NSError errorWithDomain:DUXBetaSpeakerMediaSyncerErrorDomain code:duxbeta_SPEAKER_MEDIA_SYNCER_ERROR_CODE userInfo:@{NSLocalizedDescriptionKey : description}];
}

- (void)refreshFileListAndPlayLatestFileOnce {
    [self.speaker refreshFileListWithCompletion:^(NSError * _Nullable error) {
        if (!error) {
            NSArray<DUXBetaSpeakerMediaModel *> *list = [self setupMediaModelsWithMediaFiles:self.speaker.fileListSnapshot];
            if (list.count > 0) {
                NSUInteger index = [[list firstObject] fileIndex];
                [self playFileWithIndex:index completion:nil];
            }
        }
    }];
}

@end
