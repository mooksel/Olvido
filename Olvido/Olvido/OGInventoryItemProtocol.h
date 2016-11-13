//
//  OGInventoryItemProtocol.h
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/12/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

@protocol OGInventoryItemProtocol <NSObject>

- (NSString *)inventoryIdentifier;
- (SKNode *)itemNode;

@end