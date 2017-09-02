//
//  SJVideoPlayerPrompt.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPrompt.h"

#import <Masonry/Masonry.h>

#import "UIView+Extension.h"


#define SJVideoPlayerPrompt_H   (50)

#define SJVideoPlayerPrompt_F   (14)


@interface SJVideoPlayerPrompt ()

@property (nonatomic, strong, readwrite) UIView *presentView;

@property (nonatomic, strong, readonly) UIView *backgroundView;

@property (nonatomic, strong, readonly) UILabel *promptLabel;

@end

@implementation SJVideoPlayerPrompt

@synthesize backgroundView = _backgroundView;
@synthesize promptLabel = _promptLabel;

+ (instancetype)promptWithPresentView:(UIView *)presentView {
    SJVideoPlayerPrompt *prompt = [SJVideoPlayerPrompt new];
    prompt.presentView = presentView;
    return prompt;
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return self;
    [self _setupView];
    return self;
}

// MARK: Public

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration {
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
    CGFloat width = [self sizeFortitle:title size:CGSizeMake(1000, SJVideoPlayerPrompt_H)].width;
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_presentView);
        make.size.mas_offset(CGSizeMake(width + 24, SJVideoPlayerPrompt_H));
    }];
    _backgroundView.transform = _presentView.transform;
    _promptLabel.text = title;
    [self _show];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _hidden];
    });
}

- (void)hidden {
    [self _hidden];
}

// MARK: Anima

- (void)_show {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 1;
    }];
}

- (void)_hidden {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0.001;
    }];
}

// MARK: ...

- (void)_setupView {
    [self.backgroundView addSubview:self.promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIView *)presentView {
    if ( _presentView ) return _presentView;
    return _presentView;
}

- (UIView *)backgroundView  {
    if ( _backgroundView ) return _backgroundView;
    _backgroundView = [UIView new];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.layer.cornerRadius = 6;
    _backgroundView.clipsToBounds = YES;
    _backgroundView.alpha = 0.001;
    return _backgroundView;
}

- (UILabel *)promptLabel {
    if ( _promptLabel ) return _promptLabel;
    _promptLabel = [UILabel labelWithFontSize:SJVideoPlayerPrompt_F textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    return _promptLabel;
}

- (CGSize)sizeFortitle:(NSString *)title size:(CGSize)size {
    CGSize result;
    if ( [title respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] ) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = [UIFont systemFontOfSize:SJVideoPlayerPrompt_F];
        CGRect rect = [title boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [title sizeWithFont:[UIFont systemFontOfSize:SJVideoPlayerPrompt_F] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    return result;
}

@end
