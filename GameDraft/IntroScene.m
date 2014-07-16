//
//  IntroScene.m
//  GameDraft
//
//  Created by Jessica Kwok on 7/15/14.
//  Copyright (c) 2014 Jessica Kwok. All rights reserved.
//

#import "IntroScene.h"
#import "HelloWorldScene.h"

@implementation IntroScene

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
    CCSprite *background = [CCSprite spriteWithImageNamed:@"titleScreen.png"];
    background.scale = 0.25;
    background.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    background.anchorPoint = ccp(.5,.5);
    [self addChild:background];
    
    // Hello world
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"tap anywhere to continue" fontName:@"Helvetica" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor redColor];
    label.position = ccp(0.5f, 0.5f); // Middle of screen
    [self addChild:label];
    
    self.userInteractionEnabled = YES;
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"yo");
    self.userInteractionEnabled = NO;
    [[CCDirector sharedDirector] replaceScene:[HelloWorldScene scene]];
}


@end
