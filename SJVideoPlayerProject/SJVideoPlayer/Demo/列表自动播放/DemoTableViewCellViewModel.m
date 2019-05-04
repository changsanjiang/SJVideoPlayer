//
//  DemoTableViewCellViewModel.m
//  MJRefreshDemo
//
//  Created by BlueDancer on 2019/5/4.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "DemoTableViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN
NSInteger DemoTableViewCellCoverTag = 101;

@interface DemoTableViewCellViewModel ()
@end

@implementation DemoTableViewCellViewModel
@synthesize coverTag = _coverTag;

- (instancetype)initWithModel:(DemoMediaModel *)model {
    self = [super init];
    if ( !self ) return nil;
    _model = model;
    return self;
}

- (NSInteger)coverTag {
    return DemoTableViewCellCoverTag;
}

- (nullable NSString *)title {
    return _model.title;
}

- (nullable NSString *)coverURL {
    return _model.coverURL;
}

- (CGFloat)height {
    return UIScreen.mainScreen.bounds.size.width * 9 / 16.0 + 8;
}
@end
NS_ASSUME_NONNULL_END
