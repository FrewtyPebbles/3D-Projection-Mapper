from __future__ import annotations
from dataclasses import dataclass
from typing import Callable
import math as m

from mesh import Mesh
from vertex import Vec3
            


class Object:
    def __init__(self, mesh:Mesh, position:Vec3 | None = None, rotation:Vec3 | None = None) -> None:
        self.mesh = mesh
        self.position = position if position else Vec3(0,0,0)
        self.rotation = rotation if rotation else Vec3(0,0,0)
    
    def render(self, render_func:Callable[[Vec3, Vec3],None]):
        verts = self.mesh.get_polygons(
            self.get_translation(
                self.position,
                self.get_rotation(
                    self.rotation,
                    self.mesh.vertexes
                )
            )
            
        )

        for vert in verts:
            vert.render(render_func)

    @classmethod
    def get_translation(cls, translation:Vec3, vertexes:list[Vec3]) -> list[Vec3]:
        ret_verts:list[Vec3] = []
        for vert in vertexes:
            ret_verts.append(vert + translation)
        return ret_verts

    @classmethod
    def get_rotation(cls, rotation:Vec3, vertexes:list[Vec3]) -> list[Vec3]:
        ret_verts:list[Vec3] = []
        for vert in vertexes:
            ret_verts.append(vert.rotate(rotation))
        return ret_verts
