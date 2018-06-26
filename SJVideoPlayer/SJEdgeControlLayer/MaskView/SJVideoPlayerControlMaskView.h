//
//  SJVideoPlayerControlMaskView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 style

 - SJMaskStyle_bottom:  从上到下的颜色 浅->深
 - SJMaskStyle_top:     从上到下的颜色 深->浅
 */
typedef NS_ENUM(NSUInteger, SJMaskStyle) {
    SJMaskStyle_bottom,
    SJMaskStyle_top,
};

@interface SJVideoPlayerControlMaskView : UIView

- (instancetype)initWithStyle:(SJMaskStyle)style;

@end

NS_ASSUME_NONNULL_END
