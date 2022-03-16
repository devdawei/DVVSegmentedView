//
//  DVVSegmentedCell.h
//  DVVSegmentedView
//
//  Created by David on 2022/2/24.
//

#import <UIKit/UIKit.h>
#import "DVVSegmentedModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 复用标识
extern NSString * const DVVSegmentedCellRID;

@interface DVVSegmentedCell : UICollectionViewCell

@property (nonatomic, readonly, assign) BOOL didSelected;

@property (nonatomic, strong) UIView *sepLineView;

@property (nonatomic, readonly, weak) DVVSegmentedModel *model;

- (void)refreshWithModel:(DVVSegmentedModel *)model didSelected:(BOOL)didSelected;

- (void)refreshStatusWithScrollProgress:(CGFloat)scrollProgress isHidden:(BOOL)isHidden;

/// 获取实际需要的宽度
+ (CGFloat)actualWidthWithString:(NSString *)str font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
