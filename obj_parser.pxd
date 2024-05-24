from vertex cimport Vec3

cdef class OBJParser:
    cdef public str file_path

    cpdef public tuple[list[Vec3], list[list[int]]] parse(self)

    @staticmethod
    cdef list[int] parse_face(list[str] tokens)