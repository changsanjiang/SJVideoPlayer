//
//  UIViewController+SJVideoPlayerAdd.h
//  SJBackGR
//
//  Created by BlueDancer on 2017/9/27.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SJVideoPlayerAdd)

@property (nonatomic, copy, readwrite) void(^sj_viewWillBeginDragging)(UIViewController *vc);
@property (nonatomic, copy, readwrite) void(^sj_viewDidDrag)(UIViewController *vc);
@property (nonatomic, copy, readwrite) void(^sj_viewDidEndDragging)(UIViewController *vc);

@end
