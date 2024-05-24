from __future__ import annotations


from libc.math cimport sqrt, cosf, sinf, fmaf

from camera cimport Camera, Screen
cimport cython



cdef class Vec3:
    def __init__(self, float x = 0.0, float y = 0.0, float z = 0.0):
        self.x = x
        self.y = y
        self.z = z

    def __repr__(self) -> str:
        return "Vec3< {}, {}, {} >".format(self.x, self.y, self.z)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
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
    
    cpdef bint eq_vec(self, Vec3 other):
        return self.x == other.x * self.y == other.y * self.z == other.z

    def __eq__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return self.eq_vec(other)
        else:
            return False


    cpdef Vec3 clone(self):
        return Vec3(self.x, self.y, self.z)
    
    cpdef (float, float, float) tuple(self):
        return (self.x, self.y, self.z)
    
    cpdef (float, float) tuple2d(self):
        return (self.x, self.y)
    
    
    cpdef public float get_magnitude(self):
        cdef float x = self.x
        cdef float y = self.y
        cdef float z = self.z
        return sqrt(fmaf(x, x, fmaf(y, y, z*z)))
    
    cpdef public Vec3 get_normalized(self):
        cdef float mag = self.get_magnitude()
        if mag == 0.0:
            return Vec3(self.x, self.y, self.z)
        return Vec3(self.x/mag, self.y/mag, self.z/mag)
    
    
    @staticmethod
    cdef tuple[list[Vec3], list[Vec3], list[Vec3]] get_rotation_matrix(Vec3 rot):
        return (
            [ # X ROTATION
                Vec3(1.0, 0.0, 0.0),
                Vec3(0.0, cosf(rot.x), -sinf(rot.x)),
                Vec3(0.0, sinf(rot.x), cosf(rot.x))
            ],
            [ # Y ROTATION
                Vec3(cosf(rot.y), 0.0, sinf(rot.y)),
                Vec3(0.0, 1.0, 0.0),
                Vec3(-sinf(rot.y), 0.0, cosf(rot.y))
            ],
            [ # Z ROTATION
                Vec3(cosf(rot.z), -sinf(rot.z), 0.0),
                Vec3(sinf(rot.z), cosf(rot.z), 0.0),
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

        cdef list[Vec3] rot
        
        for rot in Vec3.get_rotation_matrix(rotation):
            x = new_vec.x
            y = new_vec.y
            z = new_vec.z
            new_vec = Vec3(
                fmaf(rot[0].x, x, fmaf(rot[0].y, y, rot[0].z*z)),
                fmaf(rot[1].x, x, fmaf(rot[1].y, y, rot[1].z*z)),
                fmaf(rot[2].x, x, fmaf(rot[2].y, y, rot[2].z*z))
            )
        return new_vec
            
    # ADD

    cpdef Vec3 add_vec(self, Vec3 other):
        return Vec3(self.x + other.x,
            self.y + other.y,
            self.z + other.z)

    cpdef Vec3 add_float(self, float other):
        return Vec3(self.x + other,
            self.y + other,
            self.z + other)

    cpdef Vec3 add_int(self, int other):
        return Vec3(self.x + other,
            self.y + other,
            self.z + other)
    
    def __add__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return self.add_vec(other)
        elif isinstance(other, float):
            return self.add_float(other)
        elif isinstance(other, int):
            return self.add_int(other)
        else:
            return Vec3(self.x + other,
            self.y + other,
            self.z + other)

    # SUBTRACT

    cpdef Vec3 sub_vec(self, Vec3 other):
        return Vec3(self.x - other.x,
            self.y - other.y,
            self.z - other.z)

    cpdef Vec3 sub_float(self, float other):
        return Vec3(self.x - other,
            self.y - other,
            self.z - other)

    cpdef Vec3 sub_int(self, int other):
        return Vec3(self.x - other,
            self.y - other,
            self.z - other)

    def __sub__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return self.sub_vec(other)
        elif isinstance(other, float):
            return self.sub_float(other)
        elif isinstance(other, int):
            return self.sub_int(other)
        else:
            return Vec3(self.x - other,
            self.y - other,
            self.z - other)

    # MULTIPLY

    cpdef Vec3 mul_vec(self, Vec3 other):
        return Vec3(self.x * other.x,
            self.y * other.y,
            self.z * other.z)

    cpdef Vec3 mul_float(self, float other):
        return Vec3(self.x * other,
            self.y * other,
            self.z * other)

    cpdef Vec3 mul_int(self, int other):
        return Vec3(self.x * other,
            self.y * other,
            self.z * other)

    def __mul__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return self.mul_vec(other)
        elif isinstance(other, float):
            return self.mul_float(other)
        elif isinstance(other, int):
            return self.mul_int(other)
        else:
            return Vec3(self.x * other,
            self.y * other,
            self.z * other)

    # DIVIDE
    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    cpdef Vec3 div_vec(self, Vec3 other):
        return Vec3(self.x / other.x,
            self.y / other.y,
            self.z / other.z)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    cpdef Vec3 div_float(self, float other):
        return Vec3(self.x / other,
            self.y / other,
            self.z / other)
    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    cpdef Vec3 div_int(self, int other):
        return Vec3(self.x / other,
            self.y / other,
            self.z / other)

    def __truediv__(self, other:Vec3 | any):
        if isinstance(other, Vec3):
            return self.div_vec(other)
        elif isinstance(other, float):
            return self.div_float(other)
        elif isinstance(other, int):
            return self.div_int(other)
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

    cpdef Vec3 neg(self):
        return Vec3(-self.x,
        -self.y,
        -self.z)

    def __neg__(self):
        return self.neg()