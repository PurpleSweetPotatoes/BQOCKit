//
//  SwipeSubTableVc.m
//  tianyaTest
//
//  Created by baiqiang on 2019/3/12.
//  Copyright © 2019年 baiqiang. All rights reserved.
//

#import "BQSwipeSubTableVc.h"
#import "UIView+Custom.h"
#import "BQDefineHead.h"

@interface BQSwipeSubTableVc ()

@property (nonatomic, strong) UIView * disPalyHeaderView;
@property (nonatomic, strong) UIView * tempHeaderView;
@property (nonatomic, assign) CGFloat  disPalyHeaderTop;
@property (nonatomic, assign) NSInteger  currentTabIndex;
@property (nonatomic, assign) BOOL  isFirst;
@property (nonatomic, copy) void(^switchBlock)(NSInteger index);


@end

@implementation BQSwipeSubTableVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isFirst = YES;
    self.currentTabIndex = 0;
    [self setUpUI];
}

- (void)setUpUI {
    self.disPalyHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    
    if (self.headerView) {
        [self.disPalyHeaderView addSubview:self.headerView];
        self.disPalyHeaderView.height = self.headerView.bottom;
    }
    
    if (self.barView) {
        self.barView.top = self.headerView.bottom;
        [self.view addSubview:self.barView];
        self.disPalyHeaderView.height = self.barView.bottom;
    }
    
    self.tempHeaderView = [self.headerView tailorWithFrame:CGRectMake(0, 0, self.view.width, self.headerView.height)];
    self.tempHeaderView.hidden = YES;
    self.tempHeaderView.userInteractionEnabled = NO;
    [self.view addSubview:self.tempHeaderView];
    
    [self configTabArrs];
}

- (void)configTabArrs {

    for (UIViewController<BQSwipTableViewDelegate> * tVc in self.tabArrs) {
        tVc.headerHeight = self.disPalyHeaderView.height;
        WeakSelf;
        [tVc scrollViewDidScrollBlock:^(CGFloat offsetY) {
            StrongSelf;
            [strongSelf updateDisplayViewFrame:offsetY];
        }];
        
        [self addChildViewController:tVc];
        [self.view addSubview:tVc.view];
        tVc.view.left = self.view.width;
        
        if (self.navBottom == 0) {
            tVc.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        UISwipeGestureRecognizer * swipRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestureAction:)];
        swipRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [tVc.view addGestureRecognizer:swipRightGesture];
        UISwipeGestureRecognizer * swipLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGestureAction:)];
        swipLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [tVc.view addGestureRecognizer:swipLeftGesture];
        
    }
    
    UIViewController<BQSwipTableViewDelegate> * curVc = self.tabArrs[self.currentTabIndex];
    curVc.view.left = 0;
    curVc.needScrollBlock = YES;
    curVc.tableView.tableHeaderView = self.disPalyHeaderView;

    [self.view bringSubviewToFront:self.tempHeaderView];
    [self.view bringSubviewToFront:self.barView];

}

- (void)resetTabArrs:(NSArray<UIViewController<BQSwipTableViewDelegate> *> *)tabArrs {
    
    for (UIViewController<BQSwipTableViewDelegate> * vc in tabArrs) {
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
    
    self.tabArrs = tabArrs;
    
    [self configTabArrs];
}

- (void)updateDisplayViewFrame:(CGFloat)offsetY {

    if (offsetY >= self.headerView.height - self.navBottom) {
        
        if (self.barView.top != self.headerView.height + self.navBottom - self.headerView.height) {
            [self resetTableOffset:self.headerView.height - self.navBottom];
            self.barView.top = self.headerView.height + self.navBottom - self.headerView.height;
            self.tempHeaderView.top = self.barView.top - self.tempHeaderView.height;
        }
        
    } else {
        [self resetTableOffset:offsetY];
        self.isFirst = NO;
        self.barView.top = self.headerView.height - offsetY;
        self.tempHeaderView.top = self.barView.top - self.tempHeaderView.height;
    }
}

- (void)resetTableOffset:(CGFloat)offsetY {
    
    if (!self.headerView || self.isFirst) { //第一次进入配置contentOffset会出现偏移错误
        return;
    }
    
    for (NSInteger i = 0; i < self.tabArrs.count; i++) {
        if (i == self.currentTabIndex) {
            continue;
        } else {
            [self.tabArrs[i].tableView setContentOffset:CGPointMake(0, offsetY) animated:NO];
        }
    }
}

- (void)switchToTabVc:(NSInteger)index {
    
    if (index >= 0 && index < self.tabArrs.count && index != self.currentTabIndex) {
        
        UIViewController<BQSwipTableViewDelegate> * currentTabVc = self.tabArrs[self.currentTabIndex];
        currentTabVc.needScrollBlock = NO;
        currentTabVc.view.right = 0;
        currentTabVc.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.disPalyHeaderView.height)];
        
        UIViewController<BQSwipTableViewDelegate> * tabVc = self.tabArrs[index];
        tabVc.view.left = 0;
        tabVc.needScrollBlock = YES;
        tabVc.tableView.tableHeaderView = self.disPalyHeaderView;
        
        
        self.currentTabIndex = index;
    }
}

- (void)tabVcWillSwitchToIndex:(void (^)(NSInteger))changeBlock {
    self.switchBlock = changeBlock;
}

#pragma mark - Gesture Action

- (void)swipGestureAction:(UISwipeGestureRecognizer *)sender {
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight && self.currentTabIndex != 0) {
    
        self.currentTabIndex -= 1;
        
        [self changeVcFrom:self.tabArrs[self.currentTabIndex + 1] to:self.tabArrs[self.currentTabIndex] swipRight:YES];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft && self.currentTabIndex < self.tabArrs.count - 1) {

        self.currentTabIndex += 1;
        
        [self changeVcFrom:self.tabArrs[self.currentTabIndex - 1] to:self.tabArrs[self.currentTabIndex] swipRight:NO];
    }
}

- (void)changeVcFrom:(UIViewController<BQSwipTableViewDelegate> *)fromVc to:(UIViewController<BQSwipTableViewDelegate> *)toVc swipRight:(BOOL)swipRight {
    
    self.tempHeaderView.hidden = NO;
    fromVc.needScrollBlock = NO;
    fromVc.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.disPalyHeaderView.height)];
    
    toVc.needScrollBlock = YES;
//    toVc.tableView.tableHeaderView = self.disPalyHeaderView;
    toVc.view.left = swipRight ? -self.view.width: self.view.width;
    
    [UIView animateWithDuration:0.25 animations:^{
        fromVc.view.left = swipRight ? self.view.width : -self.view.width;
        toVc.view.left = 0;
    } completion:^(BOOL finished) {
        toVc.tableView.tableHeaderView = self.disPalyHeaderView;
        self.tempHeaderView.hidden = YES;
    }];
    
    if (self.switchBlock) {
        self.switchBlock(self.currentTabIndex);
    }
}

@end
