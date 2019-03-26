//
//  SJFilmEditingSettings.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/5/31.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSNotificationName const SJFilmEditingSettingsUpdatedNotification;
@class UIImage;

extern NSString *const SJFilmEditing_cancelText;
extern NSString *const SJFilmEditing_doneText;
extern NSString *const SJFilmEditing_waitingText;
extern NSString *const SJFilmEditing_finishText;
extern NSString *const SJFilmEditing_exportingText;
extern NSString *const SJFilmEditing_exportFailedText;
extern NSString *const SJFilmEditing_exportSuccessText;
extern NSString *const SJFilmEditing_screenshotSuccessText;
extern NSString *const SJFilmEditing_albumAuthDeniedText;
extern NSString *const SJFilmEditing_savingToAlbumText;
extern NSString *const SJFilmEditing_saveToAlbumSuccessText;
extern NSString *const SJFilmEditing_uploadingText;
extern NSString *const SJFilmEditing_uploadFailedText;
extern NSString *const SJFilmEditing_uploadSuccessText;


@interface SJFilmEditingSettings : NSObject
/// shared
+ (instancetype)commonSettings;
- (void)reset;
- (void)postUpdateNotify;
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJFilmEditingSettings *settings));

@property (nonatomic, strong) UIImage *screenshotBtnImage;
@property (nonatomic, strong) UIImage *exportBtnImage;
@property (nonatomic, strong) UIImage *gifBtnImage;

/**
 top btn
 左上角按钮
 - 取消
 - 完成
 */
@property (nonatomic, strong) NSString *cancelText;
@property (nonatomic, strong) NSString *doneText;

/**
 录制时右侧按钮
 - 等待中
 - 可完成
 */
@property (nonatomic, strong) UIImage *waitingImage;
@property (nonatomic, strong) UIImage *finishImage;
@property (nonatomic, strong) NSString *waitingText;
@property (nonatomic, strong) NSString *finishText;

/**
 export
 导出
 - 导出中
 - 导出失败
 - 导出成功
    - 录制成功
    - 截屏成功
 */
@property (nonatomic, strong) NSString *exportingText;
@property (nonatomic, strong) NSString *exportFailedText;
@property (nonatomic, strong) NSString *exportSuccessText;
@property (nonatomic, strong) NSString *screenshotSuccessText;

/**
 album
 保存至相册
 - 已保存至相册
 - 保存失败, 相册访问权限未开启
 */
@property (nonatomic, strong) NSString *albumAuthDeniedText;
@property (nonatomic, strong) NSString *savingToAlbumText;
@property (nonatomic, strong) NSString *saveToAlbumSuccessText;

/**
 upload
 上传
 - 上传中
 - 上传成功
 - 上传失败
 */
@property (nonatomic, strong) NSString *uploadingText;
@property (nonatomic, strong) NSString *uploadFailedText;
@property (nonatomic, strong) NSString *uploadSuccessText;
@end

@interface SJFilmEditingSettingsUpdatedObserver : NSObject
@property (nonatomic, copy, nullable) void(^updatedExeBlock)(SJFilmEditingSettings *settings);
@end
NS_ASSUME_NONNULL_END
