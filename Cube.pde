
class Cube {
  Cube(int dim, float side) {
    vert = new array<mat>(1<<dim);
    edges = new array<ray>();
    vert.append(new mat(1, dim));
    for(int i = 0; i < dim; ++i)
      vert.get(0).set(i, side);
    dims = dim;
    for(int i = 0; i < dim; ++i)
      for(int j = 0; j < (1<<i); ++j) {
        var v = vert.get(j).copy();
        v.set(i, -side);
        vert.append(v);
      }
    for(int i = 0; i < vert.size(); ++i) {
      for(int j = 0; j < dim; ++j) {
        edges.append(new ray(vert.get(i), vert.get(i^(1<<j))));
      }
    }
  }
  
  int dims;
  array<mat> vert;
  array<ray> edges;
}
