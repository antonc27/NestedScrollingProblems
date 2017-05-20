/*
     File: ImageScrollView.m
 Abstract: Centers image within the scroll view and configures image sizing and display.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#import "ImageScrollView.h"

@implementation ImageScrollView

@synthesize index, doubleTapBool;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.bouncesZoom = NO;
        self.bounces = NO;
        self.decelerationRate = UIScrollViewDecelerationRateNormal;
        self.delegate = self;        
    }
    return self;
}

#pragma mark -
#pragma mark Override layoutSubviews to center content

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen

    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self layoutSubviews];
}

#pragma mark -
#pragma mark Configure scrollView to display new image (tiled or not)

- (void)displayImageWithInfo:(ImageItem*)imageInfo
{
    CGSize imageSize = (CGSize){.width = imageInfo.width, .height = imageInfo.height};
    
    // clear the previous imageView
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    self.imageView = [[UIImageView alloc] initWithFrame:(CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size = imageSize}];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imageInfo.path];
    ((UIImageView*)self.imageView).image = image;
    [self addSubview:self.imageView];
    
    [self configureForImageSize:imageSize];
}

- (void)removeImageView
{
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}

- (void)configureForImageSize:(CGSize)imageSize 
{
    CGSize boundsSize = self.bounds.size;
                
    // set up our content size and min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    CGFloat maxScale = MAX(xScale, yScale);
    
    self.contentSize = imageSize;
    
    self.maximumZoomScale = 2.0 * maxScale;
    self.minimumZoomScale = minScale;
    
    [self setZoom];
}

- (void)setZoom
{
    if (self.doubleTapBool)
    {
        self.zoomScale = self.maximumZoomScale / 2.0;
        self.contentOffset = CGPointZero;
    }
    else
    {
        self.zoomScale = self.minimumZoomScale;
    }
}

- (void)setZoomScale:(CGFloat)zoomScale
{
    [super setZoomScale:zoomScale];
    [self fixContentSizeForScrollingIfNecessary];
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated
{
    [super zoomToRect:rect animated:animated];
    [self fixContentSizeForScrollingIfNecessary];
}

- (void)fixContentSizeForScrollingIfNecessary
{
    if (SYSTEM_VERSION_LESS_THAN(@"10.2"))
    {
        CGSize content = self.contentSize;
        content.width = rint(content.width);
        content.height = rint(content.height);
        self.contentSize = content;
    }
}

@end
