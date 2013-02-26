//
//  IGAutoCompletionToolbar.h
//  IGAutoCompletionToolbar
//
//  Created by Chong Francis on 13年2月26日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGAutoCompletionToolbarLayout.h"

extern NSString* const IGAutoCompletionToolbarCellID;

@class IGAutoCompletionToolbar;

@protocol IGAutoCompletionToolbarDelegate <NSObject>
- (BOOL) autoCompletionToolbar:(IGAutoCompletionToolbar*)toolbar filterShouldAcceptObject:(id)object;
- (BOOL) autoCompletionToolbar:(IGAutoCompletionToolbar*)toolbar didSelectItemAtIndex:(NSInteger)index;
@end

@interface IGAutoCompletionToolbar : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, IGAutoCompletionToolbarLayoutDelegate>

@property (nonatomic, weak) id<IGAutoCompletionToolbarDelegate, NSObject> toolbarDelegate;

// the textfield this auto completion toolbar related to
@property (nonatomic, weak) UITextField* textField;

@property (nonatomic, strong) NSString* filter;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong, readonly) NSMutableArray* filteredItems;

@end
