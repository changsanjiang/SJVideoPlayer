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
    SJMediaDownloadStatus_Deleted,
    SJMediaDownloadStatus_BadURL,
    SJMediaDownloadStatus_TimeOut,
    SJMediaDownloadStatus_UnsupportedURL,
    SJMediaDownloadStatus_ConnectionWasLost,
    SJMediaDownloadStatus_NotConnectedToInternet,
};

@protocol SJMediaEntity;

@interface SJMediaDownloader : NSObject

+ (instancetype)shared;

/// default is NO
- (void)startNotifier;

- (void)stopNotifier;

#pragma mark
- (void)async_exeBlock:(void(^)(void))block;

- (void)async_requestMediasCompletion:(void(^)(SJMediaDownloader *downloader, NSArray<id<SJMediaEntity>> * __nullable medias))completionBlock;

- (void)async_requestMediaWithID:(NSInteger)mediaId
                      completion:(void(^)(SJMediaDownloader *downloader, id<SJMediaEntity> __nullable media))completionBlock;

- (void)async_requestMediasWithStatus:(SJMediaDownloadStatus)status
                           completion:(void(^)(SJMediaDownloader *downloader, NSArray<id<SJMediaEntity>> * __nullable medias))completionBlock;

- (void)async_requestMediasWithStatuses:(NSSet<NSNumber *> *)statuses
                             completion:(void(^)(SJMediaDownloader *downloader, NSArray<id<SJMediaEntity>> * __nullable medias))completionBlock;

#pragma mark download
- (void)async_downloadWithID:(NSInteger)mediaId
                 mediaURLStr:(NSString *)mediaURLStr
                       title:(NSString * __nullable)title
                 coverURLStr:(NSString * __nullable)coverURLStr;

- (void)async_downloadWithID:(NSInteger)mediaId
                       title:(NSString * __nullable)title
                 mediaURLStr:(NSString *)mediaURLStr;

- (void)async_downloadWithID:(NSInteger)mediaId
                 mediaURLStr:(NSString *)mediaURLStr;

#pragma mark pause
- (void)async_pauseWithMediaID:(NSInteger)mediaId
                    completion:(void(^ __nullable)(void))block;

- (void)async_pauseAllDownloadsCompletion:(void(^ __nullable)(void))block; // 暂停全部


#pragma mark delete or cancel
- (void)async_deleteWithMediaID:(NSInteger)mediaId completion:(void(^ __nullable)(void))block;

- (void)async_deleteWithMediaIDs:(NSArray<NSNumber *> *)mediaIds completion:(void(^ __nullable)(void))block; // 批量删除

#pragma mark file size
/**
 The file’s size, in bytes.
 */
- (unsigned long long)fileSize;

@end

@protocol SJMediaEntity <NSObject>

@property (nonatomic, readonly) NSInteger mediaId;
@property (nonatomic, strong, readonly) NSString *URLStr;
@property (nonatomic, readonly) SJMediaDownloadStatus downloadStatus;
@property (nonatomic, strong, readonly, nullable) NSString *title;
@property (nonatomic, strong, readonly, nullable) NSString *coverURLStr;
@property (nonatomic, strong, readonly, nullable) NSString *filePath;
@property (readonly) long long totalBytesWritten;
@property (readonly) long long totalBytesExpectedToWrite;
- (float)downloadProgress;
@property (nonatomic, readonly) long long speed; // 下载速度, unit is`byte/s`.
@end

NS_ASSUME_NONNULL_END
