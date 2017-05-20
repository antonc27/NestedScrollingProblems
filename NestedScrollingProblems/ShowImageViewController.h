//
//  ShowMangaViewController.h
//  NestedScrollingProblems
//
//  Created by antonc27 on 30.08.12.
//  Copyright (c) 2012-2016 AC27. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowImageViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIScrollView *mainScrollView;
    
    IBOutlet UIToolbar *topBar;
    IBOutlet UIToolbar *bottomBar;

    IBOutlet UILabel *titleLabel;
    
    IBOutlet UISlider *imagesSlider;
    
    IBOutlet UILabel *numberOfImagesLabel;
    
    BOOL isBarsHidden;
    
    int currentImageIndex;
    
    BOOL doubleTapBool;
}

@property (nonatomic, strong) NSMutableArray *localPagesInfoArray;

@end
