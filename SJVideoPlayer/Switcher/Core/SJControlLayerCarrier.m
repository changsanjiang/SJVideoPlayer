//
//  SJControlLayerCarrier.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJControlLayerCarrier.h"
#import <objc/message.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
NS_ASSUME_NONNULL_BEGIN
@interface SJControlLayerCarrier ()
@property (nonatomic) SJControlLayerIdentifier identifier;

@property (nonatomic, strong) id <SJVideoPlayerControlLayerDataSource> dataSource __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDelegate> delegate __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@property (nonatomic, copy) void(^exitExeBlock)(SJControlLayerCarrier *carrier) __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@property (nonatomic, copy) void(^restartExeBlock)(SJControlLayerCarrier *carrier) __deprecated_msg("use `initWithIdentifier:controlLayer:`");
@end

@implementation SJControlLayerCarrier
- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                      controlLayer:(id<SJControlLayer>)controlLayer {
    self = [super init];
    if ( !self ) return nil;
    _identifier = identifier;
    _controlLayer = controlLayer;
    return self;
}
@end



@implementation SJControlLayerCarrier (Deprecated)
static void *_kCarrier = "_kCarrier";

static BOOL restarted(id self, SEL _cmd) {
    return NO;
}

static void restartControlLayer(id self, SEL _cmd) {
    SJControlLayerCarrier *carrier = objc_getAssociatedObject(self, _kCarrier);
    void(^restartExeBlock)(SJControlLayerCarrier *carrier) = carrier.restartExeBlock;
    if ( restartExeBlock ) restartExeBlock(carrier);
}

static void exitControlLayer(id self, SEL _cmd) {
    SJControlLayerCarrier *carrier = objc_getAssociatedObject(self, _kCarrier);
    void(^exitExeBlock)(SJControlLayerCarrier *carrier) = carrier.exitExeBlock;
    if ( exitExeBlock ) exitExeBlock(carrier);
}

- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(id)dataSource
                          delegate:(id<SJVideoPlayerControlLayerDelegate>)delegate
                      exitExeBlock:(void(^)(SJControlLayerCarrier *carrier))exitExeBlock
                   restartExeBlock:(void(^)(SJControlLayerCarrier *carrier))restartExeBlock __deprecated_msg("use `initWithIdentifier:controlLayer:`") {
    if ( ![dataSource respondsToSelector:@selector(restarted)] ) {
        struct objc_method_description m_des = protocol_getMethodDescription(@protocol(SJControlLayerRestartProtocol), @selector(restarted), YES, YES);
        class_addMethod([dataSource class], m_des.name, (IMP)restarted, m_des.types);
    }
    
    if ( ![dataSource respondsToSelector:@selector(restartControlLayer)] ) {
        struct objc_method_description m_des = protocol_getMethodDescription(@protocol(SJControlLayerRestartProtocol), @selector(restartControlLayer), YES, YES);
        class_addMethod([dataSource class], m_des.name, (IMP)restartControlLayer, m_des.types);
    }
    
    if ( ![dataSource respondsToSelector:@selector(exitControlLayer)] ) {
        struct objc_method_description m_des = protocol_getMethodDescription(@protocol(SJControlLayerRestartProtocol), @selector(exitControlLayer), YES, YES);
        class_addMethod([dataSource class], m_des.name, (IMP)exitControlLayer, m_des.types);
    }
    
    self = [self initWithIdentifier:identifier controlLayer:dataSource];
    if ( !self ) return nil;
    _dataSource = dataSource;
    _delegate = delegate;
    _exitExeBlock = exitExeBlock;
    _restartExeBlock = restartExeBlock;
    objc_setAssociatedObject(dataSource, _kCarrier, self, OBJC_ASSOCIATION_ASSIGN);
    return self;
}
@end
NS_ASSUME_NONNULL_END
#pragma clang diagnostic pop
