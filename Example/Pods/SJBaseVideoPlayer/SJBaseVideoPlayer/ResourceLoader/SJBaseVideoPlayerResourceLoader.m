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
    NSString *path = [self.bundle pathForResource:name ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data scale:3.0];
    return image;
}

@end
NS_ASSUME_NONNULL_END
