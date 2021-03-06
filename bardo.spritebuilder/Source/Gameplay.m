//
//  Level1.m
//  GameArchitecture
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//
#import "bullet.h"
#import "Gameplay.h"
#import "WinPopup.h"
#import "CCActionFollow+CurrentOffset.h"
#define CP_ALLOW_PRIVATE_ACCESS 1
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Level.h"
#import "character.h"
#import "CCActionMoveToNode.h"
#import "bullet1.h"

static NSString * const kFirstLevel = @"Level1";
static NSString *selectedLevel = @"Level1";
static int levelSpeed = 0;

@implementation Gameplay {
//  CCSprite *_character;
   character *_character;

  CCPhysicsNode *_physicsNode;
  CCNode *_levelNode;
  Level *_loadedLevel;
  CCLabelTTF *_scoreLabel;
  BOOL _jumped;
    CCSprite*_enemie;
    CCSprite*_enemie2;
  int _score;
    CCSprite*_rightButton;
    CCSprite*_leftButton;
    CCSprite*_jumpbutton;
    CCSprite*_launchbullet;
    CCNode*_contentNode;
    NSTimer *t;
    NSTimer *t1;
}

#pragma mark - Node Lifecycle

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
  _loadedLevel = (Level *) [CCBReader load:selectedLevel owner:self];
  [_levelNode addChild:_loadedLevel];
  
  levelSpeed = _loadedLevel.levelSpeed;
}

- (void)onEnter {
  [super onEnter];

  CCActionFollow *follow = [CCActionFollow actionWithTarget:_character worldBoundary:[_loadedLevel boundingBox]];
  _physicsNode.position = [follow currentOffset];
  [_physicsNode runAction:follow];
}

- (void)onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  self.userInteractionEnabled = YES;
}

#pragma mark - Level completion

- (void)loadNextLevel {
  selectedLevel = _loadedLevel.nextLevelName;
  
  CCScene *nextScene = nil;
  
  if (selectedLevel) {
    nextScene = [CCBReader loadAsScene:@"Gameplay"];
  } else {
    selectedLevel = kFirstLevel;
    nextScene = [CCBReader loadAsScene:@"StartScene"];
  }
  
  CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
  [[CCDirector sharedDirector] presentScene:nextScene withTransition:transition];
}

#pragma mark - Touch Handling



#pragma mark - Player Movement

- (void)resetJump {
  _jumped = FALSE;
}

#pragma mark - Collision Handling

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero flag:(CCNode *)flag {
  self.paused = YES;
  
  WinPopup *popup = (WinPopup *)[CCBReader load:@"WinPopup" owner:self];
  popup.positionType = CCPositionTypeNormalized;
  popup.position = ccp(0.5, 0.5);
  [self addChild:popup];
  
  return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero star:(CCNode *)star {
  [star removeFromParent];
  _score++;
  _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
  
  return YES;
}

#pragma mark - Update

- (void)update:(CCTime)delta {
  if (CGRectGetMaxY([_character boundingBox]) <   CGRectGetMinY([_loadedLevel boundingBox])) {
    [self gameOver];
  }
//    
//    
//    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 3.0
//                                                  target: self
//                                                selector:@selector(launchbullet2)
//                                                userInfo: nil repeats:NO];
//
//    CCActionMoveBy* moveUp = [CCActionMoveBy actionWithDuration:1.0f position:ccp(1.0f, 0.0f)];
//    CCActionMoveBy* moveDown = [CCActionMoveBy actionWithDuration:1.0f position:ccp(-1.0f, 0.0f)];
//    CCActionSequence* upAndDown = [CCActionSequence actions:moveUp, moveDown, nil];
//    [_enemie runAction:[CCActionRepeatForever actionWithAction:upAndDown]];
//    
//    CCActionMoveBy* moveUp1 = [CCActionMoveBy actionWithDuration:1.0f position:ccp(-1.0f, 0.0f)];
//    CCActionMoveBy* moveDown1 = [CCActionMoveBy actionWithDuration:1.0f position:ccp(1.0f, 0.0f)];
//    CCActionSequence* upAndDown1 = [CCActionSequence actions:moveUp1, moveDown1, nil];
//    [_enemie2 runAction:[CCActionRepeatForever actionWithAction:upAndDown1]];
//    
}

#pragma mark - Game Over


-(void)launchtimer
{

   // [self launchbullet2];



}
- (void)gameOver {
  CCScene *restartScene = [CCBReader loadAsScene:@"Gameplay"];
  CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
  [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CCSprite* heroSprite = (CCSprite*) _character.children[0];

    
    CGPoint touchLocation = [touch locationInNode: _contentNode];
    CGSize size = [[CCDirector sharedDirector] viewSize];
    id moveLeft = [CCActionMoveBy actionWithDuration:5.5 position:ccp(-size.width/1,00)];
    [moveLeft setTag:11];
    id moveRight = [CCActionMoveBy actionWithDuration:5.5 position:ccp(size.width/1,00)];
    [moveRight setTag:12];
    if(CGRectContainsPoint([_leftButton boundingBox], touchLocation)) {
        
        [_character runAction:moveLeft];
        NSLog(@"the left button was pressed");
      

        heroSprite.flipX = YES;

    }
    if(CGRectContainsPoint([_rightButton boundingBox], touchLocation)) {
        
        [_character  runAction:moveRight];
        NSLog(@"the right button was pressed");

        heroSprite.flipX = NO;

        
    }
    
    
    CGPoint touchLocation2 = [touch locationInNode: _contentNode];
    
    if(CGRectContainsPoint([_jumpbutton boundingBox], touchLocation2)) {
        
            if (!_jumped) {
                [_character.physicsBody applyImpulse:ccp(0, 1600)];
                _jumped = TRUE;
                [self performSelector:@selector(resetJump) withObject:nil afterDelay:2.5f];
            }
        
    }
    
    CGPoint touchLocation3 = [touch locationInNode: _contentNode];
    
    if(CGRectContainsPoint([_launchbullet boundingBox], touchLocation3)) {
        
        [self launchbullet];
        
    }
    
}
- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    [_character stopActionByTag:11];
    [_character stopActionByTag:12];
    
}

-(void) stopActionByTag:(NSInteger)tag {
    [_character stopActionByTag:tag];
    
    
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero hide:(CCNode *)hide {
   
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
        return _character.position;
    }];
    CCActionMoveToNode *moveTo2 = [CCActionMoveToNode actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
        return _character.position;
    }];

    [_enemie runAction:moveTo];
    
    
   // _enemie.flipX = YES;

    [_enemie2 runAction:moveTo2];
    
    [hide removeFromParent];

    //
    //
        NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                      target: self
                                                    selector:@selector(launchbullet2)
                                                    userInfo: nil repeats:YES];
    
    NSTimer *t1 = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                  target: self
                                                selector:@selector(launchbullet3)
                                                userInfo: nil repeats:YES];

    return YES;
}


- (void)launchbullet {
    CCNode* bullet = [CCBReader load:@"bullet"];
    bullet.position = ccpAdd(_character.position, ccp(0, 0));
    // NSLog(@"%f ,%f", _hero.position.x, _hero.position.y);
    [_physicsNode addChild:bullet];
    bullet.physicsBody.sensor=true;
    
    // manually create & apply a force to launch the bullet
    CGPoint launchDirection;
    CCSprite* heroSprite = (CCSprite*)_character.children[0];
    if (heroSprite.flipX) {
        launchDirection = ccp(-1, 0);
    }
    else
        launchDirection = ccp(1, 0);
    
    CGPoint force = ccpMult(launchDirection, 7000);
    [bullet.physicsBody applyForce:force];
    
}

- (void)launchbullet2 {
    CCNode* bullet = [CCBReader load:@"bullet1"];
    bullet.position = ccpAdd(_enemie.position, ccp(0, 0));
    // NSLog(@"%f ,%f", _hero.position.x, _hero.position.y);
    [_physicsNode addChild:bullet];
    bullet.physicsBody.sensor=true;
    
    // manually create & apply a force to launch the bullet
    CGPoint launchDirection;
    CCSprite* heroSprite = (CCSprite*)_character.children[0];
    if (heroSprite.flipX) {
        launchDirection = ccp(-1, 0);
    }
    else
        launchDirection = ccp(1, 0);
    
    CGPoint force = ccpMult(launchDirection, 7000);
    [bullet.physicsBody applyForce:force];
    
}
- (void)launchbullet3 {
    CCNode* bullet = [CCBReader load:@"bullet1"];
    bullet.position = ccpAdd(_enemie2.position, ccp(0, 0));
    // NSLog(@"%f ,%f", _hero.position.x, _hero.position.y);
    [_physicsNode addChild:bullet];
    bullet.physicsBody.sensor=true;
    
    // manually create & apply a force to launch the bullet
    CGPoint launchDirection;
    CCSprite* heroSprite = (CCSprite*)_character.children[0];
    if (heroSprite.flipX) {
        launchDirection = ccp(-1, 0);
    }
    else
        launchDirection = ccp(1, 0);
    
    CGPoint force = ccpMult(launchDirection, 7000);
    [bullet.physicsBody applyForce:force];
    
}


- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair enemie:(CCNode *)enemie bullet:(CCNode *)bullet {
    
    [t invalidate];
    [t1 invalidate];
    [bullet removeFromParent];

    [enemie removeFromParent];

 

    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero bullet1:(CCNode *)bullet1 {
    
    [bullet1 removeFromParent];
    
    [hero removeFromParent];
    [self gameOver];

    
    return YES;
}

@end
