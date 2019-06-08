//
//  SJFloatSmallViewControlLayerResourceLoader.h
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJFloatSmallViewControlLayerResourceLoader : NSObject
/// shared
+ (instancetype)shared;

- (void)reset;

@property (nonatomic, strong, nullable) UIImage *floatSmallViewCloseImage;
@end

NS_ASSUME_NONNULL_END
