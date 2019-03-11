//
//  SJEdgeControlButtonItemDelegate.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/3/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJBaseVideoPlayer.h"
#import "SJEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlButtonItemDelegate : NSObject<SJEdgeControlButtonItemDelegate>
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *item;
- (instancetype)initWithItem:(SJEdgeControlButtonItem *)item;

@property (nonatomic, copy, nullable) void(^updatePropertiesIfNeeded)(SJEdgeControlButtonItem *item, __kindof SJBaseVideoPlayer *player);
@property (nonatomic, copy, nullable) void(^clickedItemExeBlock)(SJEdgeControlButtonItem *item);
@end
NS_ASSUME_NONNULL_END
