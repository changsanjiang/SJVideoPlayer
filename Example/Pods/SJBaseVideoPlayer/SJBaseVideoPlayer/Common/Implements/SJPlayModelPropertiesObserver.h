//
//  SJPlayModelPropertiesObserver.h
//  SJVideoPlayerAssetCarrier
//
//  Created by 畅三江 on 2018/6/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJPlayModel.h"

NS_ASSUME_NONNULL_BEGIN
@class SJPlayModelPropertiesObserver;

@protocol SJPlayModelPropertiesObserverDelegate <NSObject>
@optional
- (void)observer:(SJPlayModelPropertiesObserver *)observer userTouchedTableView:(BOOL)touched;
- (void)observer:(SJPlayModelPropertiesObserver *)observer userTouchedCollectionView:(BOOL)touched;
- (void)playerWillAppearForObserver:(SJPlayModelPropertiesObserver *)observer superview:(UIView *)superview;
- (void)playerWillDisappearForObserver:(SJPlayModelPropertiesObserver *)observer;
@end


@interface SJPlayModelPropertiesObserver : NSObject

- (instancetype)initWithPlayModel:(__kindof SJPlayModel *)playModel;

@property (nonatomic, weak, nullable) id <SJPlayModelPropertiesObserverDelegate> delegate;

@property (nonatomic, readonly) BOOL isAppeared;
@property (nonatomic, readonly) BOOL isTouched;
@property (nonatomic, readonly) BOOL isPlayInScrollView;
@property (nonatomic, readonly) BOOL isScrolling;

- (void)refreshAppearState;
@end
NS_ASSUME_NONNULL_END
