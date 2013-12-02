//
//  HelloWorldLayer.m
//  PhantomAssasins
//
//  Created by Agustin Marseillan on 9/12/13.
//  Copyright Agustin Marseillan 2013. All rights reserved.
//


// Import the interfaces
#import "MainLoopLayer.h"
#import "GameOverLayer.h"
#import "AGMonster.h"
#import "AGProjectile.h"
#import "GoldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"


// Audio files
#import "SimpleAudioEngine.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation MainLoopLayer

CCSprite *_player;
NSMutableArray * _monsters;
NSMutableArray * _projectiles;
NSMutableArray * _lives;
GoldLayer * _goldLayer;
int _projectilesFired;
long _time;
AGGameStatus* _gameStatus;
CCSpriteBatchNode *_spriteSheet;
CCAnimation *_walkAnim;



// on "init" you need to initialize your instance
- (id) initWithStatus:(AGGameStatus*)gameStatus
{
    if ((self = [super init])) {
        
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"diana2mov.plist"];
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"dianatext.png"];
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for (int i=1; i<=6; i++) {
            [walkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"diana%d.png",i]]];
        }
        _walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
        
        
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        _monstersDestroyed = 0;
        _lives = [[NSMutableArray alloc] init];
        _projectilesFired = 0;
        _time = 0;
        _gameStatus = gameStatus;
        _gold = gameStatus.gold;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        GoldLayer* goldLayer = [[GoldLayer alloc] initWithGold:_gold];
        _goldLayer = goldLayer;
        
        int i = 0;
        for( i=0; i<3; i++ ){
            CCSprite *life = [CCSprite spriteWithFile:@"heart.png"];
            life.position = ccp(winSize.width/2 - (i-1)*life.contentSize.width, winSize.height - life.contentSize.height/2);
            
            [_lives addObject:life];
        }
        _totalLives = 3;
        _player = [CCSprite spriteWithFile:@"arquero.png"];
        _player.position = ccp(_player.contentSize.width/2, winSize.height/2);
        CCSprite *background = [CCSprite spriteWithFile:@"pasto.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        CCSprite *castle = [CCSprite spriteWithFile:@"castillo.png"];
        castle.position = ccp(castle.contentSize.width/2, winSize.height/2);
        [self addChild:background];
        [self addChild:castle];
        [self addChild:_goldLayer];
        [self addChild:_player];
        [self addChild:_spriteSheet];
        [self addChild:_lives[0]];
        [self addChild:_lives[1]];
        [self addChild:_lives[2]];
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self setIsTouchEnabled:YES];
        [self schedule:@selector(update:)];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    }
    return self;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene:(AGGameStatus*)gameStatus
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainLoopLayer *layer = [[MainLoopLayer alloc] initWithStatus:gameStatus];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


- (void) addMonster {
    
    AGMonster * monster = nil;
    
    if (_time < 100 && _time%2 == 0 ){
        monster = [[AGMonster alloc] initWithAnimation:(_time/5) animation:_walkAnim];
        monster.tag = 2;
    }else{
        monster =[AGMonster createWithHp:(_time/5)];
        monster.tag = 1;
    }
    
    // Determine where to spawn the monster along the Y axis
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = monster.contentSize.height / 2;
    int maxY = winSize.height - monster.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = ccp(winSize.width + monster.contentSize.width/2, actualY);
    if (monster.tag == 2){
        [_spriteSheet addChild:monster];
    }else if(monster.tag == 1){
        [self addChild:monster];
    }
    
    CCMoveTo *actionMove = nil;
    CCMoveTo *actionUp = nil;
    CCMoveTo *actionDown = nil;
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    if (monster.tag == 1 && _time > 1 && _time % 5 == 0){
        monster.tag = 3;
        int pos = (arc4random() % 30) + winSize.width - (40 + monster.contentSize.width/2);
        actionMove = [CCMoveTo actionWithDuration:actualDuration
                                        position:ccp(pos, actualY)];
        actionUp = [CCMoveTo actionWithDuration:actualDuration
                                       position:ccp(pos, winSize.height - monster.contentSize.height/2)];
        actionDown = [CCMoveTo actionWithDuration:actualDuration
                            position:ccp(pos, -20)];
    }else{
    
        // Create the actions
        actionMove = [CCMoveTo actionWithDuration:actualDuration
                                                position:ccp(-monster.contentSize.width/2, actualY)];
    }
    
    CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        _totalLives--;
        CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"heartempty.png"];
        [_lives[_totalLives] setTexture:tex];
        if( _totalLives <= 0 ){
            _gameStatus.gold = _gold;
            CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO status:_gameStatus];
            [[CCDirector sharedDirector] replaceScene:gameOverScene];
        }
        [_monsters removeObject:node];
    }];
    if (monster.tag == 3){
        [monster runAction:[CCSequence actions:actionMove, actionUp, actionDown, actionMoveDone, nil]];
    }else{
        [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    }
    [_monsters addObject:monster];
}

-(void)gameLogic:(ccTime)dt {
    [self addMonster];
    _time++;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    _monsters = nil;
    _projectiles = nil;
    _lives = nil;
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    AGProjectile *projectile = [AGProjectile createWithMagic:((_projectilesFired++%5)==0) isSharp:NO];
    projectile.position = ccp(20, winSize.height/2);
    
    // Determine offset of location to projectile
    CGPoint offset = ccpSub(location, projectile.position);
    
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
    int realX = winSize.width + (projectile.contentSize.width/2);
    float ratio = (float) offset.y / (float) offset.x;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    //[projectile setRotation:asin(ratio)];
    
    
    // Determine the length of how far you're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Move projectile to actual endpoint
    [projectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [node removeFromParentAndCleanup:YES];
         [_projectiles removeObject:node];
     }],
      nil]];
    
    projectile.tag = 2;
    [_projectiles addObject:projectile];
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
}

- (void)update:(ccTime)dt {
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (AGProjectile *projectile in _projectiles) {
        BOOL eraseArrow = NO;
        
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (AGMonster *monster in _monsters) {
            
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                if( [monster getHit:projectile] ){
                    [monstersToDelete addObject:monster];
                }
                if( ![projectile isSharp] ){
                    eraseArrow = YES;
                }
            }
        }
        
        for (AGMonster *monster in monstersToDelete) {
            [_monsters removeObject:monster];
            [self hitAnimation:monster.position.x y:monster.position.y];
            _gold += [monster maxHp];
            if(monster.tag == 1 || monster.tag == 3){
                [self removeChild:monster cleanup:YES];
            }else if( monster.tag == 2){
                [_spriteSheet removeChild:monster cleanup:YES];
            }
            _monstersDestroyed++;
            //winning condition...
            /*if (_monstersDestroyed > 5) {
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }*/
        }
        
        if ( eraseArrow ) {
            [projectilesToDelete addObject:projectile];
        }
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    
    [_goldLayer updateWithGold:_gold];
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}


-(void) hitAnimation: (float) x y:(float) y {
    CCParticleRain *animation = [[CCParticleRain alloc] init];
    [animation setScaleX:1];
    [animation setScaleY:1];
    
    [animation resetSystem];
    animation.texture = [[CCTextureCache sharedTextureCache] addImage:@"blood.png"];
    
    animation.duration = .2;
    
    // Set the gravity effect for the stars to control how
    // fast they fall down.
    animation.gravity = ccp(_player.position.x, 0);
    
    // Specify the angle of the stars as they extend from the
    // starting point.
    animation.angle = 180;
    animation.angleVar = 120;
    
    // The speed the particles will use when floating
    animation.speed = 230;
    animation.speedVar = 50;
    
    // The radial variable
    //animation.radialAccel = -120;
    //animation.radialAccelVar = 120;
    
    // The tangential variable
    //animation.tangentialAccel = 30;
    //animation.tangentialAccelVar = 60;
    
    // How long each star should last before fading out
    animation.life = .2;
    animation.lifeVar = 0;
    
    // How much each star should spin
    //animation.startSpin = 3;
    //animation.startSpinVar = 2;
    //animation.endSpin = 80;
    //animation.endSpinVar = 50;
    
    // The color of the stars as RGB values.  Each color uses
    // a variable value for where the stars should start and
    // what color they should use when they're done.
    //ccColor4F startColor = {171.0f, 26.0f, 37.0f, 1.0f};
    //animation.startColor = startColor;
    //ccColor4F startColorVar = {245.0f, 255.f, 72.0f, 1.0f};
    //animation.startColorVar = startColorVar;
    //ccColor4F endColor = {255.0f, 223.0f, 85.0f, 1.0f};
    //animation.endColor = endColor;
    //ccColor4F endColorVar = {255.0f, 131.0f, 62.0f, 1.0f};
    //animation.endColorVar = endColorVar;
    
    // The size of each of the stars
    //animation.startSize = 50.0f;
    //animation.startSizeVar = 20.0f;
    //animation.endSize = kParticleStartSizeEqualToEndSize;
    
    // The rate at which new stars will be created
    animation.totalParticles = 10;
    animation.emissionRate = animation.totalParticles/animation.life;
    
    // The position to start the stars
    animation.posVar = ccp(0,0);
    animation.position = ccp(x,y);
    
    // We have a simple white background, so we don't want to
    // do additive blending.
    animation.blendAdditive = NO;
    
    // Now we're ready to run the particle emitter
    [self addChild: animation z:10];
    animation.autoRemoveOnFinish = YES;
}


@end
