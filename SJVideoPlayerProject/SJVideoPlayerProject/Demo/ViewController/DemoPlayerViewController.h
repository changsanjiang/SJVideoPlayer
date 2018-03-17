//
//  DemoPlayerViewController.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJVideoModel, SJVideoPlayerURLAsset;

@interface DemoPlayerViewController : UIViewController

- (instancetype)initWithVideo:(SJVideoModel *)video asset:(SJVideoPlayerURLAsset *__nullable)asset;

- (instancetype)initWithVideo:(SJVideoModel *)video beginTime:(NSTimeInterval)beginTime;

@end

NS_ASSUME_NONNULL_END
