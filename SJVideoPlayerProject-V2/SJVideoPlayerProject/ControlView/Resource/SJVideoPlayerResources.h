//
//  SJVideoPlayerResources.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJVideoPlayerResources : NSObject

+ (UIImage *)imageNamed:(NSString *)name;

+ (NSString *)bundleComponentWithImageName:(NSString *)imageName;

@end
