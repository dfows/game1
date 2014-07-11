//
//  Maze.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/7/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Maze.h"
#import "CCSprite.h"

@implementation Maze
{
    //int _numColumns;
    //int _numRows;
    int _numNodes;
    NSMutableArray *_allNodes;
}

- (id)init {
    self = [super init];
    if (self) {
        _map = [[NSMutableArray alloc] init];
        _allNodes = [[NSMutableArray alloc] init];
        self.numCols = 4;
        self.numRows = 3;
        _numNodes = _numCols * _numRows;
        NSLog(@"width: %i, height: %i, numNodes: %i",self.numCols,self.numRows,_numNodes);
        // initialize the data structure (NSMutableArray) that I am using to store cell information
        // initialize the matrix to hold 15's
        for (int j = 0; j < self.numRows; j++) {
            _allNodes[j] = [NSMutableArray array];
            for (int i = 0; i < self.numCols; i++) {
                _allNodes[j][i] = [NSNumber numberWithInteger:15];
            }
        }
        [self createMaze];
        [self createMap];
    }
    return self;
}

- (void)createMaze {
    NSMutableArray *queue = [NSMutableArray array];
    
    [queue addObject:[NSNumber numberWithInt:0]]; // position 0,0
    while ([queue count] != 0) {
        // pop nodes (mark them)
        NSNumber *current = [queue objectAtIndex:[queue count]-1];
        [queue removeObject:current];
        int currentNum = [current intValue];
        //current cell's array row and col position
        int c_row = currentNum/self.numCols;
        int c_col = currentNum%self.numCols;
        // if it's not rightmost
        int cellType = [_allNodes[c_row][c_col] intValue];
        if (c_col < self.numCols-1) {
            if ((cellType >> 2) & 1) {
                // if its immediate right neighbor hasnt already had its west wall knocked down
                int rightNeighbor = [_allNodes[c_row][c_col+1] intValue];
                if (((rightNeighbor >> 0) & 1) && (arc4random()%3!=2)) { // <=66% chance of this happening
                    // knock down wall to immediate right neighbor
                    NSLog(@"knocking down own right wall. i am at %i, %i",c_row,c_col);
                    [self knockDownWall:4 atRow:c_row atCol:c_col];
                    // add its immediate right neighbor
                    [queue addObject:[NSNumber numberWithInt:currentNum+1]];
                    [self knockDownWall:1 atRow:c_row atCol:c_col+1]; // knock down the cell's west wall
                }
            }
        }
        if (c_row < self.numRows-1) {
            if ((cellType >> 3) & 1) { // if haven't knocked it down already
                // knock down wall to above neighbor
                [self knockDownWall:8 atRow:c_row atCol:c_col];
                // and its above neighbor
                int aboveNeighbor = [_allNodes[c_row+1][c_col] intValue];
                if ((aboveNeighbor >> 1) & 1) {
                    [queue addObject:[NSNumber numberWithInt:currentNum+self.numCols]];
                    [self knockDownWall:2 atRow:c_row+1 atCol:c_col]; // knock down the cell's southern wall
                }
            }
        }
    }
}

- (void)knockDownWall:(int)wallDir atRow:(int)rowNum atCol:(int)colNum {
    NSNumber *currentCell = _allNodes[rowNum][colNum];
    _allNodes[rowNum][colNum] = [NSNumber numberWithInt:[currentCell intValue]-wallDir];
}

- (void)createMap {
    // put all nodes into _map
    for (int j = 0; j < _numRows; j++) {
        _map[j] = [NSMutableArray array]; // class method
        for (int i = 0; i < self.numCols; i++) {
            int bloktype = [_allNodes[j][i] intValue];
            NSLog(@"bloktype %i",bloktype);
            CCSprite *streetTile = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"road_%i.png",bloktype]];
            streetTile.anchorPoint = ccp(0,0);
            [_map[j] addObject:streetTile];
            NSLog(@"CELL NUMBER %i is type %i",j*self.numCols+i,bloktype);
        }
    }
}

// cells hold the followinginformation: which of its cardinal directions are blocked.


@end
