//
//  HelloWorldScene.m
//  GameDraft
//
//  Created by Jessica Kwok on 6/29/14.
//  Copyright Jessica Kwok 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import <CoreMotion/CoreMotion.h>
#import "CCTextureCache.h"
#import "HelloWorldScene.h"
#import "Maze.h"
#import "Street.h"
#import "Car.h"
#import "Bicycle.h"

static float SCALE_AMT = .28;

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
    float smooth_x, smooth_y;
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
        self.anchorPoint = ccp(0.5,0.5);
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
        _bike.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
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
    int screenWidth = self.contentSize.width;
    int screenHeight = self.contentSize.height;
    
    _physicsNode.contentSize = CGSizeMake(_grid.numCols*screenWidth, _grid.numRows*screenHeight);//screenSize;
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_bike];
    [self runAction:follow];
    
    // start tracking motion
    [_motionManager startAccelerometerUpdates];
}

// -----------------------------------------------------------------------

- (void)update:(CCTime)delta {
    [self detectObstacle];
    
    /* motion */
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _bike.position.x + acceleration.y * 1000 * delta;
    //NSLog(@"accel: (%f,%f,%f)",acceleration.x,acceleration.y, acceleration.z);
    newXPosition = clampf(newXPosition, 0, self.contentSize.width*_grid.numCols);
    CGFloat newYPosition = _bike.position.y;
    newYPosition = clampf(newYPosition, 0, self.contentSize.height*_grid.numRows);
    //_bike.position = CGPointMake(newXPosition, newYPosition);
    _bike.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    
    // convert bike to world and then node, and then to the map node?
    CGPoint bikeWPos = [self convertToWorldSpace:_bike.position];
    CGPoint mapWPos = ccp(self.anchorPoint.x*self.contentSize.width,self.anchorPoint.y*self.contentSize.height);
    NSLog(@"bikeWPos: %f,%f / mapWPos: %f,%f",bikeWPos.x,bikeWPos.y,mapWPos.x,mapWPos.y);
    
    // set self.anchorpoint to bike position so that the map can pivot about that
    
    // should alwyas be positioned in center of screen from the anchor point
    self.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    // i also want to tilt the map sprite in the direction that i am rotating the phone.
    // i know the angle is atan2(accel.y/accel.x). convert it to degrees.
    float smoothingFactor = 0.85;
    smooth_x = smoothingFactor*smooth_x + (1.0-smoothingFactor)*acceleration.x;
    smooth_y = smoothingFactor*smooth_y + (1.0-smoothingFactor)*acceleration.y;
    self.rotation = -1*(atan2(smooth_y,smooth_x)*180.0/(2*M_PI)); // angle edge case still needs to be fixed

    // acceleration
    CGFloat zAcc = 1+abs(acceleration.z);
    [_bike.physicsBody applyImpulse:ccp(0,zAcc*delta)];
    self.anchorPoint = ccp(newXPosition/self.contentSize.width,zAcc*pow(delta,2)+self.anchorPoint.y);
    
    // when bike gets to left or right boundaries of the scene,
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
        //self.anchorPoint = ccp(bikeWPos.x/self.contentSize.width, bikeWPos.y/self.contentSize.height);
        NSLog(@"moved right");
        _currentTileCol++;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
    else if (_bike.position.x < _currentMapPiece.position.x) {
        //self.anchorPoint = ccp(bikeWPos.x/self.contentSize.width, bikeWPos.y/self.contentSize.height);
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

- (void)createWallAtX:(float)posX atY:(float)posY withWidth:(float)wallW andHeight:(float)wallH {
    CCNode *wall = [CCNode node];
    wall.position = ccp(posX,posY);
    CGRect wallRect = CGRectMake(0,0,wallW,wallH);
    wall.physicsBody = [CCPhysicsBody bodyWithRect:wallRect cornerRadius:0];
    wall.physicsBody.type = CCPhysicsBodyTypeStatic;
    wall.physicsBody.collisionType = @"wall";
    [_physicsNode addChild:wall];
}

- (void)preloadSurroundingMapAtRow:(int)rowNum andCol:(int)colNum {
    [self clearPreloaded];
    
    // add things to scene
    int numRows = _grid.numRows;
    int numCols = _grid.numCols;
    int screenWidth = self.contentSize.width;
    int screenHeight = self.contentSize.height;
    
    for (int j = rowNum-1; j <= rowNum+1; j++) {
        if (j >= 0 && j < numRows) {
            for (int i = colNum-1; i <= colNum+1; i++) {
                if (i >= 0 && i < numCols) {
                    // generate map tile and set its position to i*self.contentSize.width, j*self.contentSize.height
                    CCSprite *piece = [[_grid.map objectAtIndex:j] objectAtIndex:i];
                    piece.position = ccp(i*screenWidth, j*screenHeight);
                    piece.scale = SCALE_AMT;
                    piece.zOrder = -1;
                    if (i == _currentTileCol && j == _currentTileRow) {
                        _currentMapPiece = piece;
                    }
                    [_currentlyLoadedPieces addObject:piece];
                    [self addChild:piece];
                    int bloktype = [_grid.allNodes[j][i] intValue];
                    //NSLog(@"bloktype of cell at %i,%i is %i",j,i,bloktype);
                    if ((bloktype >> 0) & 1) { // if having a west wall
                        [self createWallAtX:(i*screenWidth) atY:(j*screenHeight) withWidth:100 andHeight:screenHeight];
                    }
                    if ((bloktype >> 1) & 1) { // if having a south wall
                        [self createWallAtX:(i*screenWidth) atY:(j*screenHeight) withWidth:screenWidth andHeight:100];
                    }
                    if ((bloktype >> 2) & 1) { // if having a east wall
                        [self createWallAtX:(((i+1)*screenWidth)-1) atY:(j*screenHeight) withWidth:100 andHeight:screenHeight];
                    }
                    if ((bloktype >> 3) & 1) { // if having a north wall
                        [self createWallAtX:(i*screenWidth) atY:(((j+1)*screenHeight)-100) withWidth:screenWidth andHeight:100];
                    }
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

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bike:(Bicycle *)player car:(Car *)enemy {
    NSLog(@"FIX BIKE! REPAIR NEEDED");
    player.isBroken = YES;
    player.velocity = 0;
    enemy.velocity = 0;
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bike:(Bicycle *)player wall:(CCNode *)aWall {
    NSLog(@"you biked into a wall you are stupid");
    float energy = [pair totalKineticEnergy];
    // if impact is high enough, kill bike
    if (energy > 10000.f) {
        NSLog(@"FIX BIKE! REPAIR NEEDED");
        player.isBroken = YES;
        energy = 0;
    }
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
