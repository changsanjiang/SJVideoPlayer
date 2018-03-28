//
//  SJMoreSettingItems.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerMoreSetting;
@protocol SJMoreSettingItemsDelegate;

typedef NS_ENUM(NSUInteger, SJSharePlatform) {
    SJSharePlatform_Unknown,
    SJSharePlatform_QQ,
    SJSharePlatform_Wechat,
    SJSharePlatform_Weibo,
};

@interface SJMoreSettingItems : NSObject
@property (nonatomic, weak) id<SJMoreSettingItemsDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;
@end

@protocol SJMoreSettingItemsDelegate <NSObject>

@optional
- (void)clickedShareItem:(SJSharePlatform)platform;

- (void)clickedDownloadItem;

- (void)clickedCollectItem;

@end

NS_ASSUME_NONNULL_END
