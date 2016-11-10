//
//  OGControlInputSource.h
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/4/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#ifndef OGControlInputSource_h
#define OGControlInputSource_h

@protocol OGControlInputSourceDelegate <NSObject>

- (void)didUpdateDisplacement:(CGVector)displacement;

@end

#endif /* OGControlInputSource_h */
