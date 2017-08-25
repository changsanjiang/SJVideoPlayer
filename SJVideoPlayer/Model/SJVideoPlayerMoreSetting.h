//
//  SJVideoPlayerMoreSetting.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage, UIColor;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerMoreSetting : NSObject

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, copy) void(^clickedExeBlock)(SJVideoPlayerMoreSetting *model);



/*!
 *  default is whiteColor
 */
@property (nonatomic, strong, class) UIColor *titleColor;

/*!
 *  deafult is 14
 */
@property (nonatomic, assign, class) double titleFontSize;


- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block;

@end


NS_ASSUME_NONNULL_END
