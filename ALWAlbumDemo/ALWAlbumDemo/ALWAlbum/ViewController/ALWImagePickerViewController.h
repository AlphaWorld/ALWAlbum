//
//  ALWImagePickerViewController.h
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, ALWImagePickerSelectType) {
    ALWImagePickerSelectTypeSingle = 0, // 单张选择
    ALWImagePickerSelectTypeMulti , // 多张
};

@class ALWImagePickerViewController;
@protocol ImagePickerViewControllerDelegate <NSObject>

/**
 *  点击确定的回调
 *
 *  @param assetArray 选中的照片的数组
 */
- (void)imagePickerViewController:(ALWImagePickerViewController *)imageViewController didFinishSelected:(NSArray *)assetArray;

/**
 *  点击第一张图片（照相机）的回调
 *
 *  @param image 拍照的image
 */
- (void)imagePickerViewController:(ALWImagePickerViewController *)iamgeViewController didSelectCamera:(UIImage *)image;

@end

@interface ALWImagePickerViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) NSInteger maxSelectImageCount;
@property (nonatomic, assign) ALWImagePickerSelectType selectType;
@property (nonatomic, assign) id<ImagePickerViewControllerDelegate> delegate;

- (void)didFinished;
- (void)reloadData;


@end
