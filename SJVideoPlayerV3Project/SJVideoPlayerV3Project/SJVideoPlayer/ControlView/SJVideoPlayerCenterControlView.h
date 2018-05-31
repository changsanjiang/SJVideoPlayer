//
//  SJVideoPlayerCenterControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerCenterViewTag) {
    SJVideoPlayerCenterViewTag_Failed,
    SJVideoPlayerCenterViewTag_Replay,
};

@protocol SJVideoPlayerCenterControlViewDelegate;

@interface SJVideoPlayerCenterControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerCenterControlViewDelegate> delegate;

- (void)failedState;

- (void)replayState;

@end

@protocol SJVideoPlayerCenterControlViewDelegate <NSObject>
			
@optional
- (void)centerControlView:(SJVideoPlayerCenterControlView *)view clickedBtnTag:(SJVideoPlayerCenterViewTag)tag;

@end

NS_ASSUME_NONNULL_END
