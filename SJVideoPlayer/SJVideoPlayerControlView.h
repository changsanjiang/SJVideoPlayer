//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreMedia/CMTime.h>

#define SJPreviewImgW   (120)
#define SJPreViewImgH   (SJPreviewImgW * 9 / 16)
#define SJContainerH    (49)

#define SJHiddenControlInterval (4)

@class SJSlider;

typedef NS_ENUM(NSUInteger, SJVideoPlayControlViewTag) {
    SJVideoPlayControlViewTag_Back,
    SJVideoPlayControlViewTag_Full,
    SJVideoPlayControlViewTag_Play,
    SJVideoPlayControlViewTag_Pause,
    SJVideoPlayControlViewTag_Replay,
    SJVideoPlayControlViewTag_Preview,
    SJVideoPlayControlViewTag_Lock,
    SJVideoPlayControlViewTag_Unlock,
};




@protocol SJVideoPlayerControlViewDelegate;



@interface SJVideoPlayerControlView : UIView

@property (nonatomic, weak, readwrite) id <SJVideoPlayerControlViewDelegate> delegate;

@property (nonatomic, strong, readonly) SJSlider *sliderControl;

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

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenPreviewBtn;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenUnlockBtn;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenLockBtn;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenControl;

@end



// MARK: Time


@interface SJVideoPlayerControlView (TimeOperation)

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;

@end





// MARK: Preview

@interface SJVideoPreviewModel : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time;

@property (nonatomic, assign, readwrite) BOOL isHiddenControl;

@end


@interface SJVideoPlayerControlView (Preview)

@property (nonatomic, strong) NSArray<SJVideoPreviewModel *> *previewImages;

@end




@protocol SJVideoPlayerControlViewDelegate <NSObject>

@optional

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag;

- (void)controlView:(SJVideoPlayerControlView *)controlView selectedPreviewModel:(SJVideoPreviewModel *)model;

@end
