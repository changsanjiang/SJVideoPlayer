//
//  SJDeviceOutputPromptView.m
//  Pods
//
//  Created by BlueDancer on 2019/8/6.
//

#import "SJDeviceOutputPromptView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJDeviceOutputPromptView ()
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIProgressView *progressView;
@end

@implementation SJDeviceOutputPromptView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)refreshData {
    _imageView.image = _dataSource.image;
    _progressView.progress = _dataSource.progress;
    _progressView.trackTintColor = _dataSource.trackColor;
    _progressView.progressTintColor = _dataSource.traceColor;
}

- (void)_setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.layer.cornerRadius = 5;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    _progressView.progress = 0.5;
    [self addSubview:_progressView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.width.equalTo(self.imageView.mas_height);
        make.height.offset(38);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(5);
        make.centerY.offset(0);
        make.right.offset(-12);
        make.height.offset(2);
        make.width.offset(100);
    }];
    
    [_imageView setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [_progressView setContentHuggingPriority:250 forAxis:UILayoutConstraintAxisHorizontal];
}
@end

@implementation SJDeviceOutputPromptViewModel

@end
NS_ASSUME_NONNULL_END
