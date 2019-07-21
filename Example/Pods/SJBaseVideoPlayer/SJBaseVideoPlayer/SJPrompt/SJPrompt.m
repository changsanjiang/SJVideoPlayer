//
//  SJPrompt.m
//  SJPromptProject
//
//  Created by BlueDancer on 2017/9/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJPrompt.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


@interface SJPrompt ()

@property (nonatomic, weak, readwrite) UIView *presentView;
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UILabel *promptLabel;
@property (nonatomic, strong, readonly) SJPromptConfig *config;
@property (nonatomic, copy) void(^hiddenExeBlock)(SJPrompt *prompt);

@end

@implementation SJPrompt

@synthesize backgroundView = _backgroundView;
@synthesize promptLabel = _promptLabel;
@synthesize config = _config;

+ (instancetype)promptWithPresentView:(__weak UIView *)presentView {
    return [[SJPrompt alloc] initWithPresentView:presentView];
}

- (instancetype)initWithPresentView:(__weak UIView *)presentView {
    self = [super init];
    if ( !self ) return self;
    NSAssert(presentView, @"presentView can not be empty!");
    _presentView = presentView;
    [self _setupView];
    self.update(^(SJPromptConfig * _Nonnull config) {/**/});
    return self;
}

- (void (^)(void (^ _Nonnull)(SJPromptConfig * _Nonnull)))update {
    __weak typeof(self) _self = self;
    return ^void(void(^block)(SJPromptConfig *config)) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self.config);
        self.promptLabel.font = self.config.font;
        self.promptLabel.textColor = self.config.fontColor;
        self.backgroundView.backgroundColor = self.config.backgroundColor;
        self.backgroundView.layer.cornerRadius = self.config.cornerRadius;
        [self.promptLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(self.config.insets);
        }];
    };
}

- (void)reset {
    [self.config reset];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration {
    [self showTitle:title duration:duration hiddenExeBlock:nil];
}

- (void)showTitle:(NSString *)title duration:(NSTimeInterval)duration hiddenExeBlock:(void(^)(SJPrompt *prompt))hiddenExeBlock {
    if ( title.length == 0 ) return;
    NSMutableDictionary *attr = [NSMutableDictionary new];
    attr[NSFontAttributeName] = self.config.font;
    [self showAttributedString:[[NSAttributedString alloc] initWithString:title attributes:attr] duration:duration hiddenExeBlock:hiddenExeBlock];
}

- (void)hidden {
    [self _hidden];
}

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration {
    [self showAttributedString:attributedString duration:duration hiddenExeBlock:nil];
}

- (void)showAttributedString:(NSAttributedString *)attributedString duration:(NSTimeInterval)duration hiddenExeBlock:(void(^__nullable)(SJPrompt *prompt))hiddenExeBlock {
    if ( attributedString.length == 0 ) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_hiddenExeBlock = [hiddenExeBlock copy];
        if ( !self->_presentView ) return;
        [self->_presentView bringSubviewToFront:self->_backgroundView];
        CGFloat maxWdith = 0 != self.config.maxWidth ? self.config.maxWidth : self->_presentView.frame.size.width * 0.6;
        CGSize size = [self _sizeWithAttrString:attributedString width:maxWdith height:CGFLOAT_MAX];
        [self->_promptLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(size);
        }];
        self->_promptLabel.attributedText = attributedString;
        [self _show];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hidden) object:nil];
        if ( duration == - 1 ) return;
        [self performSelector:@selector(_hidden) withObject:nil afterDelay:duration inModes:@[NSRunLoopCommonModes]];
    });
}

- (void)_show {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 1;
    }];
}

- (void)_hidden {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0.001;
    } completion:^(BOOL finished) {
        if ( self->_hiddenExeBlock ) {self->_hiddenExeBlock(self); self->_hiddenExeBlock = nil;}
    }];
}

- (void)_setupView {
    [_presentView addSubview:self.backgroundView];
    [_backgroundView addSubview:self.promptLabel];
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (UIView *)backgroundView  {
    if ( _backgroundView ) return _backgroundView;
    _backgroundView = [UIView new];
    _backgroundView.clipsToBounds = YES;
    _backgroundView.alpha = 0.001;
    return _backgroundView;
}

- (UILabel *)promptLabel {
    if ( _promptLabel ) return _promptLabel;
    _promptLabel = [UILabel new];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.numberOfLines = 0;
    return _promptLabel;
}

- (SJPromptConfig *)config {
    if ( _config ) return _config;
    _config = [SJPromptConfig new];
    return _config;
}

- (CGSize)_sizeWithAttrString:(NSAttributedString *)attrStr width:(double)width height:(double)height {
    CGRect bounds = [attrStr boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}

@end
