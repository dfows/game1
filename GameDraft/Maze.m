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
    NSMutableArray *_adjMat; // adjacency matrix. // yo it's acting weird. can we print this shit out legit.
}

- (id)init {
    self = [super init];
    if (self) {
        _map = [[NSMutableArray alloc] init];
        _adjMat = [[NSMutableArray alloc] init];
        _numColumns = 4;
        _numRows = 3;
        _numNodes = (_numColumns*_numRows) - ((_numColumns/2)*(_numRows/2));
        NSLog(@"width: %i, height: %i, numNodes: %i",_numColumns,_numRows,_numNodes);
        // initialize the data structure (NSMutableArray) that I am using to store cell information
        // initialize the adjacency matrix to hold 0's
        for (int j = 0; j < _numNodes; j++) {
            _adjMat[j] = [NSMutableArray array];
            for (int i = 0; i < _numNodes; i++) {
                _adjMat[j][i] = [NSNumber numberWithInteger:0];
            }
        }
        [self createMap];
    }
    return self;
}

- (void)createMap {
    // put all nodes into _map
    for (int j = 0; j < _numRows; j++) {
        _map[j] = [NSMutableArray array]; // class method
        for (int i = 0; i < _numColumns; i++) {
            if ((j*i)%2==0){
                // if not at odd row and odd column, create sprite
                // add more info here to streamline map generation
                int bloktype = 0;
                
                // having a south border
                if ((j==0) || (j%2==0 && i%2==1)) {
                    bloktype += 2; // South is 2
                }
                // having a north border
                if ((j==_numRows-1) || (j%2==0 && i%2==1)) {
                    bloktype += 8; // North is 8
                }
                // having an east border
                if ((i==_numColumns-1) || (j%2==1 && i%2==0)) {
                    bloktype += 4; // East is 4
                }
                // having a west border
                if ((i==0) || (j%2==1 && i%2==0)) {
                    bloktype += 1; // West is 1
                }
                CCSprite *streetTile = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"road_%i.png",bloktype]];
                [_map[j] addObject:streetTile];
                NSLog(@"CELL NUMBER %i is type %i",j*_numColumns+i,bloktype);
            } else {
                [_map[j] addObject:[NSNumber numberWithInteger:0]];
            }
        }
    }
    //NSLog(@"%@",_map);
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
        _adjMat[selfIdx][otherIdx] = [NSNumber numberWithInteger:1];
    } else {
        _adjMat[otherIdx][selfIdx] = [NSNumber numberWithInteger:1];
    }
    //both
//    _adjMat[selfIdx][otherIdx] = [NSNumber numberWithInteger:1];
//    _adjMat[otherIdx][selfIdx] = [NSNumber numberWithInteger:1];
    
}

// cells hold the followinginformation: which of its cardinal directions are blocked.


@end
