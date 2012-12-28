//
//  GLViewController.m
//  OpenGLTutorial
//
//  Created by Eric Lanz on 12/28/12.
//  Copyright (c) 2012 200Monkeys. All rights reserved.
//

#import "GLViewController.h"
#import "ShaderController.h"
#import "Vertex.h"

@interface GLViewController ()

@end

@implementation GLViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context)
        NSLog(@"Failed to create ES context");
    
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    view.drawableMultisample = GLKViewDrawableMultisampleNone;
    self.preferredFramesPerSecond = 30;
    
    _shaders = [[ShaderController alloc] init];
    [_shaders loadShaders];
    
    glGenBuffers(1, &_lineBuffer);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_TEX01);
    
    _lineColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    glLineWidth(10.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    // draw a line
    Vertex line[2];
    Vertex point1 = {{0.0,0.0,-50.0}, {1, 0}};
    Vertex point2 = {{25.0,0.0,-50.0}, {1, 0}};
    line[0] = point1;
    line[1] = point2;
    
    glBindBuffer(GL_ARRAY_BUFFER, _lineBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(line), line,  GL_DYNAMIC_DRAW);
    
    glUseProgram(_shaders.lineShader);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glVertexAttribPointer(ATTRIB_TEX01, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord1));
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX2], 1, 0, GLKMatrix4Multiply(_viewMatrix, GLKMatrix4Identity).m);
    glVertexAttrib4fv(ATTRIB_COLOR, _lineColor.v);

    glDrawArrays(GL_LINES, 0, 2);
    
    // draw a triangle
    Vertex triangle[3];
    Vertex tpoint1 = {{-10.0,10.0,-50.0}, {1, 0}};
    Vertex tpoint2 = {{0.0,20.0,-50.0}, {1, 0}};
    Vertex tpoint3 = {{10.0,10.0,-50.0}, {1, 0}};
    triangle[0] = tpoint1;
    triangle[1] = tpoint2;
    triangle[2] = tpoint3;
    
    glBindBuffer(GL_ARRAY_BUFFER, _lineBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangle), triangle,  GL_DYNAMIC_DRAW);
    
    glUseProgram(_shaders.lineShader);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glVertexAttribPointer(ATTRIB_TEX01, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord1));
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX2], 1, 0, GLKMatrix4Multiply(_viewMatrix, GLKMatrix4Identity).m);
    glVertexAttrib4fv(ATTRIB_COLOR, _lineColor.v);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // draw a spinning triangle
    Vertex spoint1 = {{-10.0,5.0,-50.0}, {1, 0}};
    Vertex spoint2 = {{10.0,5.0,-50.0}, {1, 0}};
    Vertex spoint3 = {{0.0,-5.0,-50.0}, {1, 0}};
    triangle[0] = spoint1;
    triangle[1] = spoint2;
    triangle[2] = spoint3;
    
    glBindBuffer(GL_ARRAY_BUFFER, _lineBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangle), triangle,  GL_DYNAMIC_DRAW);
    
    glUseProgram(_shaders.lineShader);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glVertexAttribPointer(ATTRIB_TEX01, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord1));
    GLKMatrix4 model = GLKMatrix4Identity;
    model = GLKMatrix4Translate(model, 0.0, -10.0, 0.0);
    static float angle = 0.0;
    angle ++;
    if (angle > 360.0) angle = 0.0;
    model = GLKMatrix4RotateZ(model, GLKMathDegreesToRadians(angle));
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX2], 1, 0, GLKMatrix4Multiply(_viewMatrix, model).m);
    glVertexAttrib4fv(ATTRIB_COLOR, _lineColor.v);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
#ifdef DEBUG
    static int framecount = 0;
    framecount ++;
    if (framecount > 30)
    {
        float ft = self.timeSinceLastDraw;
        NSString * debugText = [NSString stringWithFormat:@"%2.1f, %0.3f, %f", 1.0/ft, ft, angle];
        [self.debugLabel setText:debugText];
        framecount = 0;
    }
#endif
}

- (void)update
{
    float aspect = fabsf([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
    _viewMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0f), aspect, 1.0, 100.0);
    static float angle = 0.0;
    angle ++;
    if (angle > 360.0) angle = 0.0;
    _viewMatrix = GLKMatrix4RotateZ(_viewMatrix,GLKMathDegreesToRadians(angle));
}

@end
