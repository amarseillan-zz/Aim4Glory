//
//  PAMonster.h
//  PhantomAssasins
//
//  Created by Agustin Marseillan on 10/3/13.
//  Copyright (c) 2013 Agustin Marseillan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AGProjectile.h"

@interface AGMonster : CCSprite

+(id) createWithHp:(int)hp;

-(id) initWithHp:(int)hp;

-(id) initWithAnimation:(int)hp animation:(CCAnimation*)animation;

-(int) hp;

-(int) maxHp;

-(BOOL) getHit:(AGProjectile*)projectile;

@end
