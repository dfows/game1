//
//  Street.h
//  GameDraft
//
//  Created by Jessica Kwok on 6/30/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "CCNode.h"

@interface Street : CCNode

@property (assign) int numLanes;
@property (assign) int numCars;
//@property (nonatomic,strong) CGPoint position; // it might already have this since it inherits from CCNode
@property (nonatomic,strong) NSMutableArray *cars;

@end
