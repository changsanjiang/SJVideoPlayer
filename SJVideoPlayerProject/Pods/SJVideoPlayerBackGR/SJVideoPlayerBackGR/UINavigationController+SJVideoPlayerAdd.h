//
//  UINavigationController+SJVideoPlayerAdd.h
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINavigationController (SJVideoPlayerAdd)<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;

@end





@interface UINavigationController (Settings)

/*!
 *  default is 0.35.
 *  0.0 .. 1.0
 */
@property (nonatomic, assign, readwrite) float scMaxOffset;

@end
