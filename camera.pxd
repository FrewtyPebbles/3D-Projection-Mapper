from vertex cimport Vec3
from object import Object
from typing import Callable
from mesh import Polygon

cdef class Screen:
    cdef public int width
    cdef public int height
    
cdef class Camera:
    cdef public Vec3 position
    cdef public int view_width
    cdef public int view_height
    cdef public int view_distance
    cdef public list[list[int]] depth_buffer
    cdef public list[list[int]] cleared_depth_buffer

    cpdef public void clear_depth_buffer(self)

    cpdef public void _render(self, list[Object] objects,
    render_function:Callable[[Polygon],None] | None,
    wire_render_func:Callable[[Vec3, Vec3],void] | None)