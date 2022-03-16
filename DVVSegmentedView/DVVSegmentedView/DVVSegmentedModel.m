//
//  DVVSegmentedModel.m
//  DVVSegmentedView
//
//  Created by David on 2022/2/24.
//

#import "DVVSegmentedModel.h"

CGFloat const DVVSegmentedTitleMarginBig = 16.0;
CGFloat const DVVSegmentedTitleMarginMedium = 12.0;
CGFloat const DVVSegmentedTitleMarginSmall = 8.0;

@implementation DVVSegmentedModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleLeftMargin = DVVSegmentedTitleMarginMedium;
        _titleRightMargin = DVVSegmentedTitleMarginMedium;
    }
    return self;
}

@end
