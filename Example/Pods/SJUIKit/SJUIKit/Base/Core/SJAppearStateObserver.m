//
//  SJViewControllerObserver.m
//  SJUIKit_Example
//
//  Created by 畅三江 on 2018/12/23.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJAppearStateObserver.h"
#import "NSObject+SJObserverHelper.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAppearStateObserver ()

@end

@implementation SJAppearStateObserver
@synthesize vc_viewWillAppearExeBlock = _vc_viewWillAppearExeBlock;
@synthesize vc_viewDidAppearExeBlock = _vc_viewDidAppearExeBlock;
@synthesize vc_viewWillDisappearExeBlock = _vc_viewWillDisappearExeBlock;
@synthesize vc_viewDidDisappearExeBlock = _vc_viewDidDisappearExeBlock;
static char appearStateKey;

- (instancetype)initWithViewController:(__kindof __weak id<SJAppearProtocol>)viewController {
    self = [super init];
    if ( !self ) return nil;
    [viewController sj_addObserver:self forKeyPath:@"appearState" context:&appearStateKey];
    return self;
}

- (void)observeValueForKeyPath:(NSString *_Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey,id> *_Nullable)change context:(void *_Nullable)context {
    if ( context == &appearStateKey ) {
        if ( [change[NSKeyValueChangeOldKey] integerValue] == [change[NSKeyValueChangeNewKey] integerValue] )
            return;
        
        id<SJAppearProtocol> vc = object;
        switch ( vc.appearState ) {
            case SJAppearState_Unknown: break;
            case SJAppearState_WillAppear: {
                if ( _vc_viewWillAppearExeBlock ) _vc_viewWillAppearExeBlock(vc);
            }
                break;
            case SJAppearState_DidAppear: {
                if ( _vc_viewDidAppearExeBlock ) _vc_viewDidAppearExeBlock(vc);
            }
                break;
            case SJAppearState_WillDisappear: {
                if ( _vc_viewWillDisappearExeBlock ) _vc_viewWillDisappearExeBlock(vc);
            }
                break;
            case SJAppearState_DidDisappear: {
                if ( _vc_viewDidDisappearExeBlock ) _vc_viewDidDisappearExeBlock(vc);
            }
                break;
        }
    }
}
@end
NS_ASSUME_NONNULL_END
