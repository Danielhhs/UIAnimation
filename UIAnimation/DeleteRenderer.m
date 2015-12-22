//
//  DeleteRenderer.m
//  StartAgain
//
//  Created by Huang Hongsen on 5/17/15.
//  Copyright (c) 2015 com.microstrategy. All rights reserved.
//

#import "DeleteRenderer.h"
#import "OpenGLHelper.h"
#import "DeleteSceneMesh.h"
@interface DeleteRenderer ()<GLKViewDelegate> {
    GLuint program;
    GLuint mvpLoc;
    GLuint sampleLoc;
    GLuint texture;
    GLuint vertexBuffer;
    GLuint indexBuffer;
    GLfloat amplitude;
    GLfloat bottomAmplitude;
    GLuint amplitudeLoc;
    GLfloat bottomAmplitudeLoc;
}
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic, strong) DeleteSceneMesh *mesh;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic) GLfloat zOffset;
@property (nonatomic, strong) void(^completion)(void);
@end


@implementation DeleteRenderer

- (void) setupOpenGL
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    program = [OpenGLHelper loadProgramWithVertexShaderSrc:@"Delete.vsl" fragmentShaderSrc:@"Delete.fsl"];
    glUseProgram(program);
    
    mvpLoc = glGetUniformLocation(program, "u_delete_mvpMatrix");
    sampleLoc = glGetUniformLocation(program, "u_delete_texture");
    amplitudeLoc = glGetUniformLocation(program, "amplitude");
    bottomAmplitudeLoc = glGetUniformLocation(program, "bottomAmplitude");
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(2);
    
    glClearColor(0, 0, 0, 1);
}

- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [EAGLContext setCurrentContext:self.context];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, (GLint)view.drawableWidth, (GLint)view.drawableHeight);
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -self.targetView.frame.size.height / 2 + self.zOffset);
    GLfloat aspect = (GLfloat)view.frame.size.width / (GLfloat)view.frame.size.height;
    GLKMatrix4 projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.f), aspect, 0.1, 1000);
    GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(projection, modelView);
    
    glUniformMatrix4fv(mvpLoc, 1, GL_FALSE, &mvpMatrix.m[0]);
    glUniform1f(amplitudeLoc, view.drawableHeight * amplitude + view.drawableHeight / 2);
    glUniform1f(bottomAmplitudeLoc, view.drawableHeight / 2 - view.drawableHeight * amplitude);
    
    [self.mesh prepareToDraw];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(sampleLoc, 0);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
}

- (void) update:(CADisplayLink *)displayLink
{
    self.elapsedTime += displayLink.duration;
    if (self.elapsedTime < self.duration) {
        amplitude -= displayLink.duration / self.duration * 0.5;
        [self.animationView display];
    } else {
        amplitude = 0.001;
        [self.animationView display];
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
    [self.mesh tearDown];
    glDeleteProgram(program);
    glDeleteTextures(1, &texture);
    self.animationView.delegate = nil;
    self.context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void) deleteView:(UIView *)view
        screenScale:(CGFloat)screenScale
      aniamtionView:(GLKView *)animationView
       withDuration:(NSTimeInterval)duration
            zOffset:(GLfloat)zOffset
         completion:(void (^)(void))completion
{
    self.duration = duration;
    self.zOffset = zOffset;
    self.completion = completion;
    [self setupOpenGL];
    texture = [OpenGLHelper setupTextureWithView:view textureWidth:view.bounds.size.width * screenScale textureHeight:view.bounds.size.height * screenScale screenScale:screenScale];
    self.mesh = [[DeleteSceneMesh alloc] initWithTargetView:view];
    self.targetView = view;
    
    self.animationView = animationView;
    self.animationView.context = self.context;
    self.animationView.delegate = self;
    self.elapsedTime = 0;
    amplitude = 0.5;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

@end
