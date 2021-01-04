//
//  SJLoadingViewDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/11/27.
//

#ifndef SJLoadingViewDefines_h
#define SJLoadingViewDefines_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJLoadingView <NSObject>
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
@property (nonatomic) BOOL showsNetworkSpeed;
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

- (void)start;
- (void)stop;
@end
NS_ASSUME_NONNULL_END

#endif /* SJLoadingViewDefines_h */
