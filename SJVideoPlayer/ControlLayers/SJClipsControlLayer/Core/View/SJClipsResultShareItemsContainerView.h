//
//  SJClipsResultShareItemsContainerView.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SJClipsResultShareItem;

NS_ASSUME_NONNULL_BEGIN
@interface SJClipsResultShareItemsContainerView : UIView
@property (nonatomic, strong, nullable) NSArray<SJClipsResultShareItem *> *shareItems;

@property (nonatomic, copy, nullable) void(^clickedShareItemExeBlock)(SJClipsResultShareItemsContainerView *view, SJClipsResultShareItem *item);
@end
NS_ASSUME_NONNULL_END
