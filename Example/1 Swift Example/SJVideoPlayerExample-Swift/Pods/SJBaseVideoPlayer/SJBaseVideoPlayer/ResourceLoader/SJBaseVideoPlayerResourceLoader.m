//
//  SJBaseVideoPlayerResourceLoader.m
//  SJDeviceVolumeAndBrightnessManager
//
//  Created by 畅三江 on 2017/12/10.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJBaseVideoPlayerResourceLoader.h"
#import <UIKit/UIImage.h>

NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseVideoPlayerResourceLoader
+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJBaseVideoPlayerResources" ofType:@"bundle"]];
    });
    return bundle;
}

+ (nullable UIImage *)imageNamed:(NSString *)name {
    if ( 0 == name.length )
        return nil;
    int scale = (int)UIScreen.mainScreen.scale;
    if ( scale < 2 ) scale = 2;
    else if ( scale > 3 ) scale = 3;
    NSString *n = [NSString stringWithFormat:@"%@@%dx.png", name, scale];
    return [UIImage imageWithContentsOfFile:[self.bundle pathForResource:n ofType:nil]];
}

@end
NS_ASSUME_NONNULL_END
