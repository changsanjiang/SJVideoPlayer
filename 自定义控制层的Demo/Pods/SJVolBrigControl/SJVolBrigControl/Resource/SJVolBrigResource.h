//
//  SJVolBrigResource.h
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const SJVolBrigControlBrightnessText;

@class UIImage;

@interface SJVolBrigResource : NSObject

+ (UIImage * __nullable)imageNamed:(NSString *)name;

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName;

+ (NSString *)localizedStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
