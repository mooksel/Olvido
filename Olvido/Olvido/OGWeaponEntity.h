//
//  OGBlaster.h
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/12/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
#import "OGEntityManaging.h"
#import "OGAttacking.h"
#import "OGInventoryItem.h"
#import "OGSceneItemEntity.h"

extern CGFloat const OGWeaponEntityDefaultAttackSpeed;
extern CGFloat const OGWeaponEntityDefaultReloadSpeed;

@interface OGWeaponEntity : OGSceneItemEntity <OGAttacking, OGInventoryItem>

@property (nonatomic, copy, readonly) NSString *inventoryIdentifier;

@property (nonatomic, weak) GKEntity *owner;

@property (nonatomic, assign, readonly) CGFloat attackSpeed;
@property (nonatomic, assign, readonly) CGFloat reloadSpeed;
@property (nonatomic, assign) NSInteger charge;
@property (nonatomic, assign) NSInteger maxCharge;

- (instancetype)initWithSpriteNode:(SKSpriteNode *)sprite
                       attackSpeed:(CGFloat)attackSpeed
                       reloadSpeed:(CGFloat)reloadSpeed
                            charge:(NSInteger)charge
                         maxCharge:(NSInteger)maxCharge
               inventoryIdentifier:(NSString *)inventoryIdentifier;

@end
