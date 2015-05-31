//
//  SpinFrontMesh.m
//  SpinAnimation
//
//  Created by Huang Hongsen on 5/19/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "SpinFrontMesh.h"

@implementation SpinFrontMesh

- (instancetype) initWithTargetView:(UIView *)targetView
{
    SceneMeshVertex vertices[] = {
        {{-targetView.frame.size.width / 2, targetView.frame.size.height / 2, 0},{0, 0, 0},{0, 0}},
        {{targetView.frame.size.width / 2, targetView.frame.size.height / 2, 0},{0, 0, 0},{1, 0}},
        {{-targetView.frame.size.width / 2, -targetView.frame.size.height / 2, 0},{0, 0, 0},{0, 1}},
        {{targetView.frame.size.width / 2, -targetView.frame.size.height / 2, 0},{0, 0, 0},{1, 1}},
    };
    GLushort indices[] = {
        0, 1, 2, 2,1,3
    };
    
    NSData *vertexData = [NSData dataWithBytes:vertices length:sizeof(vertices)];
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];
    
    return [self initWithVerticesData:vertexData indicesData:indexData];
}

- (void) drawEntireMesh
{
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
}

@end
