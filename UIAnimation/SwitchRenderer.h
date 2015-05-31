//
//  SwitchRenderer.h
//  SwitchAnimation
//
//  Created by Huang Hongsen on 5/28/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SwitchRenderer : NSObject

- (void) switchFromView:(UIView *)fromView toView:(UIView *)toView inContainerView:(UIView *)containerView duration:(NSTimeInterval)duration completion:(void(^)(void))completion;

- (void) switchFromImage:(UIImage *)fromImage toImage:(UIImage *)toImage inContainerView:(UIView *)containerView duration:(NSTimeInterval)duration completion:(void (^)(void))completion;
@end
