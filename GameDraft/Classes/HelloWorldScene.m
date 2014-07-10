//
//  HelloWorldScene.m
//  GameDraft
//
//  Created by Jessica Kwok on 6/29/14.
//  Copyright Jessica Kwok 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "Maze.h"
#import "Street.h"
#import "Car.h"
#import "Bicycle.h"

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_sprite;
    int _currentTileRow, _currentTileCol;
    Maze *_grid;
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
        _grid = [[Maze alloc] init];
        _currentTileRow = 0;
        _currentTileCol = 0;
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
    // load in the map piece
    CCSprite *mapPiece = [[_grid.map objectAtIndex:_currentTileRow] objectAtIndex:_currentTileCol];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    mapPiece.position = ccp(screenWidth/2,screenHeight/2);
    mapPiece.scale = .25;
    mapPiece.zOrder = -1;
    [self addChild:mapPiece];
    
    _physicsNode.contentSize = screenSize;
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_bike];
    //CCLOG(@"%f,%f boudning",_physicsNode.boundingBox.size.width,_physicsNode.boundingBox.size.height);
    [self runAction:follow];
}

// -----------------------------------------------------------------------

- (void)update:(CCTime)delta {
    [self detectObstacle];
    NSLog(@"bike position: (%f,%f)",_bike.position.x,_bike.position.y);
    // when bike gets to left or right boundaries of the scene, turn map to the left or right (swivel entire screen)
    
    // preload surrounding map pieces when bike enters a map piece
    // if (_bike.position.y > mapPiece????
}

- (void)preloadSurroundingMap {
    // add things to scene
    //for (int i = )
}

- (void)detectObstacle {
    // when a car is near another object, slow it down
    for (Car *c in _traffic.cars) {
        // if it is coming up on the bike, 2% chance of hitting it
        float distAway = ccpDistance(_bike.position,c.position);
        if (distAway < 50.0f) {
            if (arc4random()%10 < 9) { // 90% of the time there is no crash
                c.velocity *= .5;
            }
        }
    }
}

// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bike:(Bicycle *)player car:(CCNode *)enemy {
    NSLog(@"FIX BIKE! REPAIR NEEDED");
    player.isBroken = YES;
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
    // is there a way to get how much swiping was done / how strong/fast the swipe was
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
