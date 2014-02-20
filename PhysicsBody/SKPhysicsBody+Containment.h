//
//  SKPhysicsBody+Containment.h
//  Categories
//
//  Created by Gardrobe on 2/20/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "EPPZSwizzler.h"


@interface SKPhysicsBody (Containment)

@property (nonatomic, readonly) CGPathRef path;

-(BOOL)containsPoint:(CGPoint) point;
-(BOOL)containsBody:(SKPhysicsBody*) body;

@end
