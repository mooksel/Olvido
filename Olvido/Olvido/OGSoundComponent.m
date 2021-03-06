//
//  OGSoundComponent.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 11/17/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import "OGSoundComponent.h"
#import "OGRenderComponent.h"

NSString *const kOGSoundComponentActionKey = @"Olvido.SoundComponent.PlaySoundAction";

@interface OGSoundComponent ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, SKAction *> *actions;

@end

@implementation OGSoundComponent

- (instancetype)initWithSoundNames:(NSArray<NSString *> *)names
{
    if (names)
    {
        self = [super init];
        
        if (self)
        {
        _actions = [NSMutableDictionary dictionary];
        
            for (NSString *name in names)
            {
                SKAction *action = [SKAction playSoundFileNamed:name waitForCompletion:NO];
                [_actions setObject:action forKey:name];
            }
        }
    }
    else
    {
        self = nil;
    }
    
    return self;
}

- (void)playSoundOnce:(NSString *)soundName
{    
    [self.target removeActionForKey:kOGSoundComponentActionKey];                
    [self.target runAction:self.actions[soundName] withKey:kOGSoundComponentActionKey];
}

@end
