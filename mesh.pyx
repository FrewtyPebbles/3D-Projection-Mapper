from __future__ import annotations
from functools import lru_cache
import itertools
from typing import Callable, TYPE_CHECKING
from vertex import Vec3
from obj_parser import OBJParser

from camera cimport Camera, Screen

cdef class Polygon:
    cdef public list[Vec3] connections
    def __init__(self, connections:list[Vec3]) -> None:
        self.connections = connections

    def render_lines(self, render_func:Callable[[Vec3, Vec3],None]):
        # draw line from polygon to polygon
        for v1, v2 in itertools.pairwise(self.connections):
            
            render_func(v1, v2)

        render_func(v2, self.connections[0])

    def project(self, camera:Camera, screen:Screen) -> list[tuple[float, float]]:
        return [con.project(camera, screen) for con in self.connections]
    
    def get_projection_rect(self, camera:Camera, screen:Screen) -> tuple[tuple[float, float], tuple[float, float]]:
        min_x:float | None = None
        max_x:float | None = None
        min_y:float | None = None
        max_y:float | None = None
        for coord in self.project(camera, screen):
            coord:tuple[float,float]
            x, y = coord
            
            
            if (max_y < y) if max_y != None else True:
                max_y = y
            if (min_y > y) if min_y != None else True:
                min_y = y
            
            if (max_x < x) if max_x != None else True:
                max_x = x
            if (min_x > x) if min_x != None else True:
                min_x = x

        return (max(0.0, min_x-1), max(0.0, min_y-1)),(min(max_x+1, float(camera.view_width)), min(max_y+1, float(camera.view_height)))
    
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
    cdef public list[Vec3] vertexes
    cdef public list[list[int]] polygons
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