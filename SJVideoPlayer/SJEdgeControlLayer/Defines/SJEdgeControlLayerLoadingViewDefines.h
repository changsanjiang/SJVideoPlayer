//
//  SJEdgeControlLayerLoadingViewDefines.h
//  Pods
//
//  Created by 畅三江 on 2019/8/7.
//

#ifndef SJEdgeControlLayerLoadingViewDefines_h
#define SJEdgeControlLayerLoadingViewDefines_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJEdgeControlLayerLoadingViewProtocol <NSObject>
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@property (nonatomic, strong, null_resettable) UIColor *lineColor;
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

- (void)start;
- (void)stop;
@end
NS_ASSUME_NONNULL_END
#endif /* SJEdgeControlLayerLoadingViewDefines_h */
