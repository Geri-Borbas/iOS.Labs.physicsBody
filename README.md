`SKPhysicsBody+Containment`
---------------------------


A lovely category telling if a volume-based SKPhysicsBody is contained by another.


```Objective-C
BOOL putInto = [bodyA containsBody:bodyB];
```

What it does
------------

The category adds a really valuable **readonly property for every `SKPhysicsBody` called `path`**.
This `CGPathRef` holds the `CGPath` representation of the currently transformed state for the
body (in the coordinate space of the containing node).

The rest is just the geometry to test containment actually, and some swizzling to live in peace
with `SpriteKit` runtime.


Under the hood
--------------

There is no API to **enumerate `CGPoints` of a given `CGPath`**. The category comes with some handy
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

Another issue is to **store the initial `CGPath` representation** of the body upon creation. This initial
path can be transformed later on when it requested. This code should take place in the `SKPhysicsBody`
factory methods. Calling the default behaviour can be tricky (it could be a simple `super` call if we were
extending the class).

Solution is to "save" the default SKPhysicsBody factory implementations, then **override the factories**,
and call the default behaviour from within somewhere.

For `+(SKPhysicsBody*)bodyWithCircleOfRadius:` it means that you create an implementation that is to
be override `+(SKPhysicsBody*)bodyWithCircleOfRadius:` implementation, while you save the original
implementation into a method, called `+(SKPhysicsBody*)__bodyWithCircleOfRadius:` in this case. See 
his in action in [`SKPhysicsBody+Containment`][3] searching for `Augment factories`.


Category on `SKPhysicsBody`
---------------------------

When you ask for an `SKPhysicsBody` instance from `SKPhysicsBody` class, you'd expect an
`SKPhysicsBody` object in return. According to some design decision at Apple, **it will spit you
up a [`PKPhysicsBody`][1] instance** (part of internal [PhysicsKit][2]), which of course won't have
any instance method from the category you made for `SKPhysicsBody`. Extending that class can be
carried out only via method / property **swizzlings**, so this issue put a weight on this category.

```Objective-C
// This is not what you'd expect.
SKPhysicsBody *body = [SKPhysicsBody bodyWithRectangleOfSize:size];
NSLog(@"%@", body.class)); // PKPhysicsBody
```

Another thing to consider, that **class methods gonna stay in place**. This is cool, but you cannot
swizzle every method automatically. Class methods implementations have to be added to `SKPhysicsBody`,
but instance methods have to be added to `PKPkysicsBody` (or whatever class that factories return at
runtime).

```Objective-C
NSLog(@"%@", SKPhysicsBody.class); // SKPhysicsBody
```

So for the solution, I created a standalone **class `SKPhysicsBodyContainment` that holds all the
implementation** that needs to be swizzled around. Then upon the `+(void)load` of this class, I distribute
the implementations to the parties discussed above.


`EPPZSwizzler`
--------------

It actually wraps up the swizzling methods into an Objective-C interface, gonna put it into [eppz!kit][4]
soon, hence the class prefix.


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
  [3]: https://github.com/eppz/labs-physicsBody/blob/master/PhysicsBody/SKPhysicsBody%2BContainment.m
  [4]: https://github.com/eppz/eppz-kit

