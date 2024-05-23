from camera cimport Camera, Screen

cdef class Vec3:
    cdef public float x
    cdef public float y
    cdef public float z
    cpdef (float, float) project(self, Camera camera, Screen screen)
    cpdef public float get_magnitude(self)
    cpdef public Vec3 get_normalized(self)
    cdef public tuple[list[Vec3],list[Vec3],list[Vec3]] get_rotation_matrix(Vec3 rot)
    cpdef public Vec3 rotate(self, Vec3 rotation)