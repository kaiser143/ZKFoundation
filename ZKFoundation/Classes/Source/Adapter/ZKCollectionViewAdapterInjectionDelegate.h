//
//  ZKCollectionViewAdapterInjectionDelegate.h
//  ZKFoundation
//
//  Created by Kaiser on 2019/5/23.
//

#ifndef ZKCollectionViewAdapterInjectionDelegate_h
#define ZKCollectionViewAdapterInjectionDelegate_h

@protocol ZKCollectionViewAdapterInjectionDelegate <NSObject>

@optional
- (void)bindViewModel:(__kindof NSObject *)viewModel forItemAtIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* ZKCollectionViewAdapterInjectionDelegate_h */
