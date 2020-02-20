//
//  OsTreeViewCell.h
//  OsTreeView
//
//  Created by OneSecure on 2017/2/1.
//

#import <Foundation/Foundation.h>
#import "OsCheckButton.h"

@class OsTreeViewCell;

@protocol OsTreeViewCellDelegate <NSObject>
//@optional
- (BOOL) queryCheckableInTreeViewCell:(OsTreeViewCell *)treeViewCell;
- (void) treeViewCell:(OsTreeViewCell *)treeViewCell checked:(BOOL)checked;
- (BOOL) queryExpandableInTreeViewCell:(OsTreeViewCell *)treeViewCell;
- (void) treeViewCell:(OsTreeViewCell *)treeViewCell expanded:(BOOL)expanded;
@end

@interface OsTreeViewCell : UITableViewCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic) NSUInteger level;
@property(nonatomic) BOOL expanded;
@property(nonatomic) BOOL isFolder;
@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) BOOL showCheckBox;
@property(nonatomic, assign) id <OsTreeViewCellDelegate> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier
                         level:(NSUInteger)level
                      expanded:(BOOL)expanded
                      isFolder:(BOOL)isFolder
                    isSelected:(BOOL)value;

@end
