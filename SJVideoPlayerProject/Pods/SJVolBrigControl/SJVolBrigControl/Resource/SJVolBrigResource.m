//
//  SJVolBrigResource.m
//  SJVolBrigControl
//
//  Created by BlueDancer on 2017/12/10.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVolBrigResource.h"
#import <UIKit/UIImage.h>

@implementation SJVolBrigResource

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:[self bundleComponentWithImageName:name]];
}

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName {
    return [@"SJVolBrigResource.bundle" stringByAppendingPathComponent:imageName];
}

@end
