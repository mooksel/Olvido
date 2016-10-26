//
//  OGScenesController.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/26/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGScenesController.h"
#import "OGGameSceneDelegate.h"
#import "OGGameScene.h"
#import "OGSpriteNode.h"
#import "OGTransitionComponent.h"

NSUInteger const kOGSceneControllerInitialLevelIndex = 0;

NSString *const kOGSceneControllerLevelMapName = @"LevelsMap";
NSString *const kOGSceneControllerLevelMapExtension = @"plist";

NSString *const kOGSceneControllerPortalsKey = @"Portals";
NSString *const kOGSceneControllerNextLevelIndexKey = @"Next Level Index";
NSString *const kOGSceneControllerPortalIdentifierKey = @"Identifier";
NSString *const kOGSceneControllerClassNameKey = @"Class Name";
NSString *const kOGSceneControllerPortalColorKey = @"Color";
NSString *const kOGSceneControllerEnemiesCountKey = @"Enemies Count";

CGFloat const kOGSceneControllerTransitionDuration = 1.0;

@interface OGScenesController () <OGGameSceneDelegate>

@property (nonatomic, copy, readwrite) NSArray *levelMap;
@property (nonatomic, retain, readwrite) OGGameScene *currentScene;

@end

@implementation OGScenesController

- (void)loadLevelMap
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kOGSceneControllerLevelMapName
                                                          ofType:kOGSceneControllerLevelMapExtension];
    
    NSArray *plistData = [NSArray arrayWithContentsOfFile:plistPath];
    
    self.levelMap = [plistData copy];
}

- (NSNumber *)nextLevelIdentifierWithPortalIdentifier:(NSNumber *)identifier inLevel:(NSNumber *)levelIdentifier
{
    NSDictionary *level = self.levelMap[levelIdentifier.integerValue];
    NSArray *portals = level[kOGSceneControllerPortalsKey];
    NSNumber *result = 0;
    
    for (NSDictionary *portalDictionary in portals)
    {
        if ([portalDictionary[kOGSceneControllerPortalIdentifierKey] integerValue] == identifier.integerValue)
        {
            result = portalDictionary[kOGSceneControllerNextLevelIndexKey];
            break;
        }
    }
    
    return result;
}

- (void)gameSceneDidCallFinish
{
    NSNumber *portalIdentifier = @(self.currentScene.transitionComponent.identifier);
    NSNumber *nextLevelId = [self nextLevelIdentifierWithPortalIdentifier:portalIdentifier
                                                                  inLevel:self.currentScene.identifier];
    
    [self loadLevelWithIdentifier:nextLevelId];
    
    if (self.currentScene)
    {
        SKTransition *transition = [SKTransition doorwayWithDuration:kOGSceneControllerTransitionDuration];
        [self.view presentScene:self.currentScene transition:transition];
    }
}

- (void)gameSceneDidCallFinishGameWithScore:(NSNumber *)score
{
    
}

- (void)loadLevelWithIdentifier:(NSNumber *)identifier
{
    NSString *className = self.levelMap[identifier.integerValue][kOGSceneControllerClassNameKey];
    GKScene *sceneFile = [GKScene sceneWithFileNamed:className];
    OGGameScene *scene = (OGGameScene *)sceneFile.rootNode;
    
    scene.identifier = identifier;
    scene.sceneDelegate = self;
    
    for (GKEntity *entity in sceneFile.entities)
    {
        GKSKNodeComponent *nodeComponent = (GKSKNodeComponent *) [entity componentForClass:[GKSKNodeComponent class]];
        
        OGSpriteNode *spriteNode = (OGSpriteNode *) nodeComponent.node;
        spriteNode.entity = (OGEntity *) nodeComponent.entity;
        
        [scene addSpriteNode:spriteNode];
    }
    
    scene.scaleMode = SKSceneScaleModeAspectFit;
    self.currentScene = scene;
    [scene release];
}

@end
