//
//  DVVSegmentedView.m
//  DVVSegmentedView
//
//  Created by David on 2022/2/24.
//

#import "DVVSegmentedView.h"
#import "DVVSegmentedCell.h"

/// 正常情况下的标题宽度
NSString * const DVVSegmentedViewItemInfoNormalTitleWidth = @"NormalTitleWidth";
/// 选中情况下的标题宽度
NSString * const DVVSegmentedViewItemInfoSelectedTitleWidth = @"SelectedTitleWidth";
/// 文字左边距
NSString * const DVVSegmentedViewItemInfoTitleLeftMargin = @"TitleLeftMargin";
/// 文字右边距
NSString * const DVVSegmentedViewItemInfoTitleRightMargin = @"TitleRightMargin";
/// 总宽度
NSString * const DVVSegmentedViewItemInfoWidth = @"Width";
/// 左侧总宽度
NSString * const DVVSegmentedViewItemInfoLeftWidth = @"LeftWidth";
/// 跟随条宽度
NSString * const DVVSegmentedViewItemInfoFollowerBarWidth = @"FollowerBarWidth";
/// 跟随条左边距
NSString * const DVVSegmentedViewItemInfoFollowerBarLeftMargin = @"FollowerBarLeftMargin";
/// 跟随条右边距
NSString * const DVVSegmentedViewItemInfoFollowerBarRightMargin = @"FollowerBarRightMargin";

@interface DVVSegmentedView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, readwrite, assign) NSInteger currentSelectedIndex;
@property (nonatomic, assign) NSInteger lastSelectedIndex;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, readwrite, strong) NSArray<DVVSegmentedModel *> *dataModelArray;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *itemInfoArray;
@property (nonatomic, readwrite, assign) CGFloat totalWidth;
/// 底部跟随选中项移动的视图
@property (nonatomic, strong) UIView *followerBar;
@property (nonatomic, strong) UIImageView *followerBarImageView;

@property (nonatomic, assign) NSInteger scrollFromIndex;
@property (nonatomic, assign) CGFloat scrollOffsetX;

@property (nonatomic, assign) CGFloat collectionViewCurrentHeight;

@end

@implementation DVVSegmentedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentNeedToCenterMaxCount = NSIntegerMax;
        
        _bounces = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.collectionView];
        [self.collectionView addSubview:self.followerBar];
    }
    return self;
}

- (void)resetRefreshItemStatusInfo {
    _scrollFromIndex = -1;
    _scrollOffsetX = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self configUI];
    
    [self refreshWithSelectedIndex:self.currentSelectedIndex animated:NO];
}

- (void)configUI {
    CGSize size = self.bounds.size;
    _collectionViewCurrentHeight = size.height;
    _contentView.frame = CGRectMake(0, 0, size.width, _collectionViewCurrentHeight);
}

// 检查是否需要居中显示
- (void)checkNeedToCenterOrLeft {
    CGSize size = _contentView.bounds.size;
    if (_totalWidth > 0 && _totalWidth < size.width &&
        _contentNeedToCenter && _dataModelArray.count <= _contentNeedToCenterMaxCount) {
        // 居中
        CGFloat space = size.width - _totalWidth;
        _collectionView.frame = CGRectMake(space/2.0, 0, _totalWidth, size.height);
    } else {
        // 居左
        if (_totalWidth > size.width) {
            _collectionView.frame = _contentView.bounds;
        } else {
            _collectionView.frame = CGRectMake(0, 0, _totalWidth, size.height);
        }
    }
}

- (void)refreshWithDataModelArray:(NSArray<DVVSegmentedModel *> *)dataModelArray {
    [self refreshWithDataModelArray:dataModelArray selectedIndex:0];
}

- (void)refreshWithDataModelArray:(NSArray<DVVSegmentedModel *> *)dataModelArray selectedIndex:(NSInteger)selectedIndex {
    if (!dataModelArray) {
        return;
    }
    
    self.dataModelArray = dataModelArray;
    
    if (_itemInfoArray) {
        [_itemInfoArray removeAllObjects];
    } else {
        _itemInfoArray = [NSMutableArray array];
    }
    _totalWidth = self.insetLeftForSection;
    for (NSInteger i = 0; i < dataModelArray.count; i++) {
        DVVSegmentedModel *model = dataModelArray[i];
        CGFloat normalTitleWidth = 0;
        CGFloat selectedTitleWidth = 0;
        normalTitleWidth = [DVVSegmentedCell actualWidthWithString:_dataModelArray[i].title font:model.normalFont];
        selectedTitleWidth = [DVVSegmentedCell actualWidthWithString:_dataModelArray[i].title font:model.selectedFont];
        CGFloat width = 0;
        if (model.fixedWidth > 0) {
            width = model.fixedWidth;
            model.titleLeftMargin = model.titleRightMargin = (model.fixedWidth - selectedTitleWidth)/2.0;
        } else {
            width = model.titleLeftMargin + selectedTitleWidth + model.titleRightMargin;
        }
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[DVVSegmentedViewItemInfoNormalTitleWidth] = @(normalTitleWidth);
        info[DVVSegmentedViewItemInfoSelectedTitleWidth] = @(selectedTitleWidth);
        info[DVVSegmentedViewItemInfoTitleLeftMargin] = @(model.titleLeftMargin);
        info[DVVSegmentedViewItemInfoTitleRightMargin] = @(model.titleRightMargin);
        info[DVVSegmentedViewItemInfoWidth] = @(width);
        info[DVVSegmentedViewItemInfoLeftWidth] = @(_totalWidth);
        CGFloat followerBarWidth = 0;
        CGFloat followerBarLeftMargin = 0;
        CGFloat followerBarRightMargin = 0;
        CGFloat followerBarOffset = 0;
        if (model.fixedWidth <= 0 &&
            model.titleLeftMargin != model.titleRightMargin) {
            followerBarOffset = (model.titleLeftMargin - model.titleRightMargin)/2.0;
        }
        if (model.fixedFollowerBarWidth > 0) {
            followerBarWidth = model.fixedFollowerBarWidth;
            followerBarLeftMargin = (width - followerBarWidth)/2.0 + followerBarOffset;
            followerBarRightMargin = width - followerBarLeftMargin - followerBarWidth;
        } else {
            followerBarWidth = model.followerBarAsTitleLeftAdditionalWidth + selectedTitleWidth + model.followerBarAsTitleRightAdditionalWidth;
            followerBarLeftMargin = (width - selectedTitleWidth)/2.0 - model.followerBarAsTitleLeftAdditionalWidth + followerBarOffset;
            followerBarRightMargin = (width - selectedTitleWidth)/2.0 - model.followerBarAsTitleRightAdditionalWidth - followerBarOffset;
        }
        info[DVVSegmentedViewItemInfoFollowerBarWidth] = @(followerBarWidth);
        info[DVVSegmentedViewItemInfoFollowerBarLeftMargin] = @(followerBarLeftMargin);
        info[DVVSegmentedViewItemInfoFollowerBarRightMargin] = @(followerBarRightMargin);
        [self.itemInfoArray addObject:info];
        _totalWidth += width;
        if (self.minimumInteritemSpacing > 0) {
            if (i != dataModelArray.count - 1) {
                _totalWidth += self.minimumInteritemSpacing;
            }
        }
    }
    _totalWidth += self.insetLeftForSection;
    
    [self refreshWithSelectedIndex:selectedIndex animated:YES];
}

- (void)refreshWithSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    self.currentSelectedIndex = selectedIndex;
    [self checkNeedToCenterOrLeft];
    [self.collectionView reloadData];
    [self refreshFollowerBarPointWithAnimated:animated];
    [self refreshCollectionViewOffsetXWithAnimated:animated];
}

- (void)selectIndex:(NSInteger)index animated:(BOOL)animated {
    [self refreshWithSelectedIndex:index animated:animated];
}

- (void)showBadgeAtIndex:(NSInteger)index value:(NSInteger)value {
    if (index >= _dataModelArray.count) {
        return;
    }
    
    _dataModelArray[index].badgeCount = value;
    [self.collectionView reloadData];
}

- (void)removeBadgeAtIndex:(NSInteger)index {
    if (index >= _dataModelArray.count) {
        return;
    }
    
    _dataModelArray[index].badgeCount = 0;
    [self.collectionView reloadData];
}

- (void)showRedDotAtIndex:(NSInteger)index {
    if (index >= _dataModelArray.count) {
        return;
    }
    
    _dataModelArray[index].showRedDot = YES;
    [self.collectionView reloadData];
}

- (void)removeRedDotAtIndex:(NSInteger)index {
    if (index >= _dataModelArray.count) {
        return;
    }
    
    _dataModelArray[index].showRedDot = NO;
    [self.collectionView reloadData];
}

- (void)refreshFollowerBarPointWithAnimated:(BOOL)animated {
    if (_currentSelectedIndex < 0 || _currentSelectedIndex >= _dataModelArray.count) {
        return;
    }
    
    NSDictionary<NSString *, id> *info = _itemInfoArray[_currentSelectedIndex];
    CGFloat x = [info[DVVSegmentedViewItemInfoLeftWidth] floatValue] + [info[DVVSegmentedViewItemInfoFollowerBarLeftMargin] floatValue];
    CGFloat followerBarW = [info[DVVSegmentedViewItemInfoFollowerBarWidth] floatValue];
    CGFloat followerBarH = 3;
    CGRect frame = CGRectMake(x, self.collectionView.bounds.size.height - followerBarH - self.insetBottomForSection, followerBarW, followerBarH);
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.followerBar.frame = frame;
        }];
    } else {
        self.followerBar.frame = frame;
    }
    if (!self.useImageFollowerBar) {
        self.followerBar.backgroundColor = _dataModelArray[_currentSelectedIndex].followerBarColor;
    }
}

- (void)refreshCollectionViewOffsetXWithAnimated:(BOOL)animated {
    if (_currentSelectedIndex < 0 || _currentSelectedIndex >= _dataModelArray.count) {
        return;
    }
    
    NSInteger toIndex = self.currentSelectedIndex;
    
    CGFloat toCenterX = [_itemInfoArray[toIndex][DVVSegmentedViewItemInfoLeftWidth] floatValue] + [_itemInfoArray[toIndex][DVVSegmentedViewItemInfoWidth] floatValue]/2.0;
    
    CGFloat collectionViewW = self.collectionView.bounds.size.width;
    
    CGFloat offsetX = 0;
    CGFloat maxOffsetX = self.collectionView.contentSize.width - collectionViewW;
    
    CGFloat flagOffsetX = toCenterX - collectionViewW/2.0;
    if (flagOffsetX < 0) {
        offsetX = 0;
    } else if (flagOffsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    } else {
        offsetX = flagOffsetX;
    }
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.contentOffset = CGPointMake(offsetX, 0);
        }];
    } else {
        self.collectionView.contentOffset = CGPointMake(offsetX, 0);
    }
}

- (void)refreshFollowerBarPointScrollProgress:(CGFloat)scrollProgress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (toIndex == fromIndex) {
        return;
    }
    
    CGFloat fromW = [_itemInfoArray[fromIndex][DVVSegmentedViewItemInfoFollowerBarWidth] floatValue];
    CGFloat toW = [_itemInfoArray[toIndex][DVVSegmentedViewItemInfoFollowerBarWidth] floatValue];
    
    CGFloat fromX = [_itemInfoArray[fromIndex][DVVSegmentedViewItemInfoLeftWidth] floatValue] + [_itemInfoArray[fromIndex][DVVSegmentedViewItemInfoFollowerBarLeftMargin] floatValue];
    CGFloat toX = [_itemInfoArray[toIndex][DVVSegmentedViewItemInfoLeftWidth] floatValue] + [_itemInfoArray[toIndex][DVVSegmentedViewItemInfoFollowerBarLeftMargin] floatValue];
    
    CGRect frame = self.followerBar.frame;
    CGFloat distance = toX - fromX;
    frame.origin.x = fromX + distance*scrollProgress;
    frame.size.width = fromW + (toW - fromW)*scrollProgress;
    self.followerBar.frame = frame;
    if (scrollProgress == 1) {
        if (!self.useImageFollowerBar) {
            self.followerBar.backgroundColor = _dataModelArray[_currentSelectedIndex].followerBarColor;
        }
    }
}

- (void)refreshCellStatusWithScrollProgress:(CGFloat)scrollProgress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (toIndex == fromIndex) {
        return;
    }
    
    if (self.useCustomCell) {
        // 不处理
    } else {
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:fromIndex inSection:0];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toIndex inSection:0];
        DVVSegmentedCell *fromCell = (DVVSegmentedCell *)([self.collectionView cellForItemAtIndexPath:fromIndexPath]);
        [fromCell refreshStatusWithScrollProgress:scrollProgress isHidden:YES];
        DVVSegmentedCell *toCell = (DVVSegmentedCell *)([self.collectionView cellForItemAtIndexPath:toIndexPath]);
        [toCell refreshStatusWithScrollProgress:scrollProgress isHidden:NO];
    }
}

- (void)refreshCollectionViewOffsetXWithScrollProgress:(CGFloat)scrollProgress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (toIndex == fromIndex) {
        return;
    }
    
    CGFloat toCenterX = [_itemInfoArray[toIndex][DVVSegmentedViewItemInfoLeftWidth] floatValue] + [_itemInfoArray[toIndex][DVVSegmentedViewItemInfoWidth] floatValue]/2.0;
    
    CGFloat collectionViewW = self.collectionView.bounds.size.width;
    
    CGFloat offsetX = 0;
    CGFloat maxOffsetX = self.collectionView.contentSize.width - collectionViewW;
    if (_scrollOffsetX > 0 && _scrollFromIndex == fromIndex) {
        offsetX = _scrollOffsetX;
    } else {
        _scrollFromIndex = fromIndex;
        offsetX = _scrollOffsetX = self.collectionView.contentOffset.x;
    }
    if (offsetX < 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.contentOffset = CGPointMake(0, 0);
        }];
        offsetX = _scrollOffsetX = 0;
    } else if (offsetX > ceil(maxOffsetX)) {
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.contentOffset = CGPointMake(maxOffsetX, 0);
        }];
        offsetX = _scrollOffsetX = maxOffsetX;
    }
    CGFloat flagOffsetX = toCenterX - collectionViewW/2.0;
    if (flagOffsetX > maxOffsetX) {
        flagOffsetX = maxOffsetX;
    }
    CGFloat distance = 0;
    
    CGFloat newOffsetX = 0;
    if (toIndex > fromIndex) {
        distance = flagOffsetX - offsetX;
        if (offsetX + distance < 0) {
            distance = distance < 0 ? -offsetX : offsetX;
        }
//        else if (offsetX + distance > maxOffsetX) {
//            distance = maxOffsetX - offsetX;
//        }
        newOffsetX = offsetX + distance*scrollProgress;
    } else {
        distance = offsetX - flagOffsetX;
        if (offsetX - distance < 0) {
            distance = offsetX;
        }
//        if (offsetX + distance > maxOffsetX) {
//            distance = maxOffsetX - offsetX;
//        }
        newOffsetX = offsetX - distance*scrollProgress;
    }
    self.collectionView.contentOffset = CGPointMake(newOffsetX, 0);
}

- (void)refreshItemStatusWithScrollProgress:(CGFloat)scrollProgress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
//    NSLog(@"scrollProgress:%@  fromIndex:%@  toIndex:%@", @(scrollProgress), @(fromIndex), @(toIndex));
    
    if (fromIndex < 0 || toIndex < 0 ||
        fromIndex >= self.dataModelArray.count || toIndex >= self.dataModelArray.count) {
        return;
    }
    
    [self refreshFollowerBarPointScrollProgress:scrollProgress fromIndex:fromIndex toIndex:toIndex];
    [self refreshCellStatusWithScrollProgress:scrollProgress fromIndex:fromIndex toIndex:toIndex];
    [self refreshCollectionViewOffsetXWithScrollProgress:scrollProgress fromIndex:fromIndex toIndex:toIndex];
}

- (void)refreshItemStatusCompletion {
    [self resetRefreshItemStatusInfo];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL didSelected = indexPath.row == _currentSelectedIndex ? YES : NO;
    if (self.useCustomCell) {
        UICollectionViewCell *cell = [self.delegate segmentedView:self collectionView:collectionView cellForItemAtIndexPath:indexPath selected:didSelected];
        return cell;
    } else {
        DVVSegmentedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVVSegmentedCellRID forIndexPath:indexPath];
        if (self.showSeparateLine) {
            cell.sepLineView.hidden = indexPath.row == _dataModelArray.count - 1;
        } else {
            cell.sepLineView.hidden = YES;
        }
        [cell refreshWithModel:_dataModelArray[indexPath.row] didSelected:didSelected];
        
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _currentSelectedIndex) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentedView:canSelectAtIndex:)]) {
        BOOL canSelect = [self.delegate segmentedView:self canSelectAtIndex:indexPath.row];
        if (!canSelect) {
            return;
        }
    }
    
    self.lastSelectedIndex = self.currentSelectedIndex;
    self.currentSelectedIndex = indexPath.row;
    
    if (self.clickedNeedRefresh) {
        [self.collectionView reloadData];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [self refreshItemStatusWithScrollProgress:1 fromIndex:self.lastSelectedIndex toIndex:self.currentSelectedIndex];
        } completion:^(BOOL finished) {
            [self resetRefreshItemStatusInfo];
        }];
    }
    
    if (self.currentSelectedIndex != self.lastSelectedIndex) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentedView:didSelectAtIndex:)]) {
            [self.delegate segmentedView:self didSelectAtIndex:indexPath.row];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = _collectionViewCurrentHeight - _insetTopForSection - _insetBottomForSection;
    if (indexPath.row < _itemInfoArray.count) {
        return CGSizeMake([_itemInfoArray[indexPath.row][DVVSegmentedViewItemInfoWidth] floatValue], cellHeight);
    } else {
        return CGSizeMake(0, cellHeight);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(self.insetTopForSection, self.insetLeftForSection, self.insetBottomForSection, self.insetRightForSection);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.minimumInteritemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.minimumInteritemSpacing;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // NSLog(@"减速完成（setContentOffset/scrollRectVisible:animated）");
    [self resetRefreshItemStatusInfo];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // NSLog(@"减速完成（手动拖动）");
    [self resetRefreshItemStatusInfo];
}

#pragma mark -

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

#pragma mark - Setter

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.collectionView.bounces = bounces;
}

- (void)setFollowerBarHidden:(BOOL)followerBarHidden {
    _followerBarHidden = followerBarHidden;
    self.followerBar.hidden = followerBarHidden;
}

- (void)setUseImageFollowerBar:(BOOL)useImageFollowerBar {
    _useImageFollowerBar = useImageFollowerBar;
    if (useImageFollowerBar) {
        _followerBar.layer.masksToBounds = NO;
        _followerBar.layer.cornerRadius = 0;
    } else {
        _followerBar.layer.masksToBounds = YES;
        _followerBar.layer.cornerRadius = 1.5;
    }
}

- (void)setFollowerBarImage:(UIImage *)followerBarImage {
    _followerBarImage = followerBarImage.copy;
    
    self.followerBarImageView.image = self.followerBarImage;
    self.followerBarImageView.frame = CGRectMake(0, 0, self.followerBarImageSize.width, self.followerBarImageSize.height);
    [self.followerBar addSubview:self.followerBarImageView];
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        // 注册Cell
        [_collectionView registerClass:[DVVSegmentedCell class] forCellWithReuseIdentifier:DVVSegmentedCellRID];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

- (UIView *)followerBar {
    if (!_followerBar) {
        _followerBar = [[UIView alloc] init];
        _followerBar.layer.masksToBounds = YES;
        _followerBar.layer.cornerRadius = 1.5;
    }
    return _followerBar;
}

- (UIImageView *)followerBarImageView {
    if (!_followerBarImageView) {
        _followerBarImageView = [[UIImageView alloc] init];
    }
    return _followerBarImageView;
}

@end
