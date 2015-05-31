//
//  ProgramLoader.m
//  StartAgain
//
//  Created by Huang Hongsen on 5/11/15.
//  Copyright (c) 2015 com.microstrategy. All rights reserved.
//

#import "OpenGLHelper.h"

@implementation OpenGLHelper

+ (GLuint) loadProgramWithVertexShaderSrc:(NSString *)vertexShaderSrc fragmentShaderSrc:(NSString *)fragmentShaderSrc
{
    GLuint program = glCreateProgram();
    
    GLuint vertexShader = [OpenGLHelper loadShaderWithType:GL_VERTEX_SHADER sourceFileName:vertexShaderSrc];
    GLuint fragmentShader = [OpenGLHelper loadShaderWithType:GL_FRAGMENT_SHADER sourceFileName:fragmentShaderSrc];
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    int status = 0;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status != GL_TRUE) {
        int errorLogLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &errorLogLength);
        char *errorLog = malloc(sizeof(char) * errorLogLength);
        glGetProgramInfoLog(program, errorLogLength, NULL, errorLog);
    }
    
    return program;
}

+ (GLuint) loadShaderWithType:(GLenum)type sourceFileName:(NSString *)sourceFileName
{
    GLuint shader = glCreateShader(type);
    
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"UIAnimation" ofType:@"bundle"]];
    NSString *srcPath = [[bundle resourcePath] stringByAppendingPathComponent:sourceFileName];
    
    const char *src = [[NSString stringWithContentsOfFile:srcPath encoding:NSUTF8StringEncoding error:NULL] cStringUsingEncoding:NSUTF8StringEncoding];
    glShaderSource(shader, 1, &src, NULL);
    glCompileShader(shader);
    
    int status = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status != GL_TRUE) {
        int errorlogLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &errorlogLength);
        char *errorLog = malloc(errorlogLength * sizeof(char));
        glGetShaderInfoLog(shader, errorlogLength, NULL, errorLog);
        NSLog(@"Fail to compile shader for : %s", errorLog);
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

+ (UIImage *) highResolutionSnapshotForView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (GLuint) setupTextureWithView:(UIView *)view
{
    return [OpenGLHelper setupTextureWithImage:[OpenGLHelper highResolutionSnapshotForView:view]];
}

+ (GLuint) setupTextureWithImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    GLubyte *data = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(data, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), 1);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(spriteContext);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    free(data);
    return texture;
}
@end
