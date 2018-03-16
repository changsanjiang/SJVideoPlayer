//
//  SJMediaDownloader.h
//  SJMediaDownloader
//
//  Created by BlueDancer on 2018/3/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Post when a media download progress changed.
 Object is `id<SJMediaEntity>`.
 */
UIKIT_EXTERN NSNotificationName const SJMediaDownloadProgressNotification;

/**
 Post when a media download status changed.
 Object is `id<SJMediaEntity>`.
 */
UIKIT_EXTERN NSNotificationName const SJMediaDownloadStatusChangedNotification;

//typedef NS_ENUM(NSUInteger, SJMediaType) {
//    SJMediaType_Unknown,
//    SJMediaType_Video,
//    SJMediaType_Audio,
//    SJMediaType_M3u8,
//};

typedef NS_ENUM(NSUInteger, SJMediaDownloadStatus) {
    SJMediaDownloadStatus_Unknown,
    SJMediaDownloadStatus_Waiting,
    SJMediaDownloadStatus_Downloading,
    SJMediaDownloadStatus_Finished,
    SJMediaDownloadStatus_Paused,
    SJMediaDownloadStatus_Failed,
    SJMediaDownloadStatus_Cancelled,
    SJMediaDownloadStatus_TimeOut,
    SJMediaDownloadStatus_ConnectionWasLost,
};

@protocol SJMediaEntity;

@interface SJMediaDownloader : NSObject

+ (instancetype)shared;

- (void)startNotifier;

- (void)stopNotifier;

#pragma mark -
- (void)async_requestMediasCompletion:(void(^)(SJMediaDownloader *downloader, NSArray<id<SJMediaEntity>> * __nullable medias))completionBlock;

- (void)async_requestMediaWithID:(NSInteger)mediaId completion:(void(^)(SJMediaDownloader *downloader, id<SJMediaEntity> __nullable media))completionBlock;

#pragma mark -
- (void)async_downloadWithID:(NSInteger)mediaId
                       title:(NSString * __nullable)title
                 mediaURLStr:(NSString *)mediaURLStr
                   tmpEntity:(void(^ __nullable)(id<SJMediaEntity> entiry))entity;

- (void)async_pauseWithMediaID:(NSInteger)mediaId completion:(void(^)(void))block;

- (void)async_deleteWithMediaID:(NSInteger)mediaId completion:(void(^)(void))block;

@end

@protocol SJMediaEntity <NSObject>

@property (nonatomic, assign, readonly) NSInteger mediaId;
@property (nonatomic, assign, readonly) SJMediaDownloadStatus downloadStatus;
@property (nonatomic, strong, readonly, nullable) NSString *title;
@property (nonatomic, strong, readonly) NSString *URLStr;
@property (nonatomic, strong, readonly, nullable) NSString *filePath;
@property (nonatomic, assign, readonly) float progress;

@end

NS_ASSUME_NONNULL_END
