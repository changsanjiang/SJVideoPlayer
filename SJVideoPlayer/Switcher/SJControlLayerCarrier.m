//
//  SJControlLayerCarrier.m
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/6/1.
//  Copyright © 2018年 畅三江. All rights reserved.
//

#import "SJControlLayerCarrier.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJControlLayerCarrier ()
@property (nonatomic) SJControlLayerIdentifier identifier;
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDataSource> dataSource;
@property (nonatomic, strong) id <SJVideoPlayerControlLayerDelegate> delegate;
@end

@implementation SJControlLayerCarrier

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _identifier = SJControlLayer_Uninitialized;
    }
    return self;
}

- (instancetype)initWithIdentifier:(SJControlLayerIdentifier)identifier
                        dataSource:(__strong id <SJVideoPlayerControlLayerDataSource>)dataSource
                          delegate:(__strong id<SJVideoPlayerControlLayerDelegate>)delegate
                      exitExeBlock:(nonnull void (^)(SJControlLayerCarrier * _Nonnull))exitExeBlock
                   restartExeBlock:(nonnull void (^)(SJControlLayerCarrier * _Nonnull))restartExeBlock{
    self = [super init];
    if ( !self ) return nil;
    _identifier = identifier;
    _dataSource = dataSource;
    _delegate = delegate;
    _exitExeBlock = exitExeBlock;
    _restartExeBlock = restartExeBlock;
    return self;
}
@end
NS_ASSUME_NONNULL_END
