//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreMedia/CMTime.h>

NS_ASSUME_NONNULL_BEGIN

#define SJPreviewImgW   (160.0)
#define SJPreViewImgH   (SJPreviewImgW * 9 / 16)
#define SJContainerH    (49)


@class SJSlider, SJVideoPlayerMoreSetting;

typedef NS_ENUM(NSUInteger, SJVideoPlayControlViewTag) {
    SJVideoPlayControlViewTag_Back,
    SJVideoPlayControlViewTag_Full,
    SJVideoPlayControlViewTag_Play,
    SJVideoPlayControlViewTag_Pause,
    SJVideoPlayControlViewTag_Replay,
    SJVideoPlayControlViewTag_Preview,
    SJVideoPlayControlViewTag_Lock,
    SJVideoPlayControlViewTag_Unlock,
    SJVideoPlayControlViewTag_LoadFailed,
    SJVideoPlayControlViewTag_More,
};




typedef NS_ENUM(NSUInteger, SJVideoPlaySliderTag) {
    SJVideoPlaySliderTag_Volume,
    SJVideoPlaySliderTag_Brightness,
    SJVideoPlaySliderTag_Rate,
    SJVideoPlaySliderTag_Control,
    SJVideoPlaySliderTag_Dragging,
};





@protocol SJVideoPlayerControlViewDelegate;


#pragma mark -

@interface SJVideoPlayerControlView : UIView

@property (nonatomic, weak, readwrite) id <SJVideoPlayerControlViewDelegate> delegate;

@property (nonatomic, strong, readonly) SJSlider *sliderControl;
@property (nonatomic, strong, readonly) UILabel *draggingTimeLabel;
@property (nonatomic, strong, readonly) SJSlider *draggingProgressView;


/// 1 level more settings
@property (nonatomic, strong, readwrite) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

/// 2 level more settings
@property (nonatomic, strong, readwrite) SJVideoPlayerMoreSetting *twoLevelSettings;

- (void)startLoading;

- (void)stopLoading;

@end


#pragma mark -


@interface SJVideoPlayerControlView (TimeOperation)

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration;

- (NSString *)formatSeconds:(NSInteger)value;

@end





#pragma mark -

@class SJVideoPreviewModel;

@interface SJVideoPlayerControlView (Preview)

@property (nonatomic, strong, nullable) NSArray<SJVideoPreviewModel *> *previewImages;

@end


#pragma mark -

@interface SJVideoPreviewModel : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time;

@property (nonatomic, assign, readwrite) BOOL isHiddenControl;

@end



#pragma mark -

@interface SJVideoPlayerControlView (MoreSettings)

@property (nonatomic, strong, readonly, nullable) SJSlider *volumeSlider;
@property (nonatomic, strong, readonly, nullable) SJSlider *brightnessSlider;
@property (nonatomic, strong, readonly, nullable) SJSlider *rateSlider;

- (void)getMoreSettingsSlider:(void(^)(SJSlider *volumeSlider, SJSlider *brightnessSlider, SJSlider *rateSlider))block;

@end




#pragma mark -


@protocol SJVideoPlayerControlViewDelegate <NSObject>

@optional

- (void)controlView:(SJVideoPlayerControlView *)controlView clickedBtnTag:(SJVideoPlayControlViewTag)tag;

- (void)controlView:(SJVideoPlayerControlView *)controlView selectedPreviewModel:(SJVideoPreviewModel *)model;

@end




#pragma mark -

@interface SJVideoPlayerControlView (HiddenOrShow)

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenBackBtn;


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
@property (nonatomic, assign, readwrite) BOOL hiddenPreview;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenUnlockBtn;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenLockBtn;

/*!
 *  defautl is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenLockContainerView;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenControl;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenLoadFailedBtn;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenBottomProgressView;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenMoreBtn;

/*!
 *  default is YES
 */
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSettingsView;

/*!
 *  default is YES
 */
@property (nonatomic, assign, readwrite) BOOL hiddenMoreSettingsTwoLevelView;

/*!
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL hiddenDraggingProgress;

@end

NS_ASSUME_NONNULL_END
