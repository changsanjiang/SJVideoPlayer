//
//  SJUTRegexHandler.m
//  AttributesFactory
//
//  Created by BlueDancer on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJUTRegexHandler.h"
#import "SJUTAttributes.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJUTRegexHandler
- (instancetype)initWithRegex:(NSString *)regex {
    self = [super init];
    if ( !self ) return nil;
    _recorder = [SJUTRegexRecorder new];
    _recorder.regex = regex;
    return self;
}

- (void (^)(void (^ _Nonnull)(NSMutableAttributedString *attrStr, NSTextCheckingResult * _Nonnull)))handler {
    return ^(void(^block)(NSMutableAttributedString *attrStr, NSTextCheckingResult *result)) {
        self.recorder.handler = block;
    };
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
- (id<SJUTRegexHandlerProtocol>  _Nonnull (^)(NSMatchingOptions))matchingOptions {
    return ^id<SJUTRegexHandlerProtocol>(NSMatchingOptions ops) {
        self.recorder.matchingOptions = ops;
        return self;
    };
}
- (id<SJUTRegexHandlerProtocol>  _Nonnull (^)(NSRegularExpressionOptions))regularExpressionOptions {
    return ^id<SJUTRegexHandlerProtocol>(NSRegularExpressionOptions ops) {
        self.recorder.regularExpressionOptions = ops;
        return self;
    };
}
@end

@implementation SJUTRegexRecorder
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _matchingOptions = NSMatchingWithoutAnchoringBounds;
    return self;
}
@end
NS_ASSUME_NONNULL_END
