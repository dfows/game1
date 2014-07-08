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
}

- (id)init {
    self = [super initWithImageNamed:@"car_small.png"];
    if (self) {
        self.velocity = arc4random()%50 + 30;
        self.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:20.0f andCenter:ccp(0.5f, 0.5f)];
        self.physicsBody.collisionType = @"car";
    }
    return self;
}

- (void)update:(CCTime)delta {
    [self.physicsBody applyImpulse:ccp(0, _velocity*delta)];
    //self.position = ccp(self.position.x, self.position.y+_velocity*delta);
    // if there's space in front, move 1 velocity.
    // i need a timer to record ticks
    
    // check if there's space
//    if (_spaceInFront) {
//        
//    }
}

- (BOOL)isOffScreen {
    return (self.position.y > 320.0f+25);
}

@end
