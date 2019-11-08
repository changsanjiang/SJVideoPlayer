//
//  SJFloatSmallViewControlLayerResourceLoader.m
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//

#import "SJFloatSmallViewControlLayerResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJFloatSmallViewControlLayerResourceLoader ()
@property (nonatomic, strong, readonly) NSBundle *bundle;
@end

@implementation SJFloatSmallViewControlLayerResourceLoader
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SJFloatSmallViewControlLayer" ofType:@"bundle"]];
        [self reset];
    }
    return self;
}

- (void)reset {
    _floatSmallViewCloseImage = [self imageNamed:@"close"];
}

- (nullable UIImage *)imageNamed:(NSString *)name {
    if ( 0 == name.length )
        return nil;
    int scale = (int)UIScreen.mainScreen.scale;
    if ( scale < 2 ) scale = 2;
    else if ( scale > 3 ) scale = 3;
    NSString *n = [NSString stringWithFormat:@"%@@%dx.png", name, scale];
    return [UIImage imageWithContentsOfFile:[self.bundle pathForResource:n ofType:nil]];
}
@end
NS_ASSUME_NONNULL_END
