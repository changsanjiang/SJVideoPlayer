//
//  SJVideoPlayerTipsView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/24.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerTipsView : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;
/// 0..1
@property (nonatomic, assign, readwrite) CGFloat value;
@property (nonatomic, strong, readwrite, nullable) UIImage *image;

@end

NS_ASSUME_NONNULL_END

