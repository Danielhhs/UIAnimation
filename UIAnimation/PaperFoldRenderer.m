//
//  PaperFoldRenderer.m
//  PaperFoldAnimation
//
//  Created by Huang Hongsen on 6/10/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "PaperFoldRenderer.h"
#import "OpenGLHelper.h"
#import "PaperFoldMesh.h"
#import "OpenGLSimpleMesh.h"
@interface PaperFoldRenderer() {
    GLuint program;
    GLuint mvpLoc;
    GLuint mvLoc;
    GLuint normalLoc;
    GLuint lightEyePosLoc;
    GLuint lightDiffuseLoc;
    GLuint globalAmbientLoc;
    
    GLuint backgroundProgram;
    GLuint backgroundMVPLoc;
    GLuint backgroundSampler;
    
    GLuint samplerLoc;
    GLuint texture;
    GLuint backgroundTexture;
}
@property (nonatomic, strong) GLKView *animationView;
@property (nonatomic, strong) PaperFoldMesh *mesh;
@property (nonatomic, strong) OpenGLSimpleMesh *backgroundMesh;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) size_t headerHeight;
@property (nonatomic, strong) void(^completion)(void);
@property (nonatomic) PaperFoldAnimationAction action;
@property (nonatomic) NSBKeyframeAnimationFunction interpolator;
@property (nonatomic) GLfloat yOffset;
@property (nonatomic) BOOL dragging;
@property (nonatomic) CGFloat currentYLocation;
@property (nonatomic, weak) UIView *backgroundView;
@end

@implementation PaperFoldRenderer

- (instancetype) init
{
    self = [super init];
    if (self) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    }
    return self;
}

- (GLKVector4)globalAmbient
{
    return GLKVector4Make(0., 0., 0., 1.f);
}

- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, (GLint)view.drawableWidth, (GLint)view.drawableHeight);
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(-view.frame.size.width / 2, -view.frame.size.height / 2, -view.frame.size.height /2);
    GLfloat aspect = (GLfloat)view.frame.size.width / view.frame.size.height;
    GLKMatrix4 perspective = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000);
    GLKMatrix4 mvp = GLKMatrix4Multiply(perspective, modelView);
    
    if (self.backgroundView) {
        glUseProgram(backgroundProgram);
        glUniformMatrix4fv(backgroundMVPLoc, 1, GL_FALSE, mvp.m);
        [self.backgroundMesh prepareToDraw];
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, backgroundTexture);
        glUniform1i(backgroundSampler, 0);
        [self.backgroundMesh drawEntireMesh];
    }
    
    glUseProgram(program);
    
    glUniformMatrix4fv(mvLoc, 1, GL_FALSE, modelView.m);
    glUniformMatrix4fv(mvpLoc, 1, GL_FALSE, mvp.m);
    glUniformMatrix3fv(normalLoc, 1, GL_FALSE, GLKMatrix3Identity.m);
    glUniform3f(lightEyePosLoc, 0, 0, 100);
    glUniform4fv(lightDiffuseLoc, 1, GLKVector4Make(1, 1, 1, 1.).v);
    glUniform4fv(globalAmbientLoc, 1, [self globalAmbient].v);
    [self.mesh prepareToDraw];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(samplerLoc, 0);
    
    [self.mesh drawEntireMesh];
}

- (void) update:(CADisplayLink *)displayLink
{
    self.elapsedTime += displayLink.duration;
    GLfloat t = self.interpolator(self.elapsedTime * 1000, 0, 1, self.duration * 1000);
    if (self.elapsedTime < self.duration || self.dragging == YES) {
        GLfloat yPosition;
        if (self.action == PaperFoldAnimationActionExpand) {
            yPosition = self.yOffset + t * (self.animationView.frame.size.height - self.yOffset);
        } else {
            yPosition = self.yOffset - t * (self.yOffset - self.headerHeight);
        }
        [self.mesh updateWithYPosition:yPosition];
        [self.animationView display];
    } else {
        GLfloat yPosition;
        if (self.action == PaperFoldAnimationActionExpand) {
            yPosition = self.animationView.frame.size.height ;
        } else {
            yPosition = self.headerHeight;
        }
        [self.mesh updateWithYPosition:yPosition];
        [self.animationView display];
        [displayLink invalidate];
        if (self.completion) {
            self.completion();
        }
        [self.animationView removeFromSuperview];
        [self tearDownGL];
    }
}

- (void) tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    glDeleteProgram(program);
    program = 0;
    glDeleteTextures(1, &texture);
    texture = 0;
    [self.mesh tearDown];
    self.backgroundView = nil;
    glDeleteProgram(backgroundProgram);
    backgroundProgram = 0;
    glDeleteTextures(1, &backgroundTexture);
    backgroundTexture = 0;
    [self.backgroundMesh tearDown];
    [EAGLContext setCurrentContext:nil];
}

- (void) setupFrontGL
{
    [EAGLContext setCurrentContext:self.context];
    program = [OpenGLHelper loadProgramWithVertexShaderSrc:@"PaperFold.vsl" fragmentShaderSrc:@"PaperFold.fsl"];
    glUseProgram(program);
    
    mvpLoc = glGetUniformLocation(program, "u_mvpMatrix");
    samplerLoc = glGetUniformLocation(program, "s_tex");
    mvLoc = glGetUniformLocation(program, "u_modelViewMatrix");
    normalLoc = glGetUniformLocation(program, "u_normalMatrix");
    lightEyePosLoc = glGetUniformLocation(program, "u_lightEyePos");
    lightDiffuseLoc = glGetUniformLocation(program, "u_lightDiffuse");
    globalAmbientLoc = glGetUniformLocation(program, "u_globalAmbient");
    
    glClearColor(0, 0, 0, 1);
}

- (void) setupAnimationContextInView:(UIView *)view screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount completion:(void(^)(void))completion
{
    self.headerHeight = headerHeight;
    self.completion = completion;
    
    [self setupFrontGL];
    texture = [OpenGLHelper setupTextureWithView:view textureWidth:view.bounds.size.width * screenScale textureHeight:view.bounds.size.height * screenScale screenScale:screenScale];
    self.mesh = [[PaperFoldMesh alloc] initWithScreenWidth:view.frame.size.width screenHeight:view.frame.size.height rowCount:rowCount headerHeight:headerHeight];
    
    if (self.backgroundView) {
        [self setupBackgroundProgramWithScreenScale:screenScale];
    }
    self.animationView = [[GLKView alloc] initWithFrame:view.frame context:self.context];
    self.animationView.delegate = self;
    [viewController.view addSubview:self.animationView];
}

- (void) setupBackgroundProgramWithScreenScale:(CGFloat)screenScale
{
    [EAGLContext setCurrentContext:self.context];
    GLenum error = glGetError();
    if (GL_NO_ERROR != error) {
        NSLog(@"Error = 0x%d", error);
    }
    backgroundProgram = [OpenGLHelper loadProgramWithVertexShaderSrc:@"PaperFoldBackground.vsl" fragmentShaderSrc:@"PaperFoldBackground.fsl"];
    glUseProgram(backgroundProgram);
    
    backgroundMVPLoc = glGetUniformLocation(backgroundProgram, "u_mvpMatrix");
    backgroundSampler = glGetUniformLocation(backgroundProgram, "s_tex");
    
    backgroundTexture = [OpenGLHelper setupTextureWithView:self.backgroundView textureWidth:self.backgroundView.bounds.size.width * screenScale textureHeight:self.backgroundView.frame.size.height * screenScale screenScale:screenScale];
    self.backgroundMesh = [[OpenGLSimpleMesh alloc] initWithScreenWidth:self.backgroundView.frame.size.width screenHeight:self.backgroundView.frame.size.height];
}

#pragma mark - Interactive Animation
- (void) startPaperFoldWithView:(UIView *)view screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount action:(PaperFoldAnimationAction)action completion:(void (^)(void))completion
{
    [self startPaperFoldWithView:view backgroundView:nil screenScale:screenScale inViewController:viewController headerHeight:headerHeight rowCount:rowCount action:action completion:completion];
}

- (void) startPaperFoldWithView:(UIView *)view backgroundView:(UIView *)backgroundView screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount action:(PaperFoldAnimationAction)action completion:(void(^)(void))completion
{
    self.backgroundView = backgroundView;
    self.dragging = YES;
    self.duration = 1.f;
    self.interpolator = NSBKeyframeAnimationFunctionEaseOutBounce;
    [self setupAnimationContextInView:view screenScale:screenScale inViewController:viewController headerHeight:headerHeight rowCount:rowCount completion:completion];
    if (action == PaperFoldAnimationActionExpand) {
        self.currentYLocation = self.headerHeight;
    } else {
        self.currentYLocation = self.animationView.frame.size.height;
    }
}

- (void) updatePaperFoldWithOffset:(CGFloat)offset
{
    CGFloat yLocation = self.currentYLocation + offset;
    if (yLocation > self.headerHeight) {
        self.currentYLocation = yLocation;
        [self.mesh updateWithYPosition:yLocation];
        [self.animationView display];
    }
}

- (void) finishPaperFoldAnimationWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity
{
    if (velocity.y > 100) {
        self.action = PaperFoldAnimationActionExpand;
    } else if (velocity.y < -100) {
        self.action = PaperFoldAnimationActionFold;
    } else {
        if (location.y > CGRectGetMidY(self.animationView.bounds)) {
            self.action = PaperFoldAnimationActionExpand;
        } else {
            self.action = PaperFoldAnimationActionFold;
        }
    }
    self.yOffset = self.currentYLocation;
    self.elapsedTime = 0;
    self.dragging = NO;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Static Animation
- (void) foldView:(UIView *)view screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount
{
    [self foldView:view backgroundView:nil screenScale:screenScale inViewController:viewController duration:duration headerHeight:headerHeight rowCount:rowCount ];
}

- (void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount
{
    [self foldView:view backgroundView:backgroundView screenScale:screenScale inViewController:viewController duration:duration headerHeight:headerHeight rowCount:rowCount completion:nil];
}

- (void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount completion:(void (^)(void))completion
{
    [self foldView:view backgroundView:backgroundView screenScale:screenScale inViewController:viewController duration:duration headerHeight:headerHeight rowCount:rowCount interpolator:NSBKeyframeAnimationFunctionEaseOutBounce completion:completion];
}

- (void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount interpolator:(NSBKeyframeAnimationFunction)interpolator
{
    [self foldView:view backgroundView:backgroundView screenScale:screenScale inViewController:viewController duration:duration headerHeight:headerHeight rowCount:rowCount interpolator:interpolator completion:nil];
}

- (void) foldView:(UIView *)view backgroundView:(UIView *)backgroundView screenScale:(CGFloat)screenScale inViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration headerHeight:(size_t)headerHeight rowCount:(size_t)rowCount interpolator:(NSBKeyframeAnimationFunction)interpolator completion:(void (^)(void))completion
{
    self.duration = duration;
    self.backgroundView = backgroundView;
    self.yOffset = 0;
    self.action = PaperFoldAnimationActionExpand;
    self.interpolator = interpolator;
    [self setupAnimationContextInView:view screenScale:screenScale inViewController:viewController headerHeight:headerHeight rowCount:rowCount completion:completion];
    self.elapsedTime = 0;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

@end
