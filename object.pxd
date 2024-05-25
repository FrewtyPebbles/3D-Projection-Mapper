# distutils: language=c++
from mesh cimport Mesh, Polygon
from vertex cimport Vec3
from typing import Callable

cdef class Object:
    cdef public Mesh mesh
    cdef public Vec3 position
    cdef public Vec3 rotation
    cdef public Vec3 scale

    cpdef void _render(self, object render_function, object wire_render_func)

    cpdef public list[Vec3] get_translation(self, list[Vec3] vertexes)

    cpdef public list[Vec3] get_rotation(self, list[Vec3] vertexes)