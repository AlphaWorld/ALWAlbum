//
//  ALWAlbumImageShowViewController.m
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import "ALWAlbumImageShowViewController.h"
#import "UIView+ALWAlbumAnimation.h"
#import "ALWImageShowViewItemCell.h"

static NSString * const imageViewBackgroundColor = @"#3A3B3D";
static NSString * const bottomViewFinishButtonColor = @"#FFFFFF";
static NSString * const labelAbleColor = @"#FFFFFF";

@interface ALWAlbumImageShowViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *finishButton;

@end

@implementation ALWAlbumImageShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _snb_configSubViews];
    [self _snb_configConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //滚动到当前图片位置
    if (_currentIndex > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIndex - 1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    [self _snb_updatedTopViewAndBottomState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.pickerViewController reloadData];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)_snb_configSubViews
{
    self.topLabel = [[UILabel alloc] init];
    [self.topLabel setFont:[UIFont alw_font:ALWFontTypeMedium size:18]];
    [self.topLabel setTextColor:[UIColor alw_colorFromHexString:labelAbleColor]];
    self.topLabel.hidden = self.selectType == ALWImagePickerSelectTypeSingle;
    self.view.backgroundColor = [UIColor blackColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[ALWImageShowViewItemCell class] forCellWithReuseIdentifier:NSStringFromClass([ALWImageShowViewItemCell class])];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.topView addSubview:self.topLabel];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.topView];
}

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _topView.backgroundColor = [[UIColor alw_colorFromHexString:imageViewBackgroundColor] colorWithAlphaComponent:0.8];
        [_backButton setImage:[UIImage imageNamed:@"nav_icon_back"] forState:UIControlStateNormal];
        @weakify(self);
        [[_backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify_return_if_nil(self);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"album_icon_circle_large"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"album_icon_checkbox_large"] forState:UIControlStateSelected];
        [[_selectButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify_return_if_nil(self);
            [self _snb_selectCurrentImage];
        }];
        [_topView addSubview:_backButton];
        [_topView addSubview:_selectButton];
    }
    return _topView;
}

- (void)_snb_selectCurrentImage
{
    ALAsset *asset = self.imageAssetArray[self.currentIndex - 1];
    switch (self.selectType) {
        case ALWImagePickerSelectTypeSingle:
            self.selectButton.selected = !self.selectButton.selected;
            if (self.selectButton.selected) {
                [self.selectAssetArray removeAllObjects];
                [self.selectAssetArray addObject:asset];
            } else {
                [self.selectAssetArray removeObject:asset];
            }
            break;
        case ALWImagePickerSelectTypeMulti:
            if (self.selectAssetArray.count >= self.pickerViewController.maxSelectImageCount) {
                //  弹出相关提示
                break;
            }
            if (self.selectButton.selected) {
                [self.selectAssetArray addObject:asset];
            } else {
                [self.selectAssetArray removeObject:asset];
            }
            break;
    }
    if (self.selectButton.selected) {
        [UIView alw_showOscillatoryAnimationWithLayer:self.selectButton.layer];
    }
    [self _snb_updatedTopViewAndBottomState];
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [[UIColor alw_colorFromHexString:imageViewBackgroundColor] colorWithAlphaComponent:0.8];
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitleColor:[UIColor alw_colorFromHexString:bottomViewFinishButtonColor] forState:UIControlStateSelected];
        [_finishButton setTitleColor:[[UIColor alw_colorFromHexString:bottomViewFinishButtonColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
        [_bottomView addSubview:_finishButton];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        @weakify(self);
        [[_finishButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify_return_if_nil(self);
            [self.pickerViewController didFinished];
        }];
    }
    return _bottomView;
}

- (void)_snb_updatedTopViewAndBottomState
{
    self.finishButton.selected = self.selectAssetArray.count > 0;
    self.finishButton.enabled = self.selectAssetArray.count > 0;
    if (self.currentIndex >= 1 && self.imageAssetArray.count > self.currentIndex - 1) {
        ALAsset *asset = self.imageAssetArray[self.currentIndex - 1];
        self.selectButton.selected = [self.selectAssetArray containsObject:asset];
    }
    self.topLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentIndex, self.imageAssetArray.count];
}

- (void)_snb_configConstraints
{
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(64));
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(50));
    }];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(self.topView);
        make.width.height.equalTo(@(50));
    }];
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.right.equalTo(self.topView);
        make.width.height.equalTo(@(50));
    }];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.right.equalTo(self.bottomView).offset(-22);
    }];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.bottom.equalTo(self.topView).offset(-15);
    }];
}

- (void)setimageAssetArray:(NSMutableArray *)imageAssetArray
{
    _imageAssetArray = imageAssetArray;
    [self.collectionView reloadData];
}

#pragma mark  UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageAssetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALWImageShowViewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ALWImageShowViewItemCell class]) forIndexPath:indexPath];
    ALAsset *asset = self.imageAssetArray[indexPath.row];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:representation.fullResolutionImage];
    image = [UIImage imageWithCGImage:representation.fullResolutionImage scale:representation.scale orientation:representation.orientation];
    @weakify(self);
    [cell setSingleTapGestureBlock:^{
        @strongify_return_if_nil(self);
        self.bottomView.hidden = !self.bottomView.hidden;
        self.topView.hidden = !self.topView.hidden;
    }];
    cell.image = image;
    return cell;
}

#pragma mark--UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetWidth = scrollView.contentOffset.x;
    offsetWidth = offsetWidth +  ((self.view.width) * 0.5);
    NSInteger currentIndex = offsetWidth / (self.view.width) + 1;
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self _snb_updatedTopViewAndBottomState];
    }
}

@end
