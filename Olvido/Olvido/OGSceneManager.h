//
//  OGSceneManager.h
//  Olvido
//
//  Created by Алексей Подолян on 11/8/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameplayKit/GameplayKit.h>
#import "OGSceneManagerDelegate.h"

@class OGSceneLoader;
@class OGBaseScene;

@interface OGSceneManager : NSObject

@property (nonatomic, weak) id <OGSceneManagerDelegate> delegate;
@property (nonatomic, strong, readonly) SKView *view;
@property (nonatomic, strong, readonly) OGBaseScene *currentScene;

+ (instancetype)sceneManagerWithView:(SKView *)view;

- (void)prepareSceneWithIdentifier:(NSUInteger)sceneIdentifier;

- (void)transitionToSceneWithIdentifier:(NSUInteger)sceneIdentifier;

- (void)transitionToInitialScene;

@end
