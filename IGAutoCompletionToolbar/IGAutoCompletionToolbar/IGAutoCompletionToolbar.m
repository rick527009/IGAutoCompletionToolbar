//
//  IGAutoCompletionToolbar.m
//  IGAutoCompletionToolbar
//
//  Created by Chong Francis on 13年2月26日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "IGAutoCompletionToolbar.h"
#import "IGAutoCompletionToolbarCell.h"
#import "IGAutoCompletionToolbarLayout.h"

#define MAX_LABEL_WIDTH 280.0

NSString* const IGAutoCompletionToolbarCellID = @"IGAutoCompletionToolbarCellID";

@implementation IGAutoCompletionToolbar

@synthesize textField = _textField;
@synthesize items = _items, filteredItems = _filteredItems, filter = _filter;

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[[IGAutoCompletionToolbarLayout alloc] init]];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.items = [NSArray array];
        self.filter = nil;

        [self registerClass:[IGAutoCompletionToolbarCell class]
 forCellWithReuseIdentifier:IGAutoCompletionToolbarCellID];

        self.dataSource = self;
        self.delegate = self;

        CAGradientLayer* gradient = [CAGradientLayer layer];
        UIColor * highColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
        UIColor * lowColor = [UIColor colorWithRed:0.322 green:0.361 blue:0.412 alpha:1];
        gradient.frame = self.bounds;
        gradient.colors = @[(id)[highColor CGColor],
                            (id)[lowColor CGColor]];
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [self.backgroundView.layer addSublayer:gradient];
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

-(void) setTextField:(UITextField *)textField {
    if (_textField != textField) {
        if (_textField != NULL) {
            [_textField removeTarget:self action:@selector(autoCompletionToolbarTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        }

        if (textField != NULL) {
            [textField addTarget:self action:@selector(autoCompletionToolbarTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        }
        
        _textField = textField;
    }
}

-(void) autoCompletionToolbarTextDidChange:(id)sender {
    UITextField* textField = sender;
    self.filter = textField.text;
}

-(void) setFilter:(NSString *)filter {
    _filter = filter;
    [self reloadData];
}

-(void) setItems:(NSArray *)items {
    _items = items;
    [self reloadData];
}

-(void) reloadData {
    [self reloadFilteredItems];
    [super reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.filteredItems count];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.filteredItems objectAtIndex:[indexPath row]];
    IGAutoCompletionToolbarCell* cell = [self dequeueReusableCellWithReuseIdentifier:IGAutoCompletionToolbarCellID
                                                                        forIndexPath:indexPath];
    [cell setObject:object];
    [cell setNeedsLayout];
    return cell;
}

#pragma mark - IGAutoCompletionToolbarLayout

-(CGSize) collectionView:(UICollectionView*)collectionView sizeWithIndex:(NSInteger)index {
    id object = [self.filteredItems objectAtIndex:index];
    NSString* title = object;
    CGSize size = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]
                    constrainedToSize:CGSizeMake(MAX_LABEL_WIDTH, 32.0)];
    return CGSizeMake(size.width + 14.0, 32);
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.toolbarDelegate respondsToSelector:@selector(autoCompletionToolbar:didSelectItemAtIndex:)]) {
        [self.toolbarDelegate autoCompletionToolbar:self didSelectItemAtIndex:[indexPath row]];
    }
}

#pragma mark - Private

- (void) reloadFilteredItems {
    NSMutableArray* newFilteredItems = [NSMutableArray array];
    [self.items enumerateObjectsUsingBlock:^(id<NSObject> obj, NSUInteger idx, BOOL *stop) {
        if (!self.filter || [self.filter isEqualToString:@""]) {
            [newFilteredItems addObject:obj];
            return;
        }

        if ([self.toolbarDelegate respondsToSelector:@selector(autoCompletionToolbar:filterShouldAcceptObject:)]) {
            if ([self.toolbarDelegate autoCompletionToolbar:self filterShouldAcceptObject:obj]) {
                [newFilteredItems addObject:obj];
            }

        } else {
            NSString* content = nil;
            if ([obj isMemberOfClass:[NSString class]]) {
                content = (NSString*) obj;
            } else {
                content = [obj description];
            }

            if ([content rangeOfString:self.filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [newFilteredItems addObject:obj];
            }
        }
    }];
    
    _filteredItems = newFilteredItems;
}

@end
