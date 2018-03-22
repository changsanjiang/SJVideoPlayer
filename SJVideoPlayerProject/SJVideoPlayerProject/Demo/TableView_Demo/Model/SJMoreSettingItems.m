//
//  SJMoreSettingItems.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJMoreSettingItems.h"
#import "SJVideoPlayerMoreSettingSecondary.h"

@interface SJMoreSettingItems ()
@property (nonatomic, strong, readonly) NSArray<SJVideoPlayerMoreSettingSecondary *> *shareItems;
@end

@implementation SJMoreSettingItems

@synthesize shareItems = _shareItems;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    SJVideoPlayerMoreSetting.titleFontSize = 10;
    __weak typeof(self) _self = self;
    SJVideoPlayerMoreSetting *share =
    [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"分享"
                                              image:[UIImage imageNamed:@"share"]
                                     showTowSetting:YES
                                 twoSettingTopTitle:@"分享到"
                                    twoSettingItems:self.shareItems // share items
                                    clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {}];
    
    SJVideoPlayerMoreSetting *download =
    [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"下载"
                                              image:[UIImage imageNamed:@"download"]
                                    clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(clickedDownloadItem)] ) {
            [self.delegate clickedDownloadItem];
        }
    }];
    
    SJVideoPlayerMoreSetting *collection =
    [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"收藏"
                                              image:[UIImage imageNamed:@"collection"]
                                    clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(clickedCollectItem)] ) {
            [self.delegate clickedCollectItem];
        }
    }];
    
    _moreSettings = @[share, download, collection];
    return self;
}

- (NSArray<SJVideoPlayerMoreSettingSecondary *> *)shareItems {
    if ( _shareItems ) return _shareItems;
    __weak typeof(self) _self = self;
    SJVideoPlayerMoreSettingSecondary *QQ =
    [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"QQ"
                                                       image:[UIImage imageNamed:@"qq"]
                                             clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(clickedShareItem:)] ) {
            [self.delegate clickedShareItem:SJSharePlatform_QQ];
        }
    }];
    
    SJVideoPlayerMoreSettingSecondary *wechat =
    [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"微信"
                                                       image:[UIImage imageNamed:@"wechat"]
                                             clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(clickedShareItem:)] ) {
            [self.delegate clickedShareItem:SJSharePlatform_Wechat];
        }
    }];
    
    SJVideoPlayerMoreSettingSecondary *weibo =
    [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"微博"
                                                       image:[UIImage imageNamed:@"weibo"]
                                             clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(clickedShareItem:)] ) {
            [self.delegate clickedShareItem:SJSharePlatform_Weibo];
        }
    }];
    _shareItems = @[QQ, wechat, weibo];
    return _shareItems;
}
@end
