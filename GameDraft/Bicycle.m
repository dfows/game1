//
//  Bicycle.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/1/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "CCTextureCache.h"
#import "Bicycle.h"
#import "cocos2d.h"

@implementation Bicycle {
}

- (id)init {
    self = [super initWithImageNamed:@"bike_small.png"];
    if (self) {
        self.isBroken = NO;
        self.velocity = 30;
        self.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:5.0f andCenter:ccp(0.5f, 0.5f)];
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

- (void)update:(CCTime)delta {
    [self.physicsBody applyImpulse:ccp(0, _velocity*delta)];
    // check if hit, if so, image is now the broken bicycle.
    if (self.isBroken) {
        [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"people.png"]];
    }
}

- (BOOL)isOffScreen {
    return (self.position.y > 320.0f+25);
}

@end
