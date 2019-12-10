//
//  SJLoadingViewDefinies.h
//  Pods
//
//  Created by BlueDancer on 2019/11/27.
//

#ifndef SJLoadingViewDefinies_h
#define SJLoadingViewDefinies_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJLoadingView <NSObject>
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
- (void)start;
- (void)stop;
@end
NS_ASSUME_NONNULL_END

#endif /* SJLoadingViewDefinies_h */
