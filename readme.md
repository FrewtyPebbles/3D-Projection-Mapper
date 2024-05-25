# 3D Projections in Python

A library for mapping 3D projections to a 2D plane via a virtual camera.

Here are some rendering tests using this library and PIL as a render medium:
![](https://github.com/FrewtyPebbles/Python-3D-Projection/blob/main/tests/plain_teapot_success.gif)

![](https://github.com/FrewtyPebbles/Python-3D-Projection/blob/main/tests/barycentric_depth_buffer_success.gif)

![](https://github.com/FrewtyPebbles/Python-3D-Projection/blob/main/tests/rotating_space_teapot.gif)

![](https://github.com/FrewtyPebbles/Python-3D-Projection/blob/main/tests/surface_teapot_outline.gif)

![](https://github.com/FrewtyPebbles/Python-3D-Projection/blob/main/tests/rotate_fail1.png)

![](https://github.com/FrewtyPebbles/Python-3D-Projection/blob/main/tests/high_poly_wobble_bary.gif)

# TODO

 - Rework the library in C++ with a Cython interface so we can have genuine parrallelism.