//
//  SJAVMediaPresentView.h
//  SJBaseVideoPlayer
//
//  Created by 畅三江 on 2018/11/25.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJAVPlayerLayerPresenter <NSObject>
@property (nonatomic, strong, null_resettable) AVLayerVideoGravity videoGravity; // deafult value is `AVLayerVideoGravityResizeAspect`;
@property (nonatomic, copy, nullable) void(^isReadyForDisplayExeBlock)(id<SJAVPlayerLayerPresenter> presenter);
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;
@end

@interface SJAVMediaPresentView : UIView
- (id<SJAVPlayerLayerPresenter>)createPresenterForPlayer:(AVPlayer *)player;

@property (nonatomic, strong, readonly) NSArray<id<SJAVPlayerLayerPresenter>> *presenters;
- (void)addPresenter:(id<SJAVPlayerLayerPresenter>)presenter;
- (void)insertPresenter:(id<SJAVPlayerLayerPresenter>)presenter atIndex:(NSInteger)idx;
- (void)insertPresenter:(id<SJAVPlayerLayerPresenter>)presenter belowPresenter:(id<SJAVPlayerLayerPresenter>)belowPresenter;
- (void)insertPresenter:(id<SJAVPlayerLayerPresenter>)presenter abovePresenter:(id<SJAVPlayerLayerPresenter>)abovePresenter;
- (void)removePresenter:(id<SJAVPlayerLayerPresenter>)presenter;
- (void)removeAllPresenter;
- (void)removeLastPresenter;
- (void)removeAllPresenterAndAddNewPresenter:(id<SJAVPlayerLayerPresenter>)presenter;
@end
NS_ASSUME_NONNULL_END
