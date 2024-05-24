# distutils: language=c++
from camera cimport Screen, Camera
from mesh cimport Mesh, Polygon
from object cimport Object
from vertex cimport Vec3

cpdef void cyth_render(Screen screen, Camera camera, Polygon polygon, object img_draw)