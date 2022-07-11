//
//  SJDYUserHomepageViewController.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/13.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJDYUserHomepageViewController.h"

#import <SJUIKit/SJPageViewController.h>
#import <SJUIKit/SJPageMenuBar.h>

@interface SJDYUserHomepageViewController ()

@end

@implementation SJDYUserHomepageViewController
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)_setupViews {
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.05 blue:0.5 alpha:1];
}
@end
