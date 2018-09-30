//
//  SJHasCollectionView.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPlayView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJHasCollectionView : UIView
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, copy, nullable) void(^clickedPlayButtonExeBlock)(SJHasCollectionView *containerView, SJPlayView *view, NSIndexPath *indexPath);
@end
NS_ASSUME_NONNULL_END
