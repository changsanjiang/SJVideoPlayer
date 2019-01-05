//
//  SJDeviceVolumeAndBrightnessManagerResourceLoader.m
//  SJDeviceVolumeAndBrightnessManager
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJDeviceVolumeAndBrightnessManagerResourceLoader.h"
#import <UIKit/UIImage.h>

NSString *const SJVolBrigControlBrightnessText = @"SJVolBrigControlBrightnessText";

@implementation SJDeviceVolumeAndBrightnessManagerResourceLoader

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJDeviceVolumeAndBrightnessManager" ofType:@"bundle"]];
    });
    return bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[self bundle] compatibleWithTraitCollection:nil];
}

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName {
    return [@"SJDeviceVolumeAndBrightnessManager.bundle" stringByAppendingPathComponent:imageName];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ( [language hasPrefix:@"en"] ) {
            language = @"en";
        }
        else if ( [language hasPrefix:@"zh"] ) {
            if ( [language containsString:@"Hans"] ) {
                language = @"zh-Hans";
            }
            else {
                language = @"zh-Hant";
            }
        }
        else {
            language = @"en";
        }
        
        bundle = [NSBundle bundleWithPath:[[self bundle] pathForResource:language ofType:@"lproj"]];
    });
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
