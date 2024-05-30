from vertex cimport Vec3

cdef class OBJParser:
    def __init__(self, str file_path) -> None:
        self.file_path = file_path
    
    cpdef public tuple[list[Vec3], list[list[int]]] parse(self):
        cdef list[Vec3] verticies = []
        cdef list[list[int]] polygons = []
        cdef list[str] src = []
        cdef list[str] tokens = []
        cdef str _,x,y,z,line,prefix = ""
        cdef list[int] face, poly_buffer
        cdef int i, face_len, last_ind

        with open(self.file_path, "r") as file:
            src = file.readlines()
            for line in src:
                tokens = line.strip().split()
                
                if len(tokens) == 0:
                    continue
                prefix = tokens[0]

                if prefix == 'v':
                    _, x, y, z = tokens
                    verticies.append(
                        Vec3(
                            <float>float(x),
                            <float>float(y),
                            <float>float(z)
                        )
                    )
                elif prefix == 'f':
                    face = OBJParser.parse_face(tokens[1:])
                    face_len = len(face)
                    last_ind = face_len-1
                    poly_buffer = []
                    for i in range(face_len):
                        if len(poly_buffer) == 2:
                            poly_buffer.append(face[last_ind])
                            polygons.append(poly_buffer)
                            poly_buffer = []
                            poly_buffer.append(face[i-1])
                        poly_buffer.append(face[i])
                    poly_buffer.append(face[last_ind])
                    polygons.append(poly_buffer)

                elif prefix == 'vt':
                    pass
                elif prefix == 'g':
                    pass
                elif prefix == 'usemtl':
                    pass

        return (verticies, polygons)
    
    @staticmethod
    cdef list[int] parse_face(list[str] tokens):
        cdef list[int] polygon = []
        cdef str token
        cdef str vertex, text_coord, normal = ""
        if "//" in tokens[0]:
            # Face with vertex normals
            for token in tokens:
                vertex, normal = token.split("//")
                polygon.append(<int>int(vertex) - 1)
        elif "/" in tokens[0]:
            if tokens[0].count("/") == 1:
                # Face with texture coords
                for token in tokens:
                    vertex, text_coord = token.split("/")
                    polygon.append(<int>int(vertex) - 1)
            else:
                # Face with txt and norms
                for token in tokens:
                    vertex, text_coord, normal = token.split("/")
                    polygon.append(<int>int(vertex) - 1)
        else:
            # Face
            for token in tokens:
                polygon.append(<int>int(token) - 1)

        return polygon