//
//  OGDoorEntityLockedState.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/10/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGDoorEntityLockedState.h"
#import "OGDoorEntityUnlockedState.h"

#import "OGColliderType.h"

#import "OGLockComponent.h"
#import "OGRenderComponent.h"

@implementation OGDoorEntityLockedState

- (void)didEnterWithPreviousState:(GKState *)previousState
{
    self.lockComponent.closed = YES;
    ((SKSpriteNode *) self.renderComponent.node).color = [SKColor redColor];
    
    SKNode *doorNode = self.renderComponent.node;
    doorNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:doorNode.calculateAccumulatedFrame.size];
    doorNode.physicsBody.dynamic = NO;
    
    OGColliderType *doorColliderType = [OGColliderType door];
    doorNode.physicsBody.categoryBitMask = (uint32_t) doorColliderType.categoryBitMask;
}

- (BOOL)isValidNextState:(Class)stateClass
{
    return stateClass == OGDoorEntityUnlockedState.self;
}

- (void)updateWithDeltaTime:(NSTimeInterval)seconds
{
    [super updateWithDeltaTime:seconds];
    
    if (!self.lockComponent.isLocked)
    {
        if ([self.stateMachine canEnterState:OGDoorEntityUnlockedState.self])
        {
            [self.stateMachine enterState:OGDoorEntityUnlockedState.self];
        }
    }
}

@end
