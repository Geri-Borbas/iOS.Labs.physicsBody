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

+(void)swapClassMethod:(SEL) oneSelector
       withClassMethod:(SEL) otherSelector
               ofClass:(Class) class;

+(void)replaceClassMethod:(SEL) selector
                  ofClass:(Class) targetClass
                fromClass:(Class) sourceClass;

+(void)addClassMethod:(SEL) selector
              toClass:(Class) targetClass
            fromClass:(Class) sourceClass;

+(void)addInstanceMethod:(SEL) selector
                 toClass:(Class) targetClass
               fromClass:(Class) sourceClass;

@end
