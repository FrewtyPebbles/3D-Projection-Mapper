from mesh cimport Mesh, Polygon
from vertex cimport Vec3
from typing import Callable

cdef class Object:
    cdef public Mesh mesh
    cdef public Vec3 position
    cdef public Vec3 rotation
    cdef public Vec3 scale
    cdef public Vec3 rot_cache

    cpdef public void render(self,
        render_function:Callable[[Polygon],None] | None,
        wire_render_func:Callable[[Vec3, Vec3],None] | None
    )

    cpdef public list[Vec3] get_translation(self, list[Vec3] vertexes)

    cpdef public list[Vec3] get_rotation(self, list[Vec3] vertexes)