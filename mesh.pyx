from __future__ import annotations
from functools import lru_cache
import itertools
from typing import Callable, TYPE_CHECKING
from vertex import Vec3
from obj_parser import OBJParser
from camera cimport Camera, Screen
cdef extern from "macros.h":
    cdef float c_min2(...)
    cdef float c_max2(...)


cdef class Polygon:
    def __init__(self, connections:list[Vec3]) -> None:
        self.connections = connections

    cpdef render_lines(self, render_func:Callable[[Vec3, Vec3],None]):
        # draw line from polygon to polygon
        cdef Vec3 v1, v2
        for v1, v2 in itertools.pairwise(self.connections):
            
            render_func(v1, v2)

        render_func(v2, self.connections[0])

    cpdef list[tuple[float, float]] project(self, Camera camera, Screen screen):
        return [con.project(camera, screen) for con in self.connections]
    
    cpdef ((float,float),(float,float)) get_projection_rect(self, Camera camera, Screen screen):
        cdef list[tuple[float,float]] coords = self.project(camera, screen)
        cdef float x = coords[0][0]
        cdef float y = coords[0][1]
        cdef float min_x = x
        cdef float max_x = x
        cdef float min_y = y
        cdef float max_y = y
        for x, y in coords:
            
            
            if (max_y < y):
                max_y = y
            if (min_y > y):
                min_y = y
            
            if (max_x < x):
                max_x = x
            if (min_x > x):
                min_x = x

        return (c_max2(0.0, min_x-1), c_max2(0.0, min_y-1)),(c_min2(max_x+1, float(camera.view_width)), c_min2(max_y+1, float(camera.view_height)))
    
    cpdef public bint in_projection(self, int x, int y, Camera camera, Screen screen):
        cdef list[tuple[float, float]] cons = self.project(camera, screen)
        cdef int cons_len = len(cons)
        cdef bint result = False
        cdef int j = cons_len-1
        for i in range(cons_len):
            if (cons[i][1] < y and cons[j][1] >= y or cons[j][1] < y and cons[i][1] >= y) \
            and (cons[i][0] + (y - cons[i][1]) / (cons[j][1] - cons[i][1]) * (cons[j][0] - cons[i][0]) < x):
                result = not result

            j = i
        return result



cdef class Mesh:

    def __init__(self, vertexes:list[Vec3], polygons:list[list[int]]):
        self.vertexes = vertexes
        self.polygons = polygons

    cpdef public list[Polygon] get_polygons(self, list[Vec3] vertexes):
        """Connects vertexes together based on vertex index pairs in `connection_indexes` """
        cdef list[Polygon] polygons = []
        polygons.extend([Polygon([vertexes[i] for i in v_inds]) for v_inds in self.polygons])
        
        return polygons
    
    @staticmethod
    @lru_cache(1024)
    def from_file(file_path:str):
        return Mesh(*OBJParser(file_path).parse())