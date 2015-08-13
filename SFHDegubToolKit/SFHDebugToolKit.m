//
//  SFHDebugToolKit.m
//  DebugToolKit
//
//  Created by 古林　俊祐　 on 2015/06/02.
//  Copyright (c) 2015年 古林　俊祐　. All rights reserved.
//

#import "SFHDebugToolKit.h"

#import "FLEXManager.h"

@interface SFHDebugToolKit()

@property (strong, nonatomic) UIControl *overlayView;
@property (strong, nonatomic) UIButton *flexButton;

@end

@implementation SFHDebugToolKit

#pragma mark - Init
+ (instancetype)sharedToolKit {
    static SFHDebugToolKit *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[SFHDebugToolKit alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarFrame:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)initView {
    
    self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 50.0f);
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 30.0f;
    [self becomeFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Class Methods
+ (void)setupToolKit {
    [[self sharedToolKit] performSelector:@selector(setup) withObject:nil afterDelay:0.2f];
}

+ (BOOL)isIOS7 {
    NSArray  *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    NSInteger iOsVersionMajor  = [[aOsVersions objectAtIndex:0] intValue];
    if (iOsVersionMajor == 7) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Self Methods
- (void)setup {
    if (!self.overlayView.superview) {
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows){
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
        }
    } else {
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    if (!self.superview) {
        [self.overlayView addSubview:self];
        [self.overlayView addSubview:self.flexButton];
    }
    self.overlayView.hidden = YES;
    
    [self show];
}

- (void)show {
    self.overlayView.hidden = NO;
}

- (void)dismiss {
    self.overlayView.hidden = YES;
}

#pragma mark - Private Methods
- (CGRect)viewFrame {

    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    if ([SFHDebugToolKit isIOS7]) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
            width = CGRectGetHeight([UIScreen mainScreen].bounds);
            height = CGRectGetWidth([UIScreen mainScreen].bounds);
        }
    }
    
    return CGRectMake(width - 45, height - 20 - 49, 40, 17);
}

#pragma mark - NSNotification
- (void)willChangeStatusBarFrame:(NSNotification *)notification {
    
    self.overlayView.transform = CGAffineTransformMakeRotation(0.0);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.overlayView.frame = [self viewFrame];
        self.flexButton.frame = CGRectMake(0, 0, 40.0, 17);
    }];
    
    if ([SFHDebugToolKit isIOS7]) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat rotateAngle = 0.0f;
        switch (orientation) {
            case UIInterfaceOrientationLandscapeRight:
                rotateAngle = M_PI/2.0f;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                rotateAngle = -M_PI/2.0f;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                rotateAngle = M_PI;
                break;
            default:
                break;
        }
        self.overlayView.transform = CGAffineTransformMakeRotation(rotateAngle);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            self.overlayView.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 45.0, 0, CGRectGetWidth(self.overlayView.frame), CGRectGetHeight(self.overlayView.frame));
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            self.overlayView.frame = CGRectMake(0, 0, CGRectGetWidth(self.overlayView.frame), CGRectGetHeight(self.overlayView.frame));
        }
    }
}

#pragma mark Lazy views
- (UIControl *)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] initWithFrame:[self viewFrame]];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        _overlayView.userInteractionEnabled = YES;
    }
    return _overlayView;
}

- (UIButton *)flexButton {
    if(!_flexButton) {
        _flexButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _flexButton.frame = CGRectMake(0, 0, 40.0, 17);
        _flexButton.backgroundColor = [UIColor colorWithRed:0.9764 green:0.5294 blue:0.1137 alpha:1.0];
        _flexButton.layer.masksToBounds = YES;
        _flexButton.layer.cornerRadius = 3.0f;
        _flexButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:10.0f];
        [_flexButton setTitle:@"FLEX" forState:UIControlStateNormal];
        [_flexButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flexButton addTarget:self action:@selector(showFLEX) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flexButton;
}

#pragma mark - IBAction
- (void)showFLEX {
    [[FLEXManager sharedManager] showExplorer];
}

@end
