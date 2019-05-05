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
@implementation DemoTableViewCellViewModel
@synthesize coverTag = _coverTag;
@synthesize title = _title;
@synthesize coverURL = _coverURL;
@synthesize height = _height;

- (instancetype)initWithModel:(DemoMediaModel *)model {
    self = [super init];
    if ( !self ) return nil;
    _title = model.title;
    _coverURL = model.coverURL;
    _playURL = model.playURL;
    _height = UIScreen.mainScreen.bounds.size.width * 9 / 16.0 + 8;
    return self;
}

- (NSInteger)coverTag {
    return DemoTableViewCellCoverTag;
}
@end
NS_ASSUME_NONNULL_END
