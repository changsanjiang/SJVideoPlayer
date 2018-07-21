//
//  SJLightweightTopControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJLightweightTopControlViewDelegate;
@class SJLightweightTopItem, SJLightweightTopControlConfig;


@interface SJLightweightTopControlView : UIView
@property (nonatomic, strong, readonly) SJLightweightTopControlConfig *config;
@property (nonatomic, weak, nullable) id<SJLightweightTopControlViewDelegate> delegate;
- (void)needUpdateConfig;

@property (nonatomic, strong, nullable) NSArray<SJLightweightTopItem *> *topItems;
@property (nonatomic, strong, readonly) UIButton *backBtn;
@end


@protocol SJLightweightTopControlViewDelegate <NSObject>
			
@optional
- (void)clickedBackBtnOnTopControlView:(SJLightweightTopControlView *)view;
- (void)topControlView:(SJLightweightTopControlView *)view clickedItem:(SJLightweightTopItem *)item;
@end


@interface SJLightweightTopControlConfig : NSObject
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic) BOOL isPlayOnScrollView;
@property (nonatomic) BOOL isAlwaysShowTitle;
@property (nonatomic) BOOL isFitOnScreen;
@property (nonatomic) BOOL isFullscreen;
@end

NS_ASSUME_NONNULL_END
