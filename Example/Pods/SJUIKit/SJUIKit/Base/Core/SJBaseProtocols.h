//
//  SJBaseProtocols.h
//  SJUIKit
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#ifndef SJBaseProtocols_h
#define SJBaseProtocols_h
#import <UIKit/UIKit.h>
@protocol SJAppearStateObserver;

typedef enum : NSUInteger {
    SJAppearState_Unknown,
    SJAppearState_WillAppear,
    SJAppearState_DidAppear,
    SJAppearState_WillDisappear,
    SJAppearState_DidDisappear,
} SJAppearState;

NS_ASSUME_NONNULL_BEGIN
@protocol SJAppearProtocol
@property (nonatomic, readonly) SJAppearState appearState;
- (id<SJAppearStateObserver>)getAppearStateObserver;
@end

/// ViewController appear state Observer
@protocol SJAppearStateObserver
- (instancetype)initWithViewController:(__kindof __weak id<SJAppearProtocol>)viewController;

@property (nonatomic, copy, nullable) void(^vc_viewWillAppearExeBlock)(__kindof id<SJAppearProtocol> viewController);
@property (nonatomic, copy, nullable) void(^vc_viewDidAppearExeBlock)(__kindof id<SJAppearProtocol> viewController);
@property (nonatomic, copy, nullable) void(^vc_viewWillDisappearExeBlock)(__kindof id<SJAppearProtocol> viewController);
@property (nonatomic, copy, nullable) void(^vc_viewDidDisappearExeBlock)(__kindof id<SJAppearProtocol> viewController);

+ (instancetype)new  NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

@protocol SJHiddenNavigationBarProtocol
@property (nonatomic) BOOL needHiddenNavigationBar;
@end

@protocol SJStatusBarManager <NSObject>
@property (nonatomic, copy, null_resettable) BOOL(^prefersStatusBarHidden)(void);
@property (nonatomic, copy, null_resettable) UIStatusBarStyle(^preferredStatusBarStyle)(void);
@end
NS_ASSUME_NONNULL_END

#endif /* SJBaseProtocols_h */
