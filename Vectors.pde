import java.util.Iterator;
import java.util.InputMismatchException;

static class array<T> implements Iterable<T> {
  static final int DEFAULT_CAPACITY = 8;
  public array() {
    data = new Object[DEFAULT_CAPACITY];
    size = 0;
  }
  public array(int cap) {
    data = new Object[cap];
    size = 0;
  }
  public array(T... objs) {
    data = new Object[objs.length];
    for(int i = 0; i < objs.length; ++i)
      data[i] = objs[i];
    size = objs.length;
  }
  public array(array objs) {
    data = new Object[objs.capacity()];
    size = objs.size();
    for(int i = 0; i < size; ++i)
      data[i] = objs.get(i);
  }
  public int size() {
    return size; 
  }
  public int capacity() {
    return data.length; 
  }
  public T get(int idx) {
    return (T)data[idx];
  }
  public T at(int idx) {
    if(idx >= size)
      return null;
    return get(idx);
  }
  public T set(int idx, T obj) {
    return (T)(data[idx] = obj);
  }
  public T setSafe(int idx, T obj) {
    if(idx >= size)
      return null;
    return (T)(data[idx] = obj);
  }
  public T append(T obj) {
    if(size == data.length) 
      extend();
    return (T)(data[size++] = obj);
  }
  public T prepend(T obj) {
    shift(1);
    return (T)(data[0] = obj);
  }
  public void append(T[] objs) {
    while(size + objs.length > data.length)
      extend();
    for(int i = size; i < objs.length+size; ++i)
      data[i] = objs[i-size];
    size += objs.length;
  }
  public void prepend(T[] objs) {
    shift(objs.length);
    for(int i = 0; i < objs.length; ++i)
      data[i] = objs[i];
  }
  public void clear() {
    size = 0; 
  }
  public array copy() {
    return new array(data);
  }
  public final Object[] data() {
    return data; 
  }
  @Override
  public Iterator<T> iterator() {
    return new Iterator<T> () {
      private int index = 0;
      @Override
      public boolean hasNext() {
          return index<size;
      }
      @Override
      public T next() {
          return (T)data[index++];
      }
      @Override
      public void remove() {
          throw new UnsupportedOperationException("no changes allowed");
      }
    };
  }
  protected void shift(int amount) {
    if(amount < 0) {
      size -= amount;
      for(int i = 0; i < size; ++i)
        data[i] = data[amount + i];
      return;
    }
    while(size+amount > data.length)
      extend();
    size += amount;
    for(int i = size-1; i >= amount; --i) {
      data[i] = data[i - amount];
    }
  }
  protected void extend() {
    var newdata = new Object[data.length<<1];
    for(int i = 0; i < size; ++i)
      newdata[i] = data[i];
    data = newdata;
  }
  
  protected int size;
  protected Object[] data;
}

static class vec extends array<Float> {
  public vec(int dims) {
    super(dims);
    size = dims;
    for(int i = 0; i < size; ++i)
      data[i] = 0.;
  }
  public vec(float... args) {
    super(args.length);
    for(var elem : args)
      data[size++] = elem;
  }
  public vec(mat matrix) {
    super(matrix.size());
    for(var elem : matrix)
      data[size++] = elem;
  }
  public float x() {
    return (Float)data[0];
  }
  public float y() {
    return (Float)data[1];
  }
  public float z() {
    return (Float)data[2];
  }
  public float w() {
    return (Float)data[3];
  }
  private void checkSize(int sz) {
    if(sz > size)
    {
      while(data.length < sz)
        extend();
      size = sz;
    }
  }
  public vec add(vec b) {
    checkSize(b.size());
    for(int i = 0; i < b.size(); ++i)
      data[i] = ((float)data[i]) + (float)b.get(i);
    return this;
  }
  public vec sub(vec b) {
    checkSize(b.size());
    for(int i = 0; i < b.size(); ++i)
      data[i] = ((float)data[i]) - (float)b.get(i);
    return this;
  }
  public vec mul(vec b) {
    checkSize(b.size());
    for(int i = 0; i < b.size(); ++i)
      data[i] = ((float)data[i]) * (float)b.get(i);
    return this;
  }
  public float mag() {
    return sqrt(magSq());
  }
  public float magSq() {
    float res = 0;
    for(var dim : data) {
      float dm = (float)dim;
      res += dm*dm;
    }
    return res;
  }
  public float sum() {
    float res = 0;
    for(var dim : data) {
      float dm = (float)dim;
      res += dm;
    }
    return res;
  }
  @Override
  public vec copy() {
    return (vec)((array)this).copy();
  }
  public float dot(vec b) {
    return copy().add(b).sum();
  }
  public vec cross(vec b) {
    if(size != 3 || b.size != 3)
      return null;
      
    float a1 = (Float)data[0];
    float a2 = (Float)data[1];
    float a3 = (Float)data[2];
    float b1 = (Float)b.data[0];
    float b2 = (Float)b.data[1];
    float b3 = (Float)b.data[2];
    
    return new vec(a2*b3-a3*b2, a3*b1-a1*b3, a1*b2-a2*b1);
  }
}

static class mat extends vec {
  public mat(int n, int m) {
    super(n*m);
    stride = n;
  }
  public mat(int n, float... args) {
    super(args.length);
    size = 0;
    for(var arg : args)
      data[size++] = arg;
    stride = n;
  }
  public mat(vec vector) {
    super(vector.size());
    for(size = 0; size < vector.size(); size++) {
      data[size] = vector.get(size);
    }
  }
  private boolean checkSize(mat b) {
    return size != b.size() || stride != b.stride;
  }
  public mat add(mat b) {
    if(checkSize(b)) {
      throw new InputMismatchException();
      //return null;
    }
    for(int i = 0; i < b.size(); ++i)
      data[i] = ((float)data[i]) + (float)b.get(i);
    return this;
  }
  public mat sub(mat b) {
    if(checkSize(b)) {
      throw new InputMismatchException();
      //return null;
    }
    for(int i = 0; i < b.size(); ++i)
      data[i] = ((float)data[i]) - (float)b.get(i);
    return this;
  }
  public mat add(float b) {
    for(int i = 0; i < size(); ++i)
      data[i] = ((float)data[i]) + b;
    return this;
  }
  public mat sub(float b) {
    for(int i = 0; i < size(); ++i)
      data[i] = ((float)data[i]) - b;
    return this;
  }
  public mat mul(float b) {
    for(int i = 0; i < size(); ++i)
      data[i] = ((float)data[i]) * b;
    return this;
  }
  public mat div(float b) {
    for(int i = 0; i < size(); ++i)
      data[i] = ((float)data[i]) / b;
    return this;
  }
  @Override
  public mat copy() {
    var res = new mat(stride, size/stride);
    for(int i = 0; i < size; ++i)
      res.data[i] = data[i];
    return res;
  }
  public mat mul(mat b) {
    if(stride != b.size()/b.stride) {
      throw new InputMismatchException();
      //return null;
    }
    int n = stride;
    int m = size/stride;
    int p = b.stride;
    var res = new mat(p, m);
    for(int row = 0; row < m; ++row)
      for(int k = 0; k < n; ++k)
        for(int col = 0; col < p; ++col)
          res.data[row*p+col] = (Float)res.data[row*p+col] + ((Float)data[row*n+k])*(Float)b.data[k*p+col];
          
    return res;
  }
  
  int stride;
}

class ray {
  public ray(mat origin, mat direction) {
    or = origin;
    di = direction;
  }
  public ray(float... args) {
    int dim = args.length/2;
    var fi = new float[dim];
    var se = new float[dim];
    for(int i = 0; i < dim; ++i) {
      fi[i] = args[i];
      se[i] = args[i+dim];
    }
    or = new mat(dim, fi);
    di = new mat(dim, se);
  }
  public mat or;
  public mat di;
}
