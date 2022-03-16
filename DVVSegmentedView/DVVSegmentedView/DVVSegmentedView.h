//
//  DVVSegmentedView.h
//  DVVSegmentedView
//
//  Created by David on 2022/2/24.
//

#import <UIKit/UIKit.h>
#import "DVVSegmentedModel.h"

@protocol DVVSegmentedViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface DVVSegmentedView : UIView

/// 当内容总体长度不会超过视图的宽度，是否需要将总体内容居中处理  default: NO
@property (nonatomic, assign) BOOL contentNeedToCenter;
/// 当内容数量超过这个限定的的数量时候需要居左  default: NSIntegerMax
@property (nonatomic, assign) NSInteger contentNeedToCenterMaxCount;

/// 总体内容顶部的间距
@property (nonatomic, assign) CGFloat insetTopForSection;
/// 总体内容底部的间距
@property (nonatomic, assign) CGFloat insetBottomForSection;
/// 总体内容左侧的间距
@property (nonatomic, assign) CGFloat insetLeftForSection;
/// 总体内容右侧的间距
@property (nonatomic, assign) CGFloat insetRightForSection;
/// 每一项之间的间距
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/// 当前选中的下标  default: 0
@property (nonatomic, readonly, assign) NSInteger currentSelectedIndex;

/// 当点击的时候是否需要刷新下数据（如果需要处理标题颜色的过渡效果，则应该将此值设为: NO，否则可能会影响过渡）  default: NO
@property (nonatomic, assign) BOOL clickedNeedRefresh;

/// 代理
@property (nonatomic, weak) id<DVVSegmentedViewDelegate> delegate;

/// 数据列表（刷新完数据后可用）
@property (nonatomic, readonly, strong) NSArray<DVVSegmentedModel *> *dataModelArray;
/// 总宽度（刷新完数据后可用）
@property (nonatomic, readonly, assign) CGFloat totalWidth;

/// 是否支持弹簧效果  default: YES
@property (nonatomic, assign) BOOL bounces;

/// 跟随条是否隐藏  default: NO
@property (nonatomic, assign) BOOL followerBarHidden;
/// 是否使用图片类型的跟随条
@property (nonatomic, assign) BOOL useImageFollowerBar;
@property (nonatomic, assign) CGSize followerBarImageSize;
@property (nonatomic, copy) UIImage *followerBarImage;

/// 是否显示分割线  default: NO
@property (nonatomic, assign) BOOL showSeparateLine;

/// 是否使用自定义 Cell  default: NO
@property (nonatomic, assign) BOOL useCustomCell;
/// 如果是自定义 Cell，则需要注册 Cell
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

/**
 刷新数据

 @param dataModelArray 数据模型列表
 */
- (void)refreshWithDataModelArray:(NSArray<DVVSegmentedModel *> *)dataModelArray;

/**
 刷新数据并指定选中某一项

 @param dataModelArray 数据模型列表
 @param selectedIndex 默认选中项下标
 */
- (void)refreshWithDataModelArray:(NSArray<DVVSegmentedModel *> *)dataModelArray selectedIndex:(NSInteger)selectedIndex;

/**
 选中一项

 @param index 需要选中的下标
 @param animated 是否需要动画
 */
- (void)selectIndex:(NSInteger)index animated:(BOOL)animated;

/**
 根据进度刷新当前显示状态

 @param scrollProgress 进度
 @param fromIndex 从这个下标
 @param toIndex 滚动到这个下标
 */
- (void)refreshItemStatusWithScrollProgress:(CGFloat)scrollProgress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

/*
 如果调用了 - (void)refreshItemStatusWithScrollProgress:(CGFloat)scrollProgress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex; 方法，
 则在结束后需要调用此方法
 */
- (void)refreshItemStatusCompletion;

/**
 显示角标

 @param index 下标
 @param value 角标值
 */
- (void)showBadgeAtIndex:(NSInteger)index value:(NSInteger)value;

/**
 移除角标

 @param index 下标
 */
- (void)removeBadgeAtIndex:(NSInteger)index;

/// 显示红点
- (void)showRedDotAtIndex:(NSInteger)index;

/// 移除红点
- (void)removeRedDotAtIndex:(NSInteger)index;

@end


@protocol DVVSegmentedViewDelegate <NSObject>

@optional

/// 是否允许选中
- (BOOL)segmentedView:(DVVSegmentedView *)segmentedView canSelectAtIndex:(NSInteger)index;

/// 选中一项时调用
- (void)segmentedView:(DVVSegmentedView *)segmentedView didSelectAtIndex:(NSInteger)index;

/// 自定义 Cell
- (UICollectionViewCell *)segmentedView:(DVVSegmentedView *)segmentedView collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
