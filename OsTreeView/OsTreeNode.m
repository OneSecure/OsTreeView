//
//  OsTreeNode.m
//  OsTreeView
//
//  Created by OneSecure on 2017/2/1.
//

#import "OsTreeNode.h"

@implementation OsTreeNode {
    NSArray *_flattenedTreeCache;
}

- (void) dealloc {
    NSLog(@"OsTreeNode \"%@\" dealloc", self.title);
}

- (instancetype) initWithValue:(id)value {
    if (self = [super init]) {
        _value = value;
        _children = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (NSString *) title {
    if (_value) {
        return [_value description];
    }
    return self.description;
}

- (NSArray<OsTreeNode *> *) visibleNodes {
    NSMutableArray *allElements = [[NSMutableArray alloc] init];
    [allElements addObject:self];
    if (_isFolder) {
        if (_expanded) {
            for (OsTreeNode *child in _children) {
                [allElements addObjectsFromArray:[child visibleNodes]];
            }
        }
    }
    return allElements;
}

- (void) insertOsTreeNode:(OsTreeNode *)treeNode {
    OsTreeNode *parent = nil;
    NSUInteger index = NSNotFound;
    if (self.isFolder) {
        parent = self;
        index = 0;
    } else {
        parent = self.parent;
        index = [parent.children indexOfObject:self];
    }
    treeNode.parent = parent;
    [parent.children insertObject:treeNode atIndex:index];
}

- (void) appendChild:(OsTreeNode *)newChild {
    newChild.parent = self;
    [_children addObject:newChild];
}

- (void) removeFromParent {
    OsTreeNode *parent = self.parent;
    if (parent) {
        [parent.children removeObject:self];
        self.parent = nil;
    }
}

- (void) moveToDestination:(OsTreeNode *)destination {
    NSAssert([self containsOsTreeNode:destination]==NO, @"[self containsOsTreeNode:destination] something gent wrong!");
    if (self == destination || destination == nil) {
        return;
    }
    [self removeFromParent];

    [destination insertOsTreeNode:self];
}

- (BOOL) containsOsTreeNode:(OsTreeNode *)treeNode {
    OsTreeNode *parent = treeNode.parent;
    if (parent == nil) {
        return NO;
    }
    if (self == parent) {
        return YES;
    } else {
        return [self containsOsTreeNode:parent];
    }
}

- (NSUInteger) levelDepth {
    NSUInteger cnt = 0;
    if (_parent != nil) {
        cnt += 1;
        cnt += [_parent levelDepth];
    }
    return cnt;
}

- (BOOL) isRoot {
    return (!_parent);
}

- (BOOL) hasChildren {
    return (_children.count > 0);
}

@end
