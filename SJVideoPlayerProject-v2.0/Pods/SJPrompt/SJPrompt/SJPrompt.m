//
//  SJPrompt.m
//  SJPromptProject
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJPrompt.h"
#import <Masonry/Masonry.h>


#define SJPrompt_H   (50)

#define SJPrompt_F   (14)


@interface SJPrompt ()

@property (nonatomic, strong, readwrite) UIView *presentView;
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UILabel *promptLabel;

@end

@implementation SJPrompt

@synthesize backgroundView = _backgroundView;
@synthesize promptLabel = _promptLabel;

+ (instancetype)promptWithPresentView:(UIView *)presentView {
    SJPrompt *prompt = [SJPrompt new];
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
    [_presentView addSubview:self.backgroundView];
    CGFloat width = [self sizeFortitle:title size:CGSizeMake(1000, SJPrompt_H)].width;
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_presentView);
        make.size.mas_offset(CGSizeMake(width + 24, SJPrompt_H));
    }];
    _promptLabel.text = title;
    [self _show];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hidden) object:nil];
    if ( duration == - 1 ) return;
    [self performSelector:@selector(_hidden) withObject:nil afterDelay:duration];
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
    _promptLabel = [UILabel new];
    _promptLabel.font = [UIFont systemFontOfSize:SJPrompt_F];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.backgroundColor = [UIColor blackColor];
    return _promptLabel;
}

- (CGSize)sizeFortitle:(NSString *)title size:(CGSize)size {
    CGSize result;
    if ( [title respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] ) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = [UIFont systemFontOfSize:SJPrompt_F];
        CGRect rect = [title boundingRectWithSize:size
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [title sizeWithFont:[UIFont systemFontOfSize:SJPrompt_F] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    return result;
}

@end
