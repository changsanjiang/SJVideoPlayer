//
//  SJUIMaker.h
//  Pods
//
//  Created by BlueDancer on 2019/2/27.
//

#import <Foundation/Foundation.h>
#import "SJMakeView.h"

NS_ASSUME_NONNULL_BEGIN
extern UIView *sj_makeView(void(^block)(SJMakeView *make));
extern UIScrollView *sj_makeScrollView(void(^block)(SJMakeScrollView *make));
extern UITableView *sj_makeTableView(void(^block)(SJMakeTableView *make));
extern UIImageView *sj_makeImageView(void(^block)(SJMakeImageView *make));
NS_ASSUME_NONNULL_END
