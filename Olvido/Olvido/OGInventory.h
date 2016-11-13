//
//  OGInventory.h
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/12/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
#import "OGInventoryItemProtocol.h"

@interface OGInventory : NSObject

@property (nonatomic, strong) NSArray<id<OGInventoryItemProtocol>> *items;

- (void)addItem:(id<OGInventoryItemProtocol>)item;
- (void)removeItem:(id<OGInventoryItemProtocol>)item;

- (GKEntity *)findItemWithIdentifier:(NSString *)identifier;

@end