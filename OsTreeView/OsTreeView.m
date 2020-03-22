//
//  OsTreeView.m
//  OsTreeView
//
//  Created by OneSecure on 2017/2/1.
//
//

#import "OsTreeView.h"
#import "OsTreeViewCell.h"
#import "OsTreeNode.h"

@interface OsTreeView () <UITableViewDataSource, UITableViewDelegate, OsTreeViewCellDelegate>
@end

@implementation OsTreeView {
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate=self;
        self.dataSource=self;
        self.separatorStyle= UITableViewCellSeparatorStyleNone;
        _textColor = [UIColor blackColor];
        _font = [UIFont systemFontOfSize:16];
        _editable = YES;
    }
    return self;
}

- (void) insertTreeNode:(OsTreeNode *)treeNode {
    OsTreeNode *targetNode = nil;

    NSArray<OsTreeViewCell *> *cells = [self visibleCells];

    for (OsTreeViewCell *cell in cells) {
        OsTreeNode *iter = [self treeNodeForTreeViewCell:cell];
        if (iter == _selectedNode) {
            targetNode = iter;
            break;
        }
    }
    if (targetNode == nil) {
        targetNode = [self treeNodeForTreeViewCell:cells[0]];
    }
    NSAssert(targetNode, @"targetNode == nil, something went wrong!");
    [targetNode insertTreeNode:treeNode];

    if ([_treeViewDelegate respondsToSelector:@selector(treeView:addTreeNode:)]) {
        [_treeViewDelegate treeView:self addTreeNode:treeNode];
    }

    [self reloadData];
    [self resetSelection:NO];
}

- (void) setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self reloadData];
    [self resetSelection:NO];
}

- (void) setFont:(UIFont *)font {
    _font = font;
    [self reloadData];
    [self resetSelection:NO];
}

- (void) setEditing:(BOOL)editing {
    [super setEditing:(_editable ? editing : NO)];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    if (_editable) {
        [super setEditing:editing animated:animated];
    } else {
        [super setEditing:NO animated:NO];
    }
}

- (void) setSelectedNode:(OsTreeNode *)selectedNode {
    _selectedNode = selectedNode;
    if (selectedNode) {
        NSArray<OsTreeNode *> *allParents = [selectedNode allParents];
        for (OsTreeNode *object in allParents) {
            object.expanded = YES;
        }
        [self resetSelection:YES];
    }
}

- (void) resetSelection:(BOOL)delay {
    NSInteger row = NSNotFound;
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:rowForTreeNode:)]) {
        row = [_treeViewDelegate treeView:self rowForTreeNode:_selectedNode];
    }
    if (row != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        dispatch_block_t run = ^ {
            [self selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        };
        if (delay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), run);
        } else {
            run();
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if ([_treeViewDelegate respondsToSelector:@selector(numberOfRowsInTreeView:)]) {
        count = [_treeViewDelegate numberOfRowsInTreeView:self];
    }
    return count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:heightForRow:)]) {
        return [_treeViewDelegate treeView:(OsTreeView *)tableView heightForRow:indexPath.row];
    }
    CGSize size = [@"ABCD" sizeWithAttributes: @{NSFontAttributeName:_font}];
    return size.height*2;
}

- (BOOL) isDarkMode {
    if (@available(iOS 13.0, *)) {
        return (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    }
    return NO;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    OsTreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
    OsTreeViewCell *cell = [[OsTreeViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:CellIdentifier
                                                       level:[treeNode levelDepth]
                                                    expanded:treeNode.expanded
                                                    isFolder:treeNode.isFolder
                                                  isSelected:treeNode.checked];
    cell.titleLabel.text = treeNode.title;
    cell.textLabel.textColor = _textColor;
    cell.titleLabel.font = _font;
    cell.showCheckBox = _showCheckBox;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.isDarkMode) {
        cell.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }

    cell.delegate = self;
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_editable) {
        return NO;
    }
    OsTreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:canEditTreeNode:)]) {
        return [_treeViewDelegate treeView:self canEditTreeNode:treeNode];
    } else {
        return (treeNode.isRoot == NO);
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    OsTreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [treeNode removeFromParent];
        if ([_treeViewDelegate respondsToSelector:@selector(treeView:removeTreeNode:)]) {
            [_treeViewDelegate treeView:self removeTreeNode:treeNode];
        }
        if (treeNode.isFolder && treeNode.expanded && treeNode.hasChildren) {
            [self reloadData];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self resetSelection:YES];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if ([fromIndexPath isEqual:toIndexPath]) {
        return;
    }
    OsTreeNode *srcNode = [self treeNodeForIndexPath:fromIndexPath];
    OsTreeNode *targetNode = [self treeNodeForIndexPath:toIndexPath];
    [srcNode moveToDestination:targetNode];

    if ([_treeViewDelegate respondsToSelector:@selector(treeView:moveTreeNode:to:)]) {
        [_treeViewDelegate treeView:self moveTreeNode:srcNode to:targetNode];
    }

    [self reloadData];
    [self resetSelection:NO];
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    OsTreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:canMoveTreeNode:)]) {
        return [_treeViewDelegate treeView:self canMoveTreeNode:treeNode];
    } else {
        return (treeNode.isRoot == NO);
    }
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OsTreeNode *treeNode = [self treeNodeForIndexPath:indexPath];
    _selectedNode = treeNode;
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:didSelectedTreeNode:)]) {
        [_treeViewDelegate treeView:self didSelectedTreeNode:treeNode];
    }
}

- (NSIndexPath *)                  tableView:(UITableView *)tableView
    targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                         toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    OsTreeNode *srcNode = [self treeNodeForIndexPath:sourceIndexPath];
    OsTreeNode *targetNode = [self treeNodeForIndexPath:proposedDestinationIndexPath];
    if ([srcNode containsTreeNode:targetNode] || srcNode==targetNode) {
        return sourceIndexPath;
    } else {
        // NSLog(@"Moving to target node \"%@\"", targetNode.title);
        return proposedDestinationIndexPath;
    }
}

#pragma mark - OsTreeViewCellDelegate

- (BOOL) queryCheckableInTreeViewCell:(OsTreeViewCell *)treeViewCell {
    BOOL allow = YES;
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:queryCheckableInTreeNode:)]) {
        OsTreeNode *treeNode = [self treeNodeForTreeViewCell:treeViewCell];
        allow = [_treeViewDelegate treeView:self queryCheckableInTreeNode:treeNode];
    }
    return allow;
}

- (void) treeViewCell:(OsTreeViewCell *)treeViewCell checked:(BOOL)checked {
    OsTreeNode *treeNode = [self treeNodeForTreeViewCell:treeViewCell];
    treeNode.checked = checked;
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:treeNode:checked:)]) {
        [_treeViewDelegate treeView:self treeNode:treeNode checked:checked];
    }
}

- (BOOL) queryExpandableInTreeViewCell:(OsTreeViewCell *)treeViewCell {
    BOOL allow = YES;
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:queryExpandableInTreeNode:)]) {
        OsTreeNode *treeNode = [self treeNodeForTreeViewCell:treeViewCell];
        allow = [_treeViewDelegate treeView:self queryExpandableInTreeNode:treeNode];
    }
    return allow;
}

- (void) treeViewCell:(OsTreeViewCell *)treeViewCell expanded:(BOOL)expanded {
    OsTreeNode *treeNode = [self treeNodeForTreeViewCell:treeViewCell];
    if (treeNode.isFolder) {
        treeNode.expanded = expanded;
        if (treeNode.hasChildren) {
            [self reloadData];
            [self resetSelection:NO];
        }
        if ([_treeViewDelegate respondsToSelector:@selector(treeView:treeNode:expanded:)]) {
            [_treeViewDelegate treeView:self treeNode:treeNode expanded:expanded];
        }
    }
}

#pragma mark - retrieve OsTreeNode object from special cell

- (OsTreeNode *) treeNodeForTreeViewCell:(OsTreeViewCell *)treeViewCell {
    NSIndexPath *indexPath = [self indexPathForCell:treeViewCell];
    return [self treeNodeForIndexPath:indexPath];
}

- (OsTreeNode *) treeNodeForIndexPath:(NSIndexPath *)indexPath {
    OsTreeNode *treeNode = nil;
    if ([_treeViewDelegate respondsToSelector:@selector(treeView:treeNodeForRow:)]) {
        treeNode = [_treeViewDelegate treeView:self treeNodeForRow:indexPath.row];
    }
    NSAssert(treeNode, @"Can't get the Tree Node data");
    return treeNode;
}

@end
