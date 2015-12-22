//
//  BlindRenderer.m
//  BlindAnimation
//
//  Created by Huang Hongsen on 6/7/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "BlindsRenderer.h"
#import "BlindsHorizontalFrontMesh.h"
#import "BlindsHorizontalBackMesh.h"
#import "BlindsVerticalFrontMesh.h"
#import "BlindsVerticalBackMesh.h"
#import "OpenGLHelper.h"
@interface BlindsRenderer () {
    GLuint program;
    GLuint samplerLoc;
    GLuint mvpLoc;
    GLuint frontTexture;
    GLuint backTexture;
    GLfloat rotation;
}
@property (nonatomic, strong) BlindsMesh *frontMesh;
@property (nonatomic, strong) BlindsMesh *backMesh;
@property (nonatomic, strong) GLKView *animationView;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic, strong) void (^completion)(void);
@property (nonatomic) NSBKeyframeAnimationFunction interpolator;
@property (nonatomic) NSInteger columnCount;
@property (nonatomic) BlindsDirection direction;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation BlindsRenderer

- (instancetype) init
{
    self = [super init];
    if (self) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    }
    return self;
}

- (void) setupGL
{
    [EAGLContext setCurrentContext:self.context];
    program = [OpenGLHelper loadProgramWithVertexShaderSrc:@"Blinds.vsl" fragmentShaderSrc:@"Blinds.fsl"];
    glUseProgram(program);
    
    mvpLoc = glGetUniformLocation(program, "u_mvpMatrix");
    samplerLoc = glGetUniformLocation(program, "s_tex");
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    
    glClearColor(0, 0, 0, 1);
}

- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glViewport(0, 0, (GLint)view.drawableWidth, (GLint)view.drawableHeight);
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(-view.frame.size.width / 2, -view.frame.size.height / 2, -view.frame.size.height / 2);
    GLfloat aspect = (GLfloat)view.frame.size.width / view.frame.size.height;
    GLKMatrix4 perspective = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000);
    GLKMatrix4 mvp = GLKMatrix4Multiply(perspective, modelView);
    
    glUniformMatrix4fv(mvpLoc, 1, GL_FALSE, mvp.m);
    
    glCullFace(GL_BACK);
    
    
    for (int i = 0; i < self.columnCount / 2; i++) {
        if (self.direction == BlindsDirectionRightToLeft) {
            [self drawFrontThenBackAtIndex:i];
        } else {
            [self drawBackThenFrontAtIndex:i];
        }
    }
    
    for (int i = (int)self.columnCount - 1; i >= self.columnCount / 2; i--) {
        if (self.direction == BlindsDirectionRightToLeft) {
            [self drawBackThenFrontAtIndex:i];
        } else {
            [self drawFrontThenBackAtIndex:i];
        }
    }
}

- (void) drawFrontThenBackAtIndex:(int)i
{
    [self.frontMesh prepareToDraw];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, frontTexture);
    glUniform1i(samplerLoc, 0);
    [self.frontMesh drawColumnAtIndex:i];
    
    [self.backMesh prepareToDraw];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, backTexture);
    glUniform1i(samplerLoc, 0);
    [self.backMesh drawColumnAtIndex:i];
}

- (void) drawBackThenFrontAtIndex:(int) i
{
    [self.backMesh prepareToDraw];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, backTexture);
    glUniform1i(samplerLoc, 0);
    [self.backMesh drawColumnAtIndex:i];
    
    [self.frontMesh prepareToDraw];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, frontTexture);
    glUniform1i(samplerLoc, 0);
    [self.frontMesh drawColumnAtIndex:i];
}

- (void) update:(CADisplayLink *)displayLink
{
    self.elapsedTime += displayLink.duration;
    if (self.elapsedTime < self.duration) {
        GLfloat t = self.interpolator(self.elapsedTime * 1000, 0, 1, self.duration * 1000);
        rotation = t * [self totalRotateAngle];
        [self.frontMesh updateWithRotation:rotation];
        [self.backMesh updateWithRotation:rotation];
        [self.animationView display];
    } else {
        [self endAnimation];
    }
}

- (GLfloat) totalRotateAngle
{
    switch (self.direction) {
        case BlindsDirectionRightToLeft:
        case BlindsDirectionTopToBottom:
            return -M_PI_2;
        case BlindsDirectionBottomToTop:
        case BlindsDirectionLeftToRight:
            return M_PI_2;
    }
}

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
                screenScale:(CGFloat)screenScale
           inView:(UIView *)containerView
                columnCount:(NSInteger)columnCount
                   duration:(NSTimeInterval)duration
{
    [self transitionFromView:fromView toView:toView screenScale:screenScale inView:containerView columnCount:columnCount direction:BlindsDirectionRightToLeft duration:duration];
}

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
                screenScale:(CGFloat)screenScale
           inView:(UIView *)containerView
                columnCount:(NSInteger)columnCount
                   duration:(NSTimeInterval)duration
                 completion:(void (^)(void))completion
{
    [self transitionFromView:fromView toView:toView screenScale:screenScale inView:containerView columnCount:columnCount direction:BlindsDirectionRightToLeft duration:duration completion:completion];
}

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
                screenScale:(CGFloat)screenScale
           inView:(UIView *)containerView
                columnCount:(NSInteger)columnCount
                  direction:(BlindsDirection)direction
                   duration:(NSTimeInterval)duration
{
    [self transitionFromView:fromView toView:toView screenScale:screenScale inView:containerView columnCount:columnCount direction:direction duration:duration completion:nil];
}

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
                screenScale:(CGFloat)screenScale
           inView:(UIView *)containerView
                columnCount:(NSInteger)columnCount
                  direction:(BlindsDirection)direction
                   duration:(NSTimeInterval)duration
                 completion:(void (^)(void))completion
{
    [self transitionFromView:fromView toView:toView screenScale:screenScale inView:containerView columnCount:columnCount direction:direction duration:duration interpolator:NSBKeyframeAnimationFunctionEaseInOutBack completion:completion];
}

- (void) transitionFromView:(UIView *)fromView
                     toView:(UIView *)toView
                screenScale:(CGFloat)screenScale
           inView:(UIView *)containerView
                columnCount:(NSInteger)columnCount
                  direction:(BlindsDirection)direction
                   duration:(NSTimeInterval)duration
               interpolator:(NSBKeyframeAnimationFunction)interpolator
                 completion:(void (^)(void))completion
{
    self.interpolator = interpolator;
    self.completion = completion;
    self.duration = duration;
    self.columnCount = columnCount;
    self.direction = direction;
    [self setupGL];
    frontTexture = [OpenGLHelper setupTextureWithView:fromView textureWidth:fromView.bounds.size.width * screenScale textureHeight:fromView.bounds.size.height * screenScale screenScale:screenScale];
    backTexture = [OpenGLHelper setupTextureWithView:toView textureWidth:fromView.bounds.size.width * screenScale textureHeight:fromView.bounds.size.height * screenScale screenScale:screenScale];
    self.frontMesh = [self frontMeshForDirection:direction width:fromView.bounds.size.width height:fromView.bounds.size.height columnCount:columnCount];
    self.backMesh = [self backMeshForDirection:direction width:fromView.bounds.size.width height:fromView.bounds.size.height columnCount:columnCount];
    self.animationView = [[GLKView alloc] initWithFrame:fromView.bounds context:self.context];
    self.animationView.delegate = self;
    [containerView addSubview:self.animationView];
    
    self.elapsedTime = 0;
    rotation = 0;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (BlindsMesh *) frontMeshForDirection:(BlindsDirection)direction width:(CGFloat)width height:(CGFloat)height columnCount:(NSInteger)columnCount
{
    if (direction == BlindsDirectionLeftToRight || direction == BlindsDirectionRightToLeft) {
        return [[BlindsHorizontalFrontMesh alloc] initWithScreenWidth:width screenHeight:height columns:(GLuint)columnCount direction:direction];
    } else {
        return [[BlindsVerticalFrontMesh alloc] initWithScreenWidth:width screenHeight:height rowCount:(GLuint)columnCount direction:direction];
    }
}

- (BlindsMesh *) backMeshForDirection:(BlindsDirection)direction width:(CGFloat)width height:(CGFloat)height columnCount:(NSInteger)columnCount
{
    if (direction == BlindsDirectionLeftToRight || direction == BlindsDirectionRightToLeft) {
        return [[BlindsHorizontalBackMesh alloc] initWithScreenWidth:width screenHeight:height columns:(GLuint)columnCount direction:direction];
    } else {
        return [[BlindsVerticalBackMesh alloc] initWithScreenWidth:width screenHeight:height rowCount:(GLuint)columnCount direction:direction];
    }
}

- (void) endAnimation
{
    rotation = [self totalRotateAngle];
    [self.frontMesh updateWithRotation:rotation];
    [self.backMesh updateWithRotation:rotation];
    [self.animationView display];
    if (self.completion) {
        self.completion();
    }
    [self.displayLink invalidate];
    [self.animationView removeFromSuperview];
}
@end
