//
//  SJRotationObserver.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationObserver.h"
#import "SJRotationDefines.h"

@implementation SJRotationObserver
- (instancetype)initWithManager:(SJRotationManager *)manager {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onRotation:) name:SJRotationManagerRotationNotification object:manager];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onTransition:) name:SJRotationManagerTransitionNotification object:manager];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onRotation:(NSNotification *)note {
    BOOL isRotating = [(SJRotationManager *)note.object isRotating];
    if ( _onRotatingChanged != nil ) _onRotatingChanged(note.object, isRotating);
}

- (void)onTransition:(NSNotification *)note {
    BOOL isTransitioning = [(SJRotationManager *)note.object isTransitioning];
    if ( _onTransitioningChanged != nil ) _onTransitioningChanged(note.object, isTransitioning);
}
@end
