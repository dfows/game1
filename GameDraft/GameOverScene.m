//
//  GameOverScene.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/15/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "GameOverScene.h"
#import "HelloWorldScene.h"
#import "CCSprite.h"
#import "CCButton.h"

@implementation GameOverScene

+ (GameOverScene *)scene
{
    return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        // init stuff
        CCSprite *background = [CCSprite spriteWithImageNamed:@"gameover.png"];
        background.scale = 0.25;
        background.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
        background.anchorPoint = ccp(.5,.5);
        [self addChild:background];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"tap anywhere to restart" fontName:@"Helvetica" fontSize:36.0f];
        label.positionType = CCPositionTypeNormalized;
        label.color = [CCColor redColor];
        label.position = ccp(0.5f, 0.5f); // Middle of screen
        [self addChild:label];

        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"yo");
    self.userInteractionEnabled = NO;
    [[CCDirector sharedDirector] replaceScene:[HelloWorldScene scene]];
}

@end
