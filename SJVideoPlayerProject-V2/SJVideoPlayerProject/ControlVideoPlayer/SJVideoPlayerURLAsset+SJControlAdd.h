//
//  SJVideoPlayerURLAsset+SJControlAdd.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerURLAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerURLAsset (SJControlAdd)

@property (nonatomic, copy, readwrite, nullable) NSString *title;

@property (nonatomic, assign, readwrite) BOOL alwaysShowTitle; // default is `NO`(小屏的时候不显示, 全屏的时候显示标题)

@end

NS_ASSUME_NONNULL_END
