//
//  Maze.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/7/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "CCPhysics+ObjectiveChipmunk.h"
#import "Maze.h"
#import "CCSprite.h"

struct Tuple {
    int x;
    int y;
};
typedef struct Tuple Tuple;
CG_INLINE Tuple
TupleMake(int x, int y)
{
    Tuple p; p.x = x; p.y = y; return p;
}

struct Tuple directions[4];

@implementation Maze
{
    int _numNodes;
}

- (id)init {
    self = [super init];
    if (self) {
        directions[0] = TupleMake(0,2);
        directions[1] = TupleMake(0,-2);
        directions[2] = TupleMake(2,0);
        directions[3] = TupleMake(-2,0);
        
        self.map = [[NSMutableArray alloc] init];
        self.allNodes = [[NSMutableArray alloc] init];
        self.numCols = arc4random()%5+5;
        self.numRows = arc4random()%10+5;
        _numNodes = _numCols * _numRows;
        NSLog(@"width: %i, height: %i, numNodes: %i",self.numCols,self.numRows,_numNodes);
        // initialize the data structure (NSMutableArray) that I am using to store cell information
        // initialize the matrix to hold 15's
        for (int j = 0; j < self.numRows; j++) {
            self.allNodes[j] = [NSMutableArray array];
            for (int i = 0; i < self.numCols; i++) {
                self.allNodes[j][i] = [NSNumber numberWithInteger:15];
            }
        }
        [self createMaze];
        [self createMap];
    }
    return self;
}

- (void)createMaze {
    int visitedNodes = 0;
    Tuple currentPt,nextPt;
    Tuple randomDir;
    while (visitedNodes < _numNodes) {
        currentPt = TupleMake(1+(arc4random()%((self.numCols-1)/2)*2),1+(arc4random()%((self.numRows-1)/2)*2));
        randomDir = directions[arc4random()%4];
        int nextX = currentPt.x+randomDir.x;
        nextX = nextX >= 0 ? (nextX < self.numCols-1 ? nextX : self.numCols-1) : 0;
        int nextY = currentPt.y+randomDir.y;
        nextY = nextY >= 0 ? (nextY < self.numRows-1 ? nextY : self.numRows-1) : 0;
        nextPt = TupleMake(nextX,nextY);
        [self digBtwn:currentPt and:nextPt];
        visitedNodes++;
        currentPt = nextPt;
    }
}

- (void)digBtwn:(Tuple)p1 and:(Tuple)p2 {
    NSLog(@"p1 is %i,%i, p2 is %i,%i",p1.x,p1.y,p2.x,p2.y);
    if (p1.x == p2.x) {
        int largerY = (p1.y > p2.y) ? p1.y : p2.y;
        int smallerY = (p1.y > p2.y) ? p2.y : p1.y;
        for (int y = smallerY; y <= largerY; y++) {
            self.allNodes[y][p1.x] = [NSNumber numberWithInteger:0];
        }
    }
    else {
        int largerX = (p1.x > p2.x) ? p1.x : p2.x;
        int smallerX = (p1.x > p2.x) ? p2.x : p1.x;
        for (int x = smallerX; x <= largerX; x++) {
            self.allNodes[p1.y][x] = [NSNumber numberWithInteger:0];
        }
    }
}

- (void)createMap {
    // put all nodes into _map
    for (int j = 0; j < self.numRows; j++) {
        self.map[j] = [NSMutableArray array]; // class method
        for (int i = 0; i < self.numCols; i++) {
            int bloktype = [self.allNodes[j][i] intValue];
            CCSprite *streetTile = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"road_%i.png",bloktype]];
            streetTile.anchorPoint = ccp(0,0);
            [self.map[j] addObject:streetTile];
        }
    }
}

@end
