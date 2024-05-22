from vertex import Vec3


class Screen:
    def __init__(self, width:int, height:int) -> None:
        self.width = width
        self.height = height
    
class Camera:
    def __init__(self, position:Vec3, view_width:int, view_height:int, view_distance:int) -> None:
        self.position = position
        self.view_width = view_width
        self.view_height = view_height
        self.view_distance = view_distance