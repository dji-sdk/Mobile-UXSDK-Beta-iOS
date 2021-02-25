//
//  DUXBetaSpeakerUploadSession.m
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

#import "DUXBetaSpeakerUploadSession.h"
#import <DJISDK/DJISDK.h>
#import <AVFoundation/AVFoundation.h>
#import <UXSDKCore/DUXBetaAudioSource.h>
#import <UXSDKCore/DUXBetaAudioFilePCMParser.h>

#define duxbeta_SPEAKER_UPLOAD_SESSION_ERROR_CODE (245)

NSString * _Nonnull const DUXBetaSpeakerUploadSessionErrorDomain = @"com.dji.uxsdk.speaker.uploadsession";

@interface DUXBetaSpeakerUploadSession () <DUXBetaAudioSourceDelegate, DUXBetaAudioFilePCMParserDelegate>

@property (nonatomic) DUXBetaAudioSource *audioSource;
@property (nonatomic) DUXBetaAudioFilePCMParser *pcmFileParser;

@property (nonatomic, strong) NSString *userDirectoryPath;
@property (nonatomic, strong) NSString *cacheDirectoryPath;

@property (nonatomic, weak) DJISpeaker *speaker;
@property (nonatomic) AVAudioRecorder *recorder;

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign, readwrite) DUXBetaSpeakerUploadSessionState state;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic) dispatch_queue_t ioQueue;
@property (nonatomic) DJIAudioFileInfo *summaryInfo;

@property (nonatomic, copy) void(^uploadProgressBlock)(NSUInteger sendSize,NSUInteger totalSize);
@property (nonatomic, copy) void(^uploadCompleteBlock)(NSError *error);

@property (nonatomic, assign) NSUInteger sentFileSize;
@property (nonatomic, assign) NSUInteger currentFileSize;

@property (nonatomic, assign) DJISpeakerPlayMode lastPlayMode;

@end

@implementation DUXBetaSpeakerUploadSession

+ (instancetype)instantUploadSession {
    NSString* fileName = [NSString stringWithFormat:@"%@",[[self dateFormatter] stringFromDate:[NSDate date]]];
    DUXBetaSpeakerUploadSession* session = [[DUXBetaSpeakerUploadSession alloc]
                                        initWithFileName:fileName
                                        sessionType:DUXBetaSpeakerUploadSessionTypeInstant];
    return session;
}

+ (instancetype)listUploadSession {
    NSString* fileName = [NSString stringWithFormat:@"%@",[[self dateFormatter] stringFromDate:[NSDate date]]];
    DUXBetaSpeakerUploadSession* session = [[DUXBetaSpeakerUploadSession alloc]
                                        initWithFileName:fileName
                                        sessionType:DUXBetaSpeakerUploadSessionTypeSaveToPlayList];
    return session;
}

- (instancetype)initWithFileName:(NSString *)fileName sessionType:(DUXBetaSpeakerUploadSessionType)type {
    self = [super init];
    if (self) {
        if (fileName.length == 0) { return nil; }
        
        self.state = DUXBetaSpeakerUploadSessionStateIdle;
        
        NSString* filePath = nil;
        if (type == DUXBetaSpeakerUploadSessionTypeInstant) {
            [self createConfigDirectoryPathIfNeededWithDirectoryPath:[self cacheDirectoryPath]];
            filePath = [self filePathWithFileName:fileName directoryPath:[self cacheDirectoryPath]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        } else {
            [self createConfigDirectoryPathIfNeededWithDirectoryPath:[self userDirectoryPath]];
            filePath = [self filePathWithFileName:fileName directoryPath:[self userDirectoryPath]];
        }
        
        self.summaryInfo = [[DJIAudioFileInfo alloc] init];
        self.summaryInfo.fileName = fileName;
        self.summaryInfo.storageLocation = (type == DUXBetaSpeakerUploadSessionTypeInstant) ? DJIAudioStorageLocationTemporary: DJIAudioStorageLocationPersistent;
        
        self.fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.aif",filePath]];
        self.audioSource = [[DUXBetaAudioSource alloc] initWithSampleRate:44100 channels:1];
        self.audioSource.delegate = self;
    }
    return self;
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter* dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM_d_HH:mm:ss"];
    });
    return dateFormatter;
}

- (void)cancelAllOperations {
    [self cancelUpdating];
    [self.audioSource stop];
    if (self.fileHandle) {
        [self.fileHandle closeFile];
        self.fileHandle = nil;
    }
}

- (void)startRecordingAndUploadingWithBlock:(void (^)(NSUInteger, NSUInteger))updateBlock completion:(void (^)(NSError *))completion {
    if (self.state != DUXBetaSpeakerUploadSessionStateIdle) {
        NSError* error = [self errorWithDescription:NSLocalizedString(@"Upload session can not start recording because the session has already started.", nil)];
        if (completion) { completion(error); }
        return;
    }
    
    if (!self.summaryInfo.fileName || self.summaryInfo.fileName.length == 0) {
        NSError* error = [self errorWithDescription:NSLocalizedString(@"Upload session can not update because the recorded file was invalid.", nil)];
        if (completion) { completion(error); }
        return;
    }
    
    if (!self.speaker) {
        NSError* error = [self errorWithDescription:NSLocalizedString(@"SDK Speaker abstraction object is nil.", nil)];
        if (completion) { completion(error); }
        return;
    }
    
    self.uploadProgressBlock =  updateBlock;
    self.uploadCompleteBlock = completion;
    
    __weak typeof(self) target = self;
    
    [self.speaker startTransmissionWithInfo:self.summaryInfo startBlock:^{
        target.state = DUXBetaSpeakerUploadSessionStateRecordingAndUpdating;
        if (self.audioSource && !self.audioSource.isRecording) {
            [self.audioSource start];
        }
    } onProgress:^(NSInteger dataSize) {
        target.sentFileSize = dataSize;
        if (target.uploadProgressBlock) { target.uploadProgressBlock(target.sentFileSize, target.currentFileSize); }
    } finish:^(NSInteger index) {
        target.sentFileSize = 0;
        target.currentFileSize = 0;
        target.state = DUXBetaSpeakerUploadSessionStateUpdatingSuccess;
        if (target.uploadCompleteBlock) { target.uploadCompleteBlock(nil); }
    } failure:^(NSError * _Nonnull error) {
        target.sentFileSize = 0;
        target.currentFileSize = 0;
        target.state = DUXBetaSpeakerUploadSessionStateUpdatingFailed;
        if (target.uploadCompleteBlock) { target.uploadCompleteBlock(error); }
    }];
}

- (void)stopRecording {
    if (self.state == DUXBetaSpeakerUploadSessionStateRecordingAndUpdating && self.audioSource && self.audioSource.isRecording) {
        [self.audioSource stop];
        [[self speaker] markEOF];
        self.state = DUXBetaSpeakerUploadSessionStateUpdating;
    }
}

- (void)cancelUpdating {
    [self.speaker cancelTransmission];
    self.state = DUXBetaSpeakerUploadSessionStateCancelled;
}

#pragma mark - DUXBetaAudioFilePCMPaserDelegate

- (void)pcmParser:(DUXBetaAudioFilePCMParser *)parser pcmData:(NSData *)data numberOfFrames:(NSInteger)numberFrame {
    [[self speaker] paceData:data];
}

- (void)pcmParserDidFinish:(DUXBetaAudioFilePCMParser *)parser {
    [[self speaker] markEOF];
}

#pragma mark - AudioSourceDelegate

- (void)audioSourceOutputBuffer:(void *)pcmBuf size:(int)pcmSize {
    self.currentFileSize += pcmSize;
    [[self speaker] paceData:[NSData dataWithBytes:(void *)pcmBuf length:pcmSize]];
}

+ (void)requestMicrophoneAuthorizationWithResults:(void(^)(BOOL isSuccess))results {
    void (^notGrantedAlertShow)(void) = ^{
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Confirm", nil) style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permission Denied", nil)
                                                                                 message:NSLocalizedString(@"App doesn\'t have permission to access the microphone. Please enable access in Settings.", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:confirmAction];
        UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if (vc) {
            if ([vc isKindOfClass: [UINavigationController class]]) {
                [((UINavigationController *) vc).visibleViewController presentViewController:alertController animated:YES completion:nil];
            } else {
                [vc presentViewController:alertController animated:YES completion:nil];
            }
        }
    };
    
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    notGrantedAlertShow();
                    if (results) { results(NO); }
                } else {
                    if (results) { results(YES); }
                }
            });
        }];
    } else if (audioStatus == AVAuthorizationStatusAuthorized) {
        if (results) { results(YES); }
    } else {
        notGrantedAlertShow();
        if (results) { results(NO); }
    }
}

#pragma mark - File Path

- (NSString *)filePathWithFileName:(NSString *)fileName directoryPath:(NSString *)directoryPath {
    NSString* path = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    return path;
}

- (void)createConfigDirectoryPathIfNeededWithDirectoryPath:(NSString *)directoryPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

- (NSString *)userDirectoryPath {
    if (_userDirectoryPath) { return _userDirectoryPath; }
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES) objectAtIndex:0];
    NSString* directoryPath = [documentPath stringByAppendingPathComponent:@"/SpeakerFiles/"];
    _userDirectoryPath = directoryPath;
    return _userDirectoryPath;
}

- (NSString *)cacheDirectoryPath {
    if (_cacheDirectoryPath) { return _cacheDirectoryPath; }
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,  NSUserDomainMask,YES) objectAtIndex:0];
    NSString* directoryPath = [documentPath stringByAppendingPathComponent:@"/SpeakerCahe/"];
    _cacheDirectoryPath = directoryPath;
    return _cacheDirectoryPath;
}

#pragma mark - Getter

- (NSError *)errorWithDescription:(NSString *)description {
    if (description == nil) {
        description = NSLocalizedString(@"Unknown error", nil);
    }
    return [NSError errorWithDomain:DUXBetaSpeakerUploadSessionErrorDomain code:duxbeta_SPEAKER_UPLOAD_SESSION_ERROR_CODE userInfo:@{NSLocalizedDescriptionKey : description}];
}

- (DJISpeaker *)speaker {
    if (_speaker) {
        return _speaker;
    }
    DJIAircraft *aircraft = (DJIAircraft *)[DJISDKManager product];
    _speaker = aircraft.accessoryAggregation.speaker;
    return _speaker;
}

@end
