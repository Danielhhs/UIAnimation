//
//  ClothesLineRenderer.h
//  ClothesLineAnimation
//
//  Created by Huang Hongsen on 5/23/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ClothesLineAnimationDirection) {
    ClothesLineAnimationDirectionLeftToRight = 0,
    ClothesLineAnimationDirectionRightToLeft = 1,
};
@interface ClothesLineRenderer : NSObject
//Remove the containerView manually when it is not needed(in completion block);
@property (nonatomic, strong) UIView *containerView;
- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
           inViewController:(UIViewController *)viewController
                 direaction:(ClothesLineAnimationDirection)direction
                   duration:(NSTimeInterval)duration
                 completion:(void(^)(void))completion;


- (void) transitionFromImage:(UIImage *)fromImage
                     toImage:(UIImage *)toImage
                       frame:(CGRect) frame
            inViewController:(UIViewController *)viewController
                  direaction:(ClothesLineAnimationDirection)direction
                    duration:(NSTimeInterval)duration
                  completion:(void(^)(void))completion;

@end
