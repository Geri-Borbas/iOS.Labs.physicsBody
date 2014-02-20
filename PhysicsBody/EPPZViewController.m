//
//  EPPZViewController.m
//  Categories
//
//  Created by Gardrobe on 2/19/14.
//  Copyright (c) 2014 eppz! development, LLC. All rights reserved.
//

#import "EPPZViewController.h"
#import "EPPZScene.h"

@implementation EPPZViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    [(SKView*)self.view presentScene:[EPPZScene sceneWithSize:self.view.bounds.size]];
}


@end
