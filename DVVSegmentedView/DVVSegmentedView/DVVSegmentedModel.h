//
//  DVVSegmentedModel.h
//  DVVSegmentedView
//
//  Created by David on 2022/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 间距-大
extern CGFloat const DVVSegmentedTitleMarginBig;
/// 间距-中等
extern CGFloat const DVVSegmentedTitleMarginMedium;
/// 间距-小
extern CGFloat const DVVSegmentedTitleMarginSmall;

@interface DVVSegmentedModel : NSObject

#pragma mark -

/// 标题
@property (nonatomic, copy) NSString *title;

/// 固定宽度值，如果此值大于0，则不根据字体实际宽度和左右间距计算总体宽度
@property (nonatomic, assign) CGFloat fixedWidth;
/// 标题左间距  default: DVVSegmentedTitleMarginMedium (12.0)
@property (nonatomic, assign) CGFloat titleLeftMargin;
/// 标题右间距  default: DVVSegmentedTitleMarginMedium (12.0)
@property (nonatomic, assign) CGFloat titleRightMargin;

/// 正常情况下的字体
@property (nonatomic, copy) UIFont *normalFont;
/// 选中情况下的字体
@property (nonatomic, copy) UIFont *selectedFont;

/// 正常情况下的文本颜色
@property (nonatomic, copy) UIColor *normalTextColor;
/// 选中情况下的文本颜色
@property (nonatomic, copy) UIColor *selectedTextColor;
/// 是否处理标题颜色的过渡效果  default: NO
@property (nonatomic, assign) BOOL handleTextColorTransitionEffect;

/// 正常情况下的背景颜色
@property (nonatomic, copy) UIColor *normalBackgroundColor;
/// 选中情况下的背景颜色
@property (nonatomic, copy) UIColor *selectedBackgroundColor;
/// 选中情况下的渐变背景颜色（如果设置了，则不使用 selectedBackgroundColor 的值）
@property (nonatomic, copy) NSArray *selectedBackgroundGradientColors;

/// 底部跟随条的颜色
@property (nonatomic, copy) UIColor *followerBarColor;
/// 固定底部跟随条的宽度
@property (nonatomic, assign) CGFloat fixedFollowerBarWidth;
/// 底部跟随条的宽度同标题的宽度-左侧额外的宽度  default: 0  (固定底部跟随条的宽度时无效)
@property (nonatomic, assign) CGFloat followerBarAsTitleLeftAdditionalWidth;
/// 底部跟随条的宽度同标题的宽度-右侧额外的宽度  default: 0  (固定底部跟随条的宽度时无效)
@property (nonatomic, assign) CGFloat followerBarAsTitleRightAdditionalWidth;

/// 圆角
@property (nonatomic, assign) CGFloat cornerRadius;

/// 描边-默认颜色
@property (nonatomic, copy) UIColor *normalBorderColor;
/// 描边-选中颜色
@property (nonatomic, copy) UIColor *selectedBorderColor;
/// 描边-大小
@property (nonatomic, assign) CGFloat borderWidth;

/// 阴影-默认颜色
@property(nonatomic, copy) UIColor *normalShadowColor;
/// 阴影-选中颜色
@property(nonatomic, copy) UIColor *selectedShadowColor;
/// 阴影-
@property (nonatomic, assign) float shadowOpacity;
/// 阴影-
@property (nonatomic, assign) CGSize shadowOffset;
/// 阴影-
@property (nonatomic, assign) CGFloat shadowRadius;

#pragma mark -

/// 角标数量
@property (nonatomic, assign) NSInteger badgeCount;

/// 是否显示红点
@property (nonatomic, assign) BOOL showRedDot;

@end

NS_ASSUME_NONNULL_END
