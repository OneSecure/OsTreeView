//
//  OsComboTreeView.m
//  OsTreeView
//
//  Created by oneSecure on 14-12-24.
//  Copyright (c) 2014 oneSecure. All rights reserved.
//

#import "OsComboTreeView.h"
#import "OsTreeView.h"

static const NSTimeInterval kAnimateInerval = 0.2;

//========================== OsPassthroughView =============================================

@interface OsPassthroughView : UIView
@property (nonatomic, copy) NSArray<UIView *> *passViews;
@property(nonatomic, strong) void(^doPassthrough)(BOOL isPass);
@end

@implementation OsPassthroughView {
    BOOL _testHits;
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_testHits) {
        return nil;
    }
    if (!self.passViews || (self.passViews && self.passViews.count==0)) {
        return nil;
    }
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        _testHits = YES;
        CGPoint superPoint = [self.superview convertPoint:point fromView:self];
        UIView *superHitView = [self.superview hitTest:superPoint withEvent:event];
        _testHits = NO;
        BOOL pass = [self isPassthroughView:superHitView];
        if (pass) {
            hitView = superHitView;
        }
        if (_doPassthrough) {
            _doPassthrough(pass);
        }
    }
    return hitView;
}

- (BOOL) isPassthroughView:(UIView *)view {
    if (view == nil) {
        return NO;
    }
    if ([self.passViews containsObject:view]) {
        return YES;
    }
    return [self isPassthroughView:view.superview];
}

@end


//========================== OsImageTextView ==========================================

@interface OsImageTextView : UIView
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, assign) NSTextAlignment textAlignment;
@property(nonatomic, strong) UIColor *shadowColor;
@property(nonatomic, assign) BOOL highlighted;
- (instancetype)initWithFrame:(CGRect)frame;
@end

@implementation OsImageTextView {
    UILabel *_textLabel;
    UIImageView *_imageView;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];

        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}

- (NSString *) text {
    return _textLabel.text;
}

- (void) setText:(NSString *)text {
    _textLabel.text = text;
}

- (UIFont *) font {
    return _textLabel.font;
}

- (void) setFont:(UIFont *)font {
    _textLabel.font = font;
}

- (UIColor *) textColor {
    return _textLabel.textColor;
}

- (void) setTextColor:(UIColor *)textColor {
    _textLabel.textColor = textColor;
}

- (NSTextAlignment) textAlignment {
    return _textLabel.textAlignment;
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment {
    _textLabel.textAlignment = textAlignment;
}

- (UIColor *) shadowColor {
    return _textLabel.shadowColor;
}

- (void) setShadowColor:(UIColor *)shadowColor {
    _textLabel.shadowColor = shadowColor;
}

- (BOOL) highlighted {
    return _textLabel.highlighted;
}

- (void) setHighlighted:(BOOL)highlighted {
    _textLabel.highlighted = highlighted;
}

- (UIImage *) image {
    return _imageView.image;
}

- (void) setImage:(UIImage *)image {
    _imageView.image = image;
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    if (_imageView.image) {
        _imageView.frame = CGRectMake(0, 0, height, height);
        _textLabel.frame = CGRectMake(height, 0, width-height, height);
    } else {
        _imageView.frame = CGRectMake(0, 0, 0, height);
        _textLabel.frame = CGRectMake(0, 0, width, height);
    }
}

@end


//========================== OsComboTreeView =============================================


@interface OsComboTreeView () <OsTreeViewDelegate>
@end

@implementation OsComboTreeView {
    __weak OsImageTextView *_textLabel;
    __weak UIImageView *_rightView;
    OsTreeView *_internalTreeView;
    OsPassthroughView *_passthroughView;
    BOOL _tableViewOnAbove;
    NSDate *_tapMoment;
    
    OsTreeNode *_rootNode;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"OsComboTreeView instance %0xd", (int)self];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubviews];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (instancetype) init {
    if (self = [super initWithFrame:CGRectMake(58, 102, 165, 37)]) {
        [self initSubviews];
    }
    return self;
}

- (void) setRootNode:(OsTreeNode *)rootNode {
    _rootNode = rootNode;
    [_internalTreeView reloadData];
}

- (OsTreeNode*) rootNode {
    return _rootNode;
}

- (void) setSelectedNode:(OsTreeNode *)selectedNode {
    if (_selectedNode == selectedNode) {
        return;
    }
    _selectedNode = selectedNode;
    if (_rootNode == nil) {
        _textLabel.text = nil;
        _textLabel.image = nil;
        NSAssert(selectedNode == nil, @"selectedNode == nil");
        return;
    }
    
    [self _putLabels:selectedNode];

    [_internalTreeView setSelectedNode:selectedNode];
}

- (void) setEditable:(BOOL)editable {
    _editable = editable;
    [_internalTreeView setEditable:editable];
}

- (void) _putLabels:(OsTreeNode*)node {
    id obj = node.value;
    NSString *text = nil;
    if ([obj respondsToSelector:@selector(description)]) {
        text = [obj performSelector:@selector(description)];
    }
    _textLabel.text = text.length ? text : @"(NULL)";

    if ([obj respondsToSelector:@selector(image)]) {
        _textLabel.image = [obj performSelector:@selector(image)];
    }
}

- (void) setEnabled:(BOOL)enabled {
    //_textLabel.textLabel.enabled = enabled;
    _textLabel.textColor = enabled?[UIColor blackColor]:[UIColor grayColor];
    _rightView.highlighted = !enabled;
    [super setEnabled:enabled];
}

- (void) setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (UIFont *) font {
    return _textLabel.font;
}

- (void) setFont:(UIFont *)font {
    _textLabel.font = font;
    _internalTreeView.font = font;
    [_internalTreeView reloadData];
}

- (UIColor *) textColor {
    return _textLabel.textColor;
}

- (void) setTextColor:(UIColor *)textColor {
    _textLabel.textColor = textColor;
    _internalTreeView.textColor = textColor;
    [_internalTreeView reloadData];
}

- (void) setShowArrow:(BOOL)showArrow {
    _showArrow = showArrow;
    [self layoutIfNeeded];
}

- (UIImage *) bundleImageNamed:(NSString *)name {
    return [UIImage imageNamed:name
                      inBundle:[NSBundle bundleForClass:self.class]
 compatibleWithTraitCollection:nil];
}

- (void) initSubviews {
    self.layer.cornerRadius = 7.;
    self.layer.borderWidth = .5;
    _borderColor = [UIColor colorWithCGColor:self.layer.borderColor];

    OsImageTextView *textLabel = [[OsImageTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel];
    _textLabel = textLabel;

    UIImageView *rightView = [[UIImageView alloc] initWithImage:[self bundleImageNamed:@"combobox_down"]];
    rightView.highlightedImage = [self bundleImageNamed:@"combobox_down_highlighed"];
    [self addSubview:rightView];
    _rightView = rightView;

    self.userInteractionEnabled = YES;

    _rootNode = [[OsTreeNode alloc] initWithValue:nil];
    
    _tapMoment = [NSDate date];
    
    _showArrow = YES;
    
    //_selectedNode = _rootNode;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGRect rc = CGRectZero; rc.size = self.frame.size;

    if (_showArrow) {
        CGRect rcRight = rc;
        rcRight.size.width = rc.size.height;
        rcRight.origin.x = rc.origin.x + rc.size.width -rcRight.size.width;

        CGRect rcLabel = rc;
        rcLabel.size.width = rc.size.width - rcRight.size.width;

        rcLabel = CGRectInset(rcLabel, 2, 2);
        rcRight = CGRectInset(rcRight, 2, 2);

        _textLabel.frame = rcLabel;
        _rightView.frame = rcRight;
    } else {
        _textLabel.frame = rc;
        _rightView.frame = CGRectZero;
    }

    _passthroughView.frame = [UIScreen mainScreen].bounds;
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.enabled) {
        if (CGRectContainsPoint(_textLabel.frame, point) || CGRectContainsPoint(_rightView.frame, point)) {
            [self tapHandle];
        }
    }
    return [super hitTest:point withEvent:event];
}

- (void) traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [_internalTreeView reloadData];
}

#pragma mark - firstResponder
- (void) tapHandle {
    UIView *topView = [OsComboTreeView topMostView:self];
    NSAssert(topView, @"Can not obtain the most-top leave view.");
    if (!_internalTreeView) {
        OsTreeView * treeView0 = [[OsTreeView alloc] initWithFrame:CGRectZero];
        treeView0.showCheckBox = NO;
        treeView0.treeViewDelegate = self;
        treeView0.layer.cornerRadius = 7.;
        treeView0.layer.borderWidth = .5;
        treeView0.font = _textLabel.font;
        treeView0.textColor = _textLabel.textColor;
        treeView0.editable = _editable;
        _internalTreeView = treeView0;
    }

    OsTreeView *treeView = _internalTreeView;

    if ([_borderColor isEqual:[UIColor whiteColor]]) {
        treeView.layer.borderColor = [UIColor blackColor].CGColor;
    } else {
        treeView.layer.borderColor = _borderColor.CGColor;
    }

    if (treeView.superview == nil) {

        NSDate *current = [NSDate date];
        if ([current timeIntervalSinceDate:_tapMoment] < kAnimateInerval) {
            return;
        }
        _tapMoment = current;

        _rightView.image = [self bundleImageNamed:@"combobox_up"];
        _rightView.highlightedImage = [self bundleImageNamed:@"combobox_up_highlighed"];

        CGRect frame = [self calcTableViewRect];
        
        [topView addSubview:treeView];

        CGRect initRc = frame;
        if (_tableViewOnAbove) {
            initRc.origin.y += initRc.size.height;
        }
        initRc.size.height = 0;
        treeView.frame = initRc;
        [UIView animateWithDuration:kAnimateInerval animations:^{
            treeView.frame = frame;
        } completion:^(BOOL finished) {
            //
        }];

        treeView.selectedNode = _selectedNode;

        if (_passthroughView == nil) {
            CGRect rc = [UIScreen mainScreen].bounds;

            _passthroughView = [[OsPassthroughView alloc] initWithFrame:rc];
            _passthroughView.passViews = @[self, treeView, ];

            __weak typeof(self) weakSelf = self;
            [_passthroughView setDoPassthrough:^(BOOL isPass) {
                __strong typeof(self) strongSelf = weakSelf;
                if (!isPass) {
                    [strongSelf doClearup];
                }
            }];
        }
        [topView addSubview:_passthroughView];
    } else {
        [self doClearup];
    }
}

#pragma mark - change state when highlighed

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    _rightView.highlighted = highlighted; // change button to highlighed state
    _textLabel.highlighted = highlighted; // change label to highlighed state
    _textLabel.shadowColor = highlighted ? [UIColor lightGrayColor] : nil;
}

#pragma mark - OsTreeViewDelegate
- (NSInteger) numberOfRowsInTreeView:(OsTreeView *)treeView {
    return [_rootNode visibleNodes].count;
}

- (CGFloat) treeView:(OsTreeView *)treeView heightForRow:(NSInteger)row {
    return self.frame.size.height;
}

- (OsTreeNode *) treeView:(OsTreeView *)treeView treeNodeForRow:(NSInteger)row {
    return [[_rootNode visibleNodes] objectAtIndex:row];
}

- (NSInteger) treeView:(OsTreeView *)treeView rowForTreeNode:(OsTreeNode *)treeNode {
    return [[_rootNode visibleNodes] indexOfObject:treeNode];
}

- (void) treeView:(OsTreeView *)treeView removeTreeNode:(OsTreeNode *)treeNode {
    if (_onNodeDeleted) {
        _onNodeDeleted(treeNode);
    }
}

- (void) treeView:(OsTreeView *)treeView moveTreeNode:(OsTreeNode *)treeNode to:(OsTreeNode *)to {
}

- (void) treeView:(OsTreeView *)treeView addTreeNode:(OsTreeNode *)treeNode {
}

- (void) treeView:(OsTreeView *)treeView didSelectedTreeNode:(OsTreeNode *)treeNode {
    _selectedNode = treeNode;
    [self _putLabels:treeNode];

    [self doClearup];

    if (_onNodeSelected) {
        _onNodeSelected(treeNode);
    }
}

- (BOOL) treeView:(OsTreeView *)treeView queryCheckableInTreeNode:(OsTreeNode *)treeNode {
    return NO; // return YES;
}

- (void) treeView:(OsTreeView *)treeView treeNode:(OsTreeNode *)treeNode checked:(BOOL)checked {
    // NSLog(@"Node %@ checked = %d", treeNode.title, checked);
}

- (BOOL) treeView:(OsTreeView *)treeView queryExpandableInTreeNode:(OsTreeNode *)treeNode {
    return YES;
}

- (void) treeView:(OsTreeView *)treeView treeNode:(OsTreeNode *)treeNode expanded:(BOOL)expanded {
    NSLog(@"Node %@ expanded = %d", treeNode.title, expanded);
}

- (BOOL) treeView:(OsTreeView *)treeView canEditTreeNode:(OsTreeNode *)treeNode {
    return NO; // return (treeNode.isRoot == NO);
}

- (BOOL) treeView:(OsTreeView *)treeView canMoveTreeNode:(OsTreeNode *)treeNode {
    return NO; // return (treeNode.isRoot == NO);
}

#pragma mark -

- (void) doClearup {
    NSDate *current = [NSDate date];
    if ([current timeIntervalSinceDate:_tapMoment] < kAnimateInerval) {
        return;
    }
    _tapMoment = current;
    
    OsTreeView *treeView = _internalTreeView;
    
    CGRect frame = treeView.frame;
    if (_tableViewOnAbove) {
        frame.origin.y += frame.size.height;
    }
    frame.size.height = 0.0;
    [UIView animateWithDuration:kAnimateInerval animations:^{
        treeView.frame = frame;
    } completion:^(BOOL finished) {
        [treeView removeFromSuperview];
        [self->_passthroughView removeFromSuperview];
    }];
    _rightView.image = [self bundleImageNamed:@"combobox_down"];
    _rightView.highlightedImage = [self bundleImageNamed:@"combobox_down_highlighed"];
}

- (CGRect) calcTableViewRect {
    static const CGFloat gapOfViews = 2.0;
    UIView *topView = [OsComboTreeView topMostView:self];
    CGFloat screenHeight = topView.frame.size.height;
    CGFloat screenWidth = topView.frame.size.width;
    CGRect rc = self.frame;
    CGFloat selfHeight = rc.size.height;
    rc = [self.superview convertRect:rc toView:topView];
    
    CGFloat topLine = rc.origin.y - gapOfViews;
    CGFloat bottomLine = rc.origin.y + rc.size.height + gapOfViews;
    
    NSInteger count = [_internalTreeView numberOfRowsInSection:0];
    if (count < 1) {
        count = 1;
    }
    CGFloat tableViewMaxHeight = count * self.frame.size.height;
    CGFloat statusBarHeight = [OsComboTreeView statusBarHeight];
    
    _tableViewOnAbove = NO;
    
    if (bottomLine + tableViewMaxHeight < screenHeight) {
        rc.origin.y = bottomLine;
        rc.size.height = tableViewMaxHeight;
    } else if (topLine - tableViewMaxHeight >= statusBarHeight) {
        rc.origin.y = topLine - tableViewMaxHeight;
        rc.size.height = tableViewMaxHeight;
        _tableViewOnAbove = YES;
    } else {
        if ((topLine - statusBarHeight) > (screenHeight - bottomLine)) {
            rc.origin.y = statusBarHeight + gapOfViews;
            rc.size.height = topLine - (statusBarHeight + gapOfViews);
            _tableViewOnAbove = YES;
        } else {
            rc.origin.y = bottomLine;
            rc.size.height = screenHeight - gapOfViews - bottomLine;
        }
    }
    
    CGFloat gapInCell = 15.0;
    CGFloat imgW = 0;
    CGFloat txtW = 0;
    for (OsTreeNode *obj in [_rootNode visibleNodes]) {
        if (imgW == 0) {
            if ([obj respondsToSelector:@selector(image)]) {
                imgW = selfHeight - 2.5 * 2 + gapInCell;
            }
        }
        
        if ([obj respondsToSelector:@selector(description)]) {
            NSString *text = [obj performSelector:@selector(description)];
            text = (text.length != 0) ? [text stringByAppendingString:@"A"] : @"(NULL)A";
            CGSize size = [text sizeWithAttributes: @{NSFontAttributeName:self.font}];
            txtW = MAX(size.width, txtW);
        }
    }
    CGFloat widthNeeded = gapInCell + imgW + txtW + gapInCell;
    
    CGFloat alignLeftWidthMax = screenWidth - gapOfViews - rc.origin.x;
    CGFloat alignRightWidthMax = rc.origin.x + rc.size.width - gapOfViews;
    
    if (widthNeeded <= rc.size.width) {
        return rc;
    }
    if (alignLeftWidthMax >= alignRightWidthMax) {
        rc.size.width = (alignLeftWidthMax >= widthNeeded) ? widthNeeded : alignLeftWidthMax;
    } else {
        CGFloat finalWidth = (alignRightWidthMax >= widthNeeded) ? widthNeeded : alignRightWidthMax;
        rc.origin.x = rc.origin.x + rc.size.width - finalWidth;
        rc.size.width = finalWidth;
    }
    return rc;
}

#pragma mark -

+ (UIView *) topMostView:(UIView *)view {
    UIView *superView = view.superview;
    if (superView) {
        return [self topMostView:superView];
    } else {
        return view;
    }
}

+ (CGFloat) statusBarHeight {
    // return [UIApplication sharedApplication].statusBarFrame.size.height;
    Class appClass = NSClassFromString(@"UIApplication");
    if (appClass) {
        UIApplication *app = [appClass performSelector:@selector(sharedApplication)];
        if (app) {
            IMP imp = [app methodForSelector:@selector(statusBarFrame)];
            CGRect (*func)(id, SEL) = (void *)imp;
            CGRect rc = func(app, @selector(statusBarFrame));
            return rc.size.height;
        }
    }
    return 0;
}

@end
