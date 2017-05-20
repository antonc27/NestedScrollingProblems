//
//  ShowMangaViewController.m
//  NestedScrollingProblems
//
//  Created by antonc27 on 30.08.12.
//  Copyright (c) 2012-2016 AC27. All rights reserved.
//

#import "ShowImageViewController.h"
#import "ImageScrollView.h"
#import "ImageItem.h"

#define kDoubleTapBool @"doubleTapBool"

@interface ShowImageViewController ()
@end

@implementation ShowImageViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    isBarsHidden = YES;
    [self updateBarsVisibility];
    
    doubleTapBool = [[NSUserDefaults standardUserDefaults] boolForKey:kDoubleTapBool];
    
    [self registerForGestureRecognizerActions];
    
    titleLabel.text = @"Title";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadImages];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - Status bar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -

- (void)setCorrectCurrentImageIndex
{
    currentImageIndex = 1;
}

- (void)setupImages
{
    imagesSlider.minimumValue = 1;
    imagesSlider.maximumValue = self.self.localPagesInfoArray.count;
    
    numberOfImagesLabel.text = [NSString stringWithFormat:@"%d", (int)self.self.localPagesInfoArray.count];
    
    [self setCorrectCurrentImageIndex];
    
    imagesSlider.value = currentImageIndex;
    
    [self setupMainScrollViewWithArray:self.localPagesInfoArray];
    
    [self loadPageAndSiblingsForIndex:currentImageIndex withArray:self.localPagesInfoArray];
}

#pragma mark - Manage taps

- (void)registerForGestureRecognizerActions
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.delegate = self;
    [mainScrollView addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    doubleTapRecognizer.delegate = self;
    [mainScrollView addGestureRecognizer:doubleTapRecognizer];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
}

- (void)singleTapAction:(UITapGestureRecognizer *)sender
{
    isBarsHidden = !isBarsHidden;
    [self updateBarsVisibility];
}

- (void)updateBarsVisibility
{
    topBar.hidden = isBarsHidden;
    bottomBar.hidden = isBarsHidden;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)sender
{
    doubleTapBool = !doubleTapBool;
    
    for (ImageScrollView *imageView in mainScrollView.subviews)
    {
        if ([imageView isKindOfClass:[ImageScrollView class]])
        {
            imageView.doubleTapBool = doubleTapBool;
        }
    }
    
    int minIndex = (currentImageIndex - 1 > 0) ? currentImageIndex-1 : currentImageIndex;
    int maxIndex = (currentImageIndex + 1 < self.localPagesInfoArray.count) ? currentImageIndex+1 : currentImageIndex;
    for (int i = minIndex; i <= maxIndex; i++)
    {
        UIView *guessedImageView = [mainScrollView viewWithTag:i];
        
        if ([guessedImageView isKindOfClass:[ImageScrollView class]])
        {
            ImageScrollView *imageView = (ImageScrollView *)guessedImageView;
            
            if (i == currentImageIndex)
            {
                CGFloat newScale = doubleTapBool ? imageView.maximumZoomScale/2.0 : imageView.minimumZoomScale;
                
                CGRect zoomRect = [self zoomRectForScrollView:imageView forScale:newScale withCenter:[sender locationInView:imageView.imageView]];
                [imageView zoomToRect:zoomRect animated:YES];
            }
            else
            {
                [imageView setZoom];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:doubleTapBool forKey:kDoubleTapBool];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CGRect)zoomRectForScrollView: (UIScrollView*)imageScrollView forScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView bounds].size.height / scale;
    zoomRect.size.width  = [imageScrollView bounds].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)clearMainScrollView
{
    for(UIScrollView* scrlView in [mainScrollView.subviews copy])
    {
        if ([scrlView isKindOfClass:[UIScrollView class]])
        {
            [scrlView removeFromSuperview];
        }
    }
}

#pragma mark - Manage buttons

- (IBAction)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Manage slider

- (IBAction)sliderChanged:(id)sender
{
    int sliderValue = roundf(imagesSlider.value);
    [imagesSlider setValue:sliderValue animated:YES];
    
    NSLog(@"slider value - %d", sliderValue);
    NSLog(@"current index value - %d", currentImageIndex);

    int realIndex = currentImageIndex;
    
    if (sliderValue != realIndex)
    {
        int minIndex = (currentImageIndex - 1 > 0) ? currentImageIndex-1 : currentImageIndex;
        int maxIndex = (currentImageIndex + 1 < self.localPagesInfoArray.count) ? currentImageIndex+1 : currentImageIndex;
        for (int i = minIndex; i <= maxIndex; i++)
        {
            UIView *imageView = [mainScrollView viewWithTag:i];
            
            if ([imageView isKindOfClass:[ImageScrollView class]])
            {
                [(ImageScrollView *)imageView removeImageView];
            }
        }
        
        int newIndex = sliderValue;
        currentImageIndex = newIndex;
        mainScrollView.contentOffset = (CGPoint){.x = (currentImageIndex-1)*self.view.frame.size.width, .y = 0.0f};
        
        [self loadPageAndSiblingsForIndex:currentImageIndex withArray:self.localPagesInfoArray];
        
        if (newIndex+1 == self.localPagesInfoArray.count)
        {
            [self loadPageForIndex:newIndex+1 withInfo:[self.localPagesInfoArray lastObject]];
        }
    }
}

#pragma mark -

- (void)reloadImages
{
    [self clearMainScrollView];
    [self setupImages];
}

#pragma mark - Setuping scroll view

- (void)setupMainScrollViewWithArray: (NSArray*)arr
{
    NSLog(@"frame height %f, width %f", self.view.frame.size.height, self.view.frame.size.width);
    NSLog(@"scroll view height %f, width %f", mainScrollView.frame.size.height, mainScrollView.frame.size.width);
    
    mainScrollView.contentSize = (CGSize){.width = self.view.frame.size.width * [arr count], .height = self.view.frame.size.height};
    
    NSLog(@"current image index - %d", currentImageIndex);
    
    mainScrollView.contentOffset = (CGPoint){.x = (currentImageIndex-1)*self.view.frame.size.width, .y = 0.0f};
    
    mainScrollView.pagingEnabled = YES;
    mainScrollView.directionalLockEnabled = YES;
    
    for (int i = 0; i < arr.count; i++)
    {
        ImageScrollView *scrollView = [[ImageScrollView alloc] initWithFrame:(CGRect){.origin.x = self.view.frame.size.width * i, .origin.y = 0.0f, .size.width = self.view.frame.size.width, .size.height = self.view.frame.size.height}];
        
        [scrollView setTag:i+1];
        
        scrollView.doubleTapBool = doubleTapBool;
        
        [mainScrollView addSubview:scrollView];
    }
}

- (void)refineMainScrollViewWithArray: (NSArray*)arr
{
    mainScrollView.contentSize = (CGSize){.width = self.view.frame.size.width * [arr count], .height = self.view.frame.size.height};
    
    for (int i = 0; i < arr.count; i++)
    {
        ImageScrollView *imageView = (ImageScrollView *)[mainScrollView viewWithTag:i+1];
        
        imageView.frame = (CGRect){.origin.x = self.view.frame.size.width * i, .origin.y = 0.0f, .size.width = self.view.frame.size.width, .size.height = self.view.frame.size.height};
        
        ImageItem *imageInfo = arr[i];
        CGSize imageSize = (CGSize){.width = imageInfo.width, .height = imageInfo.height};
        [imageView configureForImageSize:imageSize];
    }
    
    mainScrollView.contentOffset = (CGPoint){.x = (currentImageIndex-1)*self.view.frame.size.width, .y = 0.0f};
}

- (void)loadPageAndSiblingsForIndex: (NSUInteger)index withArray: (NSArray*)arr
{
    if ( !([arr count] > 0) )
    {
        return;
    }
    
    if (index - 1 > 0)
    {
        //load prev page
        [self loadPageForIndex:index-1 withInfo:arr[index-2]];
    }
    
    //load current page
    [self loadPageForIndex:index withInfo:arr[index-1]];
    
    if (index + 1 < arr.count)
    {
        //load next page
        [self loadPageForIndex:index+1 withInfo:arr[index]];
    }
}

- (void)loadPageForIndex: (NSUInteger)index withInfo: (ImageItem*)imageInfo
{
    UIView *imageView = [mainScrollView viewWithTag:index];
    
    if ([imageView isKindOfClass:[ImageScrollView class]])
    {
        [(ImageScrollView *)imageView displayImageWithInfo:imageInfo];
    }
}

- (void)unloadPageForIndex: (NSUInteger)index
{
    UIView *imageView = [mainScrollView viewWithTag:index];
    
    if ([imageView isKindOfClass:[ImageScrollView class]])
    {
        [(ImageScrollView *)imageView removeImageView];
    }
}

#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage) + 1;
    
    if (currentImageIndex != page)
    {
        // Page has changed
        
        if (page > currentImageIndex)
        {
            if (currentImageIndex-1 > 0)
            {
                [self unloadPageForIndex:currentImageIndex-1];
            }
            
            if (currentImageIndex+2 <= self.localPagesInfoArray.count)
            {
                [self loadPageForIndex:currentImageIndex+2 withInfo:[self.localPagesInfoArray objectAtIndex:currentImageIndex+1]];
            }

        }
        else if (page < currentImageIndex)
        {
            if (currentImageIndex+1 < self.localPagesInfoArray.count)
            {
                [self unloadPageForIndex:currentImageIndex+1];
            }
            
            if (currentImageIndex-2 > 0)
            {
                [self loadPageForIndex:currentImageIndex-2 withInfo:[self.localPagesInfoArray objectAtIndex:currentImageIndex-3]];
            }
        }
        
        if ( !(mainScrollView.contentOffset.x == 0.0 && false) &&
             !( ((mainScrollView.contentOffset.x == self.view.frame.size.width * (self.localPagesInfoArray.count-1)) || (page == self.localPagesInfoArray.count)) && (false)) )
        {
            currentImageIndex = (int)page;
            
            imagesSlider.value = currentImageIndex;
        }
    }
}

#pragma mark - AutoRotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self refineMainScrollViewWithArray:self.localPagesInfoArray];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
