//
//  SJRouteHandlers.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJRouteHandlers.h"
#import <SJRouter/SJRouter.h>

#import "SJUITableViewDemoViewController1.h"
#import "SJUITableViewDemoViewController2.h"
#import "SJUITableViewDemoViewController3.h"
#import "SJUITableViewDemoViewController4.h"
#import "SJUITableViewDemoViewController5.h"
#import "SJUITableViewDemoViewController6.h"
#import "SJUITableViewDemoViewController7.h"
#import "SJUITableViewDemoViewController8.h"
#import "SJFloatingModeDemoViewController2.h"

#import "SJUICollectionViewDemoViewController1.h"
#import "SJUICollectionViewDemoViewController2.h"
#import "SJUICollectionViewDemoViewController3.h"
#import "SJUICollectionViewDemoViewController4.h"
#import "SJUICollectionViewDemoViewController5.h"

#import "SJKeyboardDemoViewController1.h"

#import "SJDYMainViewController.h"
#import "DYHPlaybackListViewController.h"

#import "SJUIScrollViewDemoViewController1.h"
#import "SJUIScrollViewDemoViewController2.h"

#import "SJFloatingModeDemoViewController1.h"

#import "SJPIPDemoViewController.h"

#import "SJMainPageViewController.h"

@implementation SJRouteHandlers
+ (void)addRoutesToRouter:(SJRouter *)router {
    __auto_type addBlock = ^(NSArray<SJRouteObject *> *array) {
        for ( SJRouteObject *object in array ) {
            [router addRoute:object];
        }
    };
    
    addBlock([self routeObjectArrayForFloatingModeDemo]);
    addBlock([self routeObjectArrayForUIScrollViewDemo]);
    addBlock([self routeObjectArrayForDYDemo]);
    addBlock([self routeObjectArrayForUITableViewDemo]);
    addBlock([self routeObjectArrayForUICollectionViewDemo]);
    addBlock([self routeObjectArrayForKeyboardDemo]);
    addBlock([self routeObjectArrayForPageViewControllerDemo]);
}

+ (NSArray<SJRouteObject *> *)routeObjectArrayForPageViewControllerDemo {
    return @[
        [SJRouteObject.alloc initWithPath:@"PageViewController/1" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = [SJMainPageViewController.alloc init];
            if ( completionHandler ) completionHandler(vc, nil);
        }],
    ];
}

+ (NSArray<SJRouteObject *> *)routeObjectArrayForFloatingModeDemo {
    return @[
        [SJRouteObject.alloc initWithPath:@"FloatingMode/1" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = [SJFloatingModeDemoViewController1 viewControllerWithVideoId:10];
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"FloatingMode/2" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJFloatingModeDemoViewController2.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"FloatingMode/3" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJPIPDemoViewController.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }]
    ];
}

+ (NSArray<SJRouteObject *> *)routeObjectArrayForUIScrollViewDemo {
    return @[
        [SJRouteObject.alloc initWithPath:@"UIScrollView/1" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUIScrollViewDemoViewController1.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UIScrollView/2" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUIScrollViewDemoViewController2.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
    ];
}

+ (NSArray<SJRouteObject *> *)routeObjectArrayForDYDemo {
    return @[
        [SJRouteObject.alloc initWithPath:@"dy/1" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJDYMainViewController.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"dy/2" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = DYHPlaybackListViewController.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
    ];
}

+ (NSArray<SJRouteObject *> *)routeObjectArrayForKeyboardDemo {
    return @[
        [SJRouteObject.alloc initWithPath:@"Keyboard/1" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJKeyboardDemoViewController1.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }]
    ];
}

+ (NSArray<SJRouteObject *> *)routeObjectArrayForUICollectionViewDemo {
    return @[
        [SJRouteObject.alloc initWithPath:@"UICollectionView/1" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUICollectionViewDemoViewController1.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UICollectionView/2" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUICollectionViewDemoViewController2.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UICollectionView/3" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUICollectionViewDemoViewController3.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UICollectionView/4" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUICollectionViewDemoViewController4.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UICollectionView/5" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUICollectionViewDemoViewController5.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],

    ];
}

+ (NSArray<SJRouteObject *> *)routeObjectArrayForUITableViewDemo {
    return @[
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/1" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController1.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/2" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController2.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/3" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController3.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/4" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController4.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/5" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController5.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/6" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController6.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/7" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController7.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }],
        [SJRouteObject.alloc initWithPath:@"UITableViewDemo/8" transitionMode:SJViewControllerTransitionModeNavigation createInstanceBlock:^(SJRouteRequest * _Nonnull request, SJCompletionHandler  _Nullable completionHandler) {
            __auto_type vc = SJUITableViewDemoViewController8.new;
            if ( completionHandler ) completionHandler(vc, nil);
        }]
    ];
}

@end
