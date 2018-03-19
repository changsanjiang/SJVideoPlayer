//
//  SJViewHierarchyStack.h
//  SJVideoPlayerAssetCarrier
//
//  Created by BlueDancer on 2018/3/19.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJViewHierarchyStack_h
#define SJViewHierarchyStack_h

typedef NS_ENUM(NSUInteger,  SJViewHierarchyItem) {
    SJViewHierarchyItem_View                   = 1 << 0,
    SJViewHierarchyItem_TableCell              = 1 << 1,
    SJViewHierarchyItem_TableView              = 1 << 2,
    SJViewHierarchyItem_TableHeaderView        = 1 << 3,
    
    SJViewHierarchyItem_CollectionCell         = SJViewHierarchyItem_TableCell,
    SJViewHierarchyItem_CollectionView         = SJViewHierarchyItem_TableView,
};

/**
 View hierarchy.
 
 - SJViewHierarchyStack_View:                      player -> view
 - SJViewHierarchyStack_TableView:                 player -> table cell -> table view
 - SJViewHierarchyStack_TableHeaderView:           player -> table header view -> table view
 - SJViewHierarchyStack_CollectionView:            player -> collection cell -> collection view
 - SJViewHierarchyStack_NestedInTableView:         player -> collection cell -> collection view -> table cell -> table view
 - SJViewHierarchyStack_NestedInTableHeaderView:   player -> collection cell -> collection view -> table header view -> table view
 - SJViewHierarchyStack_ScrollView:                player -> cell -> table || collection view
 */
typedef NS_ENUM(NSUInteger,  SJViewHierarchyStack) {
    SJViewHierarchyStack_View                     = SJViewHierarchyItem_View,
    
    SJViewHierarchyStack_TableView                = SJViewHierarchyItem_TableCell | SJViewHierarchyItem_TableView,
    SJViewHierarchyStack_TableHeaderView          = SJViewHierarchyItem_TableHeaderView | SJViewHierarchyItem_TableView,
    
    SJViewHierarchyStack_CollectionView           = SJViewHierarchyItem_CollectionCell | SJViewHierarchyItem_CollectionView,
    SJViewHierarchyStack_NestedInTableView        = SJViewHierarchyStack_CollectionView | SJViewHierarchyStack_TableView,
    SJViewHierarchyStack_NestedInTableHeaderView  = SJViewHierarchyStack_CollectionView | SJViewHierarchyStack_TableHeaderView,
    
    SJViewHierarchyStack_ScrollView               = SJViewHierarchyStack_TableView | SJViewHierarchyStack_CollectionView,
};

#endif /* SJViewHierarchyStack_h */
