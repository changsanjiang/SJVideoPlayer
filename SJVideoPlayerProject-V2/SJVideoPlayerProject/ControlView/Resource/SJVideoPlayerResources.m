//
//  SJVideoPlayerResources.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerResources.h"

@implementation SJVideoPlayerResources

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:[self bundleComponentWithImageName:name]];
}

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName {
    return [@"SJVideoPlayer.bundle" stringByAppendingPathComponent:imageName];
}

@end
