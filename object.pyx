from __future__ import annotations

from mesh cimport Mesh, Polygon
from vertex cimport Vec3
from cython.parallel import prange

cdef class Object:
    def __init__(self, Mesh mesh, Vec3 position = None, Vec3 rotation = None, Vec3 scale = None) -> None:
        self.mesh = mesh
        self.position = position if position else Vec3(0,0,0)
        self.rotation = rotation if rotation else Vec3(0,0,0)
        self.scale = scale if scale else Vec3(0,0,0)

    def render(self, object render_function = None, object wire_render_func = None):
        """
        render_function:Callable[[Polygon],None]

        wire_render_func:Callable[[Vec3, Vec3],None]
        """
        self._render(render_function, wire_render_func)
    
    cpdef void _render(self, object render_function, object wire_render_func):
        cdef list[Polygon] polygons = self.mesh.get_polygons(
            self.get_translation(
                self.get_rotation(
                    self.mesh.vertexes
                )
            )
        )

        cdef int i
        cdef int p_len = len(polygons)
        for i in range(p_len):
            if render_function:
                render_function(polygons[i])
            if wire_render_func:
                polygons[i].render_lines(wire_render_func)

    cpdef public list[Vec3] get_translation(self, list[Vec3] vertexes):

        cdef list[Vec3] ret_verts = []
        cdef Vec3 pos = self.position
        cdef Vec3 vert
        for vert in vertexes:
            ret_verts.append(vert.add_vec(pos))
        return ret_verts

    cpdef public list[Vec3] get_rotation(self, list[Vec3] vertexes):
        cdef Vec3 rot = self.rotation
        cdef list[Vec3] ret_verts = []
        cdef Vec3 vert
        for vert in vertexes:
            ret_verts.append(vert.rotate(rot))
        return ret_verts
