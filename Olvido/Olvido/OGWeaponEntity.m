//
//  OGBlaster.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/12/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGWeaponEntity.h"
#import "OGRenderComponent.h"
#import "OGPhysicsComponent.h"
#import "OGBullet.h"
#import "OGWeaponComponent.h"
#import "OGMovementComponent.h"
#import "OGSoundComponent.h"
#import "OGZPositionEnum.m"

CGFloat const kOGWeaponEntityDefaultBulletSpeed = 10.0;
CGFloat const kOGWeaponEntityDefaultBulletSpawnTimeInterval = 0.1;
CGFloat const kOGWeaponEntityThrowingFactor = 80.0;

static NSArray *sOGWeaponEntitySoundNames = nil;

@interface OGWeaponEntity ()

@property (nonatomic, weak, readonly) OGWeaponComponent *weaponComponent;
@property (nonatomic, assign) BOOL allowsAttacking;
@property (nonatomic, strong) NSTimer *bulletSpawnTimer;

@end

@implementation OGWeaponEntity

- (instancetype)initWithSpriteNode:(SKSpriteNode *)sprite
{
    self = [super init];

    if (self)
    {
        NSMutableArray *collisionColliders = [NSMutableArray arrayWithObjects:[OGColliderType obstacle], nil];
        [[OGColliderType definedCollisions] setObject:collisionColliders forKey:[OGColliderType weapon]];
        
        _render = [[OGRenderComponent alloc] init];
        _render.node = sprite;
        [self addComponent:_render];
        
        _physics = [[OGPhysicsComponent alloc] initWithPhysicsBody:sprite.physicsBody
                                                      colliderType:[OGColliderType weapon]];
        [self addComponent:_physics];
            
        _sound = [[OGSoundComponent alloc] initWithSoundNames:sOGWeaponEntitySoundNames];
        [self addComponent:_sound];
        
        _allowsAttacking = YES;
    }
    
    return self;
}

- (void)setOwner:(GKEntity *)owner
{
    _owner = owner;
    
    self.sound.target = ((OGRenderComponent *) [_owner componentForClass:OGRenderComponent.self]).node;
}

+ (NSArray *)sOGWeaponEntitySoundNames
{
    return sOGWeaponEntitySoundNames;
}

#pragma mark - OGAttacking

- (void)attackWithVector:(CGVector)vector speed:(CGFloat)speed
{
    if (vector.dx != 0.0 && vector.dy != 0.0)
    {
        OGRenderComponent *ownerRenderComponent = (OGRenderComponent *) [self.owner componentForClass:[OGRenderComponent class]];
        
        if (ownerRenderComponent)
        {
            self.allowsAttacking = NO;
            CGFloat vectorAngle = atan2(-vector.dx, vector.dy);
            
            CGVector bulletMovementVector = CGVectorMake(-sinf(vectorAngle) * kOGWeaponEntityDefaultBulletSpeed,
                                                         cosf(vectorAngle) * kOGWeaponEntityDefaultBulletSpeed);
            
            OGBullet *bullet = [self createBulletAtPoint:ownerRenderComponent.node.position
                                            withRotation:vectorAngle];
            
            bullet.delegate = self.delegate;
            [self.delegate addEntity:bullet];
            
            [bullet.physicsComponent.physicsBody applyImpulse:bulletMovementVector];
            
            [self.sound playSoundOnce:@"shot"];
            
            self.bulletSpawnTimer = [NSTimer scheduledTimerWithTimeInterval:kOGWeaponEntityDefaultBulletSpawnTimeInterval repeats:NO block:^(NSTimer *timer)
            {
                self.allowsAttacking = YES;
                [timer invalidate];
                timer = nil;
            }];
        }
    }
}

- (OGBullet *)createBulletAtPoint:(CGPoint)point withRotation:(CGFloat)rotation
{
    OGBullet *bullet = [[OGBullet alloc] init];
    
    bullet.renderComponent.node.zRotation = rotation;
    bullet.renderComponent.node.position = point;
    
    return bullet;
}

- (BOOL)canAttack
{
    return self.allowsAttacking;
}

- (OGWeaponComponent *)weaponComponent
{
    return (OGWeaponComponent *) [self.owner componentForClass:[OGWeaponComponent class]];
}

#pragma mark - OGInventoryItem

- (void)wasTaken
{
    [self.render.node removeFromParent];
}

- (void)didThrown
{
    SKSpriteNode *weaponNode = (SKSpriteNode *) self.render.node;
    
    OGMovementComponent *ownerMovement = (OGMovementComponent *) [self.owner componentForClass:[OGMovementComponent class]];
    SKNode *ownerNode = ((OGRenderComponent *) [self.owner componentForClass:[OGRenderComponent class]]).node;
    
    weaponNode.position = ownerNode.position;
    
    [ownerNode.scene addChild:weaponNode];
    
    CGVector dropVector = CGVectorMake(-ownerMovement.displacementVector.dx * kOGWeaponEntityThrowingFactor,
                                       -ownerMovement.displacementVector.dy * kOGWeaponEntityThrowingFactor);
    
    [weaponNode.physicsBody applyImpulse:dropVector];
    
    self.owner = nil;
}

- (SKTexture *)texture
{
    return ((SKSpriteNode *) self.render.node).texture;
}

- (NSString *)identifier
{
    return self.render.node.name;
}

- (void)dealloc
{
    if (_bulletSpawnTimer)
    {
        [_bulletSpawnTimer invalidate];
        _bulletSpawnTimer = nil;
    }
}

#pragma mark - Resources

+ (void)loadResourcesWithCompletionHandler:(void (^)())handler
{
    sOGWeaponEntitySoundNames = @[@"shot"];
    
    handler();
}

+ (BOOL)resourcesNeedLoading
{
    return sOGWeaponEntitySoundNames == nil;
}

+ (void)purgeResources
{
    sOGWeaponEntitySoundNames = nil;
}

@end
