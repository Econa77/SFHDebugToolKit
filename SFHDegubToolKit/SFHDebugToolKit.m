//
//  SFHDebugToolKit.m
//  DebugToolKit
//
//  Created by 古林　俊祐　 on 2015/06/02.
//  Copyright (c) 2015年 古林　俊祐　. All rights reserved.
//

#import "SFHDebugToolKit.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@interface SFHDebugToolKit() <UIActionSheetDelegate>

@property (strong, nonatomic) UIControl *overlayView;
@property (strong, nonatomic) UIButton *controlButton;

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
    self.frame = CGRectMake(0, 0, 60.0f, 60.0f);
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
#if DEBUG
    [[self sharedToolKit] performSelector:@selector(setup) withObject:nil afterDelay:0.2f];
#endif
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
        [self.overlayView addSubview:self.controlButton];
    }
    self.overlayView.hidden = YES;
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
    return CGRectMake(width - 70.0f, height - 70.0f, 60.0f, 60.0f);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - NSNotification
- (void)willChangeStatusBarFrame:(NSNotification *)notification {
    [UIView animateWithDuration:0.5f animations:^{
        self.overlayView.frame = [self viewFrame];
    }];
}

#pragma mark - Share Methods
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        if (self.overlayView.hidden) {
            [[SFHDebugToolKit sharedToolKit] show];
        } else {
            [[SFHDebugToolKit sharedToolKit] dismiss];
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

- (UIButton *)controlButton {
    if(!_controlButton) {
        _controlButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _controlButton.frame = CGRectMake(0, 0, 60.0f, 60.0f);
        _controlButton.backgroundColor = [UIColor colorWithRed:0.9764 green:0.5294 blue:0.1137 alpha:1.0];
        _controlButton.layer.masksToBounds = YES;
        _controlButton.layer.cornerRadius = 30.0f;
        [_controlButton setTitle:@"D Tool" forState:UIControlStateNormal];
        [_controlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_controlButton addTarget:self action:@selector(showToolSheet) forControlEvents:UIControlEventTouchUpInside];
    }
    return _controlButton;
}

#pragma mark - IBAction
- (void)showToolSheet {
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = @"Select Tool";
    [as addButtonWithTitle:@"FLEX"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 1;
    [as showInView:self];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // FLEX
#if DEBUG
        [[FLEXManager sharedManager] showExplorer];
#endif
    }
}

@end
