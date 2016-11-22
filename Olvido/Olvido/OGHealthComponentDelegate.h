//
//  OGHealthComponentDelegate.h
//  Olvido
//
//  Created by Александр Песоцкий on 11/20/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#ifndef OGHealthComponentDelegate_h
#define OGHealthComponentDelegate_h

@class OGHealthComponent;

@protocol OGHealthComponentDelegate <NSObject>

- (void)entityWillDie;

@end

#endif /* OGHealthComponentDelegate_h */