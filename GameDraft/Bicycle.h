//
//  Bicycle.h
//  GameDraft
//
//  Created by Jessica Kwok on 7/1/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "CCSprite.h"

@interface Bicycle : CCSprite

@property (assign) BOOL isBroken;

- (BOOL)isOffScreen;
- (void)moveRight;
- (void)moveLeft;

@end
