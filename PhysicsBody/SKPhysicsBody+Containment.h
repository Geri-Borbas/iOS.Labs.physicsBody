//
//  SKPhysicsBody+Containment.h
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "EPPZSwizzler.h"


#define SK_PHYSICS_BODY_CONTAINMENT_LOGGING NO
#define SKCLog if (SK_PHYSICS_BODY_CONTAINMENT_LOGGING) NSLog

typedef enum
{
    SKPhysicsBodyPathTypeCircle,
    SKPhysicsBodyPathTypeRectangle,
    SKPhysicsBodyPathTypePath
} SKPhysicsBodyPathType;


// Interface for the new features.
@interface SKPhysicsBody (Containment)

@property (nonatomic, readonly) CGPathRef path;
@property (nonatomic) NSUInteger pathType;

-(BOOL)containsPoint:(CGPoint) point;
-(BOOL)containsBody:(SKPhysicsBody*) body;

@end


// Implementation for the new features.
@interface SKPhysicsBodyContainment : SKPhysicsBody

@property (nonatomic) CGPathRef initializingPath;
@property (nonatomic) NSUInteger pathType;

@property (nonatomic, readonly) CGPathRef path;
-(BOOL)containsPoint:(CGPoint) point;
-(BOOL)containsBody:(SKPhysicsBody*) body;

@end


// CGPath helpers.

CGPathRef centeredCircleWithRadius(CGFloat radius);
CGPathRef centeredPathFromPath(CGPathRef path);

typedef void(^CGPathPointEnumeratingBlock)(CGPoint eachPoint);
void enumeratePointsOfPath(CGPathRef path, CGPathPointEnumeratingBlock enumeratingBlock);
void CGPathEnumerationCallback(void *info, const CGPathElement *element);
