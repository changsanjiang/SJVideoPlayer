//
//  SJBarrageViewModel.m
//  Pods
//
//  Created by BlueDancer on 2019/11/12.
//

#import "SJBarrageViewModel.h"

NS_ASSUME_NONNULL_BEGIN
static CGSize sj_textSize(NSAttributedString *attrStr, CGFloat width, CGFloat height) {
    if ( attrStr.length < 1 )
        return CGSizeZero;
    CGRect bounds = [attrStr boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}

@implementation SJBarrageViewModel
- (instancetype)initWithBarrageItem:(id<SJBarrageItem>)item {
    self = [super init];
    if ( self ) {
        if ( item.content.length != 0 ) {
            _content = item.content.copy;
            _contentSize = sj_textSize(item.content, CGFLOAT_MAX, CGFLOAT_MAX);
        }
        else {
            _customView = item.customView;
            _contentSize = item.customView.bounds.size;
        }
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
