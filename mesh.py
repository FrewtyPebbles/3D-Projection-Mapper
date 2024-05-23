from __future__ import annotations
from functools import lru_cache
import itertools
from typing import Callable, TYPE_CHECKING
from vertex import Vec3
from obj_parser import OBJParser

if TYPE_CHECKING:
    from camera import Camera, Screen

class Polygon:
    def __init__(self, connections:list[Vec3]) -> None:
        self.connections = connections

    def render_lines(self, render_func:Callable[[Vec3, Vec3],None]):
        # draw line from polygon to polygon
        for v1, v2 in itertools.pairwise(self.connections):
            
            render_func(v1, v2)

        render_func(v2, self.connections[0])

    def project(self, camera:Camera, screen:Screen):
        return [con.project(camera, screen) for con in self.connections]
    
    def get_projection_rect(self, camera:Camera, screen:Screen) -> tuple[tuple[int, int], tuple[int, int]]:
        min_x:int = None
        max_x:int = None
        min_y:int = None
        max_y:int = None
        for coord in self.project(camera, screen):
            coord:tuple[int,int]
            x, y = coord
            
            
            if (max_y < y) if max_y != None else True:
                max_y = y
            if (min_y > y) if min_y != None else True:
                min_y = y
            
            if (max_x < x) if max_x != None else True:
                max_x = x
            if (min_x > x) if min_x != None else True:
                min_x = x

        return (max(0, min_x-1), max(0, min_y-1)),(min(max_x+1, camera.view_width), min(max_y+1, camera.view_height))
    
    def in_projection(self, x:int, y:int, camera:Camera, screen:Screen) -> bool:
        cons = self.project(camera, screen)
        cons_len = len(cons)
        result:bool = False
        j:int = cons_len-1
        for i in range(cons_len):
            if (cons[i][1] < y and cons[j][1] >= y or cons[j][1] < y and cons[i][1] >= y) \
            and (cons[i][0] + (y - cons[i][1]) / (cons[j][1] - cons[i][1]) * (cons[j][0] - cons[i][0]) < x):
                result = not result

            j = i
        return result



class Mesh:
    def __init__(self, vertexes:list[Vec3], polygons:list[list[int]]):
        self.vertexes = vertexes
        self.polygons = polygons

    def get_polygons(self, vertexes:list[Vec3]):
        """Connects vertexes together based on vertex index pairs in `connection_indexes` """
        polygons:list[Polygon] = []
        polygons.extend([Polygon([vertexes[i] for i in v_inds]) for v_inds in self.polygons])
        
        return polygons
    
    @staticmethod
    @lru_cache(1024)
    def from_file(file_path:str):
        return Mesh(*OBJParser(file_path).parse())