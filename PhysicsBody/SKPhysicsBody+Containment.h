//
//  SKPhysicsBody+Containment.h
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "EPPZSwizzler.h"


#define SK_PHYSICS_BODY_CONTAINMENT_LOGGING YES
#define SKCLog if (SK_PHYSICS_BODY_CONTAINMENT_LOGGING) NSLog


// Interface for the new features.
@interface SKPhysicsBody (Containment)

@property (nonatomic, readonly) CGPathRef path;

-(BOOL)containsPoint:(CGPoint) point;
-(BOOL)containsBody:(SKPhysicsBody*) body;

@end


// Implementation placeholder object for the new features.
@interface SKPhysicsBodyContainment : SKPhysicsBody

@property (nonatomic) CGPathRef initializingPath;
@property (nonatomic, assign) CGPathRef batman;

@property (nonatomic, readonly) CGPathRef path;
-(BOOL)containsPoint:(CGPoint) point;
-(BOOL)containsBody:(SKPhysicsBody*) body;

@end


#pragma mark - CGPath helpers

CGPathRef centeredCircleWithRadius(CGFloat radius);
CGPathRef centeredPathFromPath(CGPathRef path);

typedef void(^CGPathPointEnumeratingBlock)(CGPoint eachPoint);
void enumeratePointsOfPath(CGPathRef path, CGPathPointEnumeratingBlock enumeratingBlock);
void CGPathEnumerationCallback(void *info, const CGPathElement *element);


#pragma mark - Guest methods from EPPZGeometry

typedef struct
{
    CGPoint center;
    CGFloat radius;
} CGCircle;

typedef struct
{
    CGPoint a;
    CGPoint b;
    CGFloat width;
    
    CGCircle circleA;
    CGCircle circleB;
    
} CGLine;

CGVector __vectorBetweenPoints(CGPoint from, CGPoint to);
CGFloat __distanceBetweenPoints(CGPoint from, CGPoint to);
CGFloat __distanceBetweenPointAndLineSegment(CGPoint point, CGLine line);
