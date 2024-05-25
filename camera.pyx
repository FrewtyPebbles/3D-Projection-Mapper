# distutils: language=c++
from __future__ import annotations
from typing import Callable
import math as m

from vertex cimport Vec3
from mesh cimport Polygon
from object cimport Object
from libc.math cimport INFINITY
cimport cython

cdef class Screen:
    def __init__(self, int width, int height) -> None:
        self.width = width
        self.height = height
    
cdef class Camera:
    def __init__(self, Vec3 position, int view_width, int view_height, int view_distance) -> None:
        self.position = position
        self.view_width = view_width
        self.view_height = view_height
        self.view_distance = view_distance
        
        # create "empty" depth buffer

        cdef vector[vector[float]] outer_vec
        cdef vector[float] inner_vec
        cdef int _
        for _ in range(view_width):
            inner_vec.clear()
            for _ in range(view_height):
                inner_vec.push_back(INFINITY)
            outer_vec.push_back(inner_vec)

        self.cleared_depth_buffer = outer_vec

        self.depth_buffer = outer_vec

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef public void set_depth_buffer(self, int x, int y, float depth):
        self.depth_buffer[x][y] = depth

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef public float get_depth_buffer(self, int x, int y):
        return self.depth_buffer[x][y]

    cpdef public void clear_depth_buffer(self):
        #cdef float inf = m.inf
        self.depth_buffer = self.cleared_depth_buffer

    def render(self, list[Object] objects, object render_function = None, object wire_render_func = None):
        """
        render_func:Callable[[Camera,Polygon],None]

        wire_render_func:Callable[[Camera,Vec3, Vec3],None]
        """
        self._render(objects, render_function, wire_render_func)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef public void _render(self, list[Object] objects, object render_function, object wire_render_func):
        cdef Object obj
        for obj in objects:
            obj._render(render_function, wire_render_func)
            
        self.clear_depth_buffer()