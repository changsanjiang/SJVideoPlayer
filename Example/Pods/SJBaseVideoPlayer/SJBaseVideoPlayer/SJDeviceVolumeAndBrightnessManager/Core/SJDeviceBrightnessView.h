//
//  SJDeviceBrightnessView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/24.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJDeviceBrightnessView : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;
/// 0..1
@property (nonatomic) CGFloat value;
@property (nonatomic, strong, nullable) UIImage *image;

@end
NS_ASSUME_NONNULL_END

