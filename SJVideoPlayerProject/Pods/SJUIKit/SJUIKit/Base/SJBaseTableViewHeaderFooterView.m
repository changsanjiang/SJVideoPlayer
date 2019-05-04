//
//  SJBaseTableViewHeaderFooterView.m
//  AFNetworking
//
//  Created by BlueDancer on 2018/12/21.
//

#import "SJBaseTableViewHeaderFooterView.h"

@implementation SJBaseTableViewHeaderFooterView
+ (NSString *)reuseIdentifier {
    return [self description];
}

+ (void)registerWithTableView:(UITableView *)tableView {
    [tableView registerClass:[self class] forHeaderFooterViewReuseIdentifier:[self reuseIdentifier]];
}
+ (__kindof SJBaseTableViewHeaderFooterView *)reusableViewWithTableView:(UITableView *)tableView {
    NSString *reuseIdentifier = [self reuseIdentifier];
    SJBaseTableViewHeaderFooterView *view = nil;
    @try {
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    } @catch (NSException *exception) {
        [self registerWithTableView:tableView];
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    }
    return view;
}
@end
