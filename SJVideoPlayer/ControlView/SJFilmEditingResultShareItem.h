//
//  SJFilmEditingResultShareItem.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJFilmEditingResultShareItem : NSObject


/**
 initialize

 @param title                       item title
 @param image                       item image
 @param yesOrNo                     Whether to exit. If YES, FilmEditingView exit when clicked item.
 @param clickedExeBlock             Clicked item exe block.
 @return instance
 */
- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
             clickToDisappear:(BOOL)yesOrNo
              clickedExeBlock:(void(^)(SJFilmEditingResultShareItem *filmEditingResultShareItem, UIImage *image, NSURL * __nullable exportedVideoURL))clickedExeBlock;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) BOOL clickToDisappear;
@property (nonatomic, strong, readonly) void(^clickedExeBlock)(SJFilmEditingResultShareItem *filmEditingResultShareItem, UIImage *image, NSURL * __nullable exportedVideoURL);

@end
NS_ASSUME_NONNULL_END
