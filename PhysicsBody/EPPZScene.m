//
//  EPPZMyScene.m
//  Categories
//
//  Created by Gardrobe on 2/19/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZScene.h"


@interface EPPZScene ()
@property (nonatomic) BOOL dragging;
@property (nonatomic, strong) SKSpriteNode *one;
@property (nonatomic, strong) SKSpriteNode *other;
@end



@implementation EPPZScene


-(void)didMoveToView:(SKView*) view
{
    self.backgroundColor = [SKColor darkGrayColor];
    
    CGSize size;
    CGPoint center = (CGPoint){self.size.width / 2.0, self.size.height / 2.0};
    
    size = (CGSize){60.0, 60.0};
    self.one = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
    self.one.position = center;
    self.one.zRotation = 0.1;
    self.one.alpha = 0.3;
    self.one.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    self.one.physicsBody.categoryBitMask = 1;
    self.one.physicsBody.collisionBitMask = 1;
    
    size = (CGSize){240.0, 240.0};
    self.other = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
    self.other.position = center;
    self.other.zRotation = 0.2;
    self.other.alpha = 0.3;
    self.other.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    self.other.physicsBody.categoryBitMask = 2;
    self.other.physicsBody.collisionBitMask = 2;
    
    [self addChild:self.one];
    [self addChild:self.other];
    
    self.one.physicsBody.pathType = SKPhysicsBodyPathTypeRectangle;
}



#pragma mark - Basic dragging

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*) event
{
    if ([self.one.physicsBody containsPoint:[[touches anyObject] locationInNode:self]])
    { self.dragging = YES; }
}

-(void)touchesMoved:(NSSet*) touches withEvent:(UIEvent*) event
{
    if (self.dragging)
    { self.one.position = [[touches anyObject] locationInNode:self]; }
}

-(void)touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event
{ self.dragging = NO; }


#pragma mark - Animation

-(void)update:(NSTimeInterval) currentTime
{
    // Animation.
    CGFloat amount = 0.01;
    self.one.zRotation += amount;
    self.other.zRotation += amount * 2.0;
    
    // Test.
    BOOL contains = [self.other.physicsBody containsBody:self.one.physicsBody];
    
    // UI.
    self.one.color = (contains) ? [UIColor greenColor] : [UIColor redColor];
    self.other.color = (contains) ? [UIColor greenColor] : [UIColor redColor];
}


@end
