//
//  ViewController.m
//  KSSideslipCellDemo
//
//  Created by Louis on 16/7/5.
//  Copyright © 2016年 Louis. All rights reserved.
//

#import "LYHomeViewController.h"
#import "KSSideslipCell.h"
#import "LYHomeCell.h"
#import "KSSideslipCellAction.h"

#define kIcon @"kIcon"
#define kName @"kName"
#define kTime @"kTime"
#define kMessage @"kMessage"


@interface LYHomeViewController () <KSSideslipCellDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) NSIndexPath *indexPath;
@end

@implementation LYHomeViewController {
    UIImageView *_logoImageView;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:236/255.0 green:235/255.0 blue:243/255.0 alpha:1];
    self.tableView.rowHeight = 70;
    
    _dataArray = [LYHomeCellModel requestDataArray];
    
    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo"]];
    _logoImageView.contentMode = UIViewContentModeCenter;
    _logoImageView.alpha = 0.7;
    [self.tableView addSubview:_logoImageView];
    
    self.title = @"xiaoxiaoxi ";
 
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _logoImageView.frame = CGRectMake(0, -100, self.tableView.frame.size.width, 100);
    _logoImageView.layer.borderColor = [UIColor redColor].CGColor;
    _logoImageView.layer.borderWidth = 1;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(KSSideslipCell.class)];
    if (!cell) {
        cell = [[LYHomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(KSSideslipCell.class)];
        cell.delegate = self;
    }
    cell.model = _dataArray[indexPath.row];
    return cell;
}

 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"------点击了 index: %ld", indexPath.row);
}



#pragma mark - KSSideslipCellDelegate

- (BOOL)sideslipCell:(KSSideslipCell *)sideslipCell canSideslipActionAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row >= 2);
}

- (NSArray<KSSideslipCellAction *> *)sideslipCell:(KSSideslipCell *)sideslipCell
                     editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LYHomeCellModel *model = _dataArray[indexPath.row];
    KSSideslipCellAction *action1 = [KSSideslipCellAction rowActionWithStyle:KSSideslipCellActionStyleNormal
                                                                       title:@"取消关注"
                                                                     handler:^(KSSideslipCellAction * _Nonnull action,
                                                                               NSIndexPath * _Nonnull indexPath) {
        NSLog(@"取消关注");
        [sideslipCell hiddenAllSideslip];
    }];
    
    KSSideslipCellAction *action2 = [KSSideslipCellAction rowActionWithStyle:KSSideslipCellActionStyleDestructive
                                                                       title:@"删除"
                                                                     handler:^(KSSideslipCellAction * _Nonnull action,
                                                                               NSIndexPath * _Nonnull indexPath) {
        
        NSLog(@" 点击了  删除");
    }];
    
    KSSideslipCellAction *action3 = [KSSideslipCellAction rowActionWithStyle:KSSideslipCellActionStyleNormal
                                                                       title:@"置顶"
                                                                     handler:^(KSSideslipCellAction * _Nonnull action,
                                                                               NSIndexPath * _Nonnull indexPath) {
        NSLog(@"置顶");
        [sideslipCell hiddenAllSideslip];
    }];
    return @[action1, action2, action3];
     
}




- (KSSideslipCellAction *)sideslipCell:(KSSideslipCell *)sideslipCell confirmActionAtIndexPath:(NSIndexPath *)indexPath forAction:(KSSideslipCellAction *)action{
    if ([action.title isEqualToString:@"取消关注"]) {
        KSSideslipCellAction *action = [KSSideslipCellAction rowActionWithStyle:KSSideslipCellActionStyleNormal
                                                                              title:@"确认 取消关注"
                                                                            handler:^(KSSideslipCellAction * _Nonnull action,
                                                                                      NSIndexPath * _Nonnull actionIndexPath) {
            NSLog(@"-----确认 取消关注 被点击了: indexRow:%ld- ", actionIndexPath.row);
            [_dataArray removeObjectAtIndex:actionIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[actionIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        
        return action;
    }
    
    if ([action.title isEqualToString:@"删除"]) {
           KSSideslipCellAction *action = [KSSideslipCellAction rowActionWithStyle:KSSideslipCellActionStyleDestructive
                                                                                 title:@"确认 删除"
                                                                               handler:^(KSSideslipCellAction * _Nonnull action,
                                                                                         NSIndexPath * _Nonnull actionIndexPath) {
               NSLog(@"-----确认 删除 被点击了: indexRow:%ld- ", actionIndexPath.row);
               [_dataArray removeObjectAtIndex:actionIndexPath.row];
               [self.tableView deleteRowsAtIndexPaths:@[actionIndexPath] withRowAnimation:UITableViewRowAnimationFade];
           }];
           
           return action;
       }
    return nil;
}




@end
