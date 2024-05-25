from __future__ import annotations
from functools import lru_cache
import itertools

from camera cimport Camera, Screen
from vertex cimport Vec3
from cython.parallel import prange
from cython cimport address
from obj_parser cimport OBJParser
from libc.math cimport fmaf, INFINITY, floor, ceil

cdef extern from "macros.h":
    cdef float c_min2(...)
    cdef float c_max2(...)

cimport cython

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cpdef (float,float) lerp2d(float x, float x0,float y0,float x1,float y1):
    cdef float y = y0 + (x - x0)*((y1-y0)/(x1-x0))
    return x,y


cdef class Polygon:
    def __init__(self, list[Vec3] connections) -> None:
        self.connections = connections

    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    cpdef float bary_get_z(self, x, y):
        cdef:
            Vec3 a = self.connections[0]
            Vec3 b = self.connections[0]
            #c = self.connections[0]
            
            float apx = a.x/a.z
            float bpx = b.x/b.z
            float bpxdiffapx = (bpx-apx)
            float b_coord = (x - apx)/ (bpxdiffapx if bpxdiffapx != 0 else 0.001)

            float z = fmaf(a.z, (1-b_coord), b.z*b_coord)
        return z

    cpdef (int, int) get_render_row_range(self, int y, list[(float, float)] projections):
        cdef:
            (float,float) p1 = projections[0]
            (float,float) p2 = projections[1]
            (float,float) p3 = projections[2]
            float denom1 = (p2[0]-p1[0])
            float denom2 = (p3[0]-p2[0])
            float denom3 = (p1[0]-p3[0])
            float a1 = (p2[1]-p1[1])/denom1 if denom1 != 0 else 1
            float a2 = (p3[1]-p2[1])/denom2 if denom2 != 0 else 1
            float a3 = (p1[1]-p3[1])/denom3 if denom3 != 0 else 1

            float b1 = p1[1]-a1*p1[0]
            float b2 = p2[1]-a2*p2[0]
            float b3 = p3[1]-a3*p3[0]
            float y1,y2,a,b
            list[int] xs = []
        y+= 1
        for y1, y2, a, b in [(p1[1], p2[1], a1, b1), (p2[1], p3[1], a2, b2), (p3[1], p1[1], a3, b3)]:
            y1, y2 = sorted((y1,y2))
            #print(floor(y1) , y , floor(y2))
            if floor(y1) < y <= floor(y2):
                if a != 0:
                    xs.append(<int>((y-b)/a))
                else:
                    xs.append(1)
        
        return (xs[0], xs[1]) if xs[0] < xs[1] else (xs[1], xs[0])


            


    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef render_lines(self, object render_func):
        """
        render_func:Callable[[Vec3, Vec3],None]
        """

        # draw line from polygon to polygon
        cdef Vec3 v1, v2
        for v1, v2 in itertools.pairwise(self.connections):
            
            render_func(v1, v2)

        render_func(v2, self.connections[0])

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef public list[(float, float)] project(self, Camera camera, Screen screen):
        cdef list[(float, float)] ret_projs = []
        cdef Vec3 con
        for con in self.connections:
            ret_projs.append(con.project(camera, screen))
        return ret_projs

    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    cpdef (float,float,float) get_subtriangle_ratios(self, float x, float y, list[(float, float)] projections):
        cdef float ax, ay, bx, by, cx, cy = 0.0
        ax, ay = projections[0]
        bx, by = projections[1]
        cx, cy = projections[2]
        cdef:
            
            (float, float) ab = (bx-ax, by-ay)
            (float, float) bc = (cx-bx, cy-by)
            (float, float) ca = (ax-cx, ay-cy)
            # p is x,y
            (float, float) p = (x-ax, y-ay)
            # scalar cross prod ab, bc, ca with p
            float dot_1 = ab[0]*p[1] - ab[1]*p[0]
            float dot_2 = bc[0]*p[1] - bc[1]*p[0]
            float dot_3 = ca[0]*p[1] - ca[1]*p[0]

            float total = dot_1 + dot_2 + dot_3

            float rat_1 = dot_1/2
            float rat_2 = dot_2/2
            float rat_3 = dot_3/2
            

        return (rat_1,rat_2,rat_3)
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef ((float,float),(float,float)) get_projection_rect(self, list[(float, float)] projections, Camera camera):
        cdef:
            list[(float,float)] coords = projections
            float x = coords[0][0]
            float y = coords[0][1]
            float min_x = x
            float max_x = x
            float min_y = y
            float max_y = y
            # addresses
            float* _min_x = address(min_x)
            float* _max_x = address(max_x)
            float* _min_y = address(min_y)
            float* _max_y = address(max_y)

        cdef int i
        cdef int c_len = len(coords)
        with nogil:
            for i in prange(0, c_len):
                with gil:
                    x,y = <(float, float)>coords[i]
                
                if (_max_y[0] < y):
                    _max_y[0] = y
                if (_min_y[0] > y):
                    _min_y[0] = y
                
                if (_max_x[0] < x):
                    _max_x[0] = x
                if (_min_x[0] > x):
                    _min_x[0] = x

        return (c_max2(0.0, min_x), c_max2(0.0, min_y)),(c_min2(max_x, <float>camera.view_width), c_min2(max_y, <float>camera.view_height))
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    cpdef public bint in_projection(self, int x, int y, Camera camera, Screen screen):
        cdef:
            list[(float, float)] cons = self.project(camera, screen)
            int cons_len = len(cons)
            Py_ssize_t j
            Py_ssize_t i
            bint result = False
            bint * _result = address(result)
            int _x = <int>x
            int _y = <int>y
            float c_i_x, c_i_y, c_j_x, c_j_y
        with nogil:
            for i in prange(0, cons_len):
                if i == 0:
                    j = cons_len-1
                else:
                    j = i-1
                with gil:
                    c_i_x, c_i_y = cons[i]
                    c_j_x, c_j_y = cons[j]
                if (c_i_y < _y and c_j_y >= _y or c_j_y < _y and c_i_y >= _y) \
                and (c_i_x + (_y - c_i_y) / (c_j_y - c_i_y) * (c_j_x - c_i_x) < _x):
                    _result[0] = not _result[0]
        return result



cdef class Mesh:

    def __init__(self, list[Vec3] vertexes, list[list[int]] polygons):
        self.vertexes = vertexes
        self.polygons = polygons
    
    @cython.boundscheck(False)
    @cython.wraparound(False)
    cpdef public list[Polygon] get_polygons(self, list[Vec3] vertexes):
        """Connects vertexes together based on vertex index pairs in `connection_indexes` """
        cdef list[Polygon] polygons = []

        cdef list[int] v_inds
        cdef int i
        cdef list[Vec3] poly_buffer
        for v_inds in self.polygons:
            poly_buffer = []
            for i in v_inds:
                if len(poly_buffer) == 2:
                    poly_buffer.append(vertexes[i])
                    polygons.append(Polygon(poly_buffer))
                    poly_buffer = []
                    poly_buffer.append(vertexes[i])
                else:
                    poly_buffer.append(vertexes[i])
            if len(poly_buffer) == 2:
                poly_buffer.append(vertexes[0])
                polygons.append(Polygon(poly_buffer))
        
        return polygons
    
    @staticmethod
    @lru_cache(1024)
    def from_file(str file_path):
        return Mesh(*OBJParser(file_path).parse())