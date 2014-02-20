//
//  EPPZSwizzler.m
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZSwizzler.h"


static char associationKeyKey;


@interface EPPZSwizzler ()

+(void)synthesizePropertyNamed:(NSString*) propertyName
                ofTypeEncoding:(const char*) typeEncoding
                      forClass:(Class) targetClass
                    withPolicy:(objc_AssociationPolicy) policy;

+(NSString*)setterMethodNameForPropertyName:(NSString*) propertyName;

@end


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

+(NSString*)setterMethodNameForPropertyName:(NSString*) propertyName
{
    // Checks.
    if (propertyName.length == 0) return propertyName;
    
    NSString *firstChar = [[propertyName substringToIndex:1] capitalizedString];
    NSString *rest = [propertyName substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:", firstChar, rest];
}

+(void)addPropertyNamed:(NSString*) propertyName
                toClass:(Class) targetClass
              fromClass:(Class) sourceClass
{
    // Get property.
    const char *name = propertyName.UTF8String;
    objc_property_t property = class_getProperty(sourceClass, name);
    unsigned int attributesCount = 0;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
    
    // Add (or replace) property.
    BOOL success = class_addProperty(targetClass, name, attributes, attributesCount);
    if (success == NO)
    { class_replaceProperty(targetClass, name, attributes, attributesCount); }

    SWLog(@"Added property `%@` of %@ to %@ with %@", propertyName, sourceClass, targetClass, (success) ? @"success" : @"error");
    
    // Add getter.
    [self addInstanceMethod:NSSelectorFromString(propertyName) toClass:targetClass fromClass:sourceClass];
    
    // Add setter.
    NSString *setterMethodName = [self setterMethodNameForPropertyName:propertyName];
    [self addInstanceMethod:NSSelectorFromString(setterMethodName) toClass:targetClass fromClass:sourceClass];
}

+(void)synthesizeAssignedPropertyNamed:(NSString*) propertyName
                        ofTypeEncoding:(const char*) typeEncoding
                              forClass:(Class) targetClass
{
    [self synthesizePropertyNamed:propertyName
                   ofTypeEncoding:typeEncoding
                         forClass:targetClass
                       withPolicy:OBJC_ASSOCIATION_ASSIGN];
}

+(void)synthesizeRetainedPropertyNamed:(NSString*) propertyName
                        ofTypeEncoding:(const char*) typeEncoding
                              forClass:(Class) targetClass
{
    [self synthesizePropertyNamed:propertyName
                   ofTypeEncoding:typeEncoding
                         forClass:targetClass
                       withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

+(void)synthesizePropertyNamed:(NSString*) propertyName
                ofTypeEncoding:(const char*) typeEncoding
                      forClass:(Class) targetClass
                    withPolicy:(objc_AssociationPolicy) policy
{
    // Associate the key for the property to the class itself.
    NSString *keyObject = [NSString stringWithFormat:@"%@Key", propertyName];
    void *key = (__bridge void*)keyObject;
    objc_setAssociatedObject(targetClass, &associationKeyKey, keyObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Getter implementation.
    IMP getterImplementation = imp_implementationWithBlock(^(id self)
    { return (id)objc_getAssociatedObject(self, key); });
       
    // Setter implementation.
    IMP setterImplementation = imp_implementationWithBlock(^(id self, id value)
    { objc_setAssociatedObject(self, key, value, policy); });
    
    // Add getter.
    BOOL success = class_addMethod(targetClass,
                                   NSSelectorFromString(propertyName),
                                   getterImplementation,
                                   typeEncoding);
    
    SWLog(@"Added synthesized getter `%@` to %@ with %@", propertyName, targetClass, (success) ? @"success" : @"error");
    
    // Add setter.
    NSString *setterMethodName = [self setterMethodNameForPropertyName:propertyName];
    success = class_addMethod(targetClass,
                              NSSelectorFromString(setterMethodName),
                              setterImplementation,
                              typeEncoding);
    
    SWLog(@"Added synthesized setter `%@` to %@ with %@", setterMethodName, targetClass, (success) ? @"success" : @"error");
}



@end
