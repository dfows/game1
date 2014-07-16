//
//  Car.h
//  GameDraft
//
//  Created by Jessica Kwok on 7/1/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "CCSprite.h"

@interface Car : CCSprite

@property (assign) float maxVelocity;
@property (assign) float velocity;
@property (assign) BOOL hasCrashed;
- (BOOL)isOffScreen;

@end
