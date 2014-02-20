//
//  SKPhysicsBody+Containment.m
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "SKPhysicsBody+Containment.h"


@implementation SKPhysicsBody (Containment)

-(void)setInitializingPath:(CGPathRef) initializingPath { }
-(CGPathRef)initializingPath { return NULL; }
-(CGPathRef)path { return NULL; }
-(BOOL)containsBody:(SKPhysicsBody*) body { return NO; }

@end


@implementation SKPhysicsBodyContainment


#pragma mark - Swizzle

+(void)load
{
    [super load];
    
    // Get runtime class for `SKPhysicsBody` instances (is `PKPhysicsBody` actually).
    Class physicsBodyClass = [SKPhysicsBody class];
    Class runtimePhysicsBodyClass = [SKPhysicsBody new].class;
    
    // Swap class method implementations.
    [EPPZSwizzler swapClassMethod:@selector(bodyWithCircleOfRadius:) withClassMethod:@selector(__bodyWithCircleOfRadius:) ofClass:self];
    [EPPZSwizzler swapClassMethod:@selector(bodyWithRectangleOfSize:) withClassMethod:@selector(__bodyWithRectangleOfSize:) ofClass:self];
    [EPPZSwizzler swapClassMethod:@selector(bodyWithPolygonFromPath:) withClassMethod:@selector(__bodyWithPolygonFromPath:) ofClass:self];
    
    [EPPZSwizzler addClassMethod:@selector(__bodyWithCircleOfRadius:) toClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler addClassMethod:@selector(__bodyWithRectangleOfSize:) toClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler addClassMethod:@selector(__bodyWithPolygonFromPath:) toClass:physicsBodyClass fromClass:self];
    
    [EPPZSwizzler replaceClassMethod:@selector(bodyWithCircleOfRadius:) ofClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler replaceClassMethod:@selector(bodyWithRectangleOfSize:) ofClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler replaceClassMethod:@selector(bodyWithPolygonFromPath:) ofClass:physicsBodyClass fromClass:self];
    
    // Add properties (from this class to `PKPhysicsBody`).
    [EPPZSwizzler addInstanceMethod:@selector(initializingPath) toClass:runtimePhysicsBodyClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(setInitializingPath:) toClass:runtimePhysicsBodyClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(path) toClass:runtimePhysicsBodyClass fromClass:self];
    
    // Add instance methods (from this class to `PKPhysicsBody`).
    [EPPZSwizzler addInstanceMethod:@selector(containsBody:) toClass:runtimePhysicsBodyClass fromClass:self];
}


#pragma mark - Augment factories

+(SKPhysicsBody*)__bodyWithCircleOfRadius:(CGFloat) radius
{
    SKPhysicsBody *instance = [self __bodyWithCircleOfRadius:radius]; // Seems an endless loop, but it's not.
    instance.initializingPath = CGPathCreateWithEllipseInRect((CGRect){CGPointZero, radius * 2.0, radius * 2.0}, NULL);
    return instance;
}

+(SKPhysicsBody*)__bodyWithRectangleOfSize:(CGSize) size
{
    SKPhysicsBody *instance = [self __bodyWithRectangleOfSize:size];
    instance.initializingPath = CGPathCreateWithRect((CGRect){CGPointZero, size}, NULL);
    return instance;
}

+(SKPhysicsBody*)__bodyWithPolygonFromPath:(CGPathRef) path
{
    SKPhysicsBody *instance = [self __bodyWithPolygonFromPath:path];
    instance.initializingPath = path;
    return instance;
}


#pragma mark - Actual features

-(CGPathRef)path
{
    return self.initializingPath;
}

-(BOOL)containsBody:(SKPhysicsBody*) body
{ return NO; }


@end


#pragma mark - CGPath helpers

void enumeratePointsOfPath(CGPathRef path, CGPathPointEnumeratingBlock enumeratingBlock)
{
    void CGPathEnumerationCallback(void *info, const CGPathElement *element);
    CGPathApply(path, (void*)enumeratingBlock, CGPathEnumerationCallback);
}

void CGPathEnumerationCallback(void *info, const CGPathElement *element)
{
    CGPathPointEnumeratingBlock enumeratingBlock = (__bridge CGPathPointEnumeratingBlock)info;
    
    switch (element->type)
    {
        case kCGPathElementMoveToPoint:
        {
            CGPoint point = element ->points[0];
            if (enumeratingBlock) { enumeratingBlock(point); }
            break;
        }
        case kCGPathElementAddLineToPoint:
        {
            CGPoint point = element ->points[0];
            if (enumeratingBlock) { enumeratingBlock(point); }
            break;
        }
        case kCGPathElementAddQuadCurveToPoint: { break; }
        case kCGPathElementAddCurveToPoint: { break; }
        case kCGPathElementCloseSubpath: { break; }
    }
}

