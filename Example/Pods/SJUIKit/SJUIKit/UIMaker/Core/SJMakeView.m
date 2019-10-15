//
//  SJMakeView.m
//  Pods
//
//  Created by BlueDancer on 2019/2/27.
//

#import "SJMakeView.h"

NS_ASSUME_NONNULL_BEGIN
// - constant
#define _SJMakeView_IMP1(__class__, __type__, __name__)\
- (__class__(^)(__type__))__name__ {\
    return ^id(__type__ b)  {\
        [self->_m setValue:@(b) forKey:[NSString stringWithFormat:@"%s", #__name__]]; \
        return self; \
    };\
}

// - used in the result
#define _SJMakeView_IMP2(__class__, __type__, __name__)\
- (__class__(^)(__type__))__name__ {\
    return ^id(__type__ b)  {\
        self->_##__name__ = b;\
        return self; \
    };\
}

// - struct
#define _SJMakeView_IMP3(__class__, __type__, __name__)\
- (__class__(^)(__type__))__name__ {\
    return ^id(__type__ b)  {\
        [self->_m setValue:[NSValue valueWith##__type__:b] forKey:[NSString stringWithFormat:@"%s", #__name__]]; \
        return self; \
    };\
}

// - obj
#define _SJMakeView_IMP4(__class__, __type__, __name__)\
- (__class__(^)(__type__))__name__ {\
    return ^id(__type__ b)  {\
        [self->_m setValue:b forKey:[NSString stringWithFormat:@"%s", #__name__]]; \
        return self; \
    };\
}

@interface SJMakeView ()
- (UIView *)result;
@end

@implementation SJMakeView {
    CGRect _frame;
    UIColor *_backgroundColor;
    UIViewContentMode _contentMode;
    BOOL _clipsToBounds;
    
    @protected
    NSMutableDictionary<NSString *, id> *_m;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _m = [NSMutableDictionary dictionary];
    self.backgroundColor([UIColor whiteColor]);
    return self;
}

_SJMakeView_IMP1(SJMakeView *, CGRect, frame);
_SJMakeView_IMP4(SJMakeView *, UIColor *, backgroundColor);
_SJMakeView_IMP1(SJMakeView *, UIViewContentMode, contentMode);
_SJMakeView_IMP1(SJMakeView *, BOOL, clipsToBounds);

- (UIView *)result {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)install {
    UIView *result = [self result];
    [_m enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [result setValue:obj forKey:key];
    }];
    return result;
}
@end

@implementation SJMakeImageView {
    UIImage *_image;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self.clipsToBounds(YES);
    return self;
}

_SJMakeView_IMP4(SJMakeImageView *, UIImage *, image);

- (UIView *)result {
    return [[UIImageView alloc] initWithFrame:CGRectZero];
}
@end

@implementation SJMakeScrollView {
    CGPoint _contentOffset;
    CGSize _contentSize;
    UIEdgeInsets _contentInset;
    id<UIScrollViewDelegate> _delegate;
    BOOL _pagingEnabled;
    BOOL _scrollEnabled;
    BOOL _showsHorizontalScrollIndicator;
    BOOL _showsVerticalScrollIndicator;
    UIEdgeInsets _scrollIndicatorInsets;
    UIScrollViewIndicatorStyle _indicatorStyle;
    UIScrollViewKeyboardDismissMode _keyboardDismissMode;
}

_SJMakeView_IMP1(SJMakeScrollView *, CGPoint, contentOffset);
_SJMakeView_IMP1(SJMakeScrollView *, CGSize, contentSize);
_SJMakeView_IMP3(SJMakeScrollView *, UIEdgeInsets, contentInset);
_SJMakeView_IMP4(SJMakeScrollView *, id<UIScrollViewDelegate>, delegate);
_SJMakeView_IMP1(SJMakeScrollView *, BOOL, pagingEnabled);
_SJMakeView_IMP1(SJMakeScrollView *, BOOL, scrollEnabled);
_SJMakeView_IMP1(SJMakeScrollView *, BOOL, showsHorizontalScrollIndicator);
_SJMakeView_IMP1(SJMakeScrollView *, BOOL, showsVerticalScrollIndicator);
_SJMakeView_IMP3(SJMakeScrollView *, UIEdgeInsets, scrollIndicatorInsets);
_SJMakeView_IMP1(SJMakeScrollView *, UIScrollViewIndicatorStyle, indicatorStyle);
_SJMakeView_IMP1(SJMakeScrollView *, UIScrollViewKeyboardDismissMode, keyboardDismissMode);

- (UIView *)result {
    return [[UIScrollView alloc] initWithFrame:CGRectZero];
}
@end

@implementation SJMakeTableView {
    UITableViewStyle _style;
    id<UITableViewDataSource> _dataSource;
    UITableViewCellSeparatorStyle _separatorStyle;
    UIColor *_separatorColor;
    CGFloat _rowHeight;
}
@dynamic delegate;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    self.style(UITableViewStylePlain).rowHeight(44).separatorStyle(UITableViewCellSeparatorStyleNone);
    return self;
}

_SJMakeView_IMP2(SJMakeTableView *, UITableViewStyle, style);
_SJMakeView_IMP4(SJMakeTableView *, id<UITableViewDataSource>, dataSource);
_SJMakeView_IMP1(SJMakeTableView *, UITableViewCellSeparatorStyle, separatorStyle);
_SJMakeView_IMP4(SJMakeTableView *, UIColor *, separatorColor);
_SJMakeView_IMP1(SJMakeTableView *, CGFloat, rowHeight);

- (UIView *)result {
    return [[UITableView alloc] initWithFrame:CGRectZero style:_style];
}
@end
NS_ASSUME_NONNULL_END
