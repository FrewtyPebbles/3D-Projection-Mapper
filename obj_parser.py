from vertex import Vec3

class OBJParser:
    def __init__(self, file_path:str) -> None:
        self.file_path = file_path

    def parse(self):
        verticies:list[Vec3] = []
        polygons:list[list[int]] = []
        with open(self.file_path, "r") as file:
            src = file.readlines()
            for line in src:
                tokens = line.strip().split()
                
                if len(tokens) == 0:
                    continue

                match tokens[0]:
                    case 'v':
                        _, x, y, z = tokens
                        verticies.append(
                            Vec3(
                                float(x),
                                float(y),
                                float(z)
                            )
                        )
                    case 'f':
                        polygons.append(
                            self.parse_face(tokens[1:])
                        )
                    case 'vt':
                        pass
                    case 'g':
                        pass
                    case 'usemtl':
                        pass

        return (verticies, polygons)
    
    def parse_face(self, tokens:list[str]):
        polygon:list[int] = []
        if "//" in tokens[0]:
            # Face with vertex normals
            for token in tokens:
                vertex, normal = token.split("//")
                polygon.append(int(vertex) - 1)
        elif "/" in tokens[0]:
            if tokens[0].count("/") == 1:
                # Face with texture coords
                for token in tokens:
                    vertex, text_coord = token.split("/")
                    polygon.append(int(vertex) - 1)
            else:
                # Face with txt and norms
                for token in tokens:
                    vertex, text_coord, normal = token.split("/")
                    polygon.append(int(vertex) - 1)
        else:
            # Face
            for token in tokens:
                polygon.append(int(token) - 1)

        return polygon