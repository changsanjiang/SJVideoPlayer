//
//  SJStatusBarManager.m
//  Pods
//
//  Created by BlueDancer on 2019/1/10.
//

#import "SJStatusBarManager.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJStatusBarManager
@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarStyle = _preferredStatusBarStyle;

- (void)setPreferredStatusBarStyle:(UIStatusBarStyle (^_Nullable)(void))preferredStatusBarStyle {
    _preferredStatusBarStyle = preferredStatusBarStyle;
}

- (UIStatusBarStyle (^)(void))preferredStatusBarStyle {
    if ( _preferredStatusBarStyle )
        return _preferredStatusBarStyle;
    
    return ^UIStatusBarStyle {
        return NO;
    };
}

- (void)setPrefersStatusBarHidden:(BOOL (^_Nullable)(void))prefersStatusBarHidden {
    _prefersStatusBarHidden = prefersStatusBarHidden;
}

- (BOOL (^)(void))prefersStatusBarHidden {
    if ( _prefersStatusBarHidden )
        return _prefersStatusBarHidden;
    return ^BOOL {
        return UIStatusBarStyleDefault;
    };
}
@end
NS_ASSUME_NONNULL_END
