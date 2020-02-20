//
//  OsTreeViewCell.m
//  OsTreeView
//
//  Created by OneSecure on 2017/2/1.
//

#import "OsTreeViewCell.h"

CGRect CGRectInflate(CGRect rect, CGFloat dx, CGFloat dy) {
    return CGRectMake(rect.origin.x-dx, rect.origin.y-dy, rect.size.width+2*dx, rect.size.height+2*dy);
}

static CGFloat IMG_HEIGHT_WIDTH = 20;
static CGFloat XOFFSET = 3;

@implementation OsTreeViewCell {
    OsCheckableButton *_arrowImageButton;
    OsCheckableButton *_checkBox;
}

- (UIImage *) bundleImageNamed:(NSString *)name {
    return [UIImage imageNamed:name
                      inBundle:[NSBundle bundleForClass:self.class]
 compatibleWithTraitCollection:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              level:(NSUInteger)level
           expanded:(BOOL)expanded
           isFolder:(BOOL)isFolder
         isSelected:(BOOL)value {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        _level = level;
        _expanded = expanded;
        _isSelected = value;
        _showCheckBox = NO;

        UIView *content = self.contentView;

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [content addSubview:titleLabel];
        _titleLabel = titleLabel;

        OsCheckableButton *checkBox = [[OsCheckableButton alloc] initWithFrame:CGRectMake(0, 0, IMG_HEIGHT_WIDTH, IMG_HEIGHT_WIDTH)];
        checkBox.checkedImage = [self bundleImageNamed:@"check_box"];
        checkBox.uncheckedImage = [self bundleImageNamed:@"uncheck_box"];
        [content addSubview:checkBox];
        [checkBox setWillCheckedBeginning:^BOOL{
            BOOL allow = YES;
            if ([self->_delegate respondsToSelector:@selector(queryCheckableInTreeViewCell:)]) {
                allow = [self->_delegate queryCheckableInTreeViewCell:self];
            }
            return allow;
        }];
        [checkBox setDidCheckedChanged:^(BOOL checked) {
            self->_isSelected = checked;
            if ([self->_delegate respondsToSelector:@selector(treeViewCell:checked:)]) {
                [self->_delegate treeViewCell:self checked:checked];
            }
        }];
        [checkBox setChecked:_isSelected];
        _checkBox = checkBox;

        OsCheckableButton *arrowImageButton = [[OsCheckableButton alloc] initWithFrame:CGRectMake(0, 0, IMG_HEIGHT_WIDTH, IMG_HEIGHT_WIDTH)];
        if (isFolder) {
            arrowImageButton.checkedImage = [self bundleImageNamed:@"open"];
            arrowImageButton.uncheckedImage = [self bundleImageNamed:@"close"];
        } else {
            arrowImageButton.checkedImage = [self bundleImageNamed:@"object"];
            arrowImageButton.uncheckedImage = [self bundleImageNamed:@"object"];
        }
        [arrowImageButton setWillCheckedBeginning:^BOOL{
            BOOL allow = isFolder;
            if (allow) {
                if ([self->_delegate respondsToSelector:@selector(queryExpandableInTreeViewCell:)]) {
                    allow = [self->_delegate queryExpandableInTreeViewCell:self];
                }
            }
            return allow;
        }];
        [arrowImageButton setDidCheckedChanged:^(BOOL checked) {
            if (isFolder == NO) {
                return;
            }
            self->_expanded = checked;
            if ([self->_delegate respondsToSelector:@selector(treeViewCell:expanded:)]) {
                [self->_delegate treeViewCell:self expanded:checked];
            }
        }];
        arrowImageButton.checked = _expanded;
        [content addSubview:arrowImageButton];
        _arrowImageButton = arrowImageButton;
    }
    return self;
}

#pragma mark -
#pragma mark Other overrides

- (void) layoutSubviews {
    [super layoutSubviews];

    CGSize size = self.contentView.bounds.size;
    CGFloat stepSize = size.height;
    CGRect rc = CGRectMake(_level * stepSize, 0, stepSize, stepSize);
    _arrowImageButton.frame = CGRectInflate(rc, -XOFFSET, -XOFFSET);

    _checkBox.hidden = !_showCheckBox;

    if (_showCheckBox) {
        rc = CGRectMake((_level + 1) * stepSize, 0, stepSize, stepSize);
        _checkBox.frame = CGRectInflate(rc, -XOFFSET, -XOFFSET);
        _titleLabel.frame = CGRectMake((_level + 2) * stepSize, 0, size.width - (_level + 3) * stepSize, stepSize);
    } else {
        _titleLabel.frame = CGRectMake((_level + 1) * stepSize, 0, size.width - (_level + 2) * stepSize, stepSize);
    }
}

@end
