//
//  OsTreeView.h
//  OsTreeView
//
//  Created by OneSecure on 2017/2/1.
//
// https://github.com/OneSecure/OsTreeView
//
//

#import <UIKit/UIKit.h>
#import "OsTreeNode.h"

@class OsTreeNode;
@class OsTreeView;

@protocol OsTreeViewDelegate <NSObject>
@required
- (NSInteger) numberOfRowsInTreeView:(OsTreeView *)treeView;
- (OsTreeNode *) treeView:(OsTreeView *)treeView treeNodeForRow:(NSInteger)row;
- (NSInteger) treeView:(OsTreeView *)treeView rowForTreeNode:(OsTreeNode *)treeNode;
- (void) treeView:(OsTreeView *)treeView removeTreeNode:(OsTreeNode *)treeNode;
- (void) treeView:(OsTreeView *)treeView moveTreeNode:(OsTreeNode *)treeNode to:(OsTreeNode *)to;
- (void) treeView:(OsTreeView *)treeView addTreeNode:(OsTreeNode *)treeNode;

//@optional
- (void) treeView:(OsTreeView *)treeView didSelectForTreeNode:(OsTreeNode *)treeNode;
- (BOOL) treeView:(OsTreeView *)treeView queryCheckableInTreeNode:(OsTreeNode *)treeNode;
- (void) treeView:(OsTreeView *)treeView treeNode:(OsTreeNode *)treeNode checked:(BOOL)checked;
- (BOOL) treeView:(OsTreeView *)treeView queryExpandableInTreeNode:(OsTreeNode *)treeNode;
- (void) treeView:(OsTreeView *)treeView treeNode:(OsTreeNode *)treeNode expanded:(BOOL)expanded;
@optional
- (BOOL) treeView:(OsTreeView *)treeView canEditTreeNode:(OsTreeNode *)treeNode;
- (BOOL) treeView:(OsTreeView *)treeView canMoveTreeNode:(OsTreeNode *)treeNode;
@end


@interface OsTreeView : UITableView

@property(nonatomic, strong) UIFont *font;
@property(nonatomic, assign) BOOL showCheckBox;
@property(nonatomic, strong) OsTreeNode *treeNode;
@property(nonatomic, weak) id<OsTreeViewDelegate> treeViewDelegate;

- (instancetype) initWithFrame:(CGRect)frame;
- (void) insertOsTreeNode:(OsTreeNode *)treeNode;
@end
