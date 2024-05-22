import itertools
from typing import Callable
from vertex import Vec3
from obj_parser import OBJParser

class Polygon:
    def __init__(self, connections:list[Vec3]) -> None:
        self.connections = connections

    def render(self, render_func:Callable[[Vec3, Vec3],None]):
        # draw line from polygon to polygon
        for v1, v2 in itertools.pairwise(self.connections):
            
            render_func(v1, v2)

        render_func(v2, self.connections[0])

class Mesh:
    def __init__(self, vertexes:list[Vec3], polygons:list[list[int]]):
        self.vertexes = vertexes
        self.polygons = polygons

    def get_polygons(self, vertexes:list[Vec3]):
        """Connects vertexes together based on vertex index pairs in `connection_indexes` """
        polygons:list[Polygon] = []
        for v_inds in self.polygons:
            polygons.append(Polygon([vertexes[i] for i in v_inds]))
        
        return polygons
    
    @classmethod
    def from_file(cls, file_path:str):
        return Mesh(*OBJParser(file_path).parse())