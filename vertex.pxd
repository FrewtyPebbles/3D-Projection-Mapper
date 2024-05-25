from camera cimport Camera, Screen

ctypedef ((float,float),(float,float)) mat2x2

cdef class Vec3:
    cdef public float x,y,z
    
    cpdef (float, float) project(self, Camera camera, Screen screen)

    cpdef bint eq_vec(self, Vec3 other)
    
    cpdef public float get_magnitude(self)
    
    cpdef public Vec3 get_normalized(self)
    
    cdef tuple[list[Vec3],list[Vec3],list[Vec3]] get_rotation_matrix(Vec3 rot)
    
    cpdef public Vec3 rotate(self, Vec3 rotation)

    cpdef public Vec3 cross_prod(self, Vec3 other)
    
    cpdef public Vec3 dot(self, Vec3 other)

    cpdef (float, float, float) tuple(self)

    cpdef (float, float) tuple2d(self)

    cpdef Vec3 clone(self)

    cpdef Vec3 mul_vec(self, Vec3 other)

    cpdef Vec3 mul_float(self, float other)

    cpdef Vec3 mul_int(self, int other)

    cpdef Vec3 add_vec(self, Vec3 other)

    cpdef Vec3 add_float(self, float other)

    cpdef Vec3 add_int(self, int other)

    cpdef Vec3 sub_vec(self, Vec3 other)

    cpdef Vec3 sub_float(self, float other)

    cpdef Vec3 sub_int(self, int other)

    cpdef Vec3 div_vec(self, Vec3 other)

    cpdef Vec3 div_float(self, float other)

    cpdef Vec3 div_int(self, int other)

    cpdef Vec3 neg(self)