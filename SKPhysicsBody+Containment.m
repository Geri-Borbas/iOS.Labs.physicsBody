//
//  SKPhysicsBody+Containment.m
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "SKPhysicsBody+Containment.h"
#import <objc/runtime.h>


@implementation EPPZSwizzler


+(void)replaceClassMethod:(SEL) selector
                  ofClass:(Class) targetClass
                fromClass:(Class) sourceClass
{
    // Get methods.
    Method targetMethod = class_getClassMethod(targetClass, selector);
    Method sourceMethod = class_getClassMethod(sourceClass, selector);
    
    // Replace target method.
    IMP previousTargetMethod = method_setImplementation(targetMethod,
                                                        method_getImplementation(sourceMethod));
    
    SKCLog(@"Added method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (previousTargetMethod) ? @"success" : @"error");
    //if (previousTargetMethod == NO) exit(0);
}

+(void)addInstanceMethod:(SEL) selector
                 toClass:(Class) targetClass
               fromClass:(Class) sourceClass
{
    // Get method.
    Method method = class_getInstanceMethod(sourceClass, selector);
    
    // Add method.
    BOOL success = class_addMethod(targetClass,
                                   selector,
                                   method_getImplementation(method),
                                   method_getTypeEncoding(method));
    
    SKCLog(@"Added method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (success) ? @"success" : @"error");
    //if (success == NO) exit(0);
}

+(void)addPropertyNamed:(NSString*) propertyName
                toClass:(Class) targetClass
              fromClass:(Class) sourceClass
{
    // Get instance variable.
    objc_property_t property = class_getProperty(sourceClass, propertyName.UTF8String);
    unsigned int attributeCount;
    objc_property_attribute_t *propertyAttributes = property_copyAttributeList(property, &attributeCount);
    
    // Add instance variable.
    BOOL success = class_addProperty(targetClass,
                                     propertyName.UTF8String,
                                     propertyAttributes,
                                     attributeCount);
    
    SKCLog(@"Added property `%@` of %@ to %@ with %@", propertyName, sourceClass, targetClass, (success) ? @"success" : @"error");
    //if (success == NO) exit(0);
    
}


@end


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
    Class runtimePhysicsBodyClass = [SKPhysicsBody new].class;
    
    // Add class methods (from this class to `PKPhysicsBody`).
    //[EPPZSwizzler replaceClassMethod:@selector(bodyWithCircleOfRadius:) ofClass:runtimePhysicsBodyClass fromClass:self];
    //[EPPZSwizzler replaceClassMethod:@selector(bodyWithRectangleOfSize:) ofClass:runtimePhysicsBodyClass fromClass:self];
    //[EPPZSwizzler replaceClassMethod:@selector(bodyWithPolygonFromPath:) ofClass:runtimePhysicsBodyClass fromClass:self];
    
    // Add properties (from this class to `PKPhysicsBody`).
    [EPPZSwizzler addPropertyNamed:@"initializingPath" toClass:runtimePhysicsBodyClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(initializingPath) toClass:runtimePhysicsBodyClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(setInitializingPath:) toClass:runtimePhysicsBodyClass fromClass:self];
    [EPPZSwizzler addInstanceMethod:@selector(path) toClass:runtimePhysicsBodyClass fromClass:self];
    
    // Add instance methods (from this class to `PKPhysicsBody`).
    [EPPZSwizzler addInstanceMethod:@selector(containsBody:) toClass:runtimePhysicsBodyClass fromClass:self];
}


#pragma mark - Augment factories

+(SKPhysicsBody*)bodyWithCircleOfRadius:(CGFloat) radius
{
    SKPhysicsBody *instance = [super bodyWithCircleOfRadius:radius];
    instance.initializingPath = CGPathCreateWithEllipseInRect((CGRect){CGPointZero, radius * 2.0, radius * 2.0}, NULL);
    return instance;
}

+(SKPhysicsBody*)bodyWithRectangleOfSize:(CGSize) size
{
    SKPhysicsBody *instance = [super bodyWithRectangleOfSize:size];
    instance.initializingPath = CGPathCreateWithRect((CGRect){CGPointZero, size}, NULL);
    return instance;
}

+(SKPhysicsBody*)bodyWithPolygonFromPath:(CGPathRef) path
{
    SKPhysicsBody *instance = [super bodyWithPolygonFromPath:path];
    instance.initializingPath = path;
    return instance;
}



-(CGPathRef)path
{
    return self.initializingPath;
}

-(BOOL)containsBody:(SKPhysicsBody*) body
{ return NO; }


@end
