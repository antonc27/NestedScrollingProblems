//
//  MainViewController.m
//  NestedScrollingProblems
//
//  Created by AC27 on 17/05/17.
//  Copyright © 2017 AC27. All rights reserved.
//

#import "MainViewController.h"
#import "ShowImageViewController.h"
#import "ImageItem.h"

#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)showNormalImages:(id)sender
{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    for (int i=1; i<=5; i++)
    {
        NSString *name = [NSString stringWithFormat:@"image_normal_%d", i];
        CGSize size = (i == 3) ? CGSizeMake(1890, 1400) : CGSizeMake(935, 1400);
        ImageItem *normalImageItem = [self makeImageInfoForPlaceholderName:name size:size type:@"png"];
        normalImageItem.index = i;
        [imagesArray addObject:normalImageItem];
    }
    
    [self showImagesWithImagesArray:imagesArray];
}

- (IBAction)showBigImages:(id)sender {
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    for (int i=1; i<=3; i++)
    {
        NSString *name = [NSString stringWithFormat:@"image_big_%d", i];
        CGSize size;
        switch (i)
        {
            case 1:
                size = CGSizeMake(690, 8280);
                break;
                
            case 2:
                size = CGSizeMake(690, 6348);
                break;
                
            case 3:
                size = CGSizeMake(690, 14300);
                break;
        }
        ImageItem *normalImageItem = [self makeImageInfoForPlaceholderName:name size:size type:@"jpg"];
        normalImageItem.index = i;
        [imagesArray addObject:normalImageItem];
    }
    
    [self showImagesWithImagesArray:imagesArray];
}


- (void)showImagesWithImagesArray:(NSMutableArray *)array
{
    NSString *nibName = @"";
    
    if (IS_IPHONE)
    {
        nibName = @"ShowImageViewController_iPhone";
    }
    else
    {
        nibName = @"ShowImageViewController_iPad";
    }
    
    ShowImageViewController *showImageVC = [[ShowImageViewController alloc] initWithNibName:nibName bundle:nil];
    
    showImageVC.localPagesInfoArray = array;
    
    [self.navigationController pushViewController:showImageVC animated:YES];
}

- (ImageItem *)makeImageInfoForPlaceholderName: (NSString*)name size:(CGSize)size type:(NSString *)type
{
    ImageItem *imageInfo = [[ImageItem alloc] init];
    imageInfo.path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    imageInfo.width = size.width;
    imageInfo.height = size.height;
    return imageInfo;
}

@end
