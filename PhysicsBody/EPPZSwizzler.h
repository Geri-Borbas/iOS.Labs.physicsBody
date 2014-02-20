//
//  EPPZSwizzler.h
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


#define EPPZ_SWIZZLER_LOGGING YES
#define SWLog if (EPPZ_SWIZZLER_LOGGING) NSLog


@interface EPPZSwizzler : NSObject


/*!
 
 Swaps class method implementations.
 
 @param oneSelector A selector to swap its implementation.
 @param otherSelector Another selector to swap implementation with.
 @param class The class to operate on.
 
 */
+(void)swapClassMethod:(SEL) oneSelector
       withClassMethod:(SEL) otherSelector
               ofClass:(Class) class;


/*!
 
 Replace class method implementation with implementation
 picked from another class (for the same method). Does nothing
 if the method is not implemented already on the target class.
 
 @param selector Selector to replace in target class, and to look for in source class.
 @param targetClass Class to operate on.
 @param sourceClass Class the implementation is picked from.
 
 */
+(void)replaceClassMethod:(SEL) selector
                  ofClass:(Class) targetClass
                fromClass:(Class) sourceClass;


/*!
 
 Add class method implementation with implementation
 picked from another class (for the same method). Does
 nothing if the method already exist on the target class.
 
 @param selector Selector to replace in target class, and to look for in source class.
 @param targetClass Class to operate on.
 @param sourceClass Class the implementation is picked from.
 
 */
+(void)addClassMethod:(SEL) selector
              toClass:(Class) targetClass
            fromClass:(Class) sourceClass;


/*!
 
 Add instance method implementation with implementation
 picked from another class (for the same method). Does
 nothing if the method already exist on the target class.
 
 @param selector Selector to replace in target class, and to look for in source class.
 @param targetClass Class to operate on.
 @param sourceClass Class the implementation is picked from.
 
 */
+(void)addInstanceMethod:(SEL) selector
                 toClass:(Class) targetClass
               fromClass:(Class) sourceClass;


/*!
 
 Creates (synthesizes) a property for the given class with the
 given properties. Creates an assign association for the property.
 
 As it uses associated object API under the hood, you can only
 synthesize object properties.
 
 To preserve IDE consistency, you may define
 the property in the class interface, or in a category for class,
 then mark property as \@dynamic in the implementation (like
 Core Data NSManagedObject properties).
 
 @param propertyName Name for the property to be created.
 @param typeEncoding Type encoding for the property.
                     You can use \@encode compiler directive to let the compiler
                     create the type encoding for you. Examples: \@encode(UIView),
                     or \@encode(CGPathRef).
 @param targetClass Class to operate on.
 
 */
+(void)synthesizeAssignedPropertyNamed:(NSString*) propertyName
                        ofTypeEncoding:(const char*) typeEncoding
                              forClass:(Class) targetClass;


/*!
 
 Creates (synthesizes) a property for the given class with the
 given properties. Uses retain association for the property.
 
 As it uses associated object API under the hood, you can only
 synthesize object properties.
 
 To preserve IDE consistency, you may define
 the property in the class interface, or in a category for class,
 then mark property as \@dynamic in the implementation (like
 Core Data NSManagedObject properties).
 
 @param propertyName Name for the property to be created.
 @param typeEncoding Type encoding for the property.
 You can use \@encode compiler directive to let the compiler
 create the type encoding for you. Examples: \@encode(UIView),
 or \@encode(CGPathRef).
 @param targetClass Class to operate on.
 
 */
+(void)synthesizeRetainedPropertyNamed:(NSString*) propertyName
                        ofTypeEncoding:(const char*) typeEncoding
                              forClass:(Class) targetClass;


@end
