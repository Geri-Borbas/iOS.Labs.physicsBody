`SKPhysicsBody+Containment`
---------------------------


A lovely category telling if an SKPhysicsBody is contained by another.


```Objective-C
BOOL putInto = [bodyA containsBody:bodyB];
```

Background
---

You cannot define category instance methods on `SKPhysicsBody`. You can, but will generate runtime exception. Class methods just invoked fine, but once you got an instance from one of the [`SKPhysicsBody` factory methods](https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKPhysicsBody_Ref/Reference/Reference.html), you'll get a [`PKPhysicsBody`](https://github.com/EthanArbuckle/IOS-7-Headers/blob/master/PrivateFrameworks/PhysicsKit.framework/PKPhysicsBody.h) instance, some internal part of `SpriteKit` seemingly much closer to `Box2D`. So implementing a category could be done via method swizzling, thatswhy you may find the implementation a bit overwhelmed at the first sight.

Having this category, every `SKPhysicsBody` have a `CGPath path` property that holds the `CGPath` representation of the body, created within [`SKPhysicsBody` factory methods](https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKPhysicsBody_Ref/Reference/Reference.html).

Soon I will implement containment test, now it is just a template.


Versions
---

* 0.0.1

    + `path` property gets populated upon creating
        + Swizzling works just fine

