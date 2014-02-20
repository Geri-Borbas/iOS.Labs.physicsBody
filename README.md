`SKPhysicsBody+Containment`
---------------------------


A lovely category telling if an SKPhysicsBody is contained by another.


```Objective-C
BOOL putInto = [bodyA containsBody:bodyB];
```

What it does
------------

The category adds a really valuable readonly property for every `SKPhysicsBody called `path`.
This `CGPathRef` holds the `CGPath` representation of the currently transformed state for the
body (in the coordinate space of the containing node).

The rest is just the geometry to test containment actually, and some swizzling to live in peace
with `SpriteKit` runtime.


Under the hood
--------------

There is no API to enumerate CGPoints of a given CGPath. The category comes with some handy
helper function that does it for the category. Containment test now can go as the following.

```Objective-C
// Test for containment for each point of body.
__block BOOL everyPointContained = YES;
enumeratePointsOfPath(body.path, ^(CGPoint eachPoint)
{
    if (CGPathContainsPoint(path, NULL, eachPoint, NO) == NO)
    { everyPointContained = NO; }
});
```


Category on `SKPhysicsBody`
---------------------------

When you ask for an `SKPhysicsBody` instance from `SKPhysicsBody` class, you'd expect an
`SKPhysicsBody` object in return. According to some design decision at Apple, it will spit you
up a [`PKPhysicsBody`][1]instance (part of internal [PhysicsKit][2]), which of course won't have
any instance method from the category you made for `SKPhysicsBody`. Extending that class can be
carried out only via method / property swizzlings, so this issue put a weight on this `Containment`
category.

```Objective-C
// This is not what you'd expect.
SKPhysicsBody *body = [SKPhysicsBody bodyWithRectangleOfSize:size];
NSLog(@"%@", body.class)); // PKPhysicsBody
```

Another thing to consider, that class methods gonna stay in place. This is cool, but you cannot
swizzle every method automatically. Class methods implementations have to be added to `SKPhysicsBody`,
but instance methods have to be added to `PKPkysicsBody` (or whatever class that factories return).

```Objective-C
NSLog(@"%@", SKPhysicsBody.class); // SKPhysicsBody
```


Versions
---

* 0.0.2

    + Added containment geomery
        + Works with path-path intersections for now

* 0.0.1

    + `path` property gets populated upon creating
        + Swizzling works just fine
        
  [1]: https://github.com/JaviSoto/iOS7-Runtime-Headers/blob/master/PrivateFrameworks/PhysicsKit.framework/PKPhysicsBody.h
  [2]: https://github.com/EthanArbuckle/IOS-7-Headers/tree/master/PrivateFrameworks/PhysicsKit.framework

