from vertex cimport Vec3
from camera cimport Camera, Screen
from typing import Callable

cdef class Polygon:
    cdef public list[Vec3] connections

    cpdef render_lines(self, object render_func)

    cpdef public list[(float, float)] project(self, Camera camera, Screen screen)

    cpdef ((float,float),(float,float)) get_projection_rect(self, Camera camera, Screen screen)
    
    cpdef public bint in_projection(self, int x, int y, Camera camera, Screen screen)

cdef class Mesh:
    cdef public list[Vec3] vertexes
    cdef public list[list[int]] polygons

    cpdef public list[Polygon] get_polygons(self, list[Vec3] vertexes)