//
//  SJApplicationInfo.h
//  SJUIKit
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJApplicationInfo <NSObject>
/// 当前最顶部的视图控制器
@property (nonatomic, readonly, nullable) __kindof UIViewController *topViewController;

/// 是否是今天首次启动
@property (nonatomic, readonly) BOOL isFirstLaunchedAtToday;

@property (nonatomic, readonly) NSString *machineModel;
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, readonly) NSString *systemVersion;
@end

@interface SJApplicationInfo : NSObject<SJApplicationInfo>
+ (instancetype)shared;
@end
NS_ASSUME_NONNULL_END
