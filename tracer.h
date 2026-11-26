#pragma once

#ifdef __cplusplus
extern "C"
{
#endif


    unsigned long long renderPixels(unsigned char *image, int width, int height, double cam_center_x,
                                       double cam_center_y, double cam_center_z, double pixel00_x, double pixel00_y,
                                       double pixel00_z, double delta_u_x, double delta_u_y, double delta_u_z,
                                       double delta_v_x, double delta_v_y, double delta_v_z, int samples_per_pixel,
                                       int max_depth);


#ifdef __cplusplus
}
#endif