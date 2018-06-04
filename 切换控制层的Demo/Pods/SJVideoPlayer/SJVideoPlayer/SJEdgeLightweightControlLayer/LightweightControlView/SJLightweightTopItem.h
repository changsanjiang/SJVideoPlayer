//
//  SJLightweightTopItem.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/22.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLightweightTopItemImageNameKeyPath;

@interface SJLightweightTopItem : NSObject

- (instancetype)initWithFlag:(NSInteger)flag imageName:(NSString *)imageName;

/**
 Player will observe the change in this property.
 Will do the appropriate update.
 If you change the image of item, the player will also be updated.
 
 readwrite.
 */
@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, assign, readonly) NSInteger flag;

@end
