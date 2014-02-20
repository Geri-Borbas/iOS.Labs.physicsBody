//
//  SKPhysicsBody+Containment.h
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


#define SK_PHYSICS_BODY_CONTAINMENT_LOGGING YES
#define SKCLog if (SK_PHYSICS_BODY_CONTAINMENT_LOGGING) NSLog


// Swizzle implementations at runtime.
@interface EPPZSwizzler : NSObject

+(void)replaceClassMethod:(SEL) selector
                  ofClass:(Class) targetClass
                fromClass:(Class) sourceClass;

+(void)addInstanceMethod:(SEL) selector
                 toClass:(Class) targetClass
               fromClass:(Class) sourceClass;

+(void)addPropertyNamed:(NSString*) instanceVariableName
                toClass:(Class) targetClass
              fromClass:(Class) sourceClass;

@end


// Interface for the new features.
@interface SKPhysicsBody (Containment)

@property (nonatomic) CGPathRef initializingPath;
@property (nonatomic, readonly) CGPathRef path;
-(BOOL)containsBody:(SKPhysicsBody*) body;

@end


// Implementation for the new features.
@interface SKPhysicsBodyContainment : SKPhysicsBody

@property (nonatomic) CGPathRef initializingPath;
@property (nonatomic, readonly) CGPathRef path;
-(BOOL)containsBody:(SKPhysicsBody*) body;

@end
