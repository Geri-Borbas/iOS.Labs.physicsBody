//
//  EPPZMyScene.m
//  Categories
//
//  Created by Gardrobe on 2/19/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZScene.h"

@implementation EPPZScene


-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor lightGrayColor];
        SKPhysicsBody *body;
        SKPhysicsBody *buddy;
        
        CGFloat width = 60.0;
        CGRect rect = (CGRect){CGPointZero, width, width};
        CGPathRef path = CGPathCreateWithRect(rect, NULL);
        
        body = [SKPhysicsBody bodyWithCircleOfRadius:width / 4.0];
        NSLog(@"%.1f should 30.0", CGPathGetBoundingBox(body.path).size.width);
        body = [SKPhysicsBody bodyWithPolygonFromPath:path];
        NSLog(@"%i should 1", (body.path == path));
        body = [SKPhysicsBody bodyWithRectangleOfSize:rect.size];
        NSLog(@"%.1f should 60.0", CGPathGetBoundingBox(body.path).size.width);
        
        CGPathRef anotherPath = CGPathCreateWithRect(rect, NULL);
        buddy = [SKPhysicsBody bodyWithPolygonFromPath:anotherPath];
        NSLog(@"%i should 1", (buddy.path == anotherPath));
    }
    return self;
}


@end
