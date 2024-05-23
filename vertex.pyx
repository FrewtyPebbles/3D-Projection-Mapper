from __future__ import annotations
from dataclasses import dataclass
from functools import lru_cache
import math as m
import struct
from typing import TYPE_CHECKING


if TYPE_CHECKING:
    from camera import Camera, Screen




cdef class Vec3:
    def __init__(self, x:float = 0.0, y:float = 0.0, z:float = 0.0):
        self.x = x
        self.y = y
        self.z = z

    def __repr__(self) -> str:
        return "Vec3< {}, {}, {} >".format(self.x, self.y, self.z)

    cpdef (float, float) project(self, Camera camera, Screen screen):
        cdef float x = self.x
        cdef float y = self.y
        cdef float z = self.z
        cdef int cam_w = camera.view_width
        cdef int cam_h = camera.view_height
        cdef int scr_w = screen.width
        cdef int scr_h = screen.height
        cdef int z_prime = camera.view_distance
        cdef float y_prime = y*z_prime / z
        cdef float x_prime = x*z_prime / z

        x = x_prime * cam_w / scr_w
        y = y_prime * cam_h / scr_h
        return -x + (cam_w/2), -y + (cam_h/2)
    
    def __hash__(self) -> int:
        return hash(f"{self.x},{self.y},{self.z}")
    
    def __deepcopy__(self):
        return self.clone()
    
    def __eq__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return self.x == other.x and self.y == other.y and self.z == other.z
        else:
            return False


    cpdef Vec3 clone(self):
        return Vec3(self.x, self.y, self.z)
    
    cpdef tuple[float, float, float] tuple(self):
        return (self.x, self.y, self.z)
    
    cpdef tuple[float, float] tuple2d(self):
        return (self.x, self.y)
    
    
    cpdef public float get_magnitude(self):
        cdef float x = self.x
        cdef float y = self.y
        cdef float z = self.z
        return m.sqrt(x**2 + y**2 + z**2)
    
    cpdef public Vec3 get_normalized(self):
        cdef float mag = self.get_magnitude()
        if mag == 0.0:
            return Vec3(self.x, self.y, self.z)
        return Vec3(self.x/mag, self.y/mag, self.z/mag)
    
    
    @staticmethod
    cdef public tuple[list[Vec3],list[Vec3],list[Vec3]] get_rotation_matrix(Vec3 rot):
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
    

    cpdef public Vec3 rotate(self, Vec3 rotation):
        cdef Vec3 new_vec = self.clone()
        cdef float x
        cdef float y
        cdef float z
        if rotation == Vec3(0,0,0):
            return new_vec
        for rot in Vec3.get_rotation_matrix(rotation):
            x = new_vec.x
            y = new_vec.y
            z = new_vec.z
            new_vec = Vec3(
                rot[0].x*x + rot[0].y*y + rot[0].z*z,
                rot[1].x*x + rot[1].y*y + rot[1].z*z,
                rot[2].x*x + rot[2].y*y + rot[2].z*z
            )
        return new_vec
            

    
    def __add__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return Vec3(self.x + other.x,
            self.y + other.y,
            self.z + other.z)
        else:
            return Vec3(self.x + other,
            self.y + other,
            self.z + other)

    def __sub__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return Vec3(self.x - other.x,
            self.y - other.y,
            self.z - other.z)
        else:
            return Vec3(self.x - other,
            self.y - other,
            self.z - other)

    def __mul__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return Vec3(self.x * other.x,
            self.y * other.y,
            self.z * other.z)
        else:
            return Vec3(self.x * other,
            self.y * other,
            self.z * other)

    def __div__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return Vec3(self.x / other.x,
            self.y / other.y,
            self.z / other.z)
        else:
            return Vec3(self.x / other,
            self.y / other,
            self.z / other)

    def __pow__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return Vec3(self.x ** other.x,
            self.y ** other.y,
            self.z ** other.z)
        else:
            return Vec3(self.x ** other,
            self.y ** other,
            self.z ** other)

    def __neg__(self):
        return Vec3(-self.x,
        -self.y,
        -self.z)