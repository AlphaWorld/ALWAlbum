//
//  ALWImageShowViewItemCell.m
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import "ALWImageShowViewItemCell.h"

#define DeviceOrientationKey @"DeviceOrientationKey"

@interface ALWImageShowViewItemCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;

@end

@implementation ALWImageShowViewItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _snb_configSubViews];
        [self _snb_configConstraints];
    }
    return self;
}

- (void)_snb_configSubViews
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.bouncesZoom = YES;
    self.scrollView.frame = CGRectMake(0, 0, self.width, self.height);
    self.scrollView.maximumZoomScale = 2.5;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.canCancelContentTouches = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.imageView.layer.masksToBounds = YES;
    self.imageContainerView = [[UIView alloc] init];
    self.imageContainerView.clipsToBounds = YES;
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    self.imageView.clipsToBounds = YES;
    
    [self addSubview:_scrollView];
    [self.scrollView addSubview:self.imageContainerView];
    [self.contentView addSubview:self.scrollView];
    [self.imageContainerView addSubview:self.imageView];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_snb_singleTap:)];
    [self addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_snb_doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
}

- (void)_snb_configConstraints
{
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView);
        make.right.bottom.equalTo(self.contentView);
    }];
}

- (void)setImage:(UIImage *)image
{
    [self.scrollView setZoomScale:1.0 animated:NO];
    self.imageView.image = image;
    [self _snb_resizeSubviews];
}

- (void)_snb_resizeSubviews {
    self.imageContainerView.origin = CGPointZero;
    self.imageContainerView.width = self.scrollView.width;
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.height / self.scrollView.width) {
        self.imageContainerView.height = floor(image.size.height / (image.size.width / self.scrollView.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        self.imageContainerView.height = height;
        self.imageContainerView.centerY = self.height / 2;
    }
    if (self.imageContainerView.height > self.height && self.imageContainerView.height - self.height <= 1) {
        self.imageContainerView.height = self.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, MAX(self.imageContainerView.height, self.height));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.imageContainerView.height <= self.height ? NO : YES;
    self.imageView.frame = self.imageContainerView.bounds;
}

#pragma mark - UITapGestureRecognizer Event

- (void)_snb_doubleTap:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)_snb_singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark--UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}


@end
