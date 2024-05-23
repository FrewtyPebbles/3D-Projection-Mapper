from __future__ import annotations
from copy import deepcopy
from dataclasses import dataclass
from functools import lru_cache
from typing import Callable
import math as m

from mesh import Mesh, Polygon
from vertex import Vec3
            


class Object:
    def __init__(self, mesh:Mesh, position:Vec3 | None = None, rotation:Vec3 | None = None) -> None:
        self.mesh = mesh
        self.position = position if position else Vec3(0,0,0)
        self.rotation = rotation if rotation else Vec3(0,0,0)
        self.rot_cache:Vec3 | None = None
    
    def render(self,
        render_function:Callable[[Polygon],None] | None = None,
        wire_render_func:Callable[[Vec3, Vec3],None] | None = None
    ):
        polygons = self.mesh.get_polygons(
            self.get_translation(
                self.get_rotation(
                    self.mesh.vertexes
                )
            )
        )

        for polygon in polygons:
            if render_function:
                render_function(polygon)
            if wire_render_func:
                polygon.render_lines(wire_render_func)

    def get_translation(self, vertexes:list[Vec3]) -> list[Vec3]:

        ret_verts:list[Vec3] = []
        ret_verts.extend([vert + self.position for vert in vertexes])
        return ret_verts

    def get_rotation(self, vertexes:list[Vec3]) -> list[Vec3]:
        if self.rot_cache == self.rotation:
            return vertexes
        self.rot_cache = self.rotation

        ret_verts:list[Vec3] = []
        ret_verts.extend([vert.rotate(self.rotation) for vert in vertexes])
        return ret_verts
