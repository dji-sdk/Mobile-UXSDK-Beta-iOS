//
//  DUXBetaAudioFilePCMParser.m
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

#import "DUXBetaAudioFilePCMParser.h"
#import <AudioToolbox/AudioToolbox.h>

@interface DUXBetaAudioFilePCMParser ()

@property (strong, nonatomic) NSURL *url;

@end

@implementation DUXBetaAudioFilePCMParser

- (instancetype)initWithFile:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)startParser {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(pcmParser:pcmData:numberOfFrames:)]) {
        return;
    }
    
    ExtAudioFileRef sourceFile = nil;
    
    if (![self checkError:ExtAudioFileOpenURL((__bridge CFURLRef)self.url, &sourceFile) description:@"ExtAudioFileGetProperty couldn't get the source data format"]) {
        if (sourceFile) {
            ExtAudioFileDispose(sourceFile);
        }
        return;
    }
    
    AudioStreamBasicDescription sourceFormat;
    uint32_t size = sizeof(AudioStreamBasicDescription);
    if (![self checkError:ExtAudioFileGetProperty(sourceFile, kExtAudioFileProperty_FileDataFormat, &size, &sourceFormat) description:@"ExtAudioFileGetProperty couldn't get the source data format"]) {
        if (sourceFile) {
            ExtAudioFileDispose(sourceFile);
        }
        return;
    }
    
    uint32_t bufferByteSize = 16384;
    uint8_t *sourceBuffer = malloc(bufferByteSize);
    
    while (true) {
        AudioBufferList fillBufferList;
        fillBufferList.mNumberBuffers = 1;
        fillBufferList.mBuffers->mNumberChannels = 1;
        fillBufferList.mBuffers->mDataByteSize = bufferByteSize;
        fillBufferList.mBuffers->mData = sourceBuffer;
        
        uint32_t numberOfFrames = 0;
        if (sourceFormat.mBytesPerFrame > 0) {
            numberOfFrames = bufferByteSize / sourceFormat.mBytesPerFrame;
        }
        
        if (![self checkError:ExtAudioFileRead(sourceFile, &numberOfFrames, &fillBufferList) description:@"ExtAudioFileRead failed!"]) {
            break;
        }
        
        if (numberOfFrames <= 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(pcmParserDidFinish:)]) {
                [self.delegate pcmParserDidFinish:self];
            }
            
            break;
        }
        
        NSData *data = [NSData dataWithBytes:fillBufferList.mBuffers->mData length:fillBufferList.mBuffers->mDataByteSize];
        [self.delegate pcmParser:self pcmData:data numberOfFrames:numberOfFrames];
    }
    
    free(sourceBuffer);
    
    if (sourceFile) {
        ExtAudioFileDispose(sourceFile);
    }
}

- (BOOL)checkError:(OSStatus)errorCode description:(NSString *)description {
    if (errorCode == noErr) {
        return YES;
    }
    
    NSError *error = [[NSError alloc] initWithDomain:@"AudioFilePCMParser" code:errorCode userInfo:@{NSLocalizedDescriptionKey: description}];
    NSLog(@"Error: %@", error);
    
    return NO;
}

@end
