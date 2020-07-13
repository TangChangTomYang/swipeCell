//
//  UITableView+KSSideslipCell.h
//  LYSideslipCellDemo
//
//  Created by edz on 2020/7/13.
//  Copyright © 2020 Louis. All rights reserved.
//
 
#import <UIKit/UIKit.h>
@class KSSideslipCellProxy;
@class KSSideslipCell;

@interface UITableView (KSSideslipCell)

#pragma mark- 给 tableView 扩展的属性
@property (nonatomic) KSSideslipCellProxy *sideslipCellProxy;
@property (nonatomic) BOOL sideslip;

/**
  隐藏所有cell的侧滑按钮
 */
- (void)hiddenAllSideslip;
- (void)hiddenOtherSideslip:(KSSideslipCell *)cell;
@end
 
