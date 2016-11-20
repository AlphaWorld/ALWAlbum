//
//  ALWAlbumImageShowViewController.h
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALWImagePickerViewController.h"

@interface ALWAlbumImageShowViewController : UIViewController

@property (nonatomic, copy) NSArray *imageAssetArray;
@property (nonatomic, strong) NSMutableArray *selectAssetArray;
@property (nonatomic, weak) ALWImagePickerViewController *pickerViewController;
@property (nonatomic, assign) ALWImagePickerSelectType selectType;
@property (nonatomic, assign) NSInteger currentIndex;

@end
