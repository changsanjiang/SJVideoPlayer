//
//  SJAVMediaPresentView.h
//  Pods
//
//  Created by 畅三江 on 2019/10/5.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@class SJAVMediaPresentViewObserver;

NS_ASSUME_NONNULL_BEGIN
extern NSNotificationName const SJAVMediaPresentViewReadyForDisplayDidChangeNotification;

@interface SJAVMediaPresentView : UIView
- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player;

@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;
@property (nonatomic, strong, readonly, nullable) AVPlayer *player;
@property (nonatomic, copy, null_resettable) AVLayerVideoGravity videoGravity;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
