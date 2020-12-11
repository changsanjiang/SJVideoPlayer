//
//  SJPopPromptCustomView.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/10/12.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJPopPromptCustomView : UIView
@property (nonatomic, copy, nullable) NSString *time;

@property (nonatomic, copy, nullable) void(^jumpButtonWasTappedExeBlock)(SJPopPromptCustomView *view);
@end

NS_ASSUME_NONNULL_END
