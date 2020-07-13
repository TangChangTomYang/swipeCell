//
//  UITableView+KSSideslipCell.m
//  LYSideslipCellDemo
//
//  Created by edz on 2020/7/13.
//  Copyright © 2020 Louis. All rights reserved.
//

#import "UITableView+KSSideslipCell.h"
#import "KSSideslipCellProxy.h"
#import "KSSideslipCell.h"

#import <objc/runtime.h>

 
@implementation UITableView (KSSideslipCell)
#pragma mark - 隐藏扩展按钮

- (void)hiddenOtherSideslip:(KSSideslipCell *)cell {
    self.sideslip = NO;
    for (KSSideslipCell *c in self.visibleCells) {
        if (c == cell) {
            self.sideslip = YES;
        }else if ([c isKindOfClass:KSSideslipCell.class] && c.sideslip ) {
            
            [c hiddenSideslip];
        }
    }
}

- (void)hiddenAllSideslip {
    self.sideslip = NO;
    for (KSSideslipCell *cell in self.visibleCells) {
        if ([cell isKindOfClass:KSSideslipCell.class] && cell.sideslip) {
            [cell hiddenSideslip];
        }
    }
}


-(void)setSideslipCellProxy:(KSSideslipCellProxy *)sideslipCellProxy{
    objc_setAssociatedObject(self, @selector(sideslipCellProxy), sideslipCellProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(KSSideslipCellProxy *)sideslipCellProxy{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSideslip:(BOOL)sideslip {
    objc_setAssociatedObject(self, @selector(sideslip), [NSNumber numberWithBool:sideslip], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)sideslip {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end
