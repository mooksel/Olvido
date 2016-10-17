//
//  OGFlameScene.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/17/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGFlameScene.h"
#import "OGGameScene+OGGameSceneCreation.h"
#import "OGTimer.h"

typedef NS_ENUM (NSUInteger, OGFlameLocation)
{
    kOGFlameLocationHorizontal = 0,
    kOGFlameLocationVertical = 1
};

NSString *const kOGFlameSceneParticleFileName = @"Flame";
NSString *const kOGFlameSceneParticleFileExtension = @"sks";

NSUInteger const kOGFlameChangeInterval = 5.0;

@interface OGFlameScene ()

@property (nonatomic, retain) NSMutableArray<SKEmitterNode *> *flames;
@property (nonatomic, assign) NSUInteger currentFlameLocation;

@end

@implementation OGFlameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    if (self)
    {
        _flames = [[NSMutableArray alloc] init];
        _currentFlameLocation = 0;
    }
    else
    {
        [self release];
        self = nil;
    }
    
    return self;
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor gameBlue];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = kOGCollisionBitMaskObstacle;
    self.physicsBody.collisionBitMask = kOGCollisionBitMaskPlayer | kOGCollisionBitMaskEnemy;
    self.physicsBody.contactTestBitMask = kOGCollisionBitMaskPlayer;
    
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    [self addChild:[self createBackgroundBorderWithColor:[SKColor gameDarkBlue]]];
    
    [self createEnemies];
    [self createPlayer];
    
    [self createFlameAtPoint:CGPointMake(CGRectGetMidX(self.frame), 0.0) emissionAngle:M_PI_2];
    [self createFlameAtPoint:CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height) emissionAngle:3 * M_PI_2];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kOGFlameChangeInterval
                                                      target:self
                                                    selector:@selector(changeFlameLocation)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)createFlameAtPoint:(CGPoint)point emissionAngle:(CGFloat)angle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:kOGFlameSceneParticleFileName
                                                     ofType:kOGFlameSceneParticleFileExtension];
    
    SKEmitterNode *flame = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    flame.targetNode = self;
    flame.position = point;
    flame.emissionAngle = angle;
    
    [self.flames addObject:flame];
    [self addChild:flame];
}

- (void)changeFlameLocation
{
    self.currentFlameLocation = (self.currentFlameLocation + 1) % 2;
    SKAction *rotation = [SKAction rotateByAngle:M_PI_2 duration:0.0];
    
    switch (self.currentFlameLocation)
    {
        case kOGFlameLocationHorizontal:
            for (NSUInteger i = 0; i < self.flames.count; i++)
            {
                self.flames[i].position = CGPointMake(CGRectGetMidX(self.frame), i * self.frame.size.height);
                self.flames[i].emissionAngle = ((i * 2.0) + 1.0) * M_PI_2;
                [self.flames[i] runAction:rotation];
            }
            break;
            
        case kOGFlameLocationVertical:
            for (NSUInteger i = 0; i < self.flames.count; i++)
            {
                self.flames[i].position = CGPointMake(self.frame.size.width * i, CGRectGetMidY(self.frame));
                self.flames[i].emissionAngle = i * M_PI;
                [self.flames[i] runAction:rotation];
            }
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    OGTransitionComponent *transitionComponent = (OGTransitionComponent *) [self.portals[0] componentForClass:[OGTransitionComponent class]];
    
    transitionComponent.closed = NO;
    
    [self.sceneDelegate gameSceneDidCallFinishWithPortal:self.portals[0]];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
