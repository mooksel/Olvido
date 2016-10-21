//
//  OGMainMenu.h
//  Olvido
//
//  Created by Александр Песоцкий on 10/19/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>

@class OGScenesController;

@interface OGMainMenuState : GKState

/* Temporary code */
- (void)startGameWithControlType:(NSString *)type godMode:(BOOL)mode;
/* Temporary code */

- (instancetype)initWithView:(SKView *)view;

@end
