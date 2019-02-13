//
//  SJAVMediaPresentView.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/11/25.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol SJAVPlayerLayerPresenter, SJAVPlayerLayerPresenterObserver;

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPresentView : UIView
@property (nonatomic, strong, null_resettable) AVLayerVideoGravity videoGravity;
@property (nonatomic, strong, readonly) id<SJAVPlayerLayerPresenter> mainPresenter;
@property (nonatomic, strong, readonly) id<SJAVPlayerLayerPresenter> subPresenter;

- (void)exchangePresenter;
- (void)reset;
- (void)resetMainPresenter;
- (void)resetSubPresenter;
@end


@protocol SJAVPlayerLayerPresenter
@property (nonatomic, strong, nullable) AVPlayer *player;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;
- (id<SJAVPlayerLayerPresenterObserver>)getObserver;
@end

@protocol SJAVPlayerLayerPresenterObserver
@property (nonatomic, copy, nullable) void(^isReadyForDisplayExeBlock)(id<SJAVPlayerLayerPresenter> presenter);
@end
NS_ASSUME_NONNULL_END
