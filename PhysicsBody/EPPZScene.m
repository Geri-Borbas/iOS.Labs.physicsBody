//
//  EPPZMyScene.m
//  Categories
//
//  Created by Gardrobe on 2/19/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZScene.h"


@interface EPPZScene ()
@property (nonatomic, weak) SKNode *draggedNode;
@property (nonatomic, strong) SKSpriteNode *smallSquare;
@property (nonatomic, strong) SKShapeNode *smallCircle;
@property (nonatomic, strong) SKShapeNode *middleCircle;
@property (nonatomic, strong) SKSpriteNode *bigSquare;
@end



@implementation EPPZScene


-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {        
        self.backgroundColor = [SKColor darkGrayColor];
        
        CGSize size;
        CGFloat alpha = 0.3;
        CGPoint center = (CGPoint){self.size.width / 2.0, self.size.height / 2.0};
        
        size = (CGSize){192.0, 192.0};
        self.bigSquare = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
        self.bigSquare.position = center;
        self.bigSquare.zRotation = 0.2;
        self.bigSquare.alpha = alpha;
        self.bigSquare.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.bigSquare.physicsBody.affectedByGravity = NO;
        self.bigSquare.physicsBody.categoryBitMask = 1;
        self.bigSquare.physicsBody.collisionBitMask = 1;
        
        size = (CGSize){128.0, 128.0};
        self.middleCircle = [SKShapeNode new];
        self.middleCircle.alpha = alpha;
        self.middleCircle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size.width / 2.0];
        self.middleCircle.physicsBody.affectedByGravity = NO;
        self.middleCircle.physicsBody.categoryBitMask = 2;
        self.middleCircle.physicsBody.collisionBitMask = 2;
        self.middleCircle.path = self.middleCircle.physicsBody.path; // Simply init with the path of the physics body.
        self.middleCircle.lineWidth = 0.0;
        self.middleCircle.fillColor = [UIColor redColor];
        self.middleCircle.position = center;
        
        size = (CGSize){72.0, 72.0};
        self.smallCircle = [SKShapeNode new];
        self.smallCircle.alpha = alpha;
        self.smallCircle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size.width / 2.0];
        self.smallCircle.physicsBody.affectedByGravity = NO;
        self.smallCircle.physicsBody.categoryBitMask = 4;
        self.smallCircle.physicsBody.collisionBitMask = 4;
        self.smallCircle.path = self.smallCircle.physicsBody.path; // Simply init with the path of the physics body.
        self.smallCircle.lineWidth = 0.0;
        self.smallCircle.fillColor = [UIColor redColor];
        self.smallCircle.position = center;
        
        size = (CGSize){64.0, 64.0};
        self.smallSquare = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:size];
        self.smallSquare.position = center;
        self.smallSquare.zRotation = 0.1;
        self.smallSquare.alpha = alpha;
        self.smallSquare.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.smallSquare.physicsBody.affectedByGravity = NO;
        self.smallSquare.physicsBody.categoryBitMask = 8;
        self.smallSquare.physicsBody.collisionBitMask = 8;
        
        [self addChild:self.bigSquare];
        [self addChild:self.middleCircle];
        [self addChild:self.smallCircle];
        [self addChild:self.smallSquare];
    }
    return self;
}



#pragma mark - Basic dragging

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*) event
{ self.draggedNode = [self nodeAtPoint:[[touches anyObject] locationInNode:self]]; }

-(void)touchesMoved:(NSSet*) touches withEvent:(UIEvent*) event
{ self.draggedNode.position = [[touches anyObject] locationInNode:self]; }

-(void)touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event
{ self.draggedNode = nil; }


#pragma mark - Animation

-(void)update:(NSTimeInterval) currentTime
{
    // Animation.
    CGFloat amount = 0.001;
    self.smallSquare.zRotation += amount;
    self.bigSquare.zRotation += amount * 2.0;

    // Containment tests.
    BOOL smallSquareIsInMiddleCircle = [self.middleCircle.physicsBody containsBody:self.smallSquare.physicsBody];
    BOOL smallSquareIsInBigSquare = [self.bigSquare.physicsBody containsBody:self.smallSquare.physicsBody];
    BOOL smallCircleIsInMiddleCircle = [self.middleCircle.physicsBody containsBody:self.smallCircle.physicsBody];
    BOOL smallCircleIsInBigSquare = [self.bigSquare.physicsBody containsBody:self.smallCircle.physicsBody];
    BOOL middleCircleIsInBigSquare = [self.bigSquare.physicsBody containsBody:self.middleCircle.physicsBody];
    
    // UI.
    self.smallSquare.color = (smallSquareIsInMiddleCircle || smallSquareIsInBigSquare)
    ? [UIColor greenColor] : [UIColor redColor];
    
    self.smallCircle.fillColor = (smallCircleIsInMiddleCircle || smallCircleIsInBigSquare)
    ? [UIColor greenColor] : [UIColor redColor];
    
    self.middleCircle.fillColor = (smallSquareIsInMiddleCircle || smallCircleIsInMiddleCircle || middleCircleIsInBigSquare)
    ? [UIColor greenColor] : [UIColor redColor];
    
    self.bigSquare.color = (smallSquareIsInBigSquare || smallCircleIsInBigSquare || middleCircleIsInBigSquare)
    ? [UIColor greenColor] : [UIColor redColor];
}


@end
