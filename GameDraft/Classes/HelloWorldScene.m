//
//  HelloWorldScene.m
//  GameDraft
//
//  Created by Jessica Kwok on 6/29/14.
//  Copyright Jessica Kwok 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import <CoreMotion/CoreMotion.h>
#import "HelloWorldScene.h"
#import "Maze.h"
#import "Street.h"
#import "Car.h"
#import "Bicycle.h"

static float SCALE_AMT = .25;

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    int _currentTileRow, _currentTileCol; // keeps track of current map piece with respect to array
    CCSprite *_currentMapPiece; // keeps track of dimensions of current map piece
    NSMutableArray *_currentlyLoadedPieces; // keeps track of map pieces that have been added to self as children
    Maze *_grid; // sets up the map
    
    Street *_traffic; // holds cars / obstacles
    CCPhysicsNode *_physicsNode; // encloses objects that will collide
    Bicycle *_bike; // main character
    
    CMMotionManager *_motionManager; // to track motion
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
        // motion manager initialize
        _motionManager = [[CMMotionManager alloc] init];
        
        /*
        // gesture recognizers for swiping
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
         */
        
        _physicsNode = [CCPhysicsNode node];
        _physicsNode.collisionDelegate = self;
        _physicsNode.gravity = ccp(0,0);
        
        _grid = [[Maze alloc] init];
        _currentTileRow = 0;
        _currentTileCol = 0;
        _currentlyLoadedPieces = [NSMutableArray array];
        
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
    [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    NSLog(@"preloaded in on enter");
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    
    _physicsNode.contentSize = screenSize;
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_bike];
    [self runAction:follow];
    
    // start tracking motion
    [_motionManager startAccelerometerUpdates];
}

// -----------------------------------------------------------------------

- (void)update:(CCTime)delta {
    [self detectObstacle];
    
    /* bicycle motion */
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _bike.position.x + acceleration.y * 1000 * delta;
    NSLog(@"accel: (%f,%f,%f)",acceleration.x,acceleration.y, acceleration.z);
    newXPosition = clampf(newXPosition, 0, self.contentSize.width*_grid.numCols);
    CGFloat newYPosition = _bike.position.y;
    newYPosition = clampf(newYPosition, 0, self.contentSize.height*_grid.numRows);
    _bike.position = CGPointMake(newXPosition, newYPosition);
    
    // i also want to tilt the bike sprite in the direction that i am rotating the phone.
    // i know the angle is atan2(accel.y/accel.x). convert it to degrees.
    _bike.rotation = (atan2(acceleration.y,acceleration.x)*180.0/M_PI);

    // acceleration
    CGFloat zAcc = acceleration.z;
    [_bike.physicsBody applyImpulse:ccp(0,-1*(.5+zAcc))];
    
    // when bike gets to left or right boundaries of the scene,
    // detect if there is a wall there
    // turn map to the left or right (swivel entire screen)
    
    //NSLog(@"currentmapppiece -%f < %f",_currentMapPiece.boundingBox.size.height, _currentMapPiece.position.y);
    //CGPoint mapPos = [self convertToWorldSpace:_currentMapPiece.position];
    //CGPoint bikeWPos = [self convertToWorldSpace:_bike.position];
    //NSLog(@"bikePos: %f / bikeWPos: %f",_bike.position.y,bikeWPos.y);
    
    /* loading more map pieces */
    if (_bike.position.y > _currentMapPiece.position.y+self.contentSize.height) {
        NSLog(@"bikePos: %f / _currentMPPos: %f",_bike.position.y,_currentMapPiece.position.y+self.contentSize.height);
        NSLog(@"moved up");
        _currentTileRow++;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
    else if (_bike.position.y < _currentMapPiece.position.y) {
        NSLog(@"moved down");
        _currentTileRow--;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
    if (_bike.position.x > _currentMapPiece.position.x+self.contentSize.width) {
        NSLog(@"moved right");
        _currentTileCol++;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
    else if (_bike.position.x < _currentMapPiece.position.x) {
        NSLog(@"moved left");
        _currentTileCol--;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
}

- (void)clearPreloaded {
    if ([_currentlyLoadedPieces count] == 0) {
        return;
    } else {
        for (int i = (int)([_currentlyLoadedPieces count]-1); i >= 0; i--) {
            [self removeChild:[_currentlyLoadedPieces objectAtIndex:i]];
            [_currentlyLoadedPieces removeObjectAtIndex:i];
        }
    }
}

- (void)preloadSurroundingMapAtRow:(int)rowNum andCol:(int)colNum {
    [self clearPreloaded];
    // add things to scene
    int numRows = _grid.numRows;
    int numCols = _grid.numCols;
    for (int j = rowNum-1; j <= rowNum+1; j++) {
        if (j >= 0 && j < numRows) {
            for (int i = colNum-1; i <= colNum+1; i++) {
                if (i >= 0 && i < numCols) {
                    // generate map tile and set its position to i*self.contentSize.width, j*self.contentSize.height
                    CCSprite *piece = [[_grid.map objectAtIndex:j] objectAtIndex:i];
                    piece.position = ccp(i*self.contentSize.width, j*self.contentSize.height);
                    piece.scale = SCALE_AMT;
                    piece.zOrder = -1;
                    if (i == _currentTileCol && j == _currentTileRow) {
                        _currentMapPiece = piece;
                    }
                    [_currentlyLoadedPieces addObject:piece];
                    [self addChild:piece];
                }
            }
        }
    }
}

- (void)detectObstacle {
    // when a car is near another object, slow it down
    for (Car *c in _traffic.cars) {
        // if it is coming up on the bike, 2% chance of hitting it
        float distAway = ccpDistance(_bike.position,c.position);
        if (distAway < 50.0f) {
            if (arc4random()%10 < 9) { // 90% of the time there is no crash
                c.velocity *= .1;
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
    
    [_motionManager stopAccelerometerUpdates];
    
    /*
    // not sure why i'm doing this part but the tutorial said to
    NSArray *grs = [[[CCDirector sharedDirector] view] gestureRecognizers];
    
    for (UIGestureRecognizer *gesture in grs){
        if([gesture isKindOfClass:[UISwipeGestureRecognizer class]]){
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:gesture];
        }
    }
     */
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {

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
