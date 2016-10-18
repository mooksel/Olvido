//
//  OGMovementControlComponent.m
//  Olvido
//
//  Created by Алексей Подолян on 10/17/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGMovementControlComponent.h"

CGFloat const kOGTapMovementControlComponentDefaultSpeedFactor = 1.0;

@implementation OGMovementControlComponent

- (instancetype)initWithNode:(SKNode *)node
{
    self = [super init];
    
    if (self)
    {
        _node = [node retain];
        _speedFactor = kOGTapMovementControlComponentDefaultSpeedFactor;
    }
    
    return self;
}


#pragma mark subclasses should implement

- (void)touchBeganAtPoint:(CGPoint)point
{
    
}

- (void)touchEndedAtPoint:(CGPoint)point
{
    
}

- (void)touchMovedToPoint:(CGPoint)point
{
    
}

- (void)stop
{
    
}

- (void)setSpeedFactor:(CGFloat)speedFactor
{
    _speedFactor = speedFactor;
    
    CGVector velocity = self.node.physicsBody.velocity;
    self.node.physicsBody.velocity = CGVectorMake(velocity.dx * speedFactor, velocity.dy * speedFactor);
}

- (void)dealloc
{
    [_node release];
    
    [super dealloc];
}

@end