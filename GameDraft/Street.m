//
//  Street.m
//  GameDraft
//
//  Created by Jessica Kwok on 6/30/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Street.h"
#import "Car.h"
#import "Bicycle.h"

@implementation Street {
    // private vars here
    
}

- (id)init {
    if (self = [super init]) {
        // init the number of lanes.
        // random number of lanes, min 1 and max 4
        // for the purposes of prototyping, all traffic will go in the same direction as you.
        // each lane has an array property. i don't know how many cars to put in it. maybe create a function to populate the lanes.

        self.cars = [[NSMutableArray alloc] init];
        self.numLanes = (int)((arc4random() % 4)+1); // buckets
        NSLog(@"numLanes %i",self.numLanes);
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGSize screenSize = screenBound.size;
        CGFloat screenWidth = screenSize.width;
        CGFloat screenHeight = screenSize.height;
        //CCLOG(@"screensize %f,%f",screenWidth, screenHeight);
        //for (int i = 0; i < self.numLanes; i++) {
        for (int i = 0; i < 4; i++) {
             // make new car obj.
            CGFloat carx = (screenWidth/4)*(i+1)+50;
            CGFloat cary = -100;
            [self makeCarAtX:carx AtY:cary];
        }
    }
    return self;
}

- (void)makeCarAtX:(float)xpos AtY:(float)ypos {
    Car *car = [[Car alloc] init];
    car.position = ccp(xpos, ypos);
    [self.cars addObject:car]; // adds to array self.cars
    [self addChild:car]; // adds to CCNode
}

- (void)update:(CCTime)delta {
    // remove any cars that have disappeared off the screen
    for (int i = (int)[self.cars count]-1; i >= 0; i--) {
        Car *car = [self.cars objectAtIndex:i];
        if ([car isOffScreen]) {
            float carx = car.position.x;
            [self.cars removeObjectAtIndex:i];
            [self removeChild:car];
            [self makeCarAtX:carx AtY:0];
        }
    }
}

- (void)refillLanes {

}

@end
