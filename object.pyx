from __future__ import annotations
from copy import deepcopy
from dataclasses import dataclass
from functools import lru_cache
from typing import Callable
import math as m

from mesh import Mesh, Polygon
from vertex import Vec3
            


cdef class Object:
    def __init__(self, mesh:Mesh, position:Vec3 | None = None, rotation:Vec3 | None = None, scale:Vec3 | None = None) -> None:
        self.mesh = mesh
        self.position = position if position else Vec3(0,0,0)
        self.rotation = rotation if rotation else Vec3(0,0,0)
        self.scale = scale if scale else Vec3(0,0,0)
        self.rot_cache = None
    
    cpdef public void render(self,
        render_function:Callable[[Polygon],None] | None,
        wire_render_func:Callable[[Vec3, Vec3],None] | None
    ):
        cdef list[Polygon] polygons = self.mesh.get_polygons(
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

    cpdef public list[Vec3] get_translation(self, list[Vec3] vertexes):

        cdef list[Vec3] ret_verts = []
        cdef Vec3 pos = self.position
        ret_verts.extend([vert + pos for vert in vertexes])
        return ret_verts

    cpdef public list[Vec3] get_rotation(self, list[Vec3] vertexes):
        cdef Vec3 rot = self.rotation
        if self.rot_cache == rot:
            return vertexes
        self.rot_cache = rot

        cdef list[Vec3] ret_verts = []
        ret_verts.extend([vert.rotate(rot) for vert in vertexes])
        return ret_verts
