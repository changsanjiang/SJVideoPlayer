//
//  SJLightweightTopItem.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/22.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

// - Deprecated

extern NSString *const kLightweightTopItemImageNameKeyPath;

@interface SJLightweightTopItem : NSObject
- (instancetype)initWithFlag:(NSInteger)flag imageName:(NSString *)imageName __deprecated;
@property (nonatomic, copy) NSString *imageName __deprecated;
@property (nonatomic, assign, readonly) NSInteger flag __deprecated;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
