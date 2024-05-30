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
    cdef:
        list[(float,float)] projections = polygon.project(camera, screen)
        int min_x, min_y, max_x, max_y, x1, x2
        (float, float) t_min, t_max
        int shade
        int y,x
        vector[vector[float]]* dbuff = address(camera.depth_buffer)
        float z
        (float,float,float) rats
    #print(projections)
    t_min, t_max = polygon.get_projection_rect(projections, camera)
    min_x, min_y = <int>t_min[0], <int>t_min[1]
    max_x, max_y = <int>t_max[0], <int>t_max[1]
    #print(min_x, min_y)
    for y in range(min_y, max_y):
        x1, x2 = polygon.get_render_row_range(y, projections)
        
        for x in range(max(0, x1), min(x2, camera.view_width)):
            z = polygon.bary_get_z(x,y, projections)
            if 0 < dbuff[0][x][y] > z:
                shade = max(0, 255 - <int>(z/130*255))
                
                img_draw.point((x, y), (shade, shade, shade, 255))
                
                dbuff[0][x][y] = z
