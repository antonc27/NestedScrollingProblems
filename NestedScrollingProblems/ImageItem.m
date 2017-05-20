//
//  MangaImageItem.m
//  NestedScrollingProblems
//
//  Created by Malmygin Anton on 12/08/13.
//  Copyright (c) 2013 AC27. All rights reserved.
//

#import "ImageItem.h"

@implementation ImageItem

- (id)init
{
    self = [super init];
    if (self)
    {
        self.path = @"";
        
        self.width = 0;
        self.height = 0;
        
        self.index = -1;
    }
    
    return self;
}

@end
