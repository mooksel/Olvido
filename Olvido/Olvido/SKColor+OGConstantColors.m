//
//  SKColor+OGConstantColors.m
//  Olvido
//
//  Created by Дмитрий Антипенко on 9/30/16.
//  Copyright © 2016 Дмитрий Антипенко. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKColor+OGConstantColors.h"

NSUInteger const kOGConstantColorsBackgroundLightGray = 0xf2f2f2;
NSUInteger const kOGConstantColorsBackgroundGray = 0xdddddd;

NSUInteger const kOGConstantColorsRed = 0xe74c3c;
NSUInteger const kOGConstantColorsDarkRed = 0xc0392b;

NSUInteger const kOGConstantColorsBlue = 0x3498db;
NSUInteger const kOGConstantColorsDarkBlue = 0x2980b9;

NSUInteger const kOGConstantColorsBlack = 0x11181f;
NSUInteger const kOGConstantColorsLightBlack = 0x2c3e50;

NSUInteger const kOGConstantColorsGreen = 0x1abc9c;
NSUInteger const kOGConstantColorsDarkGreen = 0x16a085;

NSUInteger const kOGConstantColorsWhite = 0xecf0f1;

@implementation SKColor (OGConstantColors)

+ (SKColor *)backgroundGrayColor
{
    return [SKColor colorWithHex:kOGConstantColorsBackgroundGray];
}

+ (SKColor *)backgroundLightGrayColor
{
    return [SKColor colorWithHex:kOGConstantColorsBackgroundLightGray];
}

+ (SKColor *)gameRed
{
    return [SKColor colorWithHex:kOGConstantColorsRed];
}

+ (SKColor *)gameDarkRed
{
    return [SKColor colorWithHex:kOGConstantColorsDarkRed];
}

+ (SKColor *)gameGreen
{
    return [SKColor colorWithHex:kOGConstantColorsGreen];
}

+ (SKColor *)gameDarkGreen
{
    return [SKColor colorWithHex:kOGConstantColorsDarkGreen];
}

+ (SKColor *)gameBlue
{
    return [SKColor colorWithHex:kOGConstantColorsBlue];
}

+ (SKColor *)gameDarkBlue
{
    return [SKColor colorWithHex:kOGConstantColorsDarkBlue];
}

+ (SKColor *)gameBlack
{
    return [SKColor colorWithHex:kOGConstantColorsBlack];
}

+ (SKColor *)gameLightBlack
{
    return [SKColor colorWithHex:kOGConstantColorsLightBlack];
}

+ (SKColor *)gameWhite
{
    return [SKColor colorWithHex:kOGConstantColorsWhite];
}

+ (SKColor *)colorWithHex:(NSUInteger)hex
{
    return [SKColor colorWithRed:((float) ((hex & 0xFF0000) >> 16)) / 255.0
                           green:((float) ((hex & 0x00FF00) >>  8)) / 255.0
                            blue:((float) ((hex & 0x0000FF) >>  0)) / 255.0
                           alpha:1.0];
}

+ (SKColor *)colorWithString:(NSString *)string
{
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    [scanner scanHexInt:&result];
    
    return [self colorWithHex:result];
}

+ (SKColor *)inverseColor:(SKColor *)color
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
}

@end
