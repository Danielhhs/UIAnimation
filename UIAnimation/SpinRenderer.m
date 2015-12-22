//
//  SpinRenderer.m
//  SpinAnimation
//
//  Created by Huang Hongsen on 5/19/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "SpinRenderer.h"
#import "OpenGLHelper.h"
#import "SpinFrontMesh.h"
#import "SpinBackMesh.h"
@interface SpinRenderer() {
    GLuint program;
    GLuint mvpLoc;
    GLuint samplerLoc;
    GLfloat rotation;
    GLfloat zOffset;
    GLuint frontTexture;
    GLuint backTexture;
}
@property (nonatomic, weak) GLKView *animationView;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) GLfloat targetZOffset;
@property (nonatomic, strong) SpinFrontMesh *frontMesh;
@property (nonatomic, strong) SpinBackMesh *backMesh;
@property (nonatomic) GLfloat targetRotation;
@property (nonatomic, strong) void (^completion)(void);
@end

@implementation SpinRenderer

- (void) setupOpenGL
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    program = [OpenGLHelper loadProgramWithVertexShaderSrc:@"Spin.vsl" fragmentShaderSrc:@"Spin.fsl"];
    glUseProgram(program);
    
    mvpLoc = glGetUniformLocation(program, "u_mvpMatrix");
    samplerLoc = glGetUniformLocation(program, "u_texture");
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(2);
    
    glClearColor(0, 0, 0, 1);
}

- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [EAGLContext setCurrentContext:self.context];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, (GLint)view.drawableWidth, (GLint)view.drawableHeight);
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -view.frame.size.height / 2 + zOffset);
    modelView = GLKMatrix4Rotate(modelView, rotation, 0, 1, 0);
    GLfloat aspect = (GLfloat)view.frame.size.width / (GLfloat)view.frame.size.height;
    GLKMatrix4 projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 1000);
    GLKMatrix4 mvp = GLKMatrix4Multiply(projection, modelView);
    
    glUniformMatrix4fv(mvpLoc, 1, GL_FALSE, &mvp.m[0]);
    
    [self.frontMesh prepareToDraw];
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, frontTexture);
    glUniform1i(samplerLoc, 0);
    [self.frontMesh drawEntireMesh];
    
    [self.backMesh prepareToDraw];
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, backTexture);
    glUniform1i(samplerLoc, 0);
    [self.backMesh drawEntireMesh];
}

- (void) update:(CADisplayLink *)displayLink
{
    self.elapsedTime += displayLink.duration;
    if (self.elapsedTime < self.duration) {
        rotation += displayLink.duration / self.duration * self.targetRotation;
        zOffset += displayLink.duration / self.duration * self.targetZOffset;
        [self.animationView display];
    } else {
        rotation = self.targetRotation;
        [self.animationView display];
        self.animationView.delegate = nil;
        [displayLink invalidate];
        displayLink = nil;
        [self tearDownOpenGL];
        if (self.completion) {
            self.completion();
        }
    }
}

- (void) tearDownOpenGL
{
    [EAGLContext setCurrentContext:self.context];
    [self.frontMesh tearDown];
    [self.backMesh tearDown];
    glDeleteTextures(1, &frontTexture);
    glDeleteTextures(1, &backTexture);
    glDeleteProgram(program);
    self.animationView.delegate = nil;
    self.context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void) spinFromView:(UIView *)fromView
               toView:(UIView *)toView
          screenScale:(CGFloat)screenScale
        animationView:(GLKView *)animationView
             duration:(NSTimeInterval)duration
                angle:(GLfloat)angle
              zOffset:(GLfloat)zoffset
           completion:(void (^)(void))completion
{
    self.targetRotation = angle;
    self.targetZOffset = zoffset;
    self.completion = completion;
    [self setupOpenGL];
    frontTexture = [OpenGLHelper setupTextureWithView:fromView textureWidth:fromView.bounds.size.width * screenScale textureHeight:fromView.bounds.size.height * screenScale screenScale:screenScale];
    backTexture = [OpenGLHelper setupTextureWithView:toView textureWidth:toView.bounds.size.width * screenScale textureHeight:toView.bounds.size.height * screenScale screenScale:screenScale];
    self.frontMesh = [[SpinFrontMesh alloc] initWithTargetView:fromView];
    self.backMesh = [[SpinBackMesh alloc] initWithTargetView:toView];
    self.duration = duration;
    self.animationView = animationView;
    self.animationView.context = self.context;
    self.animationView.delegate = self;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

@end
