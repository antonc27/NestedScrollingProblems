//
//  MangaImageItem.h
//  NestedScrollingProblems
//
//  Created by Malmygin Anton on 12/08/13.
//  Copyright (c) 2013 AC27. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageItem : NSObject

@property (nonatomic, strong) NSString *path;

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

@property (nonatomic, assign) int index;

@end
