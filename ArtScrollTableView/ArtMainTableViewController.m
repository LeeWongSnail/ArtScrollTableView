//
//  ArtMainTableViewController.m
//  ArtScrollTableView
//
//  Created by LeeWong on 16/8/27.
//  Copyright © 2016年 LeeWong. All rights reserved.
//

#import "ArtMainTableViewController.h"
#import "ArtTableView2.h"
#import "ArtSubViewCell.h"

@interface ArtMainTableViewController () <UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) ArtTableView2 *tableView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, assign) CGPoint fixOffset;

@end

@implementation ArtMainTableViewController

-(void)acceptMsg : (NSNotification *)notification{
    //NSLog(@"%@",notification);
    if ([notification.name isEqualToString: kLeaveTopNotificationName]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            _canScroll = YES;
        }
    } else if ([notification.name isEqualToString:kGoTopNotificationName]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
    } else if ([notification.name isEqualToString:kTopLeaveTopNotificationName]) {
        self.fixOffset = CGPointZero;
        self.canScroll = NO;
    }
    else {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            _canScroll = YES;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.tableView reloadData];
    self.tableView.showsVerticalScrollIndicator = NO;

    self.fixOffset = CGPointZero;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kTopGotoTopNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kGoTopNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kTopLeaveTopNotificationName object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 2) {
        ArtSubViewCell *subCell = [[ArtSubViewCell alloc] init];
        subCell.navigationController = self.navigationController;
        [cell.contentView addSubview:subCell.view];
        [subCell.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView);
        }];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"第%tu行",indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"click");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return CGRectGetHeight(self.view.frame);;
    }
    return 44;
}


#pragma mark - UISCrollviewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.canScroll) {
        [scrollView setContentOffset:self.fixOffset];
        return;
    }
    CGFloat tabOffsetY = [_tableView rectForSection:2].origin.y;
    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"offsetY ----- %f",offsetY);
    NSLog(@"tabOffsetY ----- %f",tabOffsetY);
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    
    if (offsetY>=tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
            self.fixOffset = scrollView.contentOffset;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            //NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
        }
    }

    NSLog(@"-------%@",@(offsetY));
    if (self.canScroll && offsetY < 5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTopLeaveTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
    }
}

- (ArtTableView2 *)tableView
{
    if (_tableView == nil) {
        _tableView = [[ArtTableView2 alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    }
    return _tableView;
}

@end
