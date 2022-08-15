//
//  SJTestViewController.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/7/19.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJTestViewController.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <Masonry/Masonry.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import "SJSourceURLs.h"
#import <SDWebImage.h>

#import <SJBaseVideoPlayer/SJRotationManager.h>

#import "AppDelegate.h"

@interface SJTestViewController ()
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (nonatomic, strong) SJRotationManager *rotationManager;
@end

@implementation SJTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    _rotationManager = [SJRotationManager rotationManager];

    UIView *greenView = [UIView.alloc initWithFrame:CGRectZero];
    greenView.backgroundColor = UIColor.greenColor;
    greenView.frame = _playerContainerView.bounds;
    greenView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [greenView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(rotate:)]];
    [_playerContainerView addSubview:greenView];
    
    UIView *subview = [UIView.alloc initWithFrame:CGRectMake(44, 44, 20, 20)];
    subview.backgroundColor = UIColor.orangeColor;
    subview.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [greenView addSubview:subview];
    
//    _rotationManager.disabledAutorotation = YES;
    _rotationManager.superview = _playerContainerView;
    _rotationManager.target = greenView;
}

- (IBAction)rotate:(id)sender {
    [_rotationManager rotate];
}
- (IBAction)onSwitch:(UISwitch *)st {
    _rotationManager.disabledAutorotation = !st.isOn;
}
@end

#import <SJRouter/SJRouter.h>
@interface SJTestViewController (RouteHandler)<SJRouteHandler>

@end

@implementation SJTestViewController (RouteHandler)

+ (NSString *)routePath {
    return @"test";
}

+ (void)handleRequest:(SJRouteRequest *)request topViewController:(UIViewController *)topViewController completionHandler:(SJCompletionHandler)completionHandler {
    [topViewController.navigationController pushViewController:[[SJTestViewController alloc] initWithNibName:@"SJTestViewController" bundle:nil] animated:YES];
}

@end
