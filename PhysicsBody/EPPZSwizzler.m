//
//  EPPZSwizzler.m
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZSwizzler.h"


@implementation EPPZSwizzler


+(void)swapClassMethod:(SEL) oneSelector
       withClassMethod:(SEL) otherSelector
               ofClass:(Class) class
{
    // Get methods.
    Method oneMethod = class_getClassMethod(class, oneSelector);
    Method otherMethod = class_getClassMethod(class, otherSelector);
    
    // Exchange.
    method_exchangeImplementations(oneMethod, otherMethod);
    
    SWLog(@"Exchanged method `%@` with `%@` in %@", NSStringFromSelector(oneSelector), NSStringFromSelector(otherSelector), class);
}

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
    
    SWLog(@"Added method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (previousTargetMethod) ? @"success" : @"error");
}

+(void)addClassMethod:(SEL) selector
              toClass:(Class) targetClass
            fromClass:(Class) sourceClass
{
    
    // Get methods.
    Method sourceMethod = class_getClassMethod(sourceClass, selector);
    
    targetClass = object_getClass((id)targetClass);
    BOOL success = class_addMethod(targetClass,
                                   selector,
                                   method_getImplementation(sourceMethod),
                                   method_getTypeEncoding(sourceMethod));
    
    SWLog(@"Added class method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (success) ? @"success" : @"error");
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
    
    SWLog(@"Added instance method `%@` of %@ to %@ with %@", NSStringFromSelector(selector), sourceClass, targetClass, (success) ? @"success" : @"error");
}


@end
