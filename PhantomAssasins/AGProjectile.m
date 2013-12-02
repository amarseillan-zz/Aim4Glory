//
//  PAProjectile.m
//  PhantomAssasins
//
//  Created by Agustin Marseillan on 10/3/13.
//  Copyright (c) 2013 Agustin Marseillan. All rights reserved.
//

#import "AGProjectile.h"
#import "AGMagicProjectile.h"

@implementation AGProjectile

int _damage;
BOOL _isSharp;
BOOL _hasMagic;

+(id)createWithMagic:(BOOL)hasMagic isSharp:(BOOL)isSharp{
    return [[AGProjectile alloc] initWithMagic:hasMagic isSharp:isSharp];
}

-(id)initWithMagic:(BOOL)hasMagic isSharp:(BOOL)isSharp{
    if( hasMagic ){
        _hasMagic = YES;
        return [AGMagicProjectile create];
    }else{
        self = [super initWithFile:@"arrow.png"];
        _damage = 5;
        return self ;
    }
}

-(int)damage{
    return _damage;
}

-(BOOL)hasMagic{
    return _hasMagic;
}

-(BOOL)isSharp{
    return _isSharp;
}

@end
