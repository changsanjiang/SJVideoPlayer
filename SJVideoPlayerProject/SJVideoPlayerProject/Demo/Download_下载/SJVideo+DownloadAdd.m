//
//  SJVideo+DownloadAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/17.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideo+DownloadAdd.h"
#import <objc/message.h>
#import <SJMediaDownloader.h>

NS_ASSUME_NONNULL_BEGIN
@interface _SJAssociatedTmpObj : NSObject
@property (nonatomic, unsafe_unretained) id object;
@property (nonatomic, copy) void(^deallocExeBlock)(id object);
@end

@implementation _SJAssociatedTmpObj
- (void)dealloc {
    if ( _deallocExeBlock ) _deallocExeBlock(_object);
}
@end

@implementation SJVideo (DownloadAdd)
- (void)addDownloadObserver {
    // start notifi
    [[SJMediaDownloader shared] startNotifier];
    
    // add notifi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDownloadStatusChanged:) name:SJMediaDownloadStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDownloadProgress:) name:SJMediaDownloadProgressNotification object:nil];
    
    // auto remove notifi
    _SJAssociatedTmpObj *tmpObj = [_SJAssociatedTmpObj new];
    tmpObj.object = self;
    tmpObj.deallocExeBlock = ^(id  _Nonnull object) {
        [[NSNotificationCenter defaultCenter] removeObserver:object name:SJMediaDownloadProgressNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:object name:SJMediaDownloadStatusChangedNotification object:nil];
    };
    objc_setAssociatedObject(self, _cmd, tmpObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[SJMediaDownloader shared] async_requestMediaWithID:self.mediaId completion:^(SJMediaDownloader * _Nonnull downloader, id<SJMediaEntity>  _Nullable media) {
        self.entity = media;
    }];
}
#pragma mark - notifi observer methods
- (void)mediaDownloadStatusChanged:(NSNotification *)notifi {
    id<SJMediaEntity> entity = notifi.object;
    [self _updateEntity:entity];
}
- (void)mediaDownloadProgress:(NSNotification *)notifi {
    id<SJMediaEntity> entity = notifi.object;
    [self _updateEntity:entity];
}
- (void)_updateEntity:(id<SJMediaEntity>)entity {
    if ( entity.mediaId != self.mediaId ) return;
    if ( entity != self.entity ) self.entity = entity;
}
#pragma mark -
- (void)setEntity:(id<SJMediaEntity> __nullable)entity {
    objc_setAssociatedObject(self, @selector(entity), entity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id<SJMediaEntity>__nullable)entity {
    return objc_getAssociatedObject(self, _cmd);
}
@end
NS_ASSUME_NONNULL_END
