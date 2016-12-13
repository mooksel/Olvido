//
//  OGGameScene.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/26/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

//MARK: Miscelaneous

#import "OGAudioManager.h"
#import "OGGameScene.h"
#import "OGCollisionBitMask.h"
#import "OGLightBitMask.h"
#import "OGTouchControlInputNode.h"
#import "OGConstants.h"
#import "OGZPositionEnum.h"
#import "OGGameSceneConfiguration.h"
#import "OGZoneConfiguration.h"
#import "OGEnemyConfiguration.h"
#import "OGCameraController.h"
#import "OGContactNotifiableType.h"
#import "OGLevelManager.h"
#import "OGLevelStateSnapshot.h"
#import "OGEntitySnapshot.h"

//MARK: Components

#import "OGInputComponent.h"
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
#import "OGTrailComponent.h"
#import "OGRulesComponent.h"
#import "OGShadowComponent.h"
#import "OGHealthBarComponent.h"
#import "OGFlashlightComponent.h"

//MARK: Entities

#import "OGPlayerEntity.h"
#import "OGZombie.h"
#import "OGEnemyEntity.h"
#import "OGDoorEntity.h"
#import "OGWeaponEntity.h"
#import "OGShootingWeapon.h"
#import "OGPeriodicalZone.h"
#import "OGKey.h"
#import "OGAidKit.h"
#import "OGShop.h"
#import "OGObstacle.h"

//MARK: Nodes

#import "OGInventoryBarNode.h"
#import "OGWeaponStatisticsNode.h"
#import "OGButtonNode.h"
#import "OGHUDNode.h"
#import "OGScreenNode.h"

//MARK: States

#import "OGBeforeStartLevelState.h"
#import "OGStoryConclusionLevelState.h"
#import "OGGameLevelState.h"
#import "OGPauseLevelState.h"
#import "OGCompleteLevelState.h"
#import "OGDeathLevelState.h"

#import "OGInGameShopManager.h"
#import "OGRoom.h"

//MARK: Constants

NSString *const OGGameSceneDoorsNodeName = @"doors";
NSString *const OGGameSceneRoomsNodeName = @"rooms";
NSString *const OGGameSceneItemsNodeName = @"items";
NSString *const OGGameSceneInteractionsNodeName = @"interactions";
NSString *const OGGameSceneShopNodeName = @"shop";
NSString *const OGGameSceneWeaponNodeName = @"weapon";
NSString *const OGGameSceneKeysNodeName = @"keys";
NSString *const OGGameSceneAidKitsNodeName = @"aid_kits";
NSString *const OGGameSceneSourceNodeName = @"source";
NSString *const OGGameSceneDestinationNodeName = @"destination";
NSString *const OGGameSceneUserDataGraphs = @"Graphs";
NSString *const OGGameSceneUserDataGraph = @"Graph_";
NSString *const OGGameSceneDoorLockedKey = @"locked";
NSString *const OGGameSceneRoomNeedsFlashlightKey = @"needsFlashlight";

NSString *const OGGameScenePlayerInitialPointNodeName = @"player_initial_point";

NSString *const OGGameSceneDoorKeyPrefix = @"key";

NSString *const OGGameScenePauseScreenNodeName = @"OGPauseScreen.sks";
NSString *const OGGameSceneGameOverScreenNodeName = @"OGGameOverScreen.sks";
NSString *const OGGameSceneLevelCompleteScreenNodeName = @"OGLevelCompleteScreen.sks";

NSString *const OGGameScenePlayerInitialPoint = @"player_initial_point";
NSString *const OGGameSceneEnemyInitialsPoints = @"enemy_initial_point";
NSString *const OGGameSceneObstaclesNameNode = @"obstacles";

NSString *const OGGameSceneResumeButtonName = @"ResumeButton";
NSString *const OGGameSceneRestartButtonName = @"RestartButton";
NSString *const OGGameSceneMenuButtonName = @"MenuButton";
NSString *const OGGameScenePauseButtonName = @"PauseButton";
NSString *const OGGameSceneNextLevelButtonName = @"NextLevelButton";

CGFloat const OGGameScenePauseSpeed = 0.0;
CGFloat const OGGameScenePlaySpeed = 1.0;

NSUInteger const OGGameSceneZSpacePerCharacter = 30;

@interface OGGameScene () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSMutableArray<GKEntity *> *entitiesSortableByZ;
@property (nonatomic, strong) OGRoom *currentRoom;
@property (nonatomic, strong) OGCameraController *cameraController;
@property (nonatomic, weak) OGPlayerEntity *player;
@property (nonatomic, strong) OGGameSceneConfiguration *sceneConfiguration;

@property (nonatomic, strong) OGScreenNode *pauseScreenNode;
@property (nonatomic, strong) OGScreenNode *gameOverScreenNode;
@property (nonatomic, strong) OGScreenNode *levelCompleteScreenNode;

@property (nonatomic, strong) OGHUDNode *hudNode;
@property (nonatomic, strong) OGInventoryBarNode *inventoryBarNode;
@property (nonatomic, strong) OGWeaponStatisticsNode *weaponStatisticsNode;
@property (nonatomic, strong) OGTouchControlInputNode *controllInputNode;

@property (nonatomic, assign) CGFloat lastUpdateTimeInterval;
@property (nonatomic, assign) NSTimeInterval pausedTimeInterval;

@property (nonatomic, strong) NSMutableOrderedSet<GKEntity *> *mutableEntities;

@property (nonatomic, strong) NSMutableArray<GKComponentSystem *> *componentSystems;

@property (nonatomic, strong) OGLevelStateSnapshot *levelSnapshot;

@property (nonatomic, strong) OGInGameShopManager *shopManager;
@property (nonatomic, strong) SKNode *currentInteraction;

@property (nonatomic, strong) NSMutableArray<OGRoom *> *mutableRooms;
@end

@implementation OGGameScene

@synthesize name = _name;

#pragma mark - Initializer

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _entitiesSortableByZ = [[NSMutableArray alloc] init];
        
        NSString *configurationFileName = [[NSString alloc] initWithFormat:@"%@%@", _name, OGConstantsSceneConfigurationSuffix];
        
        _sceneConfiguration = [OGGameSceneConfiguration gameSceneConfigurationWithFileName:configurationFileName];
        
        _cameraController = [[OGCameraController alloc] init];
        
        _stateMachine = [[GKStateMachine alloc] initWithStates:@[
                                                                 [OGStoryConclusionLevelState stateWithLevelScene:self],
                                                                 [OGBeforeStartLevelState stateWithLevelScene:self],
                                                                 [OGGameLevelState stateWithLevelScene:self],
                                                                 [OGPauseLevelState stateWithLevelScene:self],
                                                                 [OGCompleteLevelState stateWithLevelScene:self],
                                                                 [OGDeathLevelState stateWithLevelScene:self]
                                                                 ]];
        
        _mutableEntities = [[NSMutableOrderedSet alloc] init];
        _mutableRooms = [[NSMutableArray alloc] init];
        
        _componentSystems = [[NSMutableArray alloc] initWithObjects:
                             [[GKComponentSystem alloc] initWithComponentClass:[GKAgent2D class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGAnimationComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGMovementComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGIntelligenceComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGLockComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGMessageComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGWeaponComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGTrailComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGRulesComponent class]],
                             [[GKComponentSystem alloc] initWithComponentClass:[OGHealthBarComponent class]],
                             nil];
        
        _pauseScreenNode = [[OGScreenNode alloc] initWithFileNamed:OGGameScenePauseScreenNodeName];
        _pauseScreenNode.zPosition = OGZPositionCategoryScreens;
        
        _gameOverScreenNode = [[OGScreenNode alloc] initWithFileNamed:OGGameSceneGameOverScreenNodeName];
        _gameOverScreenNode.zPosition = OGZPositionCategoryScreens;
        
        _levelCompleteScreenNode = [[OGScreenNode alloc] initWithFileNamed:OGGameSceneLevelCompleteScreenNodeName];
        _levelCompleteScreenNode.zPosition = OGZPositionCategoryScreens;
        
        _shopManager = [[OGInGameShopManager alloc] init];
        _shopManager.delegate = self;
    }
    
    return self;
}

- (void)configureScene
{
    [super configureScene];
    
    [self.obstaclesGraph addObstacles:self.polygonObstacles];
    
    SKNode *roomNodes = [self childNodeWithName:OGGameSceneRoomsNodeName];
    
    for (SKNode *roomNode in roomNodes.children)
    {
        OGRoom *room = [[OGRoom alloc] initWithNode:roomNode];
        room.needsFlashlight = [roomNode.userData[OGGameSceneRoomNeedsFlashlightKey] boolValue];
        [room addGradient];
        
        [self.mutableRooms addObject:room];
        
        if ([room.identifier isEqualToString:self.sceneConfiguration.startRoom])
        {
            self.currentRoom = room;
        }
    }
    [self createSceneContents];
    
    [self createCameraNode];
    [self createTouchControlInputNode];
    
    [self createHUD];
}

#pragma mark - Scene contents

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    
    self.physicsWorld.contactDelegate = self;
    
    [self.audioManager playMusic:self.sceneConfiguration.backgroundMusic];
    self.audioManager.musicPlayerDelegate = self;
    
    [self.stateMachine enterState:[OGGameLevelState class]];
    
    [self.cameraController moveCameraToNode:self.currentRoom.roomNode];
}

#pragma mark - Scene Contents Creation

- (void)createSceneContents
{
    [self createPlayer];
    [self createEnemies];
    [self createDoors];
    [self createSceneItems];
    [self createSceneInteractions];
    [self createZones];
    [self createObstacles];
}

- (void)createObstacles
{
    SKNode *obstacles = [self childNodeWithName:OGGameSceneObstaclesNameNode];
    
    for (SKSpriteNode *spriteNode in obstacles.children)
    {
        OGObstacle *obstacle = [[OGObstacle alloc] initWithSpriteNode:spriteNode];
        
        [self addEntity:obstacle];
    }
}

- (void)createSceneInteractions
{
    SKNode *interactions = [self childNodeWithName:OGGameSceneInteractionsNodeName];
    
    __block NSInteger counter = 0;
    
    [interactions enumerateChildNodesWithName:OGGameSceneShopNodeName usingBlock:^(SKNode *node, BOOL *stop)
     {
         OGShop *shop = [[OGShop alloc] initWithSpriteNode:(SKSpriteNode *)node shopConfiguration:self.sceneConfiguration.shopConfigurations[counter]];
         
         shop.interactionDelegate = self.shopManager;
         [self addEntity:shop];
         
         counter++;
     }];
}

- (void)createZones
{
    for (OGZoneConfiguration *zoneConfiguration in self.sceneConfiguration.zoneConfigurations)
    {
        SKSpriteNode *zoneNode = nil;
        NSString *zoneName = zoneConfiguration.zoneNodeName;
        zoneNode = (SKSpriteNode *)[self childNodeWithName:zoneName];
        
        if (zoneNode)
        {
            OGZone *zone = [OGZone zoneWithSpriteNode:zoneNode zoneType:zoneConfiguration.zoneType];
            [self addEntity:zone];
        }
    }
}

- (void)createTouchControlInputNode
{
    OGTouchControlInputNode *inputNode = [[OGTouchControlInputNode alloc] initWithFrame:self.frame thumbStickNodeSize:[self thumbStickNodeSize]];
    inputNode.size = self.size;
    self.controllInputNode = inputNode;
    self.controllInputNode.zPosition = OGZPositionCategoryTouchControl;
    
    OGInputComponent *inputComponent = (OGInputComponent *) [self.player componentForClass:[OGInputComponent class]];
    inputNode.inputSourceDelegate = (id<OGControlInputSourceDelegate>) inputComponent;
    inputNode.position = CGPointZero;
    [self.camera addChild:inputNode];
}

- (void)createCameraNode
{
    SKCameraNode *camera = [[SKCameraNode alloc] init];
    self.camera = camera;
    self.camera.zPosition = OGZPositionCategoryHUD;
    self.cameraController.camera = camera;
    [self addChild:camera];
    
    self.cameraController.target = self.player.renderComponent.node;
}

- (void)createPlayer
{
    OGPlayerEntity *player = [[OGPlayerEntity alloc] initWithConfiguration:self.sceneConfiguration.playerConfiguration];
    player.delegate = self;
    self.player = player;
    
    [self addEntity:self.player];
    
    self.listener = self.player.renderComponent.node;
    
    SKNode *playerInitialNode = [self childNodeWithName:OGGameScenePlayerInitialPointNodeName];
    self.player.renderComponent.node.position = playerInitialNode.position;
}

- (void)createEnemies
{
    NSUInteger counter = 0;
    
    for (OGEnemyConfiguration *enemyConfiguration in self.sceneConfiguration.enemyConfigurations)
    {
        NSString *graphName = [NSString stringWithFormat:@"%@%lu", OGGameSceneUserDataGraph, (unsigned long) counter];
        GKGraph *graph = self.userData[OGGameSceneUserDataGraphs][graphName];
        
        OGEnemyEntity *enemy = [[enemyConfiguration.enemyClass alloc] initWithConfiguration:enemyConfiguration graph:graph];
        enemy.delegate = self;
        
        if ([enemy isMemberOfClass:[OGZombie class]])
        {
            //OGTrailComponent *trailComponent = (OGTrailComponent *) [enemy componentForClass:[OGTrailComponent class]];
            //trailComponent.targetNode = self;
        }
        
        [self addEntity:enemy];
        
        counter++;
    }
}

- (void)createDoors
{
    NSArray<SKNode *> *doorNodes = [self childNodeWithName:OGGameSceneDoorsNodeName].children;
    
    for (SKNode *doorNode in doorNodes)
    {
        if ([doorNode isKindOfClass:[SKSpriteNode class]])
        {
            OGDoorConfiguration *doorConfiguration = (OGDoorConfiguration *) [self.sceneConfiguration findConfigurationWithUnitName:doorNode.name];
            OGDoorEntity *door = [[OGDoorEntity alloc] initWithSpriteNode:(SKSpriteNode *) doorNode configuration:doorConfiguration];
            
            OGLockComponent *lockComponent = (OGLockComponent *) [door componentForClass:[OGLockComponent class]];
            
            door.transitionDelegate = self;
            lockComponent.target = self.player.renderComponent.node;
            
            [self addEntity:door];
        }
    }
}

- (void)createSceneItems
{
    SKNode *items = [self childNodeWithName:OGGameSceneItemsNodeName];
    NSArray *weapons = [items childNodeWithName:OGGameSceneWeaponNodeName].children;
    NSArray *keys = [items childNodeWithName:OGGameSceneKeysNodeName].children;
    NSArray *aidKits = [items childNodeWithName:OGGameSceneAidKitsNodeName].children;
    
    for (SKSpriteNode *weaponSprite in weapons)
    {
        OGWeaponConfiguration *weaponConfiguration = (OGWeaponConfiguration *) [self.sceneConfiguration findConfigurationWithUnitName:weaponSprite.name];
        OGShootingWeapon *shootingWeapon = [[OGShootingWeapon alloc] initWithSpriteNode:weaponSprite
                                                                          configuration:weaponConfiguration];
        shootingWeapon.delegate = self;
        [self addEntity:shootingWeapon];
    }
    
    for (SKSpriteNode *keySprite in keys)
    {
        OGKey *key = [[OGKey alloc] initWithSpriteNode:keySprite];
        [self addEntity:key];
    }
    
    for (SKSpriteNode *aidKitSprite in aidKits)
    {
        OGAidKit *aidKit = [[OGAidKit alloc] initWithSpriteNode:aidKitSprite];
        aidKit.delegate = self;
        aidKit.healthComponentDelegate = (id<OGHealthComponentDelegate>) self.player;
        [self addEntity:aidKit];
    }
}

#pragma mark HUD creation

- (void)createHUD
{
    self.hudNode = [OGHUDNode node];
    self.hudNode.size = self.size;
    self.hudNode.playerEntity = self.player;
    self.hudNode.gameScene = self;
    
    if (self.camera)
    {
        [self.camera addChild:self.hudNode];
    }
    
    [self createInventoryBar];
    [self createWeaponStatistics];
}

- (void)createWeaponStatistics
{
    self.weaponStatisticsNode = [[OGWeaponStatisticsNode alloc] init];
    
    if (self.weaponStatisticsNode)
    {
        OGWeaponComponent *weaponComponent = (OGWeaponComponent *) [self.player componentForClass:[OGWeaponComponent class]];
        weaponComponent.weaponObserver = self.weaponStatisticsNode;
        [self.hudNode addHUDElement:self.weaponStatisticsNode];
    }
}

- (void)createInventoryBar
{
    OGInventoryComponent *inventoryComponent = (OGInventoryComponent *) [self.player componentForClass:[OGInventoryComponent class]];
    self.inventoryBarNode = [OGInventoryBarNode inventoryBarNodeWithInventoryComponent:inventoryComponent];
    
    if (self.hudNode)
    {
        [self.hudNode addHUDElement:self.inventoryBarNode];
    }
    
    [self.inventoryBarNode updateConstraints];
}

#pragma mark - rooms methods

- (OGRoom *)roomWithIdentifier:(NSString *)identifier
{
    OGRoom *result;
    
    for (OGRoom *room in self.mutableRooms)
    {
        if ([room.identifier isEqualToString:identifier])
        {
            result = room;
            break;
        }
    }
    
    return result;
}

#pragma mark - OGInteractionsManaging protocol methods

- (void)showInteractionButtonWithNode:(SKNode *)node
{
    if (!node.parent)
    {
        node.position = CGPointMake(self.frame.size.width / 2.0 - 170,
                                    self.frame.size.height / 2.0 - node.frame.size.height);
        
        [self.camera addChild:node];
    }
}

- (void)showInteractionWithNode:(OGScreenNode *)screenNode
{
    [self pauseWithoutPauseScreen];
    
    if (!screenNode.parent && !self.currentInteraction)
    {
        self.currentInteraction = screenNode;
        
        [screenNode addToNode:self.camera];
    }
}

- (void)closeCurrentInteraction
{
    if (self.currentInteraction)
    {
        [self resume];
        
        [self.currentInteraction removeFromParent];
        self.currentInteraction = nil;
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
    
    if ([entity isKindOfClass:[OGSceneItemEntity class]])
    {
        ((OGSceneItemEntity *) entity).gameScene = self;
    }
    
    OGRenderComponent *renderComponent = (OGRenderComponent *)[entity componentForClass:[OGRenderComponent class]];
    
    if(renderComponent)
    {
        if (renderComponent.isSortableByZ)
        {
            [self.entitiesSortableByZ addObject:entity];
        }
        
        SKNode *renderNode = renderComponent.node;
        
        if (renderNode && !renderNode.parent)
        {
            [self addChild:renderNode];
            
            OGShadowComponent *shadowComponent = ((OGShadowComponent *) [entity componentForClass:[OGShadowComponent class]]);
            
            if (shadowComponent)
            {
                shadowComponent.node.zPosition = OGZPositionCategoryShadows;
            }
        }
    }
    
    OGWeaponComponent *weaponComponent = (OGWeaponComponent *) [entity componentForClass:[OGWeaponComponent class]];
    
    if (weaponComponent && weaponComponent.weapon)
    {
        weaponComponent.weapon.delegate = self;
    }
    
    OGIntelligenceComponent *intelligenceComponent = (OGIntelligenceComponent *) [entity componentForClass:[OGIntelligenceComponent class]];
    
    if (intelligenceComponent)
    {
        [intelligenceComponent enterInitialState];
    }
}

- (void)removeEntity:(GKEntity *)entity
{
    OGRenderComponent *renderComponent = (OGRenderComponent *) [entity componentForClass:[OGRenderComponent class]];
    
    if (renderComponent)
    {
        if (renderComponent.isSortableByZ)
        {
            [self.entitiesSortableByZ removeObject:entity];
        }
        
        SKNode *node = renderComponent.node;
        [node removeFromParent];
    }
    
    for (GKComponentSystem *componentSystem in self.componentSystems)
    {
        [componentSystem removeComponentWithEntity:entity];
    }
    
    [self.mutableEntities removeObject:entity];
}

- (void)playerDidDie
{
    [self.stateMachine enterState:[OGDeathLevelState class]];
}

#pragma mark - TransitionComponentDelegate

- (void)transitToDestinationWithTransitionComponent:(OGTransitionComponent *)component completion:(void (^)(void))completion
{
    self.currentRoom = component.destination;
    
    OGFlashlightComponent *playerFlashlight = (OGFlashlightComponent *) [self.player componentForClass:[OGFlashlightComponent class]];
    
    if (playerFlashlight)
    {
        if (self.currentRoom.isNeedsFlashlight)
        {
            [playerFlashlight turnOn];
        }
        else
        {
            [playerFlashlight turnOff];
        }
    }
    
    [self.cameraController moveCameraToNode:self.currentRoom.roomNode];
    
    completion();
}

#pragma mark - Audio Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag)
    {
        [player play];
    }
}

#pragma mark - Contact handling

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self handleContact:contact contactCallback:^(id<OGContactNotifiableType> notifiable, GKEntity *entity)
     {
         [notifiable contactWithEntityDidBegin:entity];
     }];
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    [self handleContact:contact contactCallback:^(id<OGContactNotifiableType> notifiable, GKEntity *entity)
     {
         [notifiable contactWithEntityDidEnd:entity];
     }];
}

- (void)handleContact:(SKPhysicsContact *)contact contactCallback:(void (^)(id<OGContactNotifiableType>, GKEntity *))callback
{
    SKPhysicsBody *bodyA = contact.bodyA.node.physicsBody;
    SKPhysicsBody *bodyB = contact.bodyB.node.physicsBody;
    
    GKEntity *entityA = bodyA.node.entity;
    GKEntity *entityB = bodyB.node.entity;
    
    OGColliderType *colliderTypeA = [OGColliderType existingColliderTypeWithCategoryBitMask:bodyA.categoryBitMask];
    OGColliderType *colliderTypeB = [OGColliderType existingColliderTypeWithCategoryBitMask:bodyB.categoryBitMask];
    
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
    [self pauseWithoutPauseScreen];
    [self showPauseScreen];
}

- (void)pauseWithoutPauseScreen
{
    [super pause];
    
    self.physicsWorld.speed = OGGameScenePauseSpeed;
    self.speed = OGGameScenePauseSpeed;
    
    self.pausedTimeInterval = NSTimeIntervalSince1970;
    self.controllInputNode.shouldHideThumbStickNodes = YES;
    self.controllInputNode.shouldHidePauseNode = YES;
}

- (void)showPauseScreen
{
    if (!self.pauseScreenNode.parent)
    {
        [self.pauseScreenNode addToNode:self.camera];
    }
}

- (void)showCompletionScreen
{
    if (!self.levelCompleteScreenNode.parent)
    {
        [self.levelCompleteScreenNode addToNode:self.camera];
    }
}

- (void)resume
{
    [super resume];
    
    self.controllInputNode.shouldHideThumbStickNodes = NO;
    self.controllInputNode.shouldHidePauseNode = NO;
    
    self.physicsWorld.speed = OGGameScenePlaySpeed;
    self.speed = OGGameScenePlaySpeed;
    
    if (self.pauseScreenNode.parent)
    {
        [self.pauseScreenNode removeFromParent];
    }
    
    if (self.gameOverScreenNode.parent)
    {
        [self.gameOverScreenNode removeFromParent];
    }
    
    if (self.pausedTimeInterval != 0.0)
    {
        self.lastUpdateTimeInterval = NSTimeIntervalSince1970 - self.pausedTimeInterval;
    }
}

- (void)runStoryConclusion
{
    
}

- (void)showGameOverScreen
{
    if (!self.gameOverScreenNode.parent)
    {
        [self.gameOverScreenNode addToNode:self.camera];
    }
}

#pragma mark - Snapshot

- (OGEntitySnapshot *)entitySnapshotWithEntity:(GKEntity *)entity
{
    if (!self.levelSnapshot)
    {
        self.levelSnapshot = [[OGLevelStateSnapshot alloc] initWithScene:self];
    }
    
    NSUInteger index = [self.levelSnapshot.snapshot[OGLevelStateSnapshotEntitiesKey] indexOfObject:entity];
    
    return [self.levelSnapshot.snapshot[OGLevelStateSnapshotSnapshotsKey] objectAtIndex:index];
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    if (self.lastUpdateTimeInterval == 0)
    {
        self.lastUpdateTimeInterval = currentTime;
    }
    
    if (!self.customPaused)
    {
        self.levelSnapshot = nil;
        
        CGFloat deltaTime = currentTime - self.lastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        
        NSArray *array = [NSArray arrayWithArray:self.componentSystems];
        for (GKComponentSystem *componentSystem in array)
        {
            [componentSystem updateWithDeltaTime:deltaTime];
        }
        
        [self.inventoryBarNode checkPlayerPosition];
    }
    
    [self.hudNode updateHUD];
    
    [self.player updateWithDeltaTime:currentTime];
}

- (void)didFinishUpdate
{
    [super didFinishUpdate];
    
    if (((OGRenderComponent *) [self.player componentForClass:[OGRenderComponent class]]).node)
    {
        [self.player updateAgentPositionToMatchNodePosition];
    }
    
    [self sortSpritesWithZPosition];
}

- (void)sortSpritesWithZPosition
{
    [self.entitiesSortableByZ sortUsingComparator:(NSComparator)^(GKEntity *objA, GKEntity *objB)
     {
         OGRenderComponent *renderComponentA = (OGRenderComponent *) [objA componentForClass:[OGRenderComponent class]];
         OGRenderComponent *renderComponentB = (OGRenderComponent *) [objB componentForClass:[OGRenderComponent class]];
         NSComparisonResult result = NSOrderedSame;
         
         if (renderComponentA.node.position.y > renderComponentB.node.position.y)
         {
             result = NSOrderedAscending;
         }
         else
         {
             result = NSOrderedDescending;
         }
         
         return result;
     }];
    
    NSUInteger characterZPosition = OGZPositionCategoryEntities;
    
    for (GKEntity *entity in self.entitiesSortableByZ)
    {
        OGRenderComponent *renderComponent = (OGRenderComponent *) [entity componentForClass:[OGRenderComponent class]];
        renderComponent.node.zPosition = characterZPosition;
        characterZPosition += OGGameSceneZSpacePerCharacter;
    }
}

#pragma mark - Getters

- (NSArray<SKSpriteNode *> *)obstacleSpriteNodes
{
    NSMutableArray<SKSpriteNode *> *result = nil;
    
    SKNode *obstacles = [self childNodeWithName:OGGameSceneObstaclesNameNode];
    
    if (obstacles.children.count > 0)
    {
        result = [NSMutableArray arrayWithArray:obstacles.children];
    }
    
    return result;
}

- (NSArray<GKPolygonObstacle *> *)polygonObstacles
{
    return [SKNode obstaclesFromNodePhysicsBodies:self.obstacleSpriteNodes];;
}

- (NSArray<GKEntity *> *)entities
{
    return self.mutableEntities.array;
}

- (GKObstacleGraph *)obstaclesGraph
{
    if (!_obstaclesGraph)
    {
        _obstaclesGraph = [[GKObstacleGraph alloc] initWithObstacles:[[NSArray alloc] init]
                                                        bufferRadius:OGEnemyEntityPathfindingGraphBufferRadius];
    }
    
    return _obstaclesGraph;
}

- (CGSize)thumbStickNodeSize
{
    CGFloat thumbStickNodeDiameter = self.size.height / 5.0;    
    return CGSizeMake(thumbStickNodeDiameter, thumbStickNodeDiameter);
}

- (NSArray<OGRoom *> *)rooms
{
    return self.mutableRooms;
}

#pragma mark - Button Click Handling

- (void)onButtonClick:(OGButtonNode *)buttonNode
{
    if ([buttonNode.name isEqualToString:OGGameSceneResumeButtonName])
    {
        [self.sceneDelegate didCallResume];
    }
    else if ([buttonNode.name isEqualToString:OGGameSceneRestartButtonName])
    {
        [self.sceneDelegate didCallRestart];
    }
    else if ([buttonNode.name isEqualToString:OGGameSceneMenuButtonName])
    {
        [self.sceneDelegate didCallExit];
    }
    else if ([buttonNode.name isEqualToString:OGGameScenePauseButtonName])
    {
        [self.sceneDelegate didCallPause];
    }
    else if([buttonNode.name isEqualToString:OGGameSceneNextLevelButtonName])
    {
        [self.sceneDelegate didCallFinish];
    }
}

@end
