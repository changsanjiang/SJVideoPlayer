//
//  SJUIMaker.m
//  Pods
//
//  Created by BlueDancer on 2019/2/27.
//

#import "SJUIMaker.h"

NS_ASSUME_NONNULL_BEGIN
UIView *sj_makeView(void(^block)(SJMakeView *make)) {
    SJMakeView *make = [SJMakeView new];
    block(make);
    return make.install;
}
UITableView *sj_makeTableView(void(^block)(SJMakeTableView *make)) {
    SJMakeTableView *make = [SJMakeTableView new];
    block(make);
    return make.install;
}
UIImageView *sj_makeImageView(void(^block)(SJMakeImageView *make)) {
    SJMakeImageView *make = [SJMakeImageView new];
    block(make);
    return make.install;
}
NS_ASSUME_NONNULL_END
