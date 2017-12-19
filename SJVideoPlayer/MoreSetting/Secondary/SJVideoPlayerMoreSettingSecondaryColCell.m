//
//  SJVideoPlayerMoreSettingSecondaryColCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerMoreSettingSecondaryColCell.h"
#import <Masonry/Masonry.h>
#import "SJVideoPlayerMoreSettingSecondary.h"
#import <SJAttributesFactory/SJAttributesFactoryHeader.h>
#import <SJUIFactory/SJUIFactory.h>

@interface SJVideoPlayerMoreSettingSecondaryColCell ()

@property (nonatomic, strong, readonly) UIButton *itemBtn;

@end

@implementation SJVideoPlayerMoreSettingSecondaryColCell

@synthesize itemBtn = _itemBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayerMoreSettingTwoSettingsCellSetupUI];
    return self;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( self.model.clickedExeBlock ) self.model.clickedExeBlock(self.model);
}

- (void)setModel:(SJVideoPlayerMoreSettingSecondary *)model {
    _model = model;
    [_itemBtn setAttributedTitle:[SJAttributesFactory producingWithTask:^(SJAttributeWorker * _Nonnull worker) {
        
        if ( model.image ) {
            worker.insert(model.image, 0, CGPointZero, model.image.size);
        }
        
        if ( model.title ) {
            worker.insert([NSString stringWithFormat:@"\n%@", model.title], -1);;
        }
        
        worker
        .font([UIFont systemFontOfSize:[SJVideoPlayerMoreSetting titleFontSize]])
        .fontColor([SJVideoPlayerMoreSetting titleColor])
        .alignment(NSTextAlignmentCenter)
        .lineSpacing(6);
    }] forState:UIControlStateNormal];
}

- (void)_SJVideoPlayerMoreSettingTwoSettingsCellSetupUI {
    [self.contentView addSubview:self.itemBtn];
    [_itemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (UIButton *)itemBtn {
    if ( _itemBtn ) return _itemBtn;
    _itemBtn = [SJUIButtonFactory buttonWithTarget:self sel:@selector(clickedBtn:)];
    _itemBtn.titleLabel.numberOfLines = 0;
    _itemBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    return _itemBtn;
}

@end

