//
//  SJDeviceVolumeAndBrightnessManagerResourceLoader.h
//  SJDeviceVolumeAndBrightnessManager
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UIImage;

@interface SJDeviceVolumeAndBrightnessManagerResourceLoader : NSObject

+ (UIImage * __nullable)imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
