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
    int _numColumns;
    int _numRows;
    int _numNodes;
    NSMutableArray *_allNodes;
}

- (id)init {
    self = [super init];
    if (self) {
        _map = [[NSMutableArray alloc] init];
        _allNodes = [[NSMutableArray alloc] init];
        _numColumns = 4;
        _numRows = 3;
        _numNodes = _numColumns * _numRows;
        NSLog(@"width: %i, height: %i, numNodes: %i",_numColumns,_numRows,_numNodes);
        // initialize the data structure (NSMutableArray) that I am using to store cell information
        // initialize the matrix to hold 0's
        for (int j = 0; j < _numRows; j++) {
            _allNodes[j] = [NSMutableArray array];
            for (int i = 0; i < _numColumns; i++) {
                _allNodes[j][i] = [NSNumber numberWithInteger:15];
            }
        }
        //NSLog(@"@",_allNodes);
        [self createMaze];
        [self createMap];
    }
    return self;
}

- (void)createMaze {
    // creates a maze using a maze algorithm i have found on the internet
    
    NSMutableArray *queue = [NSMutableArray array];
    
    [queue addObject:[NSNumber numberWithInt:0]]; // position 0,0
    while ([queue count] != 0) {
        // pop nodes (mark them)
        NSNumber *current = [queue objectAtIndex:[queue count]-1];
        [queue removeObject:current];
        int currentNum = [current intValue];
        //current cell's array row and col position
        int c_row = currentNum/_numColumns;
        int c_col = currentNum%_numColumns;
        // if it's not rightmost
        int cellType = [_allNodes[c_row][c_col] intValue];
        if (c_col < _numColumns-1) {
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
        if (c_row < _numRows-1) {
            if ((cellType >> 3) & 1) { // if haven't knocked it down already
                // knock down wall to above neighbor
                [self knockDownWall:8 atRow:c_row atCol:c_col];
                // and its above neighbor
                int aboveNeighbor = [_allNodes[c_row+1][c_col] intValue];
                if ((aboveNeighbor >> 1) & 1) {
                    [queue addObject:[NSNumber numberWithInt:currentNum+_numColumns]];
                    [self knockDownWall:2 atRow:c_row+1 atCol:c_col]; // knock down the cell's southern wall
                }
            }
        }
    }
    //NSLog(_allNodes);
}

- (void)knockDownWall:(int)wallDir atRow:(int)rowNum atCol:(int)colNum {
    NSNumber *currentCell = _allNodes[rowNum][colNum];
    _allNodes[rowNum][colNum] = [NSNumber numberWithInt:[currentCell intValue]-wallDir];
}

- (void)createMap {
    // put all nodes into _map
    for (int j = 0; j < _numRows; j++) {
        _map[j] = [NSMutableArray array]; // class method
        for (int i = 0; i < _numColumns; i++) {
            int bloktype = [_allNodes[j][i] intValue];
            NSLog(@"bloktype %i",bloktype);
            CCSprite *streetTile = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"road_%i.png",bloktype]];
            streetTile.anchorPoint = ccp(0,0);
            [_map[j] addObject:streetTile];
            NSLog(@"CELL NUMBER %i is type %i",j*_numColumns+i,bloktype);
        }
    }
}

/*- (void)initNodes {
    for (int j = 0; j < _numRows; j++) {
        int i = 0;
        while (i < _numColumns) {
            int current;
            if (j%2==1) {
                current = (j*_numColumns)-((j-1)*_numColumns/4)+(i/2);
                // bottom neighbor
                NSLog(@"bottom, oddrow");

                int bottom = ((j-1)*_numColumns)-((j-1)*_numColumns/4)+i;
                [self addAsNeighbor:current atOtherIdx:bottom];
                if (j < _numRows-1) {
                    NSLog(@"top, oddrow");

                    // top neighbor
                    int top = ((j+1)*_numColumns)-((j+1)*_numColumns/4)+i;
                    [self addAsNeighbor:current atOtherIdx:top];
                }
                i+=2;
            } else {
                current = (j*_numColumns+i)-(j*_numColumns/4);
                if (i%2==0) {
                    if (j > 0) {
                        NSLog(@"bottom, not oddrow");

                        // bottom neighbor
                        int bottom = ((j-1)*_numColumns)-((j-2)*_numColumns/4)+(i/2);
                        [self addAsNeighbor:current atOtherIdx:bottom];
                    }
                    if (j < _numRows-1) {
                        NSLog(@"top, not oddrow");

                        // top neighbor
                        int top = ((j+1)*_numColumns)-(j*_numColumns/4)+(i/2);
                        [self addAsNeighbor:current atOtherIdx:top];
                    }
                }
                if (i > 0) {
                    NSLog(@"left");

                    // left neighbor
                    int left = current-1;
                    [self addAsNeighbor:current atOtherIdx:left];
                }
                if (i < _numColumns-1) {
                    // right neighbor
                    NSLog(@"right");
                    int right = current+1;
                    [self addAsNeighbor:current atOtherIdx:right];
                }
                i++;
            }
        }
    }
    NSLog(@"myarray %@",_adjMat);
//    for (int j = 0; j < _numNodes; j++) {
//        NSMutableArray *ugh = [_adjMat objectAtIndex:j];
//        NSMutableString *row;
//        for (int i = 0; i < _numNodes; i++) {
//            [row appendString:[NSString stringWithFormat:@" %@",[ugh objectAtIndex:j]]];
//        }
//        NSLog(row);
//    }
}*/

- (void)addAsNeighbor:(int)selfIdx atOtherIdx:(int)otherIdx {
    if (selfIdx > otherIdx) {
        //NSLog(@"added at %i,%i",selfIdx,otherIdx);
        _allNodes[selfIdx][otherIdx] = [NSNumber numberWithInteger:1];
    } else {
        _allNodes[otherIdx][selfIdx] = [NSNumber numberWithInteger:1];
    }
    //both
//    _adjMat[selfIdx][otherIdx] = [NSNumber numberWithInteger:1];
//    _adjMat[otherIdx][selfIdx] = [NSNumber numberWithInteger:1];
    
}

// cells hold the followinginformation: which of its cardinal directions are blocked.


@end
