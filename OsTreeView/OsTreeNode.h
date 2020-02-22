//
//  OsTreeNode.h
//  OsTreeView
//
//  Created by OneSecure on 2017/2/1.
//

#import <Foundation/Foundation.h>


@interface OsTreeNode : NSObject

@property(nonatomic, strong) id value;
@property(nonatomic, strong, readonly) NSString *title;
@property(nonatomic, weak) OsTreeNode *parent;
@property(nonatomic, retain, readonly) NSMutableArray<OsTreeNode *> *children;
@property(nonatomic, assign, readonly) NSUInteger levelDepth;
@property(nonatomic, assign, readonly) BOOL isRoot;
@property(nonatomic, assign, readonly) BOOL hasChildren;
@property(nonatomic, assign) BOOL expanded;
@property(nonatomic, assign) BOOL isFolder;
@property(nonatomic, assign) BOOL checked;

- (instancetype) initWithValue:(id)value;
- (void) insertTreeNode:(OsTreeNode *)osTreeNode;
- (void) appendChild:(OsTreeNode *)newChild;
- (void) removeFromParent;
- (void) moveToDestination:(OsTreeNode *)destination;
- (BOOL) containsTreeNode:(OsTreeNode *)treeNode;
- (OsTreeNode*) findNodeByValue:(id)value;
- (NSArray<OsTreeNode *> *) visibleNodes;
- (NSArray<OsTreeNode *> *) allParents;
@end
