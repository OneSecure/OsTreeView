//
//  OsComboTreeView.h
//  OsTreeView
//
//  Created by oneSecure on 20-02-24.
//  Copyright (c) 2020 oneSecure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OsTreeNode;

@interface OsComboTreeView : UIControl
@property(nonatomic, strong) OsTreeNode *rootNode;
@property(nonatomic, strong) OsTreeNode *selectedNode;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, strong) void (^onNodeSelected)(OsTreeNode *selectedNode);
@property(nonatomic, strong) void (^onNodeDeleted)(OsTreeNode *deletedNode);
@property(nonatomic, strong) UIColor *borderColor;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, assign) BOOL showArrow;
@end

