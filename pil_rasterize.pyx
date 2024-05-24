# distutils: language=c++
from camera cimport Screen, Camera
from mesh cimport Polygon
cimport cython
from libcpp.vector cimport vector

from cython.parallel cimport prange
from cython cimport address, sizeof as csizeof
from cython.view cimport array as carray


@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cpdef void cyth_render(Screen screen, Camera camera, Polygon polygon, object img_draw):
    cdef int min_x, min_y, max_x, max_y
    cdef (float, float) t_min, t_max
    t_min, t_max = polygon.get_projection_rect(camera, screen)
    min_x, min_y = <int>t_min[0], <int>t_min[1]
    max_x, max_y = <int>t_max[0], <int>t_max[1]
    cdef int shade = (<int>sum([vec3.get_normalized().z * 255 for vec3 in polygon.connections]))/len(polygon.connections)

    cdef float avg_d = sum([vec3.z for vec3 in polygon.connections])/len(polygon.connections)
    cdef int y,x
    cdef vector[vector[float]]* dbuff = address(camera.depth_buffer)
    
    for y in range(min_y, max_y):
        for x in range(min_x, max_x):
            if dbuff[0][x][y] > avg_d:
                if polygon.in_projection(x, y, camera, screen):
                    img_draw.point((x, y), (shade, shade, shade, 255))
                    
                    dbuff[0][x][y] = avg_d
