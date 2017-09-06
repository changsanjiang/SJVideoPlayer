//
//  ViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "ViewController.h"

#import "UIView+SJExtension.h"

#import <Masonry/Masonry.h>

#import "VideoPlayerViewController.h"

#import "VideoPlayerTableViewController.h"

#import "VideoPlayerCollectionViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *pushBtn;
@property (nonatomic, strong) UIButton *pushTableViewBtn;
@property (nonatomic, strong) UIButton *pushCollectionViewBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.pushBtn];
    [self.view addSubview:self.pushTableViewBtn];
    [self.view addSubview:self.pushCollectionViewBtn];
    
    [self.pushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [self.pushTableViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pushBtn.mas_bottom).offset(12);
        make.centerX.equalTo(_pushBtn);
    }];
    
    [self.pushCollectionViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pushTableViewBtn.mas_bottom).offset(12);
        make.centerX.equalTo(_pushTableViewBtn);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)clickedBtn:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            [self.navigationController pushViewController:[VideoPlayerViewController new] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[VideoPlayerTableViewController new] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[[VideoPlayerCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]] animated:YES];
            break;
        default:
            break;
    }
}

- (UIButton *)pushBtn {
    if ( _pushBtn ) return _pushBtn;
    _pushBtn = [UIButton buttonWithTitle:@"Single" titleColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] tag:0 target:self sel:@selector(clickedBtn:) fontSize:14];
    return _pushBtn;
}

- (UIButton *)pushTableViewBtn {
    if ( _pushTableViewBtn ) return _pushTableViewBtn;
    _pushTableViewBtn = [UIButton buttonWithTitle:@"TableView" titleColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] tag:1 target:self sel:@selector(clickedBtn:) fontSize:14];
    return _pushTableViewBtn;
}

- (UIButton *)pushCollectionViewBtn {
    if ( _pushCollectionViewBtn ) return _pushCollectionViewBtn;
    _pushCollectionViewBtn = [UIButton buttonWithTitle:@"CollectionView" titleColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] tag:2 target:self sel:@selector(clickedBtn:) fontSize:14];
    return _pushCollectionViewBtn;
}
@end
