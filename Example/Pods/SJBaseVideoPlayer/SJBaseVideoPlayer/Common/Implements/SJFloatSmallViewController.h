//
//  SJFloatSmallViewController.h
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#import <UIKit/UIKit.h>
#import "SJFloatSmallViewControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SJFloatViewLayoutPosition) {
    SJFloatViewLayoutPositionTopLeft,
    SJFloatViewLayoutPositionTopRight,
    SJFloatViewLayoutPositionBottomLeft,
    SJFloatViewLayoutPositionBottomRight,
};

@interface SJFloatSmallViewController : NSObject<SJFloatSmallViewController>
/// default value is SJFloatViewLayoutPositionBottomRight.
@property (nonatomic) SJFloatViewLayoutPosition layoutPosition;
/// default value is UIEdgeInsetsMake(20, 12, 20, 12).
@property (nonatomic) UIEdgeInsets layoutInsets;
@property (nonatomic) CGSize layoutSize;
@property (nonatomic) BOOL ignoreSafeAreaInsets API_AVAILABLE(ios(11.0));
@end
NS_ASSUME_NONNULL_END
