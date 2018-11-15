//
//  TestAdapterViewController.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/15.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "TestAdapterViewController.h"
#import <SJRouter/SJRouteHandler.h>
#import <Masonry/Masonry.h>
#import "SJEdgeControlLayerItemAdapter.h"

@interface TestAdapterViewController ()<SJRouteHandler>
@property (nonatomic, strong) SJEdgeControlLayerItemAdapter *frameAdapter;
@end

@implementation TestAdapterViewController

+ (NSString *)routePath {
    return @"test/testAdapter";
}

+ (void)handleRequestWithParameters:(SJParameters)parameters topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[self new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _frameAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithLayoutType:SJAdapterItemsLayoutTypeFrameLayout];
    _frameAdapter.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_frameAdapter.view];
    
    [_frameAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    
    UIView *c1 = [UIView new];
    c1.backgroundColor = [UIColor redColor];
    c1.bounds = CGRectMake(0, 0, 100, 100);
    SJEdgeControlButtonItem *t1 = [SJEdgeControlButtonItem frameLayoutWithCustomView:c1 tag:1];
    [_frameAdapter addItem:t1];
    
    UIView *c2 = [UIView new];
    c2.backgroundColor = [UIColor orangeColor];
    c2.bounds = CGRectMake(0, 0, 50, 50);
    SJEdgeControlButtonItem *t2 = [SJEdgeControlButtonItem frameLayoutWithCustomView:c2 tag:2];
    [_frameAdapter addItem:t2];
    
    [_frameAdapter reload];
}

@end
