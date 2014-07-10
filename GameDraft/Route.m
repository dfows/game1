//
//  Route.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/5/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Route.h"
#import "CCSprite.h"

@implementation Route {
    int _length;
    CCSprite *_currentRoad;
}

/* okay. A route is the sequence of nodes that the bike has traversed
 */
- (id)init {
    if (self = [super init]) {
        [_currentRoad initWithImageNamed:@"road_1.png"];
    }
    return self;
}

- (void)didLoadFromCCB {
    
}

@end
