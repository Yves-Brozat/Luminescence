class SVGImport{
  
  PShape svgShape;
  int N; //nombres de vertices
  ArrayList<PVector> vertices;
  PVector offset;
  float scale;
  boolean visible;

  SVGImport(PShape _svgShape, float _scale, float x, float y){
    svgShape = _svgShape;
    scale = _scale;
    offset = new PVector(x,y);
    visible = false;
    N = svgShape.getVertexCount();
    vertices = new ArrayList<PVector>();
    for(int i=0; i<N; i++){
      vertices.add(new PVector(svgShape.getVertex(i).x,svgShape.getVertex(i).y));
      vertices.get(i).add(svgShape.height, svgShape.width);
    }
    resize(scale,offset.x,offset.y);

  }

  void drawShape(PGraphics pg_obstacles){
    pg_obstacles.smooth(4);
    pg_obstacles.beginShape();
    if (visible)
      pg_obstacles.stroke(255);
    else 
      pg_obstacles.stroke(0);
    pg_obstacles.fill(0);
    for (int i = 0; i<N; i++){
      pg_obstacles.curveVertex(vertices.get(i).x, vertices.get(i).y);
    }
    pg_obstacles.endShape(CLOSE);   
  }

  void resize(float _scale){
    float scl = _scale/scale;
    for(int i = 0; i<N; i++){
      vertices.get(i).sub(offset.x,offset.y);
      vertices.get(i).sub(0.5*svgShape.width,0.5*svgShape.height);
      vertices.get(i).mult(scl);
      vertices.get(i).add(offset.x,offset.y);
      vertices.get(i).add(0.5*svgShape.width,0.5*svgShape.height);
    }   
    scale = _scale;
  }

  void displace(float x, float y){
    float offx = x - offset.x;
    float offy = y - offset.y;
    for(int i = 0; i<N; i++){
      vertices.get(i).add(offx,offy);
    }   
    offset.x = x;
    offset.y = y;
  }

  void resize(float scale, float x, float y){

 
    for(int i = 0; i<N; i++){
     // vertices.get(i).rotate(HALF_PI);
      vertices.get(i).mult(scale);
      vertices.get(i).add(x,y);
   //  vertices.get(i).set(0.15*svgShape.getVertex(i).x,
    //                      0.15*svgShape.getVertex(i).y);
    }
  }
  
}
