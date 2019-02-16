//
//  ViewControllerDouYin.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/2/13.
//  Copyright © 2019 畅三江. All rights reserved.
//

#if 0
#import "ViewControllerDouYin.h"
#import <SJUIKit/SJBaseCollectionViewCell.h>
#import <Masonry/Masonry.h>
#import <SJRouter/SJRouter.h>

@interface ViewControllerDouYin ()<UICollectionViewDelegate, UICollectionViewDataSource, SJRouteHandler>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ViewControllerDouYin
+ (NSString *)routePath {
    return @"douYin";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.needHiddenNavigationBar = YES;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = self.view.bounds.size;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } 
    [SJBaseCollectionViewCell registerWithCollectionView:_collectionView];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 99;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJBaseCollectionViewCell *cell = [SJBaseCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                        green:arc4random() % 256 / 255.0
                                                         blue:arc4random() % 256 / 255.0
                                                        alpha:1];
    return cell;
}
@end
#endif
