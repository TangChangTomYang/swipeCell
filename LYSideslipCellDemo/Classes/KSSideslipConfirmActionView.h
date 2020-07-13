//
//  KSSideslipConfirmActionView.h
//  LYSideslipCellDemo
//
//  Created by edz on 2020/7/13.
//  Copyright © 2020 Louis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSSideslipCellAction.h"
 
@interface KSSideslipConfirmActionView : UIView
@property (nonatomic, strong) KSSideslipCellAction *action;

@property (nonatomic,weak) id targetCell;
@end
 
