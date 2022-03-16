//
//  DVVSegmentedCell.m
//  DVVSegmentedView
//
//  Created by David on 2022/2/24.
//

#import "DVVSegmentedCell.h"
#import "PureLayout.h"
#import "DVVGradientView.h"

NSString * const DVVSegmentedCellRID = @"DVVSegmentedCell";

@interface DVVSegmentedCell ()

@property (nonatomic, strong) DVVGradientView *selectedBackgroundGradientView;
@property (nonatomic, assign) BOOL didAddSelectedBackgroundGradientView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIView *redDotView;

@property (nonatomic, readwrite, weak) DVVSegmentedModel *model;

@property (nonatomic, weak) NSLayoutConstraint *titleLabelAxisVerticalConstraint;

@property (nonatomic, weak) NSLayoutConstraint *badgeLabelWidthConstraint;
@property (nonatomic, weak) NSLayoutConstraint *badgeLabelHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *badgeLabelRightConstraint;

@end

@implementation DVVSegmentedCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.redDotView];
        [self.contentView addSubview:self.badgeLabel];
        [self.contentView addSubview:self.sepLineView];
        
        _titleLabelAxisVerticalConstraint = [self.titleLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.titleLabel.superview withOffset:0];
        [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.titleLabel setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
        [self.titleLabel setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisVertical];
        
        CGFloat redDotW = 5;
        CGFloat redDotH = redDotW;
        self.redDotView.layer.masksToBounds = YES;
        self.redDotView.layer.cornerRadius = redDotW/2.0;
        [self.redDotView autoSetDimensionsToSize:CGSizeMake(redDotW, redDotH)];
        [self.redDotView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.titleLabel withOffset:-redDotW/2.0];
        [self.redDotView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel withOffset:redDotH/2.0];
        
        CGFloat badgeW = 15;
        CGFloat badgeH = badgeW;
        self.badgeLabel.layer.masksToBounds = YES;
        self.badgeLabel.layer.cornerRadius = badgeW/2.0;
        _badgeLabelWidthConstraint = [self.badgeLabel autoSetDimension:ALDimensionWidth toSize:badgeW];
        _badgeLabelHeightConstraint = [self.badgeLabel autoSetDimension:ALDimensionHeight toSize:badgeH];
        [self.badgeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.titleLabel withOffset:-badgeH/2.0];
        _badgeLabelRightConstraint = [self.badgeLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.titleLabel withOffset:badgeW/2.0];
        
        [self.sepLineView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.sepLineView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.sepLineView autoSetDimensionsToSize:CGSizeMake(1/UIScreen.mainScreen.scale, 14)];
    }
    return self;
}

- (void)refreshWithModel:(DVVSegmentedModel *)model didSelected:(BOOL)didSelected {
    if (!model) {
        return;
    }
    self.model = model;
    _didSelected = didSelected;
    
    [self configBackgroundColorWithIsHidden:!didSelected];
    [self configTextColorWithIsHidden:!didSelected];
    [self configTitleLabelWithScrollProgress:1 isHidden:!didSelected];
    
    if (model.fixedWidth > 0 ||
        model.titleLeftMargin == model.titleRightMargin) {
        _titleLabelAxisVerticalConstraint.constant = 0;
    } else {
        _titleLabelAxisVerticalConstraint.constant = (model.titleLeftMargin - model.titleRightMargin)/2.0;
    }
    _titleLabel.text = model.title;
    
    self.layer.cornerRadius = model.cornerRadius;
    
    if (model.normalBorderColor) {
        if (didSelected) {
            self.layer.borderColor = model.selectedBorderColor.CGColor;
        } else {
            self.layer.borderColor = model.normalBorderColor.CGColor;
        }
        self.layer.borderWidth = model.borderWidth;
    } else {
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0;
    }
    
    if (model.normalShadowColor) {
        if (didSelected) {
            self.layer.shadowColor = model.selectedShadowColor.CGColor;
        } else {
            self.layer.shadowColor = model.normalShadowColor.CGColor;
        }
        self.layer.shadowOpacity = model.shadowOpacity;
        self.layer.shadowOffset = model.shadowOffset;
        self.layer.shadowRadius = model.shadowRadius;
    } else {
        self.layer.shadowColor = nil;
        self.layer.shadowOpacity = 0;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 0;
    }
    
    if (model.showRedDot) {
        self.redDotView.hidden = NO;
    } else {
        self.redDotView.hidden = YES;
    }
    
    if (model.badgeCount > 0) {
        self.badgeLabel.hidden = NO;
        NSString *badgeText = [NSString stringWithFormat:@"%@", model.badgeCount > 99 ? @"99+" : @(model.badgeCount)];
        self.badgeLabel.text = badgeText;
        CGFloat badgeW = 15;
        CGFloat badgeH = badgeW;
        CGSize actualSize = [DVVSegmentedCell actualSizeWithString:badgeText font:[UIFont boldSystemFontOfSize:9]];
        if (actualSize.width > actualSize.height) {
            badgeW = actualSize.width + (badgeH - 9) + 1;
        }
        _badgeLabelWidthConstraint.constant = badgeW;
        _badgeLabelHeightConstraint.constant = badgeH;
        _badgeLabelRightConstraint.constant = badgeW/2.0;
    } else {
        self.badgeLabel.hidden = YES;
    }
}

- (void)configBackgroundColorWithIsHidden:(BOOL)isHidden {
    if (isHidden) {
        if (self.didAddSelectedBackgroundGradientView) {
            self.selectedBackgroundGradientView.hidden = YES;
        }
        self.backgroundColor = self.model.normalBackgroundColor;
    } else {
        if (self.model.selectedBackgroundGradientColors) {
            if (!self.didAddSelectedBackgroundGradientView) {
                self.didAddSelectedBackgroundGradientView = YES;
                [self.contentView insertSubview:self.selectedBackgroundGradientView atIndex:0];
                [self.selectedBackgroundGradientView autoPinEdgesToSuperviewEdges];
            }
            self.selectedBackgroundGradientView.hidden = NO;
            self.selectedBackgroundGradientView.colors = self.model.selectedBackgroundGradientColors;
            self.selectedBackgroundGradientView.gradientCornerRadius = self.model.cornerRadius;
        } else {
            if (self.didAddSelectedBackgroundGradientView) {
                self.selectedBackgroundGradientView.hidden = YES;
            }
            self.backgroundColor = self.model.selectedBackgroundColor;
        }
    }
}

- (void)configTextColorWithIsHidden:(BOOL)isHidden {
    if (isHidden) {
        _titleLabel.textColor = self.model.normalTextColor;
    } else {
        _titleLabel.textColor = self.model.selectedTextColor;
    }
}

- (void)refreshStatusWithScrollProgress:(CGFloat)scrollProgress isHidden:(BOOL)isHidden {
    [self configTitleLabelWithScrollProgress:scrollProgress isHidden:isHidden];
    
    if (self.model.handleTextColorTransitionEffect) {
        NSArray<NSNumber *> *normalRGBArray = [self rgbValueWithColor:self.model.normalTextColor];
        NSArray<NSNumber *> *selectedRGBArray = [self rgbValueWithColor:self.model.selectedTextColor];
        NSArray<NSNumber *> *RGBArray = @[@([selectedRGBArray[0] floatValue] - [normalRGBArray[0] floatValue]),
                                          @([selectedRGBArray[1] floatValue] - [normalRGBArray[1] floatValue]),
                                          @([selectedRGBArray[2] floatValue] - [normalRGBArray[2] floatValue])];
        UIColor *color = nil;
        if (isHidden) {
            color = [UIColor colorWithRed:([selectedRGBArray[0] floatValue] - [RGBArray[0] floatValue]*scrollProgress)/255.0
                                    green:([selectedRGBArray[1] floatValue] - [RGBArray[1] floatValue]*scrollProgress)/255.0
                                     blue:([selectedRGBArray[2] floatValue] - [RGBArray[2] floatValue]*scrollProgress)/255.0
                                    alpha:1];
        } else {
            color = [UIColor colorWithRed:([normalRGBArray[0] floatValue] + [RGBArray[0] floatValue]*scrollProgress)/255.0
                                    green:([normalRGBArray[1] floatValue] + [RGBArray[1] floatValue]*scrollProgress)/255.0
                                     blue:([normalRGBArray[2] floatValue] + [RGBArray[2] floatValue]*scrollProgress)/255.0
                                    alpha:1];
        }
        _titleLabel.textColor = color;
    } else {
        if (scrollProgress == 1) {
            [self configTextColorWithIsHidden:isHidden];
        }
    }
    
    if (scrollProgress == 1) {
        [self configBackgroundColorWithIsHidden:isHidden];
    }
}

- (NSArray<NSNumber *> *)rgbValueWithColor:(UIColor *)color {
    CGFloat R = 0, G = 0, B = 0;
    CGColorRef cgColor = [color CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(cgColor);
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(cgColor);
        R = components[0];
        G = components[1];
        B = components[2];
    }
    return @[@(R*255.0), @(G*255.0), @(B*255.0)];
}

- (void)configTitleLabelWithScrollProgress:(CGFloat)scrollProgress isHidden:(NSInteger)isHidden {
    // 设置 transform 会模糊
//    CGFloat scale = 1.0;
//    CGFloat increased = (self.model.selectedFont.pointSize - self.model.normalFont.pointSize)/self.model.selectedFont.pointSize;
//    if (isHidden) {
//        scale += increased - increased*scrollProgress;
//    } else {
//        scale += increased*scrollProgress;
//    }
//    _titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    // 设置字体会跳动
    CGFloat fontSize = self.model.normalFont.pointSize;
    CGFloat increased = self.model.selectedFont.pointSize - self.model.normalFont.pointSize;
    if (isHidden) {
        fontSize += increased*(1 - scrollProgress);
    } else {
        fontSize += increased*scrollProgress;
    }
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
    
    // 字体不根据进度变化
//    if (scrollProgress == 1) {
//        if (isHidden) {
//            _titleLabel.font = self.model.normalFont;
//        } else {
//            _titleLabel.font = self.model.selectedFont;
//        }
//    }
}

/// 获取实际需要的宽度
+ (CGFloat)actualWidthWithString:(NSString *)str font:(UIFont *)font {
    return [DVVSegmentedCell actualSizeWithString:str font:font].width;
}

+ (CGSize)actualSizeWithString:(NSString *)str font:(UIFont *)font {
    if (!str || !font) {
        return CGSizeZero;
    }
    //大小
    CGSize boundRectSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    //绘制属性
    NSDictionary *fontDict = @{ NSFontAttributeName: font };
    // 获取实际大小
    CGSize actualSize = [str boundingRectWithSize:boundRectSize
                                          options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:fontDict
                                          context:nil].size;
    return actualSize;
}

- (DVVGradientView *)selectedBackgroundGradientView {
    if (!_selectedBackgroundGradientView) {
        _selectedBackgroundGradientView = [[DVVGradientView alloc] init];
        _selectedBackgroundGradientView.locations = @[@0, @1];
        _selectedBackgroundGradientView.type = DVVGradientViewTypeLeftToRight;
    }
    return _selectedBackgroundGradientView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:95/255.0 alpha:1];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.font = [UIFont boldSystemFontOfSize:9];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.hidden = YES;
    }
    return _badgeLabel;
}

- (UIView *)redDotView {
    if (!_redDotView) {
        _redDotView = [[UIView alloc] init];
        _redDotView.backgroundColor = [UIColor colorWithRed:255/255.0 green:95/255.0 blue:95/255.0 alpha:1];
    }
    return _redDotView;
}

- (UIView *)sepLineView {
    if (!_sepLineView) {
        _sepLineView = [[UIView alloc] init];
        _sepLineView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        _sepLineView.hidden = YES;
    }
    return _sepLineView;
}

@end
