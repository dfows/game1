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
#import "GameOverScene.h"
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
    CCNode *_mapNode; // wraps the map
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
        // init stuff
        // motion manager initialize
        _motionManager = [[CMMotionManager alloc] init];
        
        _grid = [[Maze alloc] init];
        _currentTileRow = 0;
        _currentTileCol = 0;
        _currentlyLoadedPieces = [NSMutableArray array];
        
        _physicsNode = [CCPhysicsNode node];
        _physicsNode.collisionDelegate = self;
        _physicsNode.gravity = ccp(0,0);
        _physicsNode.contentSize = CGSizeMake(_grid.numCols*self.contentSize.width, _grid.numRows*self.contentSize.height);
        
        _mapNode = [CCNode node];
        _mapNode.anchorPoint = ccp(0.5,0.5);
        _mapNode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
        [_physicsNode addChild:_mapNode];
        
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

    CCActionFollow *follow = [CCActionFollow actionWithTarget:_bike];
    [self runAction:follow];
    
//    NSLog(@"mapnode position is: %f,%f and its anchor point is at %f,%f and its content size is %fx%f", _mapNode.position.x,_mapNode.position.y,_mapNode.anchorPoint.x,_mapNode.anchorPoint.y,_mapNode.contentSize.width,_mapNode.contentSize.height);
//    NSLog(@"physnode position is: %f,%f and its anchor point is at %f,%f", _physicsNode.position.x,_physicsNode.position.y,_physicsNode.anchorPoint.x,_physicsNode.anchorPoint.y);
//    NSLog(@"traffic position is: %f,%f and its anchor point is at %f,%f", _traffic.position.x,_traffic.position.y,_traffic.anchorPoint.x,_traffic.anchorPoint.y);
//    NSLog(@"bike position is: %f,%f and its anchor point is at %f,%f", _bike.position.x,_bike.position.y,_bike.anchorPoint.x,_bike.anchorPoint.y);
    
    
    // start tracking motion
    [_motionManager startAccelerometerUpdates];
}

// -----------------------------------------------------------------------

- (void)update:(CCTime)delta {
    [self detectObstacle];
    
    /* motion */
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    float smoothingFactor = 0.85;
    smooth_x = smoothingFactor*smooth_x + (1.0-smoothingFactor)*acceleration.x;
    smooth_y = smoothingFactor*smooth_y + (1.0-smoothingFactor)*acceleration.y;
    float a_rad = atan2(smooth_y,smooth_x); // angle of rotation in radians
    
    // acceleration
    CGFloat mag_a = fabsf(acceleration.z)*-1; // magnitude of acceleration
    CGFloat newX = -15*mag_a*sin(a_rad)*pow(delta,2)+_mapNode.anchorPoint.x;
    CGFloat newY = -15*mag_a*cos(a_rad)*pow(delta,2)+_mapNode.anchorPoint.y;
    _mapNode.anchorPoint = ccp(newX,newY);
    _mapNode.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    
    // rotation
    // TODO make it increment instead of setting it to a designated angle
    _mapNode.rotation = -1*(a_rad*180.0/M_PI); // TODO angle edge case
    
    /* loading more map pieces */
    if (_mapNode.anchorPoint.y*self.contentSize.height > _currentMapPiece.position.y+self.contentSize.height) {
        NSLog(@"bikePos: %f / _currentMPPos: %f",_bike.position.y,_currentMapPiece.position.y+self.contentSize.height);
        NSLog(@"moved up");
        _currentTileRow++;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
    else if (_mapNode.anchorPoint.y*self.contentSize.height < _currentMapPiece.position.y) {
        NSLog(@"moved down");
        _currentTileRow--;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
    if (_mapNode.anchorPoint.x*self.contentSize.width > _currentMapPiece.position.x+self.contentSize.width) {
        NSLog(@"moved right");
        _currentTileCol++;
        NSLog(@"currentTileRow: %i",_currentTileRow);
        [self preloadSurroundingMapAtRow:(int)_currentTileRow andCol:(int)_currentTileCol];
    }
    else if (_mapNode.anchorPoint.x*self.contentSize.width < _currentMapPiece.position.x) {
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
            [_mapNode removeChild:[_currentlyLoadedPieces objectAtIndex:i]];
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
                    [_mapNode addChild:piece];
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
                c.physicsBody.friction += 0.1;
                c.velocity = pow(distAway,2)/c.maxVelocity;
            }
        }
    }
}

// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bike:(Bicycle *)player car:(Car *)enemy {
    [self becomeIncapacitated];
    enemy.hasCrashed = YES;
    [_motionManager stopAccelerometerUpdates];
    
    [self scheduleOnce:@selector(endGame) delay:2.0f];
    return TRUE;
}

- (void)endGame {
    [[CCDirector sharedDirector] replaceScene:[GameOverScene scene]];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bike:(Bicycle *)player wall:(CCNode *)aWall {
    NSLog(@"you biked into the sidewalks you are stupid");
    float energy = [pair totalKineticEnergy];
    // if impact is high enough, kill bike
    if (energy > 10000.f) {
        [self becomeIncapacitated];
        energy = 0;
    }
    return TRUE;
}

- (void)becomeIncapacitated {
    [_motionManager stopAccelerometerUpdates];
    NSLog(@"FIX BIKE! REPAIR NEEDED");
    _bike.isBroken = YES;
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
    
    [_motionManager stopAccelerometerUpdates];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {

}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------


// -----------------------------------------------------------------------
@end
