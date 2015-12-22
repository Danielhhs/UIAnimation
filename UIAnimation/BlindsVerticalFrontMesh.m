//
//  BlindsVerticalFrontMesh.m
//  BlindAnimation
//
//  Created by Huang Hongsen on 15/8/3.
//  Copyright (c) 2015年 cn.daniel. All rights reserved.
//

#import "BlindsVerticalFrontMesh.h"
@interface BlindsVerticalFrontMesh() {
    SceneMeshVertex* vertices;
    GLsizei vertexCount;
}
@property (nonatomic) GLuint rowCount;
@property (nonatomic) GLfloat yResolution;
@property (nonatomic) GLfloat width;
@end

@implementation BlindsVerticalFrontMesh
- (instancetype) initWithScreenWidth:(size_t)screenWidth
                        screenHeight:(size_t)screenHeight
                            rowCount:(GLuint)rowCount
                           direction:(BlindsDirection)direction
{
    _rowCount = rowCount;
    _width = screenWidth;
    vertexCount = rowCount * 2 * 2;
    self.yResolution = (GLfloat)screenHeight / rowCount;
    GLsizeiptr vertexSize = sizeof(SceneMeshVertex) * vertexCount;
    vertices = malloc(vertexSize);
    
    [self updateWithRotation:0];
    
    GLsizei indexCount = rowCount * 4;
    GLsizeiptr indexSize = sizeof(GLushort) * indexCount;
    GLushort *indicies = malloc(indexSize);
    int index = 0;
    for (int i = 0; i < rowCount; i++) {
        indicies[index++] = i * 4;
        indicies[index++] = i * 4 + 1;
        indicies[index++] = i * 4 + 2;
        indicies[index++] = i * 4 + 3;
    }
    NSData *vertexData = [NSData dataWithBytes:vertices length:vertexSize];
    NSData *indexData = [NSData dataWithBytes:indicies length:indexSize];
    return [self initWithVerticesData:vertexData indicesData:indexData];
}

- (void) drawColumnAtIndex:(NSInteger)index
{
    glDrawElements(GL_TRIANGLE_STRIP, 4 , GL_UNSIGNED_SHORT, NULL + (index * 4) * sizeof(GLushort));
}

- (void) drawEntireMesh
{
    for (int i = 0; i < self.rowCount; i++) {
        glDrawElements(GL_TRIANGLE_STRIP, 4 , GL_UNSIGNED_SHORT, NULL + (i * 4) * sizeof(GLushort));
    }
}

- (void) updateWithRotation:(GLfloat)rotation
{
    rotation += M_PI_4;
    GLint columnCount = self.rowCount;
    GLfloat sqr2Over2 = sqrt(2) / 2;
    GLfloat zAnchor = -self.yResolution / 2;
    for (int i = 0; i < columnCount; i++) {
        GLfloat yCenter = (i + 0.5) * self.yResolution;
        vertices[i * 4].position.x = 0;
        vertices[i * 4].position.y = yCenter - self.yResolution * sqr2Over2 * cos(rotation);
        vertices[i * 4].position.z = zAnchor + self.yResolution *sqr2Over2 * sin(rotation);
        vertices[i * 4].normal.x = 0;
        vertices[i * 4].normal.y = 0;
        vertices[i * 4].normal.z = 1;
        vertices[i * 4].texCoords.s = 0;
        vertices[i * 4].texCoords.t = 1 - (GLfloat)i / columnCount;
        
        vertices[i * 4 + 1].position.x  = self.width;
        vertices[i * 4 + 1].position.y = vertices[i * 4].position.y;
        vertices[i * 4 + 1].position.z = vertices[i * 4].position.z;
        
        vertices[i * 4 + 1].normal.x = 0;
        vertices[i * 4 + 1].normal.y = 0;
        vertices[i * 4 + 1].normal.z = 1;
        vertices[i * 4 + 1].texCoords.s = 1;
        vertices[i * 4 + 1].texCoords.t = 1 - (GLfloat)i / columnCount;
        
        vertices[i * 4 + 2].position.x = 0;
        vertices[i * 4 + 2].position.y = yCenter + self.yResolution * sqr2Over2 * cos(rotation - M_PI_2);
        vertices[i * 4 + 2].position.z = zAnchor + self.yResolution * sqr2Over2 * sin(rotation + M_PI_2);
        vertices[i * 4 + 2].normal.x = 0;
        vertices[i * 4 + 2].normal.y = 0;
        vertices[i * 4 + 2].normal.z = 1;
        vertices[i * 4 + 2].texCoords.s = 0;
        vertices[i * 4 + 2].texCoords.t = 1 - (GLfloat)(i + 1) / columnCount;
        
        vertices[i * 4 + 3].position.x = self.width;
        vertices[i * 4 + 3].position.y = vertices[i * 4 + 2].position.y;
        vertices[i * 4 + 3].position.z = vertices[i * 4 + 2].position.z;
        vertices[i * 4 + 3].normal.x = 0;
        vertices[i * 4 + 3].normal.y = 0;
        vertices[i * 4 + 3].normal.z = 1;
        vertices[i * 4 + 3].texCoords.s =  1;
        vertices[i * 4 + 3].texCoords.t = 1 - (GLfloat)(i + 1) / columnCount;
    }
    [self makeDynamicAndUpdateWithVertices:vertices numberOfVertices:vertexCount];
}
@end
