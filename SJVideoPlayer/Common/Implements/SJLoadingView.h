//
//  SJLoadingView.h
//  Pods
//
//  Created by 畅三江 on 2019/11/27.
//

#import "SJLoadingViewDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJLoadingView : UIView<SJLoadingView>
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
@property (nonatomic) BOOL showsNetworkSpeed;
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

- (void)start;
- (void)stop;
@end
NS_ASSUME_NONNULL_END
