//
//  BlindBackMesh.m
//  BlindAnimation
//
//  Created by Huang Hongsen on 6/7/15.
//  Copyright (c) 2015 cn.daniel. All rights reserved.
//

#import "BlindsHorizontalBackMesh.h"
@interface BlindsHorizontalBackMesh() {
    SceneMeshVertex* vertices;
    GLsizei vertexCount;
}
@property (nonatomic) GLuint columnCount;
@property (nonatomic) GLfloat xResolution;
@property (nonatomic) GLfloat height;
@property (nonatomic) BlindsDirection direction;
@end

@implementation BlindsHorizontalBackMesh
- (instancetype) initWithScreenWidth:(size_t)screenWidth
                        screenHeight:(size_t)screenHeight
                             columns:(GLuint)columnCount
                           direction:(BlindsDirection)direction
{
    _columnCount = columnCount;
    vertexCount = columnCount * 2 * 2;
    _direction = direction;
    _xResolution = (GLfloat)screenWidth / columnCount;
    _height = screenHeight;
    GLsizeiptr vertexSize = sizeof(SceneMeshVertex) * vertexCount;
    vertices = malloc(vertexSize);
    
    [self updateWithRotation:0];
    
    GLsizei indexCount = columnCount * 4;
    GLsizeiptr indexSize = sizeof(GLushort) * indexCount;
    GLushort *indicies = malloc(indexSize);
    int index = 0;
    for (int i = 0; i < columnCount; i++) {
        indicies[index++] = i * 2;
        indicies[index++] = i * 2 + 1;
        indicies[index++] = 2 * columnCount + i * 2;
        indicies[index++] = 2 * columnCount + i * 2 + 1;
    }
    NSData *vertexData = [NSData dataWithBytes:vertices length:vertexSize];
    NSData *indexData = [NSData dataWithBytes:indicies length:indexSize];
    return [self initWithVerticesData:vertexData indicesData:indexData];
}

- (void) drawColumnAtIndex:(NSInteger)index
{
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, NULL + index * 4 * sizeof(GLshort));
}

- (void) drawEntireMesh
{
    for (int i = 0; i < self.columnCount; i++) {
        glDrawElements(GL_TRIANGLE_STRIP, 4 , GL_UNSIGNED_SHORT, NULL + (i * 4) * sizeof(GLushort));
    }
}

- (void) updateWithRotation:(GLfloat)rotation
{
    if (self.direction == BlindsDirectionLeftToRight) {
        rotation -= M_PI_4;
    } else {
        rotation += M_PI_4;
    }
    GLint columnCount = self.columnCount;
    GLfloat sqr2Over2 = sqrt(2) / 2;
    GLfloat zAnchor = -self.xResolution / 2;
    for (int i = 0; i < columnCount; i++) {
        GLfloat xCenter = (i + 0.5) * self.xResolution;
        if (self.direction == BlindsDirectionRightToLeft) {
            vertices[i * 2].position.x = xCenter + self.xResolution * sqr2Over2 * cos(rotation - M_PI_2);
            vertices[i * 2].position.z = zAnchor + self.xResolution * sqr2Over2 * sin(rotation + M_PI_2);
        } else {
            vertices[i * 2].position.x = xCenter - self.xResolution * sqr2Over2 * cos(rotation);
            vertices[i * 2].position.z =zAnchor + self.xResolution * sqr2Over2 * sin(rotation);
        }
        vertices[i * 2].position.y = 0;

        vertices[i * 2].normal.x = 0;
        vertices[i * 2].normal.y = 0;
        vertices[i * 2].normal.z = 1;
        vertices[i * 2].texCoords.s = (GLfloat)i / columnCount;
        vertices[i * 2].texCoords.t = 1;
        
        
        if (self.direction == BlindsDirectionRightToLeft) {
            vertices[i * 2 + 1].position.x = xCenter + self.xResolution * sqr2Over2 * cos(rotation);
            vertices[i * 2 + 1].position.z =zAnchor + self.xResolution * sqr2Over2 * sin(-rotation);
        } else {
            vertices[i * 2 + 1].position.x = xCenter - self.xResolution * sqr2Over2 * cos(rotation + M_PI_2);
            vertices[i * 2 + 1].position.z = zAnchor + self.xResolution * sqr2Over2 * sin(rotation + M_PI_2);
        }
        vertices[i * 2 + 1].position.y = 0;

        vertices[i * 2 + 1].normal.x = 0;
        vertices[i * 2 + 1].normal.y = 0;
        vertices[i * 2 + 1].normal.z = 1;
        vertices[i * 2 + 1].texCoords.s = (GLfloat)(i + 1) / columnCount;
        vertices[i * 2 + 1].texCoords.t = 1;
        
        vertices[columnCount * 2 + i * 2].position.x = vertices[i * 2].position.x;
        vertices[columnCount * 2 + i * 2].position.y = self.height;
        vertices[columnCount * 2 + i * 2].position.z = vertices[i * 2].position.z;
        vertices[columnCount * 2 + i * 2].normal.x = 0;
        vertices[columnCount * 2 + i * 2].normal.y = 0;
        vertices[columnCount * 2 + i * 2].normal.z = 1;
        vertices[columnCount * 2 + i * 2].texCoords.s = vertices[i * 2].texCoords.s;
        vertices[columnCount * 2 + i * 2].texCoords.t = 0;
        
        vertices[columnCount * 2 + i * 2 + 1].position.x = vertices[i * 2 + 1].position.x;
        vertices[columnCount * 2 + i * 2 + 1].position.y = self.height;
        vertices[columnCount * 2 + i * 2 + 1].position.z = vertices[i * 2 + 1].position.z;
        vertices[columnCount * 2 + i * 2 + 1].normal.x = 0;
        vertices[columnCount * 2 + i * 2 + 1].normal.y = 0;
        vertices[columnCount * 2 + i * 2 + 1].normal.z = 1;
        vertices[columnCount * 2 + i * 2 + 1].texCoords.s =  vertices[i * 2 + 1].texCoords.s;
        vertices[columnCount * 2 + i * 2 + 1].texCoords.t = 0;
    }
    [self makeDynamicAndUpdateWithVertices:vertices numberOfVertices:vertexCount];
}

@end
