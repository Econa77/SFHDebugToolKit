//
//  SFHScreenRecorder.m
//  DebugToolKit
//
//  Created by 古林　俊祐　 on 2015/06/03.
//  Copyright (c) 2015年 古林　俊祐　. All rights reserved.
//

#import "SFHScreenRecorder.h"

#import "KTouchPointerWindow.h"

#ifndef APPSTORE_SAFE
#define APPSTORE_SAFE 0
#endif

#define DEFAULT_FRAME_INTERVAL 2
#define TIME_SCALE 600

static NSInteger counter;

#if !APPSTORE_SAFE
CGImageRef UICreateCGImageFromIOSurface(CFTypeRef surface);
CVReturn CVPixelBufferCreateWithIOSurface(
                                          CFAllocatorRef allocator,
                                          CFTypeRef surface,
                                          CFDictionaryRef pixelBufferAttributes,
                                          CVPixelBufferRef *pixelBufferOut);
@interface UIWindow (ScreenRecorder)
+ (CFTypeRef)createScreenIOSurface;
@end

@interface UIScreen (ScreenRecorder)
- (CGRect)_boundsInPixels;
@end
#endif

@interface SFHScreenRecorder ()

@property (strong, nonatomic) AVAssetWriter *writer;
@property (strong, nonatomic) AVAssetWriterInput *writerInput;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *writerInputPixelBufferAdaptor;
@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation SFHScreenRecorder {
    CFAbsoluteTime firstFrameTime;
    CFTimeInterval startTimestamp;
    dispatch_queue_t queue;
    UIBackgroundTaskIdentifier backgroundTask;
}

#pragma mark - Init
+ (instancetype)sharedRecorder {
    static SFHScreenRecorder *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[SFHScreenRecorder alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.frameInterval = DEFAULT_FRAME_INTERVAL;
        self.showsTouchPointer = YES;
        
        counter++;
        NSString *label = [NSString stringWithFormat:@"screen_recorder-%ld", (long)counter];
        queue = dispatch_queue_create([label cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRecording];
}

#pragma mark Setup

- (void)setupAssetWriterWithURL:(NSURL *)outputURL {
    NSError *error = nil;
    
    self.writer = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(self.writer);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    UIScreen *mainScreen = [UIScreen mainScreen];
#if APPSTORE_SAFE
    CGSize size = mainScreen.bounds.size;
#else
    CGRect boundsInPixels = [mainScreen _boundsInPixels];
    CGSize size = boundsInPixels.size;
#endif
    
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : @(size.width), AVVideoHeightKey : @(size.height)};
    self.writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    self.writerInput.expectsMediaDataInRealTime = YES;
    
    NSDictionary *sourcePixelBufferAttributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32ARGB)};
    self.writerInputPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.writerInput
                                                                                                          sourcePixelBufferAttributes:sourcePixelBufferAttributes];
    NSParameterAssert(self.writerInput);
    NSParameterAssert([self.writer canAddInput:self.writerInput]);
    
    [self.writer addInput:self.writerInput];
    
    firstFrameTime = CFAbsoluteTimeGetCurrent();
    
    [self.writer startWriting];
    [self.writer startSessionAtSourceTime:kCMTimeZero];
}

- (void)setupTouchPointer {
    if (self.showsTouchPointer) {
        KTouchPointerWindowInstall();
    } else {
        KTouchPointerWindowUninstall();
    }
}

- (void)setupTimer {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(captureFrame:)];
    self.displayLink.frameInterval = self.frameInterval;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark Recording
- (void)startRecording {
    [self setupAssetWriterWithURL:[self outputFileURL]];
    
    [self setupTouchPointer];
    
    [self setupTimer];
}

- (void)stopRecording {
    [self.displayLink invalidate];
    startTimestamp = 0.0;
    if (self.showsTouchPointer) {
        KTouchPointerWindowUninstall();
    }
    
    if (self.writer.status != AVAssetWriterStatusCompleted && self.writer.status != AVAssetWriterStatusUnknown) {
        [self.writerInput markAsFinished];
    }
    [self.writer finishWritingWithCompletionHandler:^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:self.writer.outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:self.writer.outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
            }];
        }
        
    }];
}

- (BOOL)isRecording {
    if (startTimestamp == 0.0) {
        return NO;
    }
    return YES;
}

- (void)captureFrame:(CADisplayLink *)displayLink {
    dispatch_async(queue, ^
                   {
                       if (self.writerInput.readyForMoreMediaData) {
                           CVReturn status = kCVReturnSuccess;
                           CVPixelBufferRef buffer = NULL;
                           CFTypeRef backingData;
#if APPSTORE_SAFE || TARGET_IPHONE_SIMULATOR
                           __block UIImage *screenshot = nil;
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               screenshot = [self screenshot];
                           });
                           CGImageRef image = screenshot.CGImage;
                           
                           CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
                           CFDataRef data = CGDataProviderCopyData(dataProvider);
                           backingData = CFDataCreateMutableCopy(kCFAllocatorDefault, CFDataGetLength(data), data);
                           CFRelease(data);
                           
                           const UInt8 *bytePtr = CFDataGetBytePtr(backingData);
                           
                           status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                                                 CGImageGetWidth(image),
                                                                 CGImageGetHeight(image),
                                                                 kCVPixelFormatType_32BGRA,
                                                                 (void *)bytePtr,
                                                                 CGImageGetBytesPerRow(image),
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 &buffer);
                           NSParameterAssert(status == kCVReturnSuccess && buffer);
#else
                           CFTypeRef surface = [UIWindow createScreenIOSurface];
                           backingData = surface;
                           
                           NSDictionary *pixelBufferAttributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
                           status = CVPixelBufferCreateWithIOSurface(NULL, surface, (__bridge CFDictionaryRef)(pixelBufferAttributes), &buffer);
                           NSParameterAssert(status == kCVReturnSuccess && buffer);
#endif
                           if (buffer) {
                               CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
                               CFTimeInterval elapsedTime = currentTime - firstFrameTime;
                               
                               CMTime presentTime =  CMTimeMake(elapsedTime * TIME_SCALE, TIME_SCALE);
                               
                               if(![self.writerInputPixelBufferAdaptor appendPixelBuffer:buffer withPresentationTime:presentTime]) {
                                   [self stopRecording];
                               }
                               
                               CVPixelBufferRelease(buffer);
                           }
                           
                           CFRelease(backingData);
                       }
                   });
    
    if (startTimestamp == 0.0) {
        startTimestamp = displayLink.timestamp;
    }
}

- (UIImage *)screenshot {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGSize imageSize = mainScreen.bounds.size;
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    } else {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (![window respondsToSelector:@selector(screen)] || window.screen == mainScreen) {
            CGContextSaveGState(context);
            
            CGContextTranslateCTM(context, window.center.x, window.center.y);
            CGContextConcatCTM(context, [window transform]);
            CGContextTranslateCTM(context,
                                  -window.bounds.size.width * window.layer.anchorPoint.x,
                                  -window.bounds.size.height * window.layer.anchorPoint.y);
            
            [window.layer.presentationLayer renderInContext:context];
            
            CGContextRestoreGState(context);
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark Background tasks
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.isRecording) {
        [self stopRecording];
    }
}

#pragma mark Utility methods

- (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)defaultFilename {
    time_t timer;
    time(&timer);
    NSString *timestamp = [NSString stringWithFormat:@"%ld", timer];
    return [NSString stringWithFormat:@"%@.mov", timestamp];
}

- (BOOL)existsFile:(NSString *)filename {
    NSString *path = [self.documentDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    return [fileManager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory;
}

- (NSString *)nextFilename:(NSString *)filename {
    static NSInteger fileCounter;
    
    fileCounter++;
    NSString *pathExtension = [filename pathExtension];
    filename = [[[filename stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"-%ld", (long)fileCounter]] stringByAppendingPathExtension:pathExtension];
    
    if ([self existsFile:filename]) {
        return [self nextFilename:filename];
    }
    
    return filename;
}

- (NSURL *)outputFileURL {
    if (!self.filenameBlock) {
        __block SFHScreenRecorder *wself = self;
        self.filenameBlock = ^(void) {
            return [wself defaultFilename];
        };
    }
    
    NSString *filename = self.filenameBlock();
    if ([self existsFile:filename]) {
        filename = [self nextFilename:filename];
    }
    
    NSString *path = [self.documentDirectory stringByAppendingPathComponent:filename];
    return [NSURL fileURLWithPath:path];
}

@end
