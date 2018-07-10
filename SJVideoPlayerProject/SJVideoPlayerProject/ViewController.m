//
//  ViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "ViewController.h"
#import "PlayerTableViewController.h"
#import "PlayerCollectionViewController.h"
#import "NestedTableViewController.h"
#import "SJVideoListViewController.h"
#import "FullViewController.h"
#import "TestPageViewController.h"
#import "TableViewHeaderDemoViewController.h"
#import "TableViewHeaderIsCollectionViewDemoViewController.h"
#import "AboutKeyboardViewController.h"
#import "DowloadViewController.h"
#import "LightweightViewController.h"
#import <SJFullscreenPopGesture/UINavigationController+SJVideoPlayerAdd.h>
#import "PortraitViewController.h"
#import "DemoPlayerViewController.h"
#import "TableViewAutoPlayViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.sj_gestureType = SJFullscreenPopGestureType_Full;
    self.navigationController.sj_backgroundColor = [UIColor whiteColor];
//    self.navigationController.sj_transitionMode = SJScreenshotTransitionModeShifting;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)aboutKeyboard:(id)sender {
    [self.navigationController pushViewController:[[AboutKeyboardViewController alloc] init] animated:YES];
}

- (IBAction)pushTable:(id)sender {
    [self.navigationController pushViewController:[[PlayerTableViewController alloc] init] animated:YES];
}

- (IBAction)pushCollection:(id)sender {
    [self.navigationController pushViewController:[[PlayerCollectionViewController alloc] init] animated:YES];
}

- (IBAction)pushNested:(id)sender {
    [self.navigationController pushViewController:[[NestedTableViewController alloc] init] animated:YES];
}

- (IBAction)demo:(id)sender {
    [self.navigationController pushViewController:[[SJVideoListViewController alloc] init] animated:YES];
}

- (IBAction)fullView:(id)sender {
    [self.navigationController pushViewController:[[FullViewController alloc] init] animated:YES];
}

- (IBAction)pageViewControlller:(id)sender {
    [self.navigationController pushViewController:[[TestPageViewController alloc] init] animated:YES];
}

- (IBAction)tableViewHeader:(id)sender {
    [self.navigationController pushViewController:[[TableViewHeaderDemoViewController alloc] init] animated:YES];
}

- (IBAction)tableHeaderIsCollectionView:(id)sender {
    [self.navigationController pushViewController:[[TableViewHeaderIsCollectionViewDemoViewController alloc] init] animated:YES];
}

- (IBAction)download:(id)sender {
    [self.navigationController pushViewController:[[DowloadViewController alloc] init] animated:YES];
}

- (IBAction)lightweight:(id)sender {
    [self.navigationController pushViewController:[[LightweightViewController alloc] init] animated:YES];
}

- (IBAction)landscape:(id)sender {
    [self.navigationController pushViewController:[[PortraitViewController alloc] init] animated:YES];
}

- (IBAction)pushVc:(id)sender {
    [self.navigationController pushViewController:[[DemoPlayerViewController alloc] init] animated:YES];
}

- (IBAction)tableViewAutoPlay:(id)sender {
    [self.navigationController pushViewController:[[TableViewAutoPlayViewController alloc] init] animated:YES];
}

- (IBAction)test:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
