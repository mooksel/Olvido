//
//  OGSceneLoaderInitialState.m
//  Olvido
//
//  Created by Алексей Подолян on 11/9/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGTextureAtlasesManager.h"
#import "OGSceneLoaderInitialState.h"
#import "OGSceneLoaderPrepearingResourcesState.h"
#import "OGSceneLoaderResourcesReadyState.h"
#import "OGSceneMetadata.h"

@implementation OGSceneLoaderInitialState

- (BOOL)isValidNextState:(Class)stateClass
{
    BOOL result = NO;
    
    result = (stateClass == [OGSceneLoaderPrepearingResourcesState class]);
    result = result || (stateClass == [OGSceneLoaderResourcesReadyState class]);
    
    return result;
}

- (void)didEnterWithPreviousState:(GKState *)previousState
{
    if (previousState.class == [OGSceneLoaderResourcesReadyState class])
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^
        {
            for (NSString *unitName in self.sceneLoader.metadata.textureAtlases)
            {
                [[OGTextureAtlasesManager sharedInstance] purgeAtlasesWithUnitName:unitName];
            }
        });
    }
    
    self.sceneLoader.scene = nil;
}

@end
