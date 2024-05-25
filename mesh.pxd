from vertex cimport Vec3
from camera cimport Camera, Screen
from typing import Callable

cpdef (float,float) lerp2d(float x, float x0,float y0,float x1,float y1)

cdef class Polygon:
    cdef public list[Vec3] connections

    cpdef float bary_get_z(self, x, y)

    cpdef (int, int) get_render_row_range(self, int y, list[(float, float)] projections)

    cpdef render_lines(self, object render_func)

    cpdef public list[(float, float)] project(self, Camera camera, Screen screen)

    cpdef (float,float,float) get_subtriangle_ratios(self, float x, float y, list[(float, float)] projections)

    cpdef ((float,float),(float,float)) get_projection_rect(self, list[(float, float)] projections, Camera camera)
    
    cpdef public bint in_projection(self, int x, int y, Camera camera, Screen screen)

cdef class Mesh:
    cdef public list[Vec3] vertexes
    cdef public list[list[int]] polygons

    cpdef public list[Polygon] get_polygons(self, list[Vec3] vertexes)