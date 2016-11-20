//
//  ALWImagePickerViewController.m
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import "ALWImagePickerViewController.h"
#import "ALWImagePickerTableViewCell.h"
#import "ALWAlbumImageShowViewController.h"
#import <Photos/Photos.h>
#import "UIView+ALWAlbumAnimation.h"
#import "ALWAlbumItemCell.h"

#define TabelViewCellHeight 78

static NSString * const pickerBottomViewButtonColorDisabled = @"#B7BBC2";
static NSString * const pickerBottomViewButtonColorAble = @"#3B7EEE";
static NSString * const albumLimitsAlertMessage = @"雪球没有权限访问您的相册。您可以在系统「设置」->「隐私」->「照片」中开启权限";
static NSString * const cameraLimitsAlertMessage = @"雪球没有权限访问您的相机。您可以在系统「设置」->「隐私」->「相机」中开启权限";

@interface ALWImagePickerViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *choseButton;
@property (nonatomic, strong) NSMutableArray *selectAssetArray;
@property (nonatomic, strong) NSMutableArray *imageAssetArray;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *titleTableView;
@property (nonatomic, strong) UIView *titleTableBackgroundView;
@property (nonatomic, strong) UIImageView *titleViewImageView;
@property (nonatomic, assign) BOOL isShowingTableView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *finishButton;

@end

@implementation ALWImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _snb_configNavigationBar];
    [self _snb_configSubViews];
    [self _snb_configConstraints];
    [self _snb_configTitleView];
    [self _snb_configContent];
}

- (void)_snb_dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
        @weakify(self);
        [PSAlertView alertMessage:albumLimitsAlertMessage controller:self action:^{
            @strongify_return_if_nil(self);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        return;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)_snb_configContent
{
    self.selectAssetArray = [NSMutableArray array];
    self.imageAssetArray = [NSMutableArray array];
    [self _snb_getAlbumList];
}

- (void)_snb_configNavigationBar
{
    UIButton *dismissBtn =
    [self getLeftNavButton:self action:@selector(_snb_dismiss) title:@"取消"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dismissBtn];
}

- (void)_snb_configSubViews
{
    self.view.backgroundColor = [UIColor alw_colorFromHexString:ALW_COLOR_WHITE];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    NSInteger width = (SCREEN_WIDTH - 4) / 3;
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[ALWAlbumItemCell class] forCellWithReuseIdentifier:NSStringFromClass([ALWAlbumItemCell class])];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollEnabled = YES;
    self.choseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor alw_colorFromHexString:ALW_COLOR_WHITE];
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor alw_colorFromHexString:pickerBottomViewButtonColorAble] forState:UIControlStateSelected];
        [_finishButton setTitleColor:[UIColor alw_colorFromHexString:pickerBottomViewButtonColorDisabled] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor alw_colorFromHexString:pickerBottomViewButtonColorAble] forState:UIControlStateSelected];
        [_previewButton setTitleColor:[UIColor alw_colorFromHexString:pickerBottomViewButtonColorDisabled] forState:UIControlStateNormal];
        [_bottomView addSubview:_previewButton];
        @weakify(self);
        [[_previewButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self _snb_goToPreviewView];
        }];
        [_bottomView addSubview:_finishButton];
        [[_finishButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify_return_if_nil(self);
            [self didFinished];
        }];
        [self _snb_updateBottomViewButtonState];
    }
    return _bottomView;
}

- (void)_snb_goToPreviewView
{
    ALWAlbumImageShowViewController *vc = [[ALWAlbumImageShowViewController alloc] init];
    vc.imageAssetArray = self.selectAssetArray;
    vc.selectAssetArray = self.selectAssetArray;
    vc.currentIndex = 1;
    vc.selectType = self.selectType;
    vc.pickerViewController = self;
    [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didFinished
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(imagePickerViewController:didFinishSelected:)])
        {
            [self.delegate imagePickerViewController:self didFinishSelected:self.selectAssetArray];
        }
    }];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)_snb_updateBottomViewButtonState
{
    BOOL hasSelectImage = self.selectAssetArray.count > 0;
    [self.previewButton setSelected:hasSelectImage];
    [self.finishButton setSelected:hasSelectImage];
    [self.previewButton setEnabled:hasSelectImage];
    [self.finishButton setEnabled:hasSelectImage];
}

- (void)_snb_configConstraints
{
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.equalTo(@(50));
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    [self.previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.left.equalTo(self.bottomView).offset(20);
    }];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.right.equalTo(self.bottomView).offset(-20);
    }];
}

- (void)_snb_configTitleView
{
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel setFont:[UIFont alw_font:ALWFontTypeMedium size:18]];
    self.titleLabel.textColor = [UIColor alw_colorFromHexString:ALW_COLOR_WHITE];
    [self.titleView addSubview:self.titleLabel];
    self.titleViewImageView = [[UIImageView alloc] init];
    self.titleViewImageView.image = [UIImage imageNamed:@"album_nav_icon_arrow_down"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_snb_titleTapAction)];
    [self.titleView addGestureRecognizer:tap];
    self.navigationItem.titleView = self.titleView;
    self.titleTableBackgroundView = [[UIView alloc] init];
    self.titleTableBackgroundView.backgroundColor = [UIColor whiteColor];
    self.titleTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.titleTableView.delegate = self;
    self.titleTableView.dataSource  = self;
    self.titleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.titleTableView.backgroundColor = [UIColor alw_colorFromHexString:ALW_COLOR_WHITE];
    [self.titleView addSubview:self.titleViewImageView];
    [self.view addSubview:self.titleTableBackgroundView];
    [self.titleTableBackgroundView addSubview:self.titleTableView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.titleView);
        make.bottom.equalTo(self.titleView).offset(-10);
    }];
    [self.titleViewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(4);
        make.centerY.equalTo(self.titleLabel);
    }];
    [self.titleTableBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_top);
    }];
    [self.titleTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.titleTableBackgroundView);
    }];
}

- (void)_snb_titleTapAction
{
    if (self.isShowingTableView) {
        [self _snb_hideTableView];
    } else {
        [self _snb_showTableView];
    }
}

- (void)_snb_showTableView
{
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         self.titleTableBackgroundView.top = 0;
                         self.titleViewImageView.image = [UIImage imageNamed:@"album_nav_icon_arrow_up"];
                         self.isShowingTableView = YES;
                     }
                     completion:nil];
}

- (void)_snb_hideTableView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.titleTableBackgroundView.top = - SCREEN_HEIGHT;
        self.titleViewImageView.image = [UIImage imageNamed:@"album_nav_icon_arrow_down"];
        self.isShowingTableView = NO;
    }];
}

/**
 *  获取相册列表
 */
- (void)_snb_getAlbumList
{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.groupArray = [NSMutableArray array];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group) {
             if (![group numberOfAssets]) {
                 return ;
             }
             [self.titleTableView reloadData];
             [self.groupArray addObject:group];
             NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
             if ([self _snb_isCameraRollAlbum:groupName]) {
                 self.titleLabel.text = groupName;
                 [self.titleLabel sizeToFit];
                 [self getImageWithGroup:group name:groupName];
             }
             [self.titleTableView reloadData];
         }
     } failureBlock:^(NSError *error) {
         DLog(@"error:%@",error.localizedDescription);
     }];
}

/**
 *  根据相册获取下面的图片
 *
 *  @param group 相册分组
 *  @param name  分组名
 */
- (void)getImageWithGroup:(ALAssetsGroup *)group name:(NSString *)name
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //根据相册获取下面的图片
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if (name && ![name isEqualToString:groupName]) {
            return;
        }
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.imageAssetArray addObject:result];
            }
            if (index == group.numberOfAssets - 1) {
                self.imageAssetArray = [[[self.imageAssetArray reverseObjectEnumerator] allObjects] mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
        }];
    });
}

- (void)_snb_selectItemButton:(UIButton *)button
{
    NSInteger tag = button.tag;
    ALAsset *asset = self.imageAssetArray[tag - 1];
    switch (self.selectType) {
        case ALWImagePickerSelectTypeSingle:
        {
            button.selected = !button.selected;
            if (button.selected) {
                ALAsset *lastAsset = self.selectAssetArray.lastObject;
                NSIndexPath *index = [NSIndexPath indexPathForItem:[self.imageAssetArray indexOfObject:lastAsset] + 1 inSection:0];
                ALWAlbumItemCell *item = (ALWAlbumItemCell *)[self.collectionView cellForItemAtIndexPath:index];
                item.selectButton.selected = NO;
                [self.selectAssetArray removeAllObjects];
                [self.selectAssetArray addObject:asset];
            } else {
                if ([self.selectAssetArray containsObject:asset]) {
                    [self.selectAssetArray removeObject:asset];
                }
            }
        }
            break;
        case ALWImagePickerSelectTypeMulti:
        {
            if (self.selectAssetArray.count >= self.maxSelectImageCount) {
                // 弹出通知提示
                break;
            }
            button.selected = !button.selected;
            if (button.selected) {
                [self.selectAssetArray addObject:asset];
            } else {
                if ([self.selectAssetArray containsObject:asset]) {
                    [self.selectAssetArray removeObject:asset];
                }
            }
        }
            break;
        default:
            break;
    }
    if (button.selected) {
        [UIView alw_showOscillatoryAnimationWithLayer:button.layer];
    }
    [self _snb_updateBottomViewButtonState];
}

- (BOOL)_snb_isCameraRollAlbum:(NSString *)albumName
{
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALWImagePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ALWImagePickerTableViewCell class])];
    if (!cell) {
        cell = [[ALWImagePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([ALWImagePickerTableViewCell class])];
    }
    ALAssetsGroup *group = self.groupArray[self.groupArray.count - indexPath.row - 1];
    cell.assetsGroup = group;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectAssetArray removeAllObjects];
    ALAssetsGroup *group = self.groupArray[self.groupArray.count - indexPath.row - 1];
    self.titleLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    [self.titleLabel sizeToFit];
    [self.imageAssetArray removeAllObjects];
    [self getImageWithGroup:group name:self.titleLabel.text];
    [self _snb_hideTableView];
}

#pragma mark  UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageAssetArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALWAlbumItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ALWAlbumItemCell class]) forIndexPath:indexPath];
    if (indexPath.item == 0) {
        [cell.selectButton setHidden:YES];
        cell.imageView.image = [UIImage imageNamed:@"album_icon_camre"];
    } else {
        [cell.selectButton setHidden:NO];
        cell.selectButton.tag = indexPath.item;
        [cell.selectButton addTarget:self action:@selector(_snb_selectItemButton:) forControlEvents:UIControlEventTouchUpInside];
        ALAsset *asset = self.imageAssetArray[indexPath.row - 1];
        UIImage *image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        cell.imageView.image = image;
        if ([self.selectAssetArray containsObject:asset]) {
            cell.selectButton.selected = YES;
        } else {
            cell.selectButton.selected = NO;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)) {
            // 无权限 做一个友好的提示
            [PSAlertView alertMessage:cameraLimitsAlertMessage controller:self action:nil];
        } else if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            imagePicker.delegate = self;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else {
        //进入预览页面
        ALWAlbumImageShowViewController *vc = [[ALWAlbumImageShowViewController alloc] init];
        vc.imageAssetArray = self.imageAssetArray;
        vc.selectAssetArray = self.selectAssetArray;
        vc.currentIndex = indexPath.item;
        vc.selectType = self.selectType;
        vc.pickerViewController = self;
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark--UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
{
    UIImage *image = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[image CGImage]
                                  orientation:image.imageOrientation
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  if (error) {
                                      [PSAlertView alertMessage:albumLimitsAlertMessage controller:self];
                                  }
                              }];
    }
    // 需要dismiss两次,不然会有动画闪的问题(第一次dimiss picker， 第二次是self)
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(imagePickerViewController:didSelectCamera:)])
        {
            [self.delegate imagePickerViewController:self didSelectCamera:image];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
