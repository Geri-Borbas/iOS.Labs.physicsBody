//
//  SKPhysicsBody+Containment.m
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "SKPhysicsBody+Containment.h"


@implementation SKPhysicsBody (Containment)


// These implementations gonna be swapped on runtime.
-(void)setInitializingPath:(CGPathRef) initializingPath { }
-(CGPathRef)initializingPath { return NULL; }
-(void)setPathType:(SKPhysicsBodyPathType) pathType { }
-(SKPhysicsBodyPathType)pathType { return SKPhysicsBodyPathTypeCircle; }
-(CGPathRef)path { return NULL; }
-(BOOL)containsPoint:(CGPoint) point { return NO; }
-(BOOL)containsBody:(SKPhysicsBody*) body { return NO; }


@end


@implementation SKPhysicsBodyContainment


#pragma mark - Swizzle

+(void)load
{
    [super load];
    
    // Get runtime class for `SKPhysicsBody` instances (is `PKPhysicsBody` actually).
    Class physicsBodyClass = [SKPhysicsBody class];
    Class physicsBodyInstanceClass = [SKPhysicsBody new].class;
    
    // Swap class method implementations of factories here.
    [EPPZSwizzler swapClassMethod:@selector(bodyWithCircleOfRadius:) withClassMethod:@selector(__bodyWithCircleOfRadius:) ofClass:self];
    [EPPZSwizzler swapClassMethod:@selector(bodyWithRectangleOfSize:) withClassMethod:@selector(__bodyWithRectangleOfSize:) ofClass:self];
    [EPPZSwizzler swapClassMethod:@selector(bodyWithPolygonFromPath:) withClassMethod:@selector(__bodyWithPolygonFromPath:) ofClass:self];
    
    // Add factories to `SKPhysicsBody`.
    [EPPZSwizzler addClassMethod:@selector(__bodyWithCircleOfRadius:) toClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler addClassMethod:@selector(__bodyWithRectangleOfSize:) toClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler addClassMethod:@selector(__bodyWithPolygonFromPath:) toClass:physicsBodyClass fromClass:self];
    
    [EPPZSwizzler replaceClassMethod:@selector(bodyWithCircleOfRadius:) ofClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler replaceClassMethod:@selector(bodyWithRectangleOfSize:) ofClass:physicsBodyClass fromClass:self];
    [EPPZSwizzler replaceClassMethod:@selector(bodyWithPolygonFromPath:) ofClass:physicsBodyClass fromClass:self];
    
    // Add properties to `PKPhysicsBody`.
    [EPPZSwizzler addInstanceMethod:@selector(initializingPath) toClass:physicsBodyInstanceClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(setInitializingPath:) toClass:physicsBodyInstanceClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(pathType) toClass:physicsBodyInstanceClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(setPathType:) toClass:physicsBodyInstanceClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(path) toClass:physicsBodyInstanceClass fromClass:self];
    
    // Add instance methods to `PKPhysicsBody`.
    [EPPZSwizzler addInstanceMethod:@selector(containsPoint:) toClass:physicsBodyInstanceClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(containsBody:) toClass:physicsBodyInstanceClass fromClass:self];
}


#pragma mark - Augment factories

+(SKPhysicsBody*)__bodyWithCircleOfRadius:(CGFloat) radius
{
    // May seem an endless loop, but it's not (method implementations get swapped on runtime).
    SKPhysicsBody *instance = [self __bodyWithCircleOfRadius:radius];
    instance.initializingPath = centeredCircleWithRadius(radius);
    //instance.pathType = SKPhysicsBodyPathTypeCircle;
    return instance;
}

+(SKPhysicsBody*)__bodyWithRectangleOfSize:(CGSize) size
{
    // May seem an endless loop, but it's not (method implementations get swapped on runtime).
    SKPhysicsBody *instance = [self __bodyWithRectangleOfSize:size];
    instance.initializingPath = centeredPathFromPath(CGPathCreateWithRect((CGRect){CGPointZero, size}, NULL));
    //instance.pathType = SKPhysicsBodyPathTypeRectangle;
    return instance;
}

+(SKPhysicsBody*)__bodyWithPolygonFromPath:(CGPathRef) path
{
    // May seem an endless loop, but it's not (method implementations get swapped on runtime).
    SKPhysicsBody *instance = [self __bodyWithPolygonFromPath:path];
    instance.initializingPath = path;
    //instance.pathType = SKPhysicsBodyPathTypePath;
    return instance;
}


#pragma mark - Actual features

-(CGPathRef)path
{
    // Get currently transformed body path (based on node transformation).
    CGAffineTransform move = CGAffineTransformMakeTranslation(self.node.position.x, self.node.position.y);
    CGAffineTransform rotate = CGAffineTransformMakeRotation(self.node.zRotation);
    CGAffineTransform transform = CGAffineTransformConcat(rotate, move);
    CGPathRef transformedPath = CGPathCreateCopyByTransformingPath(self.initializingPath, &transform);
    return transformedPath;
}

-(BOOL)containsPoint:(CGPoint) point
{ return CGPathContainsPoint(self.path, NULL, point, NO); }

-(BOOL)containsBody:(SKPhysicsBody*) body
{
    // Quick check.
    if ([self.allContactedBodies containsObject:body] == NO)
    {
        SKCLog(@"SKPhysicsBody containsBody quick check.");
        return NO;
    }
    
    SKCLog(@"SKPhysicsBody containsBody point by point check.");
    
    // Get transformed path.
    CGPathRef path = [self path];
    
    // Test for containment for each point of body.
    __block BOOL everyPointContained = YES;
    enumeratePointsOfPath(body.path, ^(CGPoint eachPoint)
    {
        if (CGPathContainsPoint(path, NULL, eachPoint, NO) == NO)
        { everyPointContained = NO; }
    });
    
    return everyPointContained;
}


@end


#pragma mark - CGPath helpers

CGPathRef centeredCircleWithRadius(CGFloat radius)
{ return CGPathCreateWithEllipseInRect((CGRect){-radius, -radius, radius * 2.0, radius * 2.0}, NULL); }

CGPathRef centeredPathFromPath(CGPathRef path)
{
    CGRect bounds = CGPathGetBoundingBox(path);
    CGAffineTransform move = CGAffineTransformMakeTranslation(-bounds.size.width / 2.0, -bounds.size.height / 2.0);
    return CGPathCreateCopyByTransformingPath(path, &move);
}

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

