//
//  NodeData.m
//  demo
//
//  Created by OneSecure on 29/01/2017.
//  Copyright © 2017 OneSecure. All rights reserved.
//

#import "NodeData.h"
#import <OsTreeView/OsTreeView.h>

@implementation NodeData

- (NSString *) description {
    return [_name isKindOfClass:[NSString class]] ? _name : [super description];
}

+ (OsTreeNode *) createTree {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category" ofType:@"plist"]];
    return [self _internalCreateTree:dict];
}

+ (OsTreeNode *) _internalCreateTree:(NSDictionary *)dict {
    NodeData *data = [[NodeData alloc] init];
    data.name = dict[@"name"];

    NSArray *subNodes = dict[@"categories"];
    if ([subNodes isKindOfClass:[NSArray class]] == NO) {
        subNodes = nil;
    }

    OsTreeNode *node = [[OsTreeNode alloc] initWithValue:data];
    node.isFolder = (subNodes != nil);

    node.expanded = node.isFolder ? YES : NO;

    for (NSDictionary *subDict in subNodes) {
        if ([subDict isKindOfClass:[NSDictionary class]]) {
            OsTreeNode *subNode = [self _internalCreateTree:subDict];
            [node appendChild:subNode];
        }
    }

    return node;
}

@end
