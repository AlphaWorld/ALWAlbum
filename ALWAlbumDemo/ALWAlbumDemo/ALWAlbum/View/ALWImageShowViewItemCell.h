//
//  ALWImageShowViewItemCell.h
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALWImageShowViewItemCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^singleTapGestureBlock)();

@end
