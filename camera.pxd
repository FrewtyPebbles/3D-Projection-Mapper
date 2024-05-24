# distutils: language=c++
from vertex cimport Vec3
from object cimport Object
from libcpp.vector cimport vector

cdef class Screen:
    cdef public int width
    cdef public int height
    
cdef class Camera:
    cdef public Vec3 position
    cdef public int view_width
    cdef public int view_height
    cdef public int view_distance
    cdef public vector[vector[float]] depth_buffer
    cdef public vector[vector[float]] cleared_depth_buffer

    cpdef public void set_depth_buffer(self, int x, int y, float depth)

    cpdef public float get_depth_buffer(self, int x, int y)
    
    cpdef public void clear_depth_buffer(self)

    cpdef public void _render(self, list[Object] objects, object render_function, object wire_render_func)