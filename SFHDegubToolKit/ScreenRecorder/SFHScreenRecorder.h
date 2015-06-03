//
//  SFHScreenRecorder.h
//  DebugToolKit
//
//  Created by 古林　俊祐　 on 2015/06/03.
//  Copyright (c) 2015年 古林　俊祐　. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <TargetConditionals.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NSString *(^SFHScreenRecorderOutputFilenameBlock)();

@interface SFHScreenRecorder : NSObject

@property (assign, nonatomic) NSInteger frameInterval;
@property (assign, nonatomic) BOOL showsTouchPointer;
@property (copy, nonatomic) SFHScreenRecorderOutputFilenameBlock filenameBlock;

+ (instancetype)sharedRecorder;
- (void)startRecording;
- (void)stopRecording;
- (BOOL)isRecording;

@end
