//
//  SJTableViewHeaderFooterView.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/1/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJTableViewHeaderFooterView.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJTableViewHeaderFooterView
+ (void)registerWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forHeaderFooterViewReuseIdentifier:[self description]];
}

+ (SJTableViewHeaderFooterView *)headerFooterViewWithTableView:(UITableView *)tableView {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:[self description]];
}

- (instancetype)initWithReuseIdentifier:(NSString *_Nullable)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if ( !self ) return nil;
    self.backgroundColor = [UIColor blackColor];
    _view = [SJPlayView new];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.frame = self.bounds;
    _view.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_view];
    return self;
}
@end
NS_ASSUME_NONNULL_END
