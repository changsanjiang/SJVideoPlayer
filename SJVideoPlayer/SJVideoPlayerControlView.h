//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, SJVideoPlayControlViewTag) {
    SJVideoPlayControlViewTag_Back,
    SJVideoPlayControlViewTag_Full,
    SJVideoPlayControlViewTag_Play,
    SJVideoPlayControlViewTag_Pause,
    SJVideoPlayControlViewTag_Replay,
};




@protocol SJVideoPlayerControlViewDelegate;



@interface SJVideoPlayerControlView : UIView

@property (nonatomic, weak, readwrite) id <SJVideoPlayerControlViewDelegate> delegate;

@end





@interface SJVideoPlayerControlView (HiddenOrShow)

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenPauseBtn;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenPlayBtn;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenReplayBtn;

@end



@interface SJVideoPlayerControlView (TimeOperation)

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;

@end






@protocol SJVideoPlayerControlViewDelegate <NSObject>

@optional

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag;

@end
