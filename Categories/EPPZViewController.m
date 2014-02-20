//
//  EPPZViewController.m
//  Categories
//
//  Created by Gardrobe on 2/19/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZViewController.h"
#import "EPPZMyScene.h"

@implementation EPPZViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    [(SKView*)self.view presentScene:[EPPZMyScene sceneWithSize:self.view.bounds.size]];
}


@end
