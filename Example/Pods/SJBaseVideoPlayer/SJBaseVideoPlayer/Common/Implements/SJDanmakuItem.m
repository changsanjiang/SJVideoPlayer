//
//  SJDanmakuItem.m
//  Pods
//
//  Created by 畅三江 on 2019/11/12.
//

#import "SJDanmakuItem.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJDanmakuItem
- (instancetype)initWithContent:(NSAttributedString *)content {
    self = [super init];
    if ( self ) {
        _content = content.copy;
    }
    return self;
}
- (instancetype)initWithCustomView:(__kindof UIView *)customView {
    self = [super init];
    if ( self ) {
        _customView = customView;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
