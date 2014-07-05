//
//  Bicycle.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/1/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Bicycle.h"
#import "cocos2d.h"

@implementation Bicycle {
    
}

- (id)init {
    self = [super initWithImageNamed:@"Bike.png"];
    if (self) {
        self.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:15.0f andCenter:ccp(0.5f, 0.5f)];
        self.physicsBody.collisionType = @"bike";
    }
    return self;
}

- (void)moveLeft {
    // move left
    self.position = ccp(self.position.x - 50, self.position.y);
}

- (void)moveRight {
    // move right
    self.position = ccp(self.position.x + 50, self.position.y);
}


@end
