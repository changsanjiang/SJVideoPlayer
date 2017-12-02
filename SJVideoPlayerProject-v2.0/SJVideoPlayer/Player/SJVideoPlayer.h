//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

/*!
 *  present View. you shuold set it frame (support autoLayout).
 */
@property (nonatomic, strong, readonly) UIView *view;

/*!
 *  error.
 */
@property (nonatomic, strong, readonly) NSError *error;

@end


#pragma mark - 

@interface SJVideoPlayer (Setting)

/*!
 *  if you want to play, you need to set it up.
 */
@property (nonatomic, strong, readwrite, nullable) NSURL *assetURL;

/*!
 *  loading show this.
 */
- (void)setPlaceholder:(UIImage *)placeholder;

/*!
 *  default is YES.
 */
@property (nonatomic, assign, getter=isAutoplay) BOOL autoplay;
- (void)setIsAutoplay:(BOOL)isAutoplay;

/*!
 *  default is YES.
 */
@property (nonatomic, assign, readwrite) BOOL generatePreviewImages;

/*!
 *  clicked back btn exe block.
 */
@property (nonatomic, copy, readwrite) void(^clickedBackEvent)(SJVideoPlayer *player);

/*!
 *  if playing on the cell, you should set it.
 */
- (void)setScrollView:(UIScrollView *)scrollView indexPath:(NSIndexPath *)indexPath onViewTag:(NSInteger)tag;

@property (nonatomic, strong, readwrite) AVLayerVideoGravity videoGravity;

@end


#pragma mark -

@interface SJVideoPlayer (Control)

- (BOOL)play;

- (BOOL)pause;

@end

NS_ASSUME_NONNULL_END
