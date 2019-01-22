//
//  SJFilmEditingResultShareItemsContainerView.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SJFilmEditingResultShareItem;

NS_ASSUME_NONNULL_BEGIN
@interface SJFilmEditingResultShareItemsContainerView : UIView
@property (nonatomic, strong, nullable) NSArray<SJFilmEditingResultShareItem *> *shareItems;

@property (nonatomic, copy, nullable) void(^clickedShareItemExeBlock)(SJFilmEditingResultShareItemsContainerView *view, SJFilmEditingResultShareItem *item);
@end
NS_ASSUME_NONNULL_END
