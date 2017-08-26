//
//  SJVideoPlayer.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView, UIImage, SJVideoPlayerMoreSetting;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayer : NSObject

+ (instancetype)sharedPlayer;

@property (nonatomic, copy, readwrite) void(^clickedBackEvent)();

/*!
 *  if you want to play, you need to set it up.
 */
@property (nonatomic, strong, readwrite) NSURL *assetURL;

/*!
 *  Present View. you shuold set it frame (support autoLayout).
 */
@property (nonatomic, strong, readonly) UIView *view;


@property (nonatomic, strong, readwrite) UIImage *placeholder;
@property (nonatomic, strong, readwrite) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

/*!
 *  Error
 */
@property (nonatomic, strong, readonly) NSError *error;

@end




@interface SJVideoPlayer (Operation)

- (NSTimeInterval)currentTime;

- (void)pause;

- (void)play;

- (void)jumpedToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)stop;

/*!
 *  0.5 ... 2.0
 */
@property (nonatomic, assign, readwrite) float rate;

- (UIImage *)screenShot;

@end



@interface SJVideoPlayer (Prompt)

- (void)showTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
