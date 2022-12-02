//
//  SJMainPageViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/19.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJMainPageViewController.h"
#import "SJPageViewController.h"
#import "SJMainPageHeaderView.h"
#import "SJPageMenuItemView.h"
#import "SJUITableViewDemoViewController1.h"

@interface SJMainPageViewController ()<SJPageViewControllerDataSource, SJPageViewControllerDelegate, SJPageMenuBarDataSource, SJPageMenuBarDelegate> {
    SJPageViewController *_pageViewController;
    SJPageItemManager *_pageItemManager;
    SJMainPageHeaderView *_Nullable _headerView;
}
@end

@implementation SJMainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];

    _pageViewController = [SJPageViewController.alloc initWithOptions:@{
        SJPageViewControllerOptionInterPageSpacingKey : @(8)
    }];
    _pageViewController.view.backgroundColor = UIColor.whiteColor;
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    _pageViewController.view.frame = self.view.bounds;
    _pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    _pageItemManager = [SJPageItemManager.alloc init];
    
    for ( NSInteger i = 0 ; i < 5 ; ++ i ) {
        [_pageItemManager addPageItem:[SJPageItem.alloc initWithViewControllerLoader:^UIViewController * _Nullable{
            return [SJUITableViewDemoViewController1.alloc init];
        } menuViewLoader:^UIView<SJPageMenuItemView> * _Nullable{
            NSString *title = [NSString stringWithFormat:@"Item_%ld", (long)i];
            return [SJPageMenuItemView.alloc initWithText:title font:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
        }]];
    }
}

#pragma mark - SJPageViewControllerDataSource, SJPageViewControllerDelegate

- (NSUInteger)numberOfViewControllersInPageViewController:(SJPageViewController *)pageViewController {
    return _pageItemManager.numberOfPageItems;
}

- (__kindof UIViewController *)pageViewController:(SJPageViewController *)pageViewController viewControllerAtIndex:(NSInteger)index {
    return [_pageItemManager viewControllerAtIndex:index];
}

- (SJPageViewControllerHeaderMode)modeForHeaderWithPageViewController:(SJPageViewController *)pageViewController {
    return SJPageViewControllerHeaderModePinnedToTop;
}

- (CGFloat)heightForHeaderPinToVisibleBoundsWithPageViewController:(SJPageViewController *)pageViewController {
    return _headerView.pageMenuBar.bounds.size.height;
}

- (__kindof UIView *)viewForHeaderInPageViewController:(SJPageViewController *)pageViewController {
    if ( _headerView == nil ) {
        _headerView = [SJMainPageHeaderView.alloc initWithFrame:CGRectZero];
        _headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _headerView.intrinsicContentSize.height);
        _headerView.pageMenuBar.distribution = SJPageMenuBarDistributionFillEqually;
        _headerView.pageMenuBar.dataSource = self;
        _headerView.pageMenuBar.delegate = self;
        // 关联 pageMenuBar, 进行联动
        pageViewController.pageMenuBar = _headerView.pageMenuBar;
    }
    return _headerView;
}

#pragma mark - SJPageMenuBarDataSource, SJPageMenuBarDelegate

- (NSUInteger)numberOfItemsInPageMenuBar:(SJPageMenuBar *)bar {
    return _pageItemManager.numberOfPageItems;
}

- (__kindof UIView<SJPageMenuItemView> *)pageMenuBar:(SJPageMenuBar *)bar viewForItemAtIndex:(NSInteger)index {
    return [_pageItemManager menuViewAtIndex:index];
}

- (CGSize)pageMenuBar:(SJPageMenuBar *)bar sizeForItemAtIndex:(NSUInteger)index transitionProgress:(CGFloat)transitionProgress {
    return [_pageItemManager sizeForMenuViewAtIndex:index transitionProgress:transitionProgress];
}
@end
