//
//  HelloWorldScene.m
//  GameDraft
//
//  Created by Jessica Kwok on 6/29/14.
//  Copyright Jessica Kwok 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "CCTextureCache.h"
#import "HelloWorldScene.h"
#import "Street.h"
#import "Car.h"
#import "Bicycle.h"

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_sprite;
    Street *_traffic;
    CCPhysicsNode *_physicsNode;
    Bicycle *_bike;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    if (self = [super init]) {
        // init stuff
        UISwipeGestureRecognizer *swipeUptToDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwipeBoom:)];
        [swipeUptToDown setDirection:UISwipeGestureRecognizerDirectionDown];
        [swipeUptToDown setDelegate:self];
        [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUptToDown];

        
        UISwipeGestureRecognizer *swipeLeftToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
        [swipeLeftToRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [swipeLeftToRight setDelegate:self];
        [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeftToRight];
        
        UISwipeGestureRecognizer *swipeRightToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
        [swipeRightToLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeRightToLeft setDelegate:self];
        [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRightToLeft];
        
        _physicsNode = [CCPhysicsNode node];
        _physicsNode.collisionDelegate = self;
        _physicsNode.gravity = ccp(0,0);
        _traffic = [[Street alloc] init];
        _bike = [[Bicycle alloc] init];
        _bike.position = ccp(240, 160);
        [_traffic addChild:_bike];
        [_physicsNode addChild:_traffic];
        [self addChild:_physicsNode];
        
        NSLog(@"created stuff");
    }
    return self;
}

// -----------------------------------------------------------------------
// methods setting up the screen

- (void)moveTraffic {
}

- (void)loadLane {
    
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)update:(CCTime)delta {
    
}

// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bike:(CCSprite *)player car:(CCNode *)enemy {
    NSLog(@"FIX BIKE! REPAIR NEEDED");
    [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"people.png"]];
    return TRUE;
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
    
    // not sure why i'm doing this part but the tutorial said to
    NSArray *grs = [[[CCDirector sharedDirector] view] gestureRecognizers];
    
    for (UIGestureRecognizer *gesture in grs){
        if([gesture isKindOfClass:[UISwipeGestureRecognizer class]]){
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:gesture];
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
    // Move our sprite to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.0f position:touchLoc];
    [_sprite runAction:actionMove];
}

- (void)handleRightSwipe:(UISwipeGestureRecognizer*)recognizer {
    NSLog(@"right swpipe"); //change this to accelerometer
    [_bike moveLeft];
}

- (void)handleLeftSwipe:(UISwipeGestureRecognizer*)recognizer {
    NSLog(@"left swipe");
    [_bike moveRight];
}

- (void)handleDownSwipeBoom:(UISwipeGestureRecognizer*)recognizer {
    NSLog(@"restarting");
    // restart this scene
//    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
//    [[CCDirector sharedDirector] presentScene:@"HelloWorldScene" withTransition:transition];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    /*
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
     */
}

// -----------------------------------------------------------------------
@end
