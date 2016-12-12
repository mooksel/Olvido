//
//  OGSceneItemEntity.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 12/2/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGSceneItemEntity.h"
#import "OGRenderComponent.h"
#import "OGPhysicsComponent.h"
#import "OGColliderType.h"
#import "OGGameScene.h"

@interface OGSceneItemEntity ()

@property (nonatomic, strong) OGRenderComponent *renderComponent;
@property (nonatomic, strong) OGPhysicsComponent *physicsComponent;

@end

@implementation OGSceneItemEntity

- (instancetype)initWithSpriteNode:(SKSpriteNode *)spriteNode
{
    if (spriteNode)
    {
        self = [super init];
        
        if (self)
        {
            if ([spriteNode.scene isKindOfClass:[OGGameScene class]])
            {
                _gameScene = (OGGameScene *) spriteNode.scene;
            }
            
            _renderComponent = [[OGRenderComponent alloc] init];
            _renderComponent.node = spriteNode;
            [self addComponent:_renderComponent];
            
            _physicsComponent = [[OGPhysicsComponent alloc] initWithPhysicsBody:spriteNode.physicsBody
                                                                   colliderType:[OGColliderType sceneItem]];
            
            [self addComponent:_physicsComponent];
            
            NSArray *contactColliders = @[[OGColliderType player]];
            [[OGColliderType requestedContactNotifications] setObject:contactColliders forKey:[OGColliderType sceneItem]];
        }
    }
    else
    {
        self = nil;
    }
    
    return self;
}

- (void)setDelegate:(id<OGEntityManaging>)delegate
{
    _delegate = delegate;
    
    if ([delegate isKindOfClass:[OGGameScene class]])
    {
        _gameScene = (OGGameScene *) delegate;
    }
}

- (void)contactWithEntityDidBegin:(GKEntity *)entity
{
}

- (void)contactWithEntityDidEnd:(GKEntity *)entity
{
}

@end
