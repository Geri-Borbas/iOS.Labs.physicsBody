//
//  SKPhysicsBody+Containment.m
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "SKPhysicsBody+Containment.h"


#define SK_PHYSICS_BODY_CONTAINMENT_LOGGING YES
#define SKCLog if (SK_PHYSICS_BODY_CONTAINMENT_LOGGING) NSLog


static NSString *const SKPhysicsBodyPathTypeCircle = @"SKPhysicsBodyPathTypeCircle";
static NSString *const SKPhysicsBodyPathTypePath = @"SKPhysicsBodyPathTypePath";


#pragma mark - Private SKPhysicsBody properties

@interface SKPhysicsBody (Containment_private)

@property (nonatomic) CGPathRef initializingPath;
@property (nonatomic) NSNumber *radius;
@property (nonatomic) NSString *pathType;

@end


@implementation SKPhysicsBody (Containment_private)

@dynamic initializingPath;
@dynamic pathType;
@dynamic radius;

@end


#pragma mark - Public SKPhysicsBody properties (implementation placeholders)

@implementation SKPhysicsBody (Containment)
@dynamic path;

-(BOOL)containsPoint:(CGPoint) point { return NO; }
-(BOOL)containsBody:(SKPhysicsBody*) body { return NO; }


@end


#pragma mark - Implementation donor

@interface SKPhysicsBodyContainment : SKPhysicsBody

@property (nonatomic) CGPathRef initializingPath;
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


#pragma mark - Implementation donor

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
    [EPPZSwizzler synthesizeAssignedPropertyNamed:@"initializingPath"
                                   ofTypeEncoding:@encode(CGPathRef)
                                         forClass:physicsBodyInstanceClass];
    
    [EPPZSwizzler synthesizeAssignedPropertyNamed:@"pathType"
                                   ofTypeEncoding:@encode(NSString)
                                         forClass:physicsBodyInstanceClass];
    
    [EPPZSwizzler synthesizeRetainedPropertyNamed:@"radius"
                                   ofTypeEncoding:@encode(NSNumber)
                                         forClass:physicsBodyInstanceClass];
     
    // Only a getter for `path`.
    [EPPZSwizzler addInstanceMethod:@selector(path) toClass:physicsBodyInstanceClass fromClass:self];
    
    // Add instance methods to `PKPhysicsBody`.
    [EPPZSwizzler addInstanceMethod:@selector(containsPoint:) toClass:physicsBodyInstanceClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(containsBody:) toClass:physicsBodyInstanceClass fromClass:self];
}


#pragma mark - Augment factories

+(SKPhysicsBody*)__bodyWithCircleOfRadius:(CGFloat) radius
{
    SKCLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
    
    // May seem an endless loop, but it's not (method implementations get swapped on runtime).
    SKPhysicsBody *instance = [self __bodyWithCircleOfRadius:radius];
    instance.initializingPath = centeredCircleWithRadius(radius);
    instance.radius = @(radius);
    instance.pathType = SKPhysicsBodyPathTypeCircle;
    return instance;
}

+(SKPhysicsBody*)__bodyWithRectangleOfSize:(CGSize) size
{
    SKCLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
    
    // May seem an endless loop, but it's not (method implementations get swapped on runtime).
    SKPhysicsBody *instance = [self __bodyWithRectangleOfSize:size];
    instance.initializingPath = centeredPathFromPath(CGPathCreateWithRect((CGRect){CGPointZero, size}, NULL));
    instance.pathType = SKPhysicsBodyPathTypePath;
    return instance;
}

+(SKPhysicsBody*)__bodyWithPolygonFromPath:(CGPathRef) path
{
    SKCLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
    
    // May seem an endless loop, but it's not (method implementations get swapped on runtime).
    SKPhysicsBody *instance = [self __bodyWithPolygonFromPath:path];
    instance.initializingPath = path;
    instance.pathType = SKPhysicsBodyPathTypePath;
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

    // Test path-path, circle-path.
    if (
        (self.pathType == SKPhysicsBodyPathTypePath && body.pathType == SKPhysicsBodyPathTypePath) ||
        (self.pathType == SKPhysicsBodyPathTypeCircle && body.pathType == SKPhysicsBodyPathTypePath)
       )
    {
        SKCLog(@"SKPhysicsBody containsBody path against path test (point by point).");
        
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
    
    // Test circle-circle.
    if (self.pathType == SKPhysicsBodyPathTypeCircle && body.pathType == SKPhysicsBodyPathTypeCircle)
    {
        // Size test.
        if (self.radius.floatValue < body.radius.floatValue) return NO;
        
        // Radius test.
        CGFloat maximumDistance = self.radius.floatValue - body.radius.floatValue;
        CGFloat distance = __distanceBetweenPoints(self.node.position, body.node.position);
        BOOL contained = (distance < maximumDistance);
        return contained;
    }
    
    // Test path-circle.
    if (self.pathType == SKPhysicsBodyPathTypePath && body.pathType == SKPhysicsBodyPathTypeCircle)
    {
        // Test bounding box containment first.
        BOOL boundingBoxTest;
        CGRect bounds = CGPathGetBoundingBox(self.path);
        CGRect bodyBounds = CGPathGetBoundingBox(body.path);
        boundingBoxTest = CGRectContainsRect(bounds, bodyBounds);
        if (boundingBoxTest == NO) return NO;
        
        // Test bounding box point containment then.
        return YES;
        
        // So test for circle edge distances.
    }
    
    return NO;
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


#pragma mark - Guest methods from EPPZGeometry

CGVector __vectorBetweenPoints(CGPoint from, CGPoint to)
{ return (CGVector){to.x - from.x, to.y - from.y}; }

CGFloat __distanceBetweenPoints(CGPoint from, CGPoint to)
{
    CGVector vector = __vectorBetweenPoints(from, to);
    return sqrtf(powf(vector.dx, 2) + powf(vector.dy, 2));
}

CGFloat __distanceBetweenPointAndLineSegment(CGPoint point, CGLine line)
{
    // From http://www.allegro.cc/forums/thread/589720/644831
    CGFloat a = point.x - line.a.x;
    CGFloat b = point.y - line.a.y;
    CGFloat c = line.b.x - line.a.x;
    CGFloat d = line.b.y - line.a.y;
    
    CGFloat e = a * c + b * d;
    CGFloat f = c * c + d * d;
    CGFloat test = e / f;
    
    CGPoint testPoint;
    
    if(test < 0.0)
    { testPoint = line.a; }
    
    else if (test > 1.0)
    { testPoint = line.b; }
    
    else
    {
        testPoint = (CGPoint){
            line.a.x + test * c,
            line.a.y + test * d
        };
    }
    
    return __distanceBetweenPoints(point, testPoint);
}

