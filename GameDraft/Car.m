//
//  Car.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/1/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Car.h"

@implementation Car {
    BOOL _spaceInFront; // is there space in front of the car
    float _velocity;
}

- (id)init {
    self = [super initWithImageNamed:@"trees.png"];
    if (self) {
        _velocity = arc4random()%100 + 100;
    }
    return self;
}

- (void)update:(CCTime)delta {
    self.position = ccp(self.position.x, self.position.y+_velocity*delta);
    // if there's space in front, move 1 velocity.
    // i need a timer to record ticks
    
    // check if there's space
//    if (_spaceInFront) {
//        
//    }
}

- (BOOL)isOffScreen {
    NSLog(@"ypos is: %f",self.position.y);
    return (self.position.y > 320.0f+25);
}

@end
