//
//  GridCurrentMesh.m
//  GridAnimation
//
//  Created by Huang Hongsen on 6/24/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "GridCurrentMesh.h"

@interface GridCurrentMesh () {
    SceneMeshVertex *vertices;
}

@end

@implementation GridCurrentMesh

- (instancetype) initWithScreenWidth:(size_t)screenWidth screenHeight:(size_t)screenHeight
{
    vertices = malloc(4 * sizeof(SceneMeshVertex));
    vertices[0].position = GLKVector3Make(0, 0, 0);
    vertices[0].texCoords = GLKVector2Make(0, 1);
    vertices[1].position = GLKVector3Make(screenWidth, 0, 0);
    vertices[1].texCoords = GLKVector2Make(1, 1);
    
    vertices[2].position = GLKVector3Make(0, screenHeight, 0);
    vertices[2].texCoords = GLKVector2Make(0, 0);
    vertices[3].position = GLKVector3Make(screenWidth, screenHeight, 0);
    vertices[3].texCoords = GLKVector2Make(1, 0);
    
    GLushort indicies[4] = {0, 1, 2, 3};
    
    NSData *vertexData = [NSData dataWithBytes:vertices length:4 * sizeof(SceneMeshVertex)];
    NSData *indexData = [NSData dataWithBytes:indicies length:4 * sizeof(GLushort)];
    return [self initWithVerticesData:vertexData indicesData:indexData];
}

- (void) drawEntireMesh
{
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, NULL);
}

@end
