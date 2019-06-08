//
//  SJUTRangeHandler.m
//  AttributesFactory
//
//  Created by BlueDancer on 2019/4/13.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUTRangeHandler.h"
#import "SJUTAttributes.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJUTRangeHandler
- (instancetype)initWithRange:(NSRange)range {
    self = [super init];
    if ( !self ) return nil;
    _recorder = [[SJUTRangeRecorder alloc] init];
    _recorder.range = range;
    return self;
}

- (void (^)(void (^ _Nonnull)(id<SJUIKitTextMakerProtocol> _Nonnull)))replaceWithText {
    return ^(void(^block)(id<SJUIKitTextMakerProtocol> make)) {
        self.recorder.replaceWithText = block;
    };
}
- (id<SJUTAttributesProtocol>  _Nonnull (^)(NSString * _Nonnull))replaceWithString {
    return ^id<SJUTAttributesProtocol>(NSString *string) {
        SJUTAttributes *attr = [SJUTAttributes new];
        attr.recorder->string = string;
        self.recorder.utOfReplaceWithString = attr;
        return attr;
    };
}
- (void (^)(void (^ _Nonnull)(id<SJUTAttributesProtocol> _Nonnull)))update {
    return ^(void(^block)(id<SJUTAttributesProtocol> make)) {
        self.recorder.update = block;
    };
}
@end

@implementation SJUTRangeRecorder
@end
NS_ASSUME_NONNULL_END
