//
//  SJVolBrigResource.m
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVolBrigResource.h"
#import <UIKit/UIImage.h>

NSString *const SJVolBrigControlBrightnessText = @"SJVolBrigControlBrightnessText";

@implementation SJVolBrigResource

+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    if ( bundle == nil ) {
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJVolBrigResource" ofType:@"bundle"]];
    }
    return bundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[self bundle] compatibleWithTraitCollection:nil];
}

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName {
    return [@"SJVolBrigResource.bundle" stringByAppendingPathComponent:imageName];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    static NSBundle *bundle = nil;
    if ( nil == bundle ) {
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
    }
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
