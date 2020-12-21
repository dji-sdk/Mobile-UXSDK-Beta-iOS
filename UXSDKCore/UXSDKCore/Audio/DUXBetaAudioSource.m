//
//  DUXBetaAudioSource.m
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

#import "DUXBetaAudioSource.h"

@interface DUXBetaAudioSource ()

@property (nonatomic) AudioComponentInstance m_audioUnit;
@property (nonatomic) AudioStreamBasicDescription pcmDesc;

@property (nonatomic) int samplerate;
@property (nonatomic) int channels;

@end

@implementation DUXBetaAudioSource

- (instancetype)initWithSampleRate:(int)sample_rate channels:(int)channel {
    if (self = [super init]) {
        _samplerate = sample_rate;
        _channels = channel;
        _pcmDesc = [self setupPCMDesc];
        [self setupAudioUnit];
    }
    return self;
}

- (void)start {
    OSStatus status = AudioOutputUnitStart(_m_audioUnit);
    if (status != noErr) {
        NSLog(@"Failed to start microphone!");
    } else {
        self.isRecording = YES;
    }
}

- (void)stop {
    AudioOutputUnitStop(_m_audioUnit);
    self.isRecording = NO;
}

- (AudioStreamBasicDescription)setupPCMDesc {
    AudioStreamBasicDescription pcmDesc = {0};
    pcmDesc.mSampleRate = _samplerate;
    pcmDesc.mFormatID = kAudioFormatLinearPCM;
    pcmDesc.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked);
    pcmDesc.mChannelsPerFrame = _channels;
    pcmDesc.mFramesPerPacket = 1;
    pcmDesc.mBitsPerChannel = 16;
    pcmDesc.mBytesPerFrame = pcmDesc.mBitsPerChannel / 8 * pcmDesc.mChannelsPerFrame;
    pcmDesc.mBytesPerPacket = pcmDesc.mBytesPerFrame * pcmDesc.mFramesPerPacket;
    pcmDesc.mReserved = 0;
    return pcmDesc;
}

- (void)setupAudioUnit {
    
    AudioComponentDescription component;
    component.componentType = kAudioUnitType_Output;
    component.componentSubType = kAudioUnitSubType_RemoteIO;
    component.componentManufacturer = kAudioUnitManufacturer_Apple;
    component.componentFlags = 0;
    component.componentFlagsMask = 0;
    
    AudioComponent m_component = AudioComponentFindNext(NULL, &component);
    AudioComponentInstanceNew(m_component, &_m_audioUnit);
    if (!_m_audioUnit) {
        NSLog(@"AudioComponentInstanceNew Fail !!");
        return;
    }
    
    UInt32 flagOne = 1;
    AudioUnitSetProperty(_m_audioUnit, kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         1,
                         &flagOne,
                         sizeof(flagOne));
    
    AURenderCallbackStruct cb;
    cb.inputProcRefCon = (__bridge void * _Nullable)(self);
    cb.inputProc = inputProc;
    AudioUnitSetProperty(_m_audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         1,
                         &_pcmDesc,
                         sizeof(_pcmDesc));
    
    AudioUnitSetProperty(_m_audioUnit,
                         kAudioOutputUnitProperty_SetInputCallback,
                         kAudioUnitScope_Global,
                         1,
                         &cb,
                         sizeof(cb));
    
    AudioUnitInitialize(_m_audioUnit);
    
}

static OSStatus inputProc(void *inRefCon,
                          AudioUnitRenderActionFlags *ioActionFlags,
                          const AudioTimeStamp *inTimeStamp,
                          UInt32 inBusNumber,
                          UInt32 inNumberFrames,
                          AudioBufferList *ioData) {
    
    DUXBetaAudioSource *src = (__bridge DUXBetaAudioSource*)inRefCon;
    
    AudioBuffer buffer;
    buffer.mData = NULL;
    buffer.mDataByteSize = 0;
    buffer.mNumberChannels = src.pcmDesc.mChannelsPerFrame;
    
    AudioBufferList buffers;
    buffers.mNumberBuffers = 1;
    buffers.mBuffers[0] = buffer;
    
    OSStatus status = AudioUnitRender(src.m_audioUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      &buffers);
    
    if (status == noErr) {
        [src handleInputData:buffers.mBuffers[0].mData size:buffers.mBuffers[0].mDataByteSize frameCount:inNumberFrames];
    }
    return status;
}

- (void)handleInputData:(void *)pcmBuf size:(int)pcmSize frameCount:(int)inNumberFrames {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioSourceOutputBuffer:size:)]) {
        [self.delegate audioSourceOutputBuffer:pcmBuf size:pcmSize];
    }
}

@end
