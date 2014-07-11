//
//  Maze.h
//  GameDraft
//
//  Created by Jessica Kwok on 7/7/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Maze : NSObject

@property (assign) int numRows;
@property (assign) int numCols;
@property (strong, nonatomic) NSMutableArray *map;

@end
