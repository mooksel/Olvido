//
//  OGPhysicsComponent.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/6/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGPhysicsComponent.h"

@interface OGPhysicsComponent ()

@property (nonatomic, strong, readwrite) SKPhysicsBody *physicsBody;

@end

@implementation OGPhysicsComponent

- (instancetype)initWithPhysicsBody:(SKPhysicsBody *)body colliderType:(OGColliderType *)type
{
    if (body)
    {
        self = [super init];
        
        if (self)
        {
            _physicsBody = body;
            
            _physicsBody.categoryBitMask = (uint32_t) type.categoryBitMask;
            _physicsBody.collisionBitMask = (uint32_t) type.collisionBitMask;
            _physicsBody.contactTestBitMask = (uint32_t) type.contactTestBitMask;
        }
    }
    
    return self;
}

@end
