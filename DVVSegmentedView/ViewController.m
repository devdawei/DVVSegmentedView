//
//  ViewController.m
//  DVVSegmentedView
//
//  Created by David on 2022/2/24.
//

#import "ViewController.h"
#import "DVVSegmentedView.h"

@interface ViewController () <DVVSegmentedViewDelegate>

@property (nonatomic, strong) DVVSegmentedView *segmentedView;
@property (nonatomic, strong) NSMutableArray<DVVSegmentedModel *> *segmentedModelArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize size = UIScreen.mainScreen.bounds.size;
    CGFloat segmentedViewHeight = 44;
    self.segmentedView.frame = CGRectMake(0, 300, size.width, segmentedViewHeight);
    [self.view addSubview:self.segmentedView];
    
    NSInteger count = 10;
    _segmentedModelArray = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        NSString *title = [NSString stringWithFormat:@"第%@个", @(i + 1)];
        [_segmentedModelArray addObject:[self segmentedModelWithTitle:title]];
    }
    [self.segmentedView refreshWithDataModelArray:_segmentedModelArray];
}

#pragma mark - DVVSegmentedViewDelegate

- (void)segmentedView:(DVVSegmentedView *)segmentedView didSelectAtIndex:(NSInteger)index {
    NSLog(@"选中的下标：%@", @(index));
}

#pragma mark -

- (DVVSegmentedModel *)segmentedModelWithTitle:(NSString *)title {
    DVVSegmentedModel *model = [[DVVSegmentedModel alloc] init];
    
    model.title = title;
    
    model.normalFont = [UIFont systemFontOfSize:15];
    model.selectedFont = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    
    model.normalTextColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
    model.selectedTextColor = [UIColor whiteColor];
    
    model.normalBackgroundColor = [UIColor clearColor];
    model.selectedBackgroundColor = [UIColor clearColor];
    
    model.followerBarColor = [UIColor orangeColor];
    model.fixedFollowerBarWidth = 30;
    
    return model;
}

#pragma mark -

- (DVVSegmentedView *)segmentedView {
    if (!_segmentedView) {
        _segmentedView = [[DVVSegmentedView alloc] init];
        _segmentedView.backgroundColor = [UIColor colorWithRed:0/255.0 green:100/255.0 blue:255/255.0 alpha:1];
        _segmentedView.delegate = self;
        _segmentedView.contentNeedToCenter = YES;
    }
    return _segmentedView;
}

@end
