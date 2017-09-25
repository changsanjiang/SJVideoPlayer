//
//  SJVideoPlayerMoreSetting.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SJVideoPlayerMoreSettingTwoSetting, UIColor, UIImage;

@interface SJVideoPlayerMoreSetting : NSObject

// MARK: ... Class methods

/*!
 *  SJVideoPlayerMoreSetting.titleColor = [UIColor whiteColor];
 *
 *  default is whiteColor
 */
@property (class, nonatomic, strong) UIColor *titleColor;

/*!
 *  SJVideoPlayerMoreSetting.titleFontSize = 12;
 *
 *  default is 12
 */
@property (class, nonatomic, assign) float titleFontSize;


// MARK: ... Instance Methods.   show 1 level interface

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, copy) void(^clickedExeBlock)(SJVideoPlayerMoreSetting *model);

- (instancetype)initWithTitle:(NSString *__nullable)title
                        image:(UIImage *__nullable)image
              clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block;


// MARK: ... Instance Methods.   show 2 level interface

@property (nonatomic, assign, getter=isShowTowSetting) BOOL showTowSetting;
@property (nonatomic, strong) NSString *twoSettingTopTitle;
@property (nonatomic, strong) NSArray<SJVideoPlayerMoreSettingTwoSetting *> *twoSettingItems;

- (instancetype)initWithTitle:(NSString *__nullable)title
                        image:(UIImage *__nullable)image
               showTowSetting:(BOOL)showTowSetting                                      // show
           twoSettingTopTitle:(NSString *)twoSettingTopTitle                            // top title
              twoSettingItems:(NSArray<SJVideoPlayerMoreSettingTwoSetting *> *)items    // items
              clickedExeBlock:(void(^)(SJVideoPlayerMoreSetting *model))block;

@end

NS_ASSUME_NONNULL_END
