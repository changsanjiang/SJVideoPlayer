//
//  SJVideoPlayerSettings.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSNotificationName const SJSettingsPlayerNotification;

@class UIImage, UIColor;

@interface SJVideoPlayerSettings : NSObject
// MARK: btns
@property (nonatomic, strong, readwrite) UIImage *backBtnImage;
@property (nonatomic, strong, readwrite) UIImage *playBtnImage;
@property (nonatomic, strong, readwrite) UIImage *pauseBtnImage;
@property (nonatomic, strong, readwrite) UIImage *replayBtnImage;
@property (nonatomic, strong, readwrite) NSString *replayBtnTitle;
@property (nonatomic, assign, readwrite) float replayBtnFontSize;
@property (nonatomic, strong, readwrite) UIImage *fullBtnImage;
@property (nonatomic, strong, readwrite) UIImage *previewBtnImage;
@property (nonatomic, strong, readwrite) UIImage *moreBtnImage;
@property (nonatomic, strong, readwrite) UIImage *lockBtnImage;
@property (nonatomic, strong, readwrite) UIImage *unlockBtnImage;

// MARK: slider
@property (nonatomic, strong, readwrite) UIColor *progress_traceColor;
@property (nonatomic, strong, readwrite) UIColor *progress_trackColor;
@property (nonatomic, strong, readwrite) UIImage *progress_thumbImage;
@property (nonatomic, strong, readwrite) UIColor *progress_bufferColor;
@property (nonatomic, assign, readwrite) float progress_traceHeight;

@property (nonatomic, strong, readwrite) UIColor *more_traceColor;
@property (nonatomic, strong, readwrite) UIColor *more_trackColor;
@property (nonatomic, assign, readwrite) float more_traceHeight;

// MARK: Loading
@property (nonatomic, strong, readwrite) UIColor *loadingLineColor;

@end
