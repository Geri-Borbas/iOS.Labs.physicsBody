//
//  EPPZMyScene.m
//  Categories
//
//  Created by Gardrobe on 2/19/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZMyScene.h"

@implementation EPPZMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        SKPhysicsBody *body;
        SKPhysicsBody *buddy;
        
        CGFloat width = 60.0;
        CGRect rect = (CGRect){CGPointZero, width, width};
        CGPathRef path = CGPathCreateWithRect(rect, NULL);
        
        body = [SKPhysicsBody bodyWithCircleOfRadius:width / 2.0];
        body.initializingPath = path;
        NSLog(@"%i", (body.path == path));
        body = [SKPhysicsBody bodyWithPolygonFromPath:path];
        body.initializingPath = path;
        NSLog(@"%i", (body.path == path));
        body = [SKPhysicsBody bodyWithRectangleOfSize:rect.size];
        body.initializingPath = path;
        NSLog(@"%i", (body.path == path));
        
        buddy = [SKPhysicsBody bodyWithRectangleOfSize:rect.size];
        CGPathRef anotherPath = CGPathCreateWithRect(rect, NULL);
        buddy.initializingPath = anotherPath;
        NSLog(@"%i", (buddy.path == anotherPath));
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
