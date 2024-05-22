from __future__ import annotations
from dataclasses import dataclass
import math as m
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from camera import Camera, Screen

@dataclass
class Vec3:
    x:float = 0.0
    y:float = 0.0
    z:float = 0.0

    def __repr__(self) -> str:
        return f"Vec3< {self.x}, {self.y}, {self.z} >"

    def project(self, camera:Camera, screen:Screen):
        screen = screen
        camera = camera
        z_prime = camera.view_distance
        y_prime = self.y*z_prime / self.z
        x_prime = self.x*z_prime / self.z

        x = x_prime * camera.view_width / screen.width
        y = y_prime * camera.view_height / screen.height

        return -x, -y
    
    def clone(self):
        return Vec3(self.x, self.y, self.z)
    
    def tuple(self):
        return (self.x, self.y, self.z)
    
    def tuple2d(self):
        return (self.x, self.y)
    
    def get_magnitude(self):
        return m.sqrt(self.x**2 + self.y**2 + self.z**2)
    
    def get_normalized(self):
        mag = self.get_magnitude()
        if mag == 0:
            return Vec3(self.x, self.y, self.z)
        return Vec3(self.x/mag, self.y/mag, self.z/mag)
    
    @staticmethod
    def get_rotation_matrix(rotation:Vec3):
        rot = rotation
        return (
            [ # X ROTATION
                Vec3(1.0, 0.0, 0.0),
                Vec3(0.0, m.cos(rot.x), -m.sin(rot.x)),
                Vec3(0.0, m.sin(rot.x), m.cos(rot.x))
            ],
            [ # Y ROTATION
                Vec3(m.cos(rot.y), 0.0, m.sin(rot.y)),
                Vec3(0.0, 1.0, 0.0),
                Vec3(-m.sin(rot.y), 0.0, m.cos(rot.y))
            ],
            [ # Z ROTATION
                Vec3(m.cos(rot.z), -m.sin(rot.z), 0.0),
                Vec3(m.sin(rot.z), m.cos(rot.z), 0.0),
                Vec3(0.0, 0.0, 1.0)
            ],
        )
    
    def rotate(self, rotation:Vec3):
        rotation = rotation
        new_vec = self.clone()
        for rot in new_vec.get_rotation_matrix(rotation):
            new_vec = Vec3(
                rot[0].x*new_vec.x + rot[0].y*new_vec.y + rot[0].z*new_vec.z,
                rot[1].x*new_vec.x + rot[1].y*new_vec.y + rot[1].z*new_vec.z,
                rot[2].x*new_vec.x + rot[2].y*new_vec.y + rot[2].z*new_vec.z
            )
        return new_vec
            

    
    def __add__(self, other):
        if isinstance(other, Vec3):
            return Vec3(self.x + other.x,
            self.y + other.y,
            self.z + other.z)
        else:
            return Vec3(self.x + other,
            self.y + other,
            self.z + other)

    def __sub__(self, other:Vec3):
        if isinstance(other, Vec3):
            return Vec3(self.x - other.x,
            self.y - other.y,
            self.z - other.z)
        else:
            return Vec3(self.x - other,
            self.y - other,
            self.z - other)

    def __mul__(self, other:Vec3):
        if isinstance(other, Vec3):
            return Vec3(self.x * other.x,
            self.y * other.y,
            self.z * other.z)
        else:
            return Vec3(self.x * other,
            self.y * other,
            self.z * other)

    def __div__(self, other):
        if isinstance(other, Vec3):
            return Vec3(self.x / other.x,
            self.y / other.y,
            self.z / other.z)
        else:
            return Vec3(self.x / other,
            self.y / other,
            self.z / other)

    def __pow__(self, other):
        if isinstance(other, Vec3):
            return Vec3(self.x ** other.x,
            self.y ** other.y,
            self.z ** other.z)
        else:
            return Vec3(self.x ** other,
            self.y ** other,
            self.z ** other)

    def __neg__(self,):
        return Vec3(-self.x,
        -self.y,
        -self.z)