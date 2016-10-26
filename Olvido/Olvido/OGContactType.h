//
//  OGContactType.h
//  Olvido
//
//  Created by Дмитрий Антипенко on 10/9/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#ifndef OGContactType_h
#define OGContactType_h

typedef NS_ENUM(NSUInteger, OGContactType)
{
    kOGContactTypeNone = -1,
    kOGContactTypeGameOver = 0,
    kOGContactTypePlayerDidGetCoin = 1,
    kOGContactTypePlayerDidGrantAccess = 2,
    kOGContactTypePlayerDidTouchPortal = 3,
    kOGContactTypePlayerDidTouchObstacle = 4
};

#endif /* OGContactType_h */
