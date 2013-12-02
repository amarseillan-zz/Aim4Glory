//
//  PAMagicProjectile.m
//  PhantomAssasins
//
//  Created by Agustin Marseillan on 10/3/13.
//  Copyright (c) 2013 Agustin Marseillan. All rights reserved.
//

#import "AGMagicProjectile.h"

@implementation AGMagicProjectile

int _damage;

+(id)create{
    return [[AGMagicProjectile alloc] init];
}

-(id)init{
    self = [super initWithFile:@"magic-arrow.png"];
    _damage = 8;
    return self;
}

-(int)damage{
    return _damage;
}

@end
