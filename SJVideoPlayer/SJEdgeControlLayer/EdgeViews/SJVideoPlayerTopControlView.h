//
//  SJVideoPlayerTopControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJVideoPlayerTopControlViewDelegate;
@class SJVideoPlayerTopControlConfig;

typedef NS_ENUM(NSUInteger, SJVideoPlayerTopViewTag) {
    SJVideoPlayerTopViewTag_Back,
    SJVideoPlayerTopViewTag_Preview,
    SJVideoPlayerTopViewTag_More,
};


@interface SJVideoPlayerTopControlView : UIView
@property (nonatomic, strong, readonly) SJVideoPlayerTopControlConfig *config;
@property (nonatomic, weak, nullable) id<SJVideoPlayerTopControlViewDelegate> delegate;

- (void)needUpdateConfig;
@end


@protocol SJVideoPlayerTopControlViewDelegate <NSObject>
@required
- (BOOL)hasBeenGeneratedPreviewImages;

@optional
- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayerTopViewTag)tag;
- (void)frameDidChangeOfTopControlView:(SJVideoPlayerTopControlView *)view;
@end


@interface SJVideoPlayerTopControlConfig : NSObject
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic) BOOL isPlayOnScrollView;
@property (nonatomic) BOOL isAlwaysShowTitle;
@property (nonatomic) BOOL isFitOnScreen;
@property (nonatomic) BOOL isFullscreen;
@end
NS_ASSUME_NONNULL_END
