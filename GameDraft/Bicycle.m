//
//  Bicycle.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/1/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "Bicycle.h"

@implementation Bicycle {
    
}

- (id)init {
    self = [super initWithImageNamed:@"Bike.png"];
    if (self) {
        //self.position = ccp();
    }
    return self;
}

- (void)moveLeft {
    self.position = ccp(self.position.x - 50, self.position.y);
}

- (void)moveRight {
    self.position = ccp(self.position.x + 50, self.position.y);
}


@end
