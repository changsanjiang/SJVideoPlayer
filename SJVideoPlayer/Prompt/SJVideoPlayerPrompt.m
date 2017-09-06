//
//  SJVideoPlayerPrompt.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/26.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPrompt.h"

#import <Masonry/Masonry.h>

#import "UIView+SJExtension.h"

#import "NSTimer+SJExtension.h"

#define SJVideoPlayerPrompt_H   (50)

#define SJVideoPlayerPrompt_F   (14)


@interface SJVideoPlayerPrompt ()

@property (nonatomic, strong, readwrite) UIView *presentView;

@property (nonatomic, strong, readonly) UIView *backgroundView;

@property (nonatomic, strong, readonly) UILabel *promptLabel;

@property (nonatomic, strong, readwrite) NSTimer *hiddenPromptTimer;
@property (nonatomic, assign, readwrite) NSTimeInterval hiddenPoint;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;

@end



@interface SJVideoPlayerPrompt (DBObservers)

- (void)_installObservers;

- (void)_removeObservers;

@end


#pragma mark -

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
    [self _installObservers];
    return self;
}

- (void)dealloc {
    [_hiddenPromptTimer invalidate];
    _hiddenPromptTimer = nil;
    [self _removeObservers];
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
    [_hiddenPromptTimer invalidate];
    _hiddenPromptTimer = nil;
    if ( duration == - 1 ) return;
    self.hiddenPoint = 0;
    self.duration = duration;
    [self.hiddenPromptTimer fire];
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

- (NSTimer *)hiddenPromptTimer {
    if ( _hiddenPromptTimer ) return _hiddenPromptTimer;
    __weak typeof(self) _self = self;
    _hiddenPromptTimer = [NSTimer sj_scheduledTimerWithTimeInterval:0.1 exeBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.hiddenPoint += 0.1;
    } repeats:YES];
    return _hiddenPromptTimer;
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


#pragma mark -

@implementation SJVideoPlayerPrompt (DBObservers)

- (void)_installObservers {
    [self addObserver:self  forKeyPath:@"hiddenPoint" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_removeObservers {
    [self removeObserver:self forKeyPath:@"hiddenPoint"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( _hiddenPoint > _duration ) {
        [self _hidden];
        [_hiddenPromptTimer invalidate];
        _hiddenPromptTimer = nil;
    }
}

@end
