//
//  ViewController.m
//  demo
//
//  Created by OneSecure on 24/01/2017.
//  Copyright © 2017 OneSecure. All rights reserved.
//

#import "ViewController.h"
#import <OsTreeView/OsTreeView.h>
#import "NodeData.h"

@interface ViewController () <OsTreeViewDelegate>
@end

@implementation ViewController {
    OsTreeView *_tree;
    OsTreeNode *_rootTreeNode;
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    return self;
}

#pragma mark - OsTreeViewDelegate
- (NSInteger) numberOfRowsInTreeView:(OsTreeView *)treeView {
    return [_rootTreeNode visibleNodes].count;
}

- (OsTreeNode *) treeView:(OsTreeView *)treeView treeNodeForRow:(NSInteger)row {
    return [[_rootTreeNode visibleNodes] objectAtIndex:row];
}

- (NSInteger) treeView:(OsTreeView *)treeView rowForTreeNode:(OsTreeNode *)treeNode {
    return [[_rootTreeNode visibleNodes] indexOfObject:treeNode];
}

- (void) treeView:(OsTreeView *)treeView removeTreeNode:(OsTreeNode *)treeNode {
    NSLog(@"OsTreeNode \"%@\" removeFromParent", treeNode.title);
}

- (void) treeView:(OsTreeView *)treeView moveTreeNode:(OsTreeNode *)treeNode to:(OsTreeNode *)to {
}

- (void) treeView:(OsTreeView *)treeView addTreeNode:(OsTreeNode *)treeNode {
}

- (void) treeView:(OsTreeView *)treeView didSelectForTreeNode:(OsTreeNode *)treeNode {
    NSLog(@"Node %@ selected", treeNode.title);
}

- (BOOL) treeView:(OsTreeView *)treeView queryCheckableInTreeNode:(OsTreeNode *)treeNode {
    return YES;
}

- (void) treeView:(OsTreeView *)treeView treeNode:(OsTreeNode *)treeNode checked:(BOOL)checked {
    NSLog(@"Node %@ checked = %d", treeNode.title, checked);
}

- (BOOL) treeView:(OsTreeView *)treeView queryExpandableInTreeNode:(OsTreeNode *)treeNode {
    return YES;
}

- (void) treeView:(OsTreeView *)treeView treeNode:(OsTreeNode *)treeNode expanded:(BOOL)expanded {
    NSLog(@"Node %@ expanded = %d", treeNode.title, expanded);
}

- (BOOL) treeView:(OsTreeView *)treeView canEditTreeNode:(OsTreeNode *)treeNode {
    return (treeNode.isRoot == NO);
}

- (BOOL) treeView:(OsTreeView *)treeView canMoveTreeNode:(OsTreeNode *)treeNode {
    return (treeNode.isRoot == NO);
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];

    _tree = [[OsTreeView alloc] initWithFrame:CGRectMake(100, 60, 300, 300)];
    _tree.showCheckBox = YES;
    _tree.treeViewDelegate = self;
    _rootTreeNode = [NodeData createTree];

    [self.view addSubview:_tree];
    //UIFont *font =[UIFont fontWithName:@"Helvetica" size:10];
    //[_tree setFont:font];

    [self _treeBoarder];

    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    UIBarButtonItem *addFolder = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addfolder"] style:UIBarButtonItemStylePlain target:self action:@selector(addFolder:)];
    UIBarButtonItem *addObject = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addobject"] style:UIBarButtonItemStylePlain target:self action:@selector(addObject:)];
    self.navigationItem.rightBarButtonItems = @[edit, addFolder, addObject];
}

- (void) _treeBoarder {
    _tree.layer.cornerRadius = 7.;
    _tree.layer.borderWidth = .5;
    _tree.layer.masksToBounds = YES;
    _tree.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void) edit:(UIBarButtonItem *)sender {
    _tree.editing = !_tree.editing;
}

- (void) addFolder:(UIBarButtonItem *)sender {
    NodeData *data = [[NodeData alloc] init];
    data.name = @"Holy shit folder";
    OsTreeNode *node = [[OsTreeNode alloc] initWithValue:data];
    node.isFolder = YES;
    [_tree insertTreeNode:node];
}

- (void) addObject:(UIBarButtonItem *)sender {
    NodeData *data = [[NodeData alloc] init];
    data.name = @"Holy shit object";
    OsTreeNode *node = [[OsTreeNode alloc] initWithValue:data];
    node.isFolder = NO;
    [_tree insertTreeNode:node];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {
    CGFloat left = 8;
    CGFloat top = 8;
    [super viewDidLayoutSubviews];
    CGSize size = self.view.frame.size;
    _tree.frame = CGRectMake(left, top, size.width-left*2, size.height-top*2);
}

@end
