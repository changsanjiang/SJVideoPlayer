//
//  SJBaseTableViewCell.m
//  LWZBaseViews_Example
//
//  Created by BlueDancer on 2018/12/11.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseTableViewCell
+ (NSString *)reuseIdentifier {
    return [self description];
}

+ (void)registerWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:[self reuseIdentifier]];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    SJBaseTableViewCell *cell = nil;
    NSString *reuseIdentifier = [self reuseIdentifier];
    @try {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    } @catch (NSException *exception) {
        [self registerWithTableView:tableView];
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    }
    return cell;
}
@end
NS_ASSUME_NONNULL_END
