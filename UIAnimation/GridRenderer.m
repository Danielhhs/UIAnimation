//
//  GridRenderer.m
//  GridAnimation
//
//  Created by Huang Hongsen on 6/24/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "GridRenderer.h"
#import "OpenGLHelper.h"
#import "GridCurrentMesh.h"
#import "GridNextMesh.h"

#define kGridZoomOutRatio 0.25
#define kGridGapRatio 0.1
#define kGridTransitionRatio 0.3
#define kGridZoomInRatio 0.25
#define kGridDepth 100

@interface GridRenderer() {
    GLuint program;
    GLuint mvpLoc;
    GLuint samplerLoc;
    GLuint currentTexture;
    GLuint nextTexture;
    GLKMatrix4 modelViewMatrix;
    GLKMatrix4 perspectiveMatrix;
    GLKMatrix4 mvpMatrix;
    GLfloat viewWidth;
    GLfloat viewHeight;
}
@property (nonatomic, strong) GLKView *animationView;
@property (nonatomic, strong) GridCurrentMesh *currentMesh;
@property (nonatomic, strong) GridNextMesh *nextMesh;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) void(^completion)(void);
@property (nonatomic) NSTimeInterval elapsedTime;
@end

@implementation GridRenderer

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
    program = [OpenGLHelper loadProgramWithVertexShaderSrc:@"Grid.vsl" fragmentShaderSrc:@"Grid.fsl"];
    glUseProgram(program);
    mvpLoc = glGetUniformLocation(program, "u_mvpMatrix");
    samplerLoc = glGetUniformLocation(program, "s_tex");
    
    modelViewMatrix = GLKMatrix4MakeTranslation(-viewWidth / 2, -viewHeight / 2, -viewHeight / 2);
    GLfloat aspect = (GLfloat)viewWidth / viewHeight;
    perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000);
    
    glClearColor(0, 0, 0, 1);
}

- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glViewport(0, 0, (GLint)view.drawableWidth, (GLint)view.drawableHeight);
    mvpMatrix = GLKMatrix4Multiply(perspectiveMatrix, modelViewMatrix);
    glUniformMatrix4fv(mvpLoc, 1, GL_FALSE, mvpMatrix.m);
    
    [self.currentMesh prepareToDraw];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, currentTexture);
    glUniform1i(samplerLoc, 0);
    [self.currentMesh drawEntireMesh];
    
    [self.nextMesh prepareToDraw];
    glBindTexture(GL_TEXTURE_2D, nextTexture);
    glUniform1i(samplerLoc, 0);
    [self.nextMesh drawEntireMesh];
}

- (void) update:(CADisplayLink *)displayLink
{
    self.elapsedTime += displayLink.duration;
    GLfloat ratio = self.elapsedTime / self.duration;
    if (ratio <= kGridZoomOutRatio) {
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -displayLink.duration / (self.duration * kGridZoomOutRatio) * kGridDepth);
    } else if (ratio <= kGridZoomOutRatio + kGridGapRatio) {
        modelViewMatrix.m32 = -viewHeight / 2 - kGridDepth;
    } else if (ratio <= kGridZoomOutRatio + kGridGapRatio + kGridTransitionRatio) {
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, -displayLink.duration / (self.duration * kGridTransitionRatio) * (viewWidth + 100), 0, 0);
    } else if (ratio <= kGridZoomOutRatio + 2 * kGridGapRatio + kGridTransitionRatio) {
        
    } else if (ratio < 1) {
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, displayLink.duration / (self.duration * kGridZoomInRatio) * kGridDepth);
    } else {
        modelViewMatrix = GLKMatrix4MakeTranslation(-viewWidth / 2 - viewWidth - 100, -viewHeight / 2, -viewHeight / 2);
    }
    [self.animationView display];
    if (ratio >= 1) {
        [displayLink invalidate];
        [self.animationView removeFromSuperview];
        if (self.completion) {
            self.completion();
        }
    }
}


- (void) startTransitionFromView:(UIView *)fromView toView:(UIView *)toView screenScale:(CGFloat)screenScale inView:(UIView *)view duration:(NSTimeInterval)duration completion:(void(^)(void))completion
{
    viewWidth = fromView.bounds.size.width;
    viewHeight = fromView.bounds.size.height;
    self.completion = completion;
    self.duration = duration;
    [self setupGL];
    
    self.currentMesh = [[GridCurrentMesh alloc] initWithScreenWidth:fromView.bounds.size.width screenHeight:fromView.bounds.size.height];
    self.nextMesh = [[GridNextMesh alloc] initWithScreenWidth:toView.bounds.size.width screenHeight:toView.bounds.size.height];
    
    currentTexture = [OpenGLHelper setupTextureWithView:fromView textureWidth:fromView.bounds.size.width * screenScale textureHeight:fromView.bounds.size.height * screenScale screenScale:screenScale];
    nextTexture = [OpenGLHelper setupTextureWithView:toView textureWidth:toView.bounds.size.width * screenScale textureHeight:toView.bounds.size.height * screenScale screenScale:screenScale];
    
    self.animationView = [[GLKView alloc] initWithFrame:fromView.frame context:self.context];
    self.animationView.delegate = self;
    
    [view addSubview:self.animationView];
    
    self.elapsedTime = 0;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}
@end
