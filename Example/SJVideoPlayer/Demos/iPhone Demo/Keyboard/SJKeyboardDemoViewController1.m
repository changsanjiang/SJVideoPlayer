//
//  SJKeyboardDemoViewController1.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2020/6/5.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJKeyboardDemoViewController1.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import <SJUIKit/NSAttributedString+SJMake.h>
#import <Masonry/Masonry.h>
#import <SJBaseVideoPlayer/SJDanmakuItem.h>

@protocol SJSendCommentViewControllerDelegate;

static SJEdgeControlButtonItemTag SJKeyboardDemoSendCommentItemTag = 1;

@interface SJSendCommentView : UIView
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@end

@interface SJSendCommentViewController : UIViewController
@property (nonatomic, strong) SJSendCommentView *sendView;
@property (nonatomic) BOOL isAppeared;
@property (nonatomic, weak, nullable) id <SJSendCommentViewControllerDelegate> delegate;

@end

@protocol SJSendCommentViewControllerDelegate <NSObject>
- (void)sendComment:(NSString *)text;
@end

@interface SJKeyboardDemoViewController1 ()<SJSendCommentViewControllerDelegate>
@property (nonatomic, strong) SJVideoPlayer *player;
@end

@implementation SJKeyboardDemoViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass(self.class);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];

    _player = SJVideoPlayer.player;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(100);
        make.left.right.offset(0);
        make.height.equalTo(self.player.view.mas_width).multipliedBy(9/16.0);
    }];
    
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Separator];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    [_player.defaultEdgeControlLayer.bottomAdapter removeItemForTag:SJEdgeControlLayerBottomItem_Progress];
    

    SJEdgeControlButtonItem *item = [SJEdgeControlButtonItem.alloc initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"点击发送评论");
        make.textColor(UIColor.whiteColor);
    }] target:self action:@selector(presentCommentVC) tag:SJKeyboardDemoSendCommentItemTag];
    item.fill = YES;
    [_player.defaultEdgeControlLayer.bottomAdapter insertItem:item frontItem:SJEdgeControlLayerBottomItem_Play];
    [_player.defaultEdgeControlLayer.bottomAdapter reload];
    
#ifdef DEBUG
    // test
    [_player controlLayerNeedAppear];
#endif
}

- (void)presentCommentVC {
    SJSendCommentViewController *vc = SJSendCommentViewController.new;
    vc.delegate = self;
    [_player.presentView.window.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)sendComment:(NSString *)text {
    // 创建一条弹幕
    SJDanmakuItem *item = [SJDanmakuItem.alloc initWithContent:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(text ?: @"就开始交罚款劳动竞赛");
        make.font([UIFont boldSystemFontOfSize:16]);
        make.textColor(UIColor.whiteColor);
        make.stroke(^(id<SJUTStroke>  _Nonnull make) {
            make.color = UIColor.blackColor;
            make.width = -1;
        });
    }]];

    // 发送一条弹幕, 弹幕将自动显示
    [self.player.danmakuPopupController enqueue:item];
}

#pragma mark -

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player vc_viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player vc_viewDidDisappear];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end



@implementation SJSendCommentView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _textField = [UITextField.alloc initWithFrame:CGRectZero];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.backgroundColor = UIColor.whiteColor;
        [self addSubview:_textField];
        
        _sendButton = [UIButton.alloc initWithFrame:CGRectZero];
        [_sendButton setAttributedTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(@"发送");
            make.textColor(UIColor.whiteColor);
        }] forState:UIControlStateNormal];
        [self addSubview:_sendButton];
        
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(8);
            if (@available(iOS 11.0, *)) {
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(12);
            } else {
                make.left.offset(12);
            }
            make.bottom.offset(-8);
            make.right.equalTo(self.sendButton.mas_left).offset(-12);
        }];
        
        [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.offset(0);
            if (@available(iOS 11.0, *)) {
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
            }
            else {
                make.right.offset(0);
            }
            make.width.offset(49);
        }];
    }
    return self;
}
@end


@implementation SJSendCommentViewController
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.clearColor;
    
    _sendView = [SJSendCommentView.alloc initWithFrame:CGRectZero];
    _sendView.backgroundColor = UIColor.blackColor;
    [_sendView.sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sendView];
    [_sendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
    }];
    
    [self.view layoutIfNeeded];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)send {
    [self.delegate sendComment:_sendView.textField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if ( !CGRectContainsPoint(self.sendView.frame, [touches.anyObject locationInView:self.view]) ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.sendView.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sendView.textField resignFirstResponder];
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *userInfoFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = userInfoFrameValue.CGRectValue;
    if ( @available(iOS 14.0, *) ) {
        for ( UIWindow *window in UIApplication.sharedApplication.windows ) {
            if ( [NSStringFromClass(window.class) hasPrefix:@"UIRemoteK"] ) {
                if ( window.bounds.size.width != keyboardFrame.size.width ) {
                    keyboardFrame = [[[[UIApplication.sharedApplication.windows.lastObject subviews] firstObject] subviews] firstObject].frame;
                }
            }
        }
    }
    
    [_sendView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(keyboardFrame.origin.y - self.view.frame.size.height);
    }];
    
    NSNumber *userInfoDurationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = userInfoDurationValue.doubleValue;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}
@end
