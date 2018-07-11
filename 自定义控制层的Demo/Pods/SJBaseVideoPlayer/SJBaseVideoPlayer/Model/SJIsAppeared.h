//
//  SJIsAppeared.h
//  Masonry
//
//  Created by BlueDancer on 2018/7/10.
//

#import <UIKit/UIKit.h>

extern bool sj_isAppeared1(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UITableView *tableView);

extern bool sj_isAppeared2(UIView *childView, UITableView *tableView);

extern bool sj_isAppeared3(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UICollectionView *collectionView);

extern bool sj_isAppeared4(NSInteger viewTag, NSIndexPath *viewAtIndexPath, NSInteger collectionViewTag, NSIndexPath * collectionViewAtIndexPath, UITableView *tableView);

extern bool sj_isAppeared5(NSInteger viewTag, NSIndexPath *viewAtIndexPath, UICollectionView *collectionView, UITableView *tableView);
