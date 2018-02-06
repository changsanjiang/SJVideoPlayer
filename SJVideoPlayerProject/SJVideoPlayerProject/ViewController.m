//
//  ViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "PlayerTableViewController.h"
#import "PlayerCollectionViewController.h"
#import "NestedTableViewController.h"
#import "SJVideoListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)push:(id)sender {
    [self.navigationController pushViewController:[[PlayerViewController alloc] init] animated:YES];
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
- (IBAction)test:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
