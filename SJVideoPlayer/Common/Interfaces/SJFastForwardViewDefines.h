//
//  SJFastForwardViewDefines.h
//  Pods
//
//  Created by BlueDancer on 2020/2/21.
//

#ifndef SJFastForwardViewDefines_h
#define SJFastForwardViewDefines_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJFastForwardView <NSObject>
@property (nonatomic) CGFloat rate;

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
- (void)show;
- (void)hidden;
@end
NS_ASSUME_NONNULL_END
#endif /* SJFastForwardViewDefines_h */
