//
//  PAMonster.m
//  PhantomAssasins
//
//  Created by Agustin Marseillan on 10/3/13.
//  Copyright (c) 2013 Agustin Marseillan. All rights reserved.
//

#import "AGMonster.h"

@implementation AGMonster

int _hp;
int _maxHp;


+(id)createWithHp:(int)hp{
    return [[AGMonster alloc] initWithHp:hp];
}

-(id) initWithHp:(int)hp{
    NSString *file = nil;
    if( hp < 6 ){
        file = @"dianaestática.png";
    }else{
        file = @"monster.png";
    }
    self = [super initWithFile:file];
    if( hp < 1 ){
        hp = 1;
    }
    _hp = hp;
    _maxHp = hp;
    return self;
}

-(id) initWithAnimation:(int)hp animation:(CCAnimation*)animation{
    self = [super initWithSpriteFrameName:@"diana1.png"];
    CCAction *walkAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:animation]];
    [self runAction:walkAction];
    if( hp < 1 ){
        hp = 1;
    }
    _hp = hp;
    _maxHp = hp;
    return self;
}


-(int) hp{
    return _hp;
}

-(int) maxHp{
    return _maxHp;
}


-(BOOL) getHit:(AGProjectile*)projectile{
    _hp -= [projectile damage];
    return _hp <= 0;
}

@end
