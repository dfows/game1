//
//  Maze.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/7/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Maze.h"

@implementation Maze
{
    int _width;
    int _length;
    int _numNodes;
    NSMutableArray *_adjMat; // adjacency matrix. // yo it's acting weird. can we print this shit out legit.
}

- (id)init {
    self = [super init];
    if (self) {
        _adjMat = [[NSMutableArray alloc] init];
        _width = arc4random()%10+5;
        _length = arc4random()%10+10;
        _numNodes = (_width*_length) - ((_width/2)*(_length/2));
        NSLog(@"width: %i, height: %i, numNodes: %i",_width,_length,_numNodes);
        // initialize the data structure (NSMutableArray) that I am using to store cell information
        // initialize the adjacency matrix to hold 0's
        for (int j = 0; j < _numNodes; j++) {
            _adjMat[j] = [NSMutableArray array];
            for (int i = 0; i < _numNodes; i++) {
                _adjMat[j][i] = [NSNumber numberWithInteger:0];
            }
        }
        [self initMaze];
    }
    return self;
}

- (void)initMaze {
    //self.maze = [[NSMutableArray alloc] init];
    for (int j = 0; j < _length; j++) {
        int i = 0;
        while (i < _width) {
            int current;
            if (j%2==1) {
                current = (j*_width)-((j-1)*_width/4)+(i/2);
                // bottom neighbor
                NSLog(@"bottom, oddrow");

                int bottom = ((j-1)*_width)-((j-1)*_width/4)+i;
                [self addAsNeighbor:current atOtherIdx:bottom];
                if (j < _length-1) {
                    NSLog(@"top, oddrow");

                    // top neighbor
                    int top = ((j+1)*_width)-((j+1)*_width/4)+i;
                    [self addAsNeighbor:current atOtherIdx:top];
                }
                i+=2;
            } else {
                current = (j*_width+i)-(j*_width/4);
                if (i%2==0) {
                    if (j > 0) {
                        NSLog(@"bottom, not oddrow");

                        // bottom neighbor
                        int bottom = ((j-1)*_width)-((j-2)*_width/4)+(i/2);
                        [self addAsNeighbor:current atOtherIdx:bottom];
                    }
                    if (j < _length-1) {
                        NSLog(@"top, not oddrow");

                        // top neighbor
                        int top = ((j+1)*_width)-(j*_width/4)+(i/2);
                        [self addAsNeighbor:current atOtherIdx:top];
                    }
                }
                if (i > 0) {
                    NSLog(@"left");

                    // left neighbor
                    int left = current-1;
                    [self addAsNeighbor:current atOtherIdx:left];
                }
                if (i < _width-1) {
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
}

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
