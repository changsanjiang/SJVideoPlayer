//
//  SJLightweightTopControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJLightweightTopControlModel : NSObject
@property (nonatomic) BOOL alwaysShowTitle;
@property (nonatomic) BOOL isPlayOnScrollView;
@property (nonatomic, copy, nullable) NSString *title;
@end

@protocol SJLightweightTopControlViewDelegate;

@interface SJLightweightTopControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJLightweightTopControlViewDelegate> delegate;

@property (nonatomic, assign) BOOL isFullscreen;

@property (nonatomic, strong, readonly) SJLightweightTopControlModel *model;

- (void)needUpdateTitle;

@property (nonatomic, strong, readonly) UIButton *backBtn;

@end

@protocol SJLightweightTopControlViewDelegate <NSObject>
			
@optional
- (void)clickedBackBtnOnTopControlView:(SJLightweightTopControlView *)view;

@end
NS_ASSUME_NONNULL_END
