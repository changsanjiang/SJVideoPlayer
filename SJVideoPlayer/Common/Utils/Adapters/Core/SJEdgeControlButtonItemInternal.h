//
//  SJEdgeControlButtonItemInternal.h
//  Pods
//
//  Created by 畅三江 on 2022/7/14.
//

#import "SJEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeControlButtonItem (SJInternal)
@property (nonatomic, getter=isInnerHidden) BOOL innerHidden; // 是否被sdk内部设置隐藏了;
@end
NS_ASSUME_NONNULL_END
