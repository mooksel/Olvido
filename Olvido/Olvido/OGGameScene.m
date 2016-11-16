//
//  OGGameScene.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/26/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGGameScene.h"
#import "OGCollisionBitMask.h"
#import "OGTouchControlInputNode.h"
#import "OGConstants.h"
#import "OGGameSceneConfiguration.h"
#import "OGEnemyConfiguration.h"
#import "OGCameraController.h"
#import "OGContactNotifiableType.h"

#import "OGPlayerEntity.h"
#import "OGEnemyEntity.h"
#import "OGDoorEntity.h"
#import "OGWeaponEntity.h"
#import "OGRenderComponent.h"
#import "OGLockComponent.h"
#import "OGPhysicsComponent.h"
#import "OGMovementComponent.h"
#import "OGIntelligenceComponent.h"
#import "OGAnimationComponent.h"
#import "OGMessageComponent.h"
#import "OGTransitionComponent.h"
#import "OGWeaponComponent.h"
#import "OGInventoryComponent.h"

#import "OGInventoryBarNode.h"

#import "OGBeforeStartLevelState.h"
#import "OGStoryConclusionLevelState.h"
#import "OGGameLevelState.h"
#import "OGPauseLevelState.h"
#import "OGCompleteLevelState.h"
#import "OGDeathLevelState.h"

#import "OGLevelManager.h"
#import "OGAnimationComponent.h"
#import "OGAnimationState.h"

NSString *const kOGGameSceneDoorsNodeName = @"doors";
NSString *const kOGGameSceneItemsNodeName = @"items";
NSString *const kOGGameSceneWeaponNodeName = @"weapon";
NSString *const kOGGameSceneSourceNodeName = @"source";
NSString *const kOGGameSceneDestinationNodeName = @"destination";
NSString *const kOGGameSceneUserDataGraphs = @"Graphs";
NSString *const kOGGameSceneUserDataGraph = @"Graph_";

NSString *const kOGGameScenePlayerInitialPointNodeName = @"player_initial_point";

NSString *const kOGGameScenePauseScreenNodeName = @"OGPauseScreen.sks";
NSString *const kOGGameSceneGameOverScreenNodeName = @"OGGameOverScreen.sks";

NSString *const kOGGameScenePlayerInitialPoint = @"player_initial_point";
NSString *const kOGGameSceneEnemyInitialsPoints = @"enemy_initial_point";
NSString *const kOGGameSceneObstacleName = @"obstacle";

CGFloat const kOGGameScenePauseSpeed = 0.0;
CGFloat const kOGGameScenePlayeSpeed = 1.0;

CGFloat const kOGGameSceneDoorOpenDistance = 50.0;

@interface OGGameScene ()

@property (nonatomic, strong) OGPlayerEntity *player;

@property (nonatomic, strong) SKNode *currentRoom;
@property (nonatomic, strong) OGCameraController *cameraController;

@property (nonatomic, strong) OGGameSceneConfiguration *sceneConfiguration;
@property (nonatomic, strong) GKStateMachine *stateMachine;
@property (nonatomic, strong) SKReferenceNode *pauseScreenNode;
@property (nonatomic, strong) SKReferenceNode *gameOverScreenNode;
@property (nonatomic, strong) OGInventoryBarNode *inventoryBarNode;

@property (nonatomic, assign) CGFloat lastUpdateTimeInterval;

@property (nonatomic, strong) NSMutableSet<GKEntity *> *mutableEntities;
@property (nonatomic, strong) NSMutableArray<GKComponentSystem *> *componentSystems;

@end

@implementation OGGameScene

@synthesize name = _name;

#pragma mark - Initializer

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _inventoryBarNode = [OGInventoryBarNode node];
        
        _sceneConfiguration = [OGGameSceneConfiguration gameSceneConfigurationWithFileName:_name];
        
        _cameraController = [[OGCameraController alloc] init];
        
        _stateMachine = [[GKStateMachine alloc] initWithStates:@[
            [OGStoryConclusionLevelState stateWithLevelScene:self],
            [OGBeforeStartLevelState stateWithLevelScene:self],
            [OGGameLevelState stateWithLevelScene:self],
            [OGPauseLevelState stateWithLevelScene:self],
            [OGCompleteLevelState stateWithLevelScene:self],
            [OGDeathLevelState stateWithLevelScene:self]
        ]];
        
        _mutableEntities = [[NSMutableSet alloc] init];
        
        _componentSystems = [[NSMutableArray alloc] initWithObjects:
                             [[GKComponentSystem alloc] initWithComponentClass:GKAgent2D.self],
                             [[GKComponentSystem alloc] initWithComponentClass:OGAnimationComponent.self],
                             [[GKComponentSystem alloc] initWithComponentClass:OGMovementComponent.self],
                             [[GKComponentSystem alloc] initWithComponentClass:OGIntelligenceComponent.self],
                             [[GKComponentSystem alloc] initWithComponentClass:OGLockComponent.self],
                             [[GKComponentSystem alloc] initWithComponentClass:OGMessageComponent.self],
                             [[GKComponentSystem alloc] initWithComponentClass:OGWeaponComponent.self],
                             nil];
        
        _pauseScreenNode = [[SKReferenceNode alloc] initWithFileNamed:kOGGameScenePauseScreenNodeName];
        _gameOverScreenNode = [[SKReferenceNode alloc] initWithFileNamed:kOGGameSceneGameOverScreenNodeName];
    }
    
    return self;
}

#pragma mark - Scene contents

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    
    self.physicsWorld.contactDelegate = self;
    self.lastUpdateTimeInterval = 0.0;
    
    [self.obstaclesGraph addObstacles:self.polygonObstacles];

    self.currentRoom = [self childNodeWithName:self.sceneConfiguration.startRoom];
    [self createSceneContents];

    [self createCameraNode];
    [self createInventoryBar];
    
    OGTouchControlInputNode *inputNode = [[OGTouchControlInputNode alloc] initWithFrame:self.frame thumbStickNodeSize:[self thumbStickNodeSize]];
    inputNode.size = self.size;
    inputNode.inputSourceDelegate = (id<OGControlInputSourceDelegate>) self.player.input;
    inputNode.position = CGPointZero;
    [self.camera addChild:inputNode];
    
    [self.stateMachine enterState:[OGGameLevelState class]];
}

- (CGSize)thumbStickNodeSize
{
    return CGSizeMake(200.0, 200.0);
}

#pragma mark - Scene Creation

- (void)createSceneContents
{
    [self createPlayer];
    [self createEnemies];
    [self createDoors];
    [self createSceneItems];
}

- (void)createCameraNode
{
    SKCameraNode *camera = [[SKCameraNode alloc] init];
    self.camera = camera;
    self.cameraController.camera = camera;
    [self addChild:camera];

    self.cameraController.target = self.player.render.node;
    
    [self.cameraController moveCameraToNode:self.currentRoom];
}

- (void)createPlayer
{
    OGPlayerEntity *player = [[OGPlayerEntity alloc] initWithConfiguration:self.sceneConfiguration.playerConfiguration];
    self.player = player;
    [self addEntity:self.player];
    
    SKNode *playerInitialNode = [self childNodeWithName:kOGGameScenePlayerInitialPointNodeName];
    self.player.render.node.position = playerInitialNode.position;
}

- (void)createEnemies
{
    NSUInteger counter = 0;
    
    for (OGEnemyConfiguration *enemyConfiguration in self.sceneConfiguration.enemiesConfiguration)
    {
        NSString *graphName = [NSString stringWithFormat:@"%@%lu", kOGGameSceneUserDataGraph, counter];
        GKGraph *graph = self.userData[kOGGameSceneUserDataGraphs][graphName];
        
        OGEnemyEntity *enemy = [[OGEnemyEntity alloc] initWithConfiguration:enemyConfiguration
                                                                      graph:graph];
    
        [self addEntity:enemy];
        
        counter++;
    }
}

- (void)createDoors
{
    NSArray<SKNode *> *doorNodes = [self childNodeWithName:kOGGameSceneDoorsNodeName].children;
    
    for (SKNode *doorNode in doorNodes)
    {
        if ([doorNode isKindOfClass:SKSpriteNode.self])
        {
            OGDoorEntity *door = [[OGDoorEntity alloc] initWithSpriteNode:(SKSpriteNode *) doorNode];
            door.transitionDelegate = self;
            
            door.lockComponent.target = self.player.render.node;
            door.lockComponent.openDistance = kOGGameSceneDoorOpenDistance;
            door.lockComponent.closed = YES;
            door.lockComponent.locked = NO;

            NSString *sourceNodeName = doorNode.userData[kOGGameSceneSourceNodeName];
            NSString *destinationNodeName = doorNode.userData[kOGGameSceneDestinationNodeName];
            
            door.transition.destination = destinationNodeName ? [self childNodeWithName:destinationNodeName] : nil;
            door.transition.source = sourceNodeName ? [self childNodeWithName:sourceNodeName] : nil;
            
            [self addEntity:door];
        }
    }
}

- (void)createInventoryBar
{
    self.inventoryBarNode = [OGInventoryBarNode inventoryBarNodeWithInventoryComponent:self.player.inventoryComponent];
    
    if (self.camera)
    {
        [self.camera addChild:self.inventoryBarNode];
    }
    
    [self.inventoryBarNode updateConstraints];
}

- (void)createSceneItems
{
    SKNode *items = [self childNodeWithName:kOGGameSceneItemsNodeName];
    NSArray *weapons = [items childNodeWithName:kOGGameSceneWeaponNodeName].children;
    
    for (SKSpriteNode *weapon in weapons)
    {
        OGWeaponEntity *shootingWeapon = [[OGWeaponEntity alloc] initWithSpriteNode:weapon];
        shootingWeapon.delegate = self;
        [self addEntity:shootingWeapon];
    }
}

#pragma mark - Entity Adding

- (void)addEntity:(GKEntity *)entity
{
    [self.mutableEntities addObject:entity];
    
    for (GKComponentSystem *componentSystem in self.componentSystems)
    {
        [componentSystem addComponentWithEntity:entity];
    }
    
    SKNode *renderNode = ((OGRenderComponent *) [entity componentForClass:OGRenderComponent.self]).node;
    
    if (renderNode && !renderNode.parent)
    {
        [self addChild:renderNode];
    }
    
    OGIntelligenceComponent *intelligenceComponent = (OGIntelligenceComponent *) [entity componentForClass:OGIntelligenceComponent.self];
    
    if (intelligenceComponent)
    {
        [intelligenceComponent enterInitialState];
    }
}

- (void)removeEntity:(GKEntity *)entity
{
    SKNode *node = ((OGRenderComponent *) [entity componentForClass:OGRenderComponent.self]).node;
    
    [node removeFromParent];
    
    for (GKComponentSystem *componentSystem in self.componentSystems)
    {
        [componentSystem removeComponentWithEntity:entity];
    }
    
    [self.mutableEntities removeObject:entity];
}

#pragma mark - TransitionComponentDelegate

- (void)transitToDestinationWithTransitionComponent:(OGTransitionComponent *)component completion:(void (^)(void))completion
{
    SKNode *destinationNode = component.destination;
    
    self.currentRoom = component.destination;
    
    [self.cameraController moveCameraToNode:destinationNode];
    
    completion();
}

#pragma mark - Contact handling

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self handleContact:contact contactCallback:^(id<OGContactNotifiableType> notifiable, GKEntity *entity)
    {
        [notifiable contactWithEntityDidBegin:entity];
    }];
}

- (void)handleContact:(SKPhysicsContact *)contact contactCallback:(void (^)(id<OGContactNotifiableType>, GKEntity *))callback
{
    SKPhysicsBody *bodyA = contact.bodyA.node.physicsBody;
    SKPhysicsBody *bodyB = contact.bodyB.node.physicsBody;
    
    GKEntity *entityA = bodyA.node.entity;
    GKEntity *entityB = bodyB.node.entity;
    
    OGColliderType *colliderTypeA = [OGColliderType colliderTypeWithCategoryBitMask:bodyA.categoryBitMask];
    OGColliderType *colliderTypeB = [OGColliderType colliderTypeWithCategoryBitMask:bodyB.categoryBitMask];
    
    BOOL aNeedsCallback = [colliderTypeA notifyOnContactWith:colliderTypeB];
    BOOL bNeedsCallback = [colliderTypeB notifyOnContactWith:colliderTypeA];
    
    if ([entityA conformsToProtocol:@protocol(OGContactNotifiableType)] && aNeedsCallback)
    {
        callback((id<OGContactNotifiableType>) entityA, entityB);
    }
    
    if ([entityB conformsToProtocol:@protocol(OGContactNotifiableType)] && bNeedsCallback)
    {
        callback((id<OGContactNotifiableType>) entityB, entityA);
    }
}

#pragma mark - Scene Management

- (void)pause
{
    self.physicsWorld.speed = kOGGameScenePauseSpeed;
    self.speed = kOGGameScenePauseSpeed;
    self.paused = YES;
}

- (void)pauseWithPauseScreen
{
    [self pause];
    
    if (!self.pauseScreenNode.parent)
    {
        [self addChild:self.pauseScreenNode];
    }
}

- (void)resume
{
    self.physicsWorld.speed = kOGGameScenePlayeSpeed;
    self.speed = kOGGameScenePlayeSpeed;
    self.paused = NO;
    
    if (self.pauseScreenNode.parent)
    {
        [self.pauseScreenNode removeFromParent];
    }
    
    if (self.gameOverScreenNode.parent)
    {
        [self.gameOverScreenNode removeFromParent];
    }
}

- (void)restart
{
    [self.sceneDelegate gameSceneDidCallRestart];
}

- (void)runStoryConclusion
{
    
}

- (void)gameOver
{
    [self pause];
    
    if (!self.gameOverScreenNode.parent)
    {
        [self addChild:self.gameOverScreenNode];
    }
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    [self.cameraController update];
    
    if (self.lastUpdateTimeInterval == 0)
    {
        self.lastUpdateTimeInterval = currentTime;
    }
    
    CGFloat deltaTime = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;        
    
    for (GKComponentSystem *componentSystem in self.componentSystems)
    {
        [componentSystem updateWithDeltaTime:deltaTime];
    }
}

- (NSArray<SKSpriteNode *> *)obstacleSpriteNodes
{
    NSMutableArray<SKSpriteNode *> *result = nil;
    
    [self enumerateChildNodesWithName:kOGGameSceneObstacleName usingBlock:^(SKNode * node, BOOL * stop)
    {
        [result addObject:(SKSpriteNode *)node];
    }];
    
    return result;
}

- (NSArray<GKPolygonObstacle *> *)polygonObstacles
{
    return [SKNode obstaclesFromNodePhysicsBodies:self.obstacleSpriteNodes];;
}

- (NSSet<GKEntity *> *)entities
{
    return (NSSet<GKEntity *> *)self.mutableEntities;
}

- (GKObstacleGraph *)obstaclesGraph
{
    if (!_obstaclesGraph)
    {
        _obstaclesGraph = [[GKObstacleGraph alloc] initWithObstacles:[[NSArray alloc] init]
                                                        bufferRadius:kOGEnemyEntityPathfindingGraphBufferRadius];
    }
    
    return _obstaclesGraph;
}
@end
