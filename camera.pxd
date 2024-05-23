from vertex cimport Vec3

cdef class Screen:
    cdef public int width
    cdef public int height
    
cdef class Camera:
    cdef public Vec3 position
    cdef public int view_width
    cdef public int view_height
    cdef public int view_distance
    cdef public list[list[int]] depth_buffer