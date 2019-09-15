//
//  SJAVMediaMainPresenter.h
//  Pods
//
//  Created by BlueDancer on 2019/3/28.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol SJAVMediaPresenter <NSObject>
- (instancetype)initWithAVPlayer:(AVPlayer *)player;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, strong, readonly, nullable) AVPlayer *player;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay; // support kvo
@property (nonatomic, copy, null_resettable) AVLayerVideoGravity videoGravity; // support kvo
@end

@protocol SJAVMediaMainPresenter <SJAVMediaPresenter>
- (void)insertSubPresenterToBack:(id<SJAVMediaPresenter>)presenter;
- (void)removeSubPresenter:(id<SJAVMediaPresenter>)presenter;
- (void)takeOverSubPresenter:(id<SJAVMediaPresenter>)presenter;
- (void)removeAllPresenters;
@end

@interface SJAVMediaSubPresenter : UIView<SJAVMediaPresenter>
@end

@interface SJAVMediaMainPresenter : UIView<SJAVMediaMainPresenter>
+ (instancetype)mainPresenter;
@end
NS_ASSUME_NONNULL_END
