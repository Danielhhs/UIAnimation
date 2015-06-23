//
//  PaperFoldRenderer.h
//  PaperFoldAnimation
//
//  Created by Huang Hongsen on 6/10/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NSBKeyframeAnimationFunctions.h"

typedef NS_ENUM(NSInteger, PaperFoldAnimationAction) {
    PaperFoldAnimationActionExpand = 0,
    PaperFoldAnimationActionFold = 1,
};

@interface PaperFoldRenderer : NSObject<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;

- (void) startPaperFoldWithView:(UIView *)view inViewController:(UIViewController *)viewController headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount action:(PaperFoldAnimationAction)action completion:(void(^)(void))completion;

- (void) startPaperFoldWithView:(UIView *)view backgroundView:(UIView *)backgroundView inViewController:(UIViewController *)viewController headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount action:(PaperFoldAnimationAction)action completion:(void(^)(void))completion;

- (void) updatePaperFoldWithOffset:(CGFloat)offset;

- (void) finishPaperFoldAnimationWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity;

- (void) foldView:(UIView *)view inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount;

- (void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount;

-(void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount interpolator:(NSBKeyframeAnimationFunction)interpolator;

- (void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount completion:(void(^)(void))completion;

-(void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount interpolator:(NSBKeyframeAnimationFunction)interpolator completion:(void(^)(void))completion;

@end
