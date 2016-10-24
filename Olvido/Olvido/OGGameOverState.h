//
//  OGGameOverState.h
//  Olvido
//
//  Created by Александр Песоцкий on 10/19/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGUIState.h"

@interface OGGameOverState : OGUIState

@property (nonatomic, retain) NSNumber *score;

/* temporary code */
@property (nonatomic, copy) NSString *controlType;
@property (nonatomic, assign) BOOL godMode;
/* temporary code */

@end
