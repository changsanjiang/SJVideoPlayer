//
//  UIColor+SJPageMenuBarExtended.m
//  SJUIKit
//
//  Created by BlueDancer on 2021/5/8.
//

#import "UIColor+SJPageMenuBarExtended.h"

@implementation UIColor (SJPageMenuBarExtended)
- (UIColor *)transitionToColor:(UIColor *)color progress:(CGFloat)progress {
    if ( [self isEqual:color] )
        return self;
    
    struct color {
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
    };
    
    struct color cur, to;
    [self getRed:&cur.red green:&cur.green blue:&cur.blue alpha:&cur.alpha];
    [color getRed:&to.red green:&to.green blue:&to.blue alpha:&to.alpha];
    
    return [UIColor colorWithRed:cur.red + (to.red - cur.red) * progress
                           green:cur.green + (to.green - cur.green) * progress
                            blue:cur.blue + (to.blue - cur.blue) * progress
                           alpha:cur.alpha + (to.alpha - cur.alpha) * progress];
}
@end
