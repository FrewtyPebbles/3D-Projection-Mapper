from __future__ import annotations
from functools import lru_cache
import itertools

from camera cimport Camera, Screen
from vertex cimport Vec3
from cython.parallel import prange
from cython cimport address
from obj_parser cimport OBJParser

cdef extern from "macros.h":
    cdef float c_min2(...)
    cdef float c_max2(...)

cimport cython

cdef class Polygon:
    def __init__(self, list[Vec3] connections) -> None:
        self.connections = connections

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef render_lines(self, object render_func):
        """
        render_func:Callable[[Vec3, Vec3],None]
        """

        # draw line from polygon to polygon
        cdef Vec3 v1, v2
        for v1, v2 in itertools.pairwise(self.connections):
            
            render_func(v1, v2)

        render_func(v2, self.connections[0])

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef public list[(float, float)] project(self, Camera camera, Screen screen):
        cdef list[(float, float)] ret_vec = []
        cdef Vec3 con
        for con in self.connections:
            ret_vec.append(con.project(camera, screen))
        return ret_vec
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef ((float,float),(float,float)) get_projection_rect(self, Camera camera, Screen screen):
        cdef:
            list[(float,float)] coords = self.project(camera, screen)
            float x = coords[0][0]
            float y = coords[0][1]
            float min_x = x
            float max_x = x
            float min_y = y
            float max_y = y
            # addresses
            float* _min_x = address(min_x)
            float* _max_x = address(max_x)
            float* _min_y = address(min_y)
            float* _max_y = address(max_y)

        cdef int i
        cdef int c_len = len(coords)
        with nogil:
            for i in prange(0, c_len):
                with gil:
                    x,y = <(float, float)>coords[i]
                
                if (_max_y[0] < y):
                    _max_y[0] = y
                if (_min_y[0] > y):
                    _min_y[0] = y
                
                if (_max_x[0] < x):
                    _max_x[0] = x
                if (_min_x[0] > x):
                    _min_x[0] = x

        return (c_max2(0.0, min_x-1), c_max2(0.0, min_y-1)),(c_min2(max_x+1, <float>camera.view_width), c_min2(max_y+1, <float>camera.view_height))
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    cpdef public bint in_projection(self, int x, int y, Camera camera, Screen screen):
        cdef:
            list[(float, float)] cons = self.project(camera, screen)
            int cons_len = len(cons)
            Py_ssize_t j
            Py_ssize_t i
            bint result = False
            bint * _result = address(result)
            int _x = <int>x
            int _y = <int>y
            float c_i_x, c_i_y, c_j_x, c_j_y
        with nogil:
            for i in prange(0, cons_len):
                if i == 0:
                    j = cons_len-1
                else:
                    j = i-1
                with gil:
                    c_i_x, c_i_y = cons[i]
                    c_j_x, c_j_y = cons[j]
                if (c_i_y < _y and c_j_y >= _y or c_j_y < _y and c_i_y >= _y) \
                and (c_i_x + (_y - c_i_y) / (c_j_y - c_i_y) * (c_j_x - c_i_x) < _x):
                    _result[0] = not _result[0]
        return result



cdef class Mesh:

    def __init__(self, list[Vec3] vertexes, list[list[int]] polygons):
        self.vertexes = vertexes
        self.polygons = polygons
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef public list[Polygon] get_polygons(self, list[Vec3] vertexes):
        """Connects vertexes together based on vertex index pairs in `connection_indexes` """
        cdef list[Polygon] polygons = []

        cdef list[int] v_inds
        cdef int i
        for v_inds in self.polygons:
            polygons.append(Polygon([vertexes[i] for i in v_inds]))
        
        return polygons
    
    @staticmethod
    @lru_cache(1024)
    def from_file(str file_path):
        return Mesh(*OBJParser(file_path).parse())