//
//  SJApplicationObserver.h
//  SJUIKit
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJApplicationObserver <NSObject>
/// 当前最顶部的视图控制器
@property (nonatomic, strong, readonly, nullable) __kindof UIViewController *topViewController;

/// 是否是今天首次启动
@property (nonatomic, readonly) BOOL isFirstLaunchedAtToday;
@end

@interface SJApplicationObserver : NSObject<SJApplicationObserver>
+ (instancetype)shared;
@end
NS_ASSUME_NONNULL_END
