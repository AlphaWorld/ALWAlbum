//
//  ALWImagePickerTableViewCell.m
//  AlphaWorld
//
//  Created by John on 16/11/20.
//  Copyright © 2016年 AlphaWorld. All rights reserved.
//

#import "ALWImagePickerTableViewCell.h"

static NSString * const albumTableViewCellBorderColor = @"#D4D7DC";

@interface ALWImagePickerTableViewCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLbael;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation ALWImagePickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _snb_configSubViews];
        [self _snb_configConstraints];
    }
    return self;
}

- (void)_snb_configSubViews
{
    self.thumbnailImageView = [[UIImageView alloc] init];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setFont:[UIFont alw_font:ALWFontTypeRegular size:16]];
    [self.nameLabel setTextColor:[UIColor alw_colorFromHexString:ALW_COLOR_TITLE]];
    self.countLbael = [[UILabel alloc] init];
    [self.countLbael setFont:[UIFont alw_font:ALWFontTypeRegular size:16]];
    [self.countLbael setTextColor:[UIColor alw_colorFromHexString:ALW_COLOR_DESC]];
    self.arrowImageView = [[UIImageView alloc] init];
    [self.arrowImageView setImage:[UIImage imageNamed:@"album_icon_arrow"]];
    [self.contentView alw_addBorderViewAtEdges:UIRectEdgeBottom color:[UIColor alw_colorFromHexString:albumTableViewCellBorderColor]];
    [self.contentView addSubview:self.thumbnailImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.countLbael];
    [self.contentView addSubview:self.arrowImageView];
}

- (void)_snb_configConstraints
{
    [self.thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(17);
        make.width.height.equalTo(@(48));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.thumbnailImageView.mas_centerY).offset(-3);
        make.left.equalTo(self.thumbnailImageView.mas_right).offset(10);
    }];
    [self.countLbael mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(3);
    }];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-11);
    }];
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    self.thumbnailImageView.image = [UIImage imageWithCGImage:assetsGroup.posterImage];
    self.nameLabel.text = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.countLbael.text = [@([assetsGroup numberOfAssets]) stringValue];
}

@end
