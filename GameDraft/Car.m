//
//  Car.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/1/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Car.h"
#import "cocos2d.h"

@implementation Car {
    BOOL _spaceInFront; // is there space in front of the car
    float _velocity;
}

- (id)init {
    self = [super initWithImageNamed:@"trees.png"];
    if (self) {
        _velocity = arc4random()%100 + 100;
        self.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:30.0f andCenter:ccp(0.5f, 0.5f)];
        self.physicsBody.collisionType = @"car";
    }
    return self;
}

- (void)update:(CCTime)delta {
    //[self.physicsBody applyImpulse:ccp(0, _velocity*delta)];
    self.position = ccp(self.position.x, self.position.y+_velocity*delta);
    // if there's space in front, move 1 velocity.
    // i need a timer to record ticks
    
    // check if there's space
//    if (_spaceInFront) {
//        
//    }
}

- (void)detectObstacle {
    // call this method always and slow down when an obstacle is detected
    // i think i can rip some code from robot wars and see how they do detection
}

- (BOOL)isOffScreen {
    return (self.position.y > 320.0f+25);
}

@end
