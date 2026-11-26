

#include <cstdio>
#include "vector.cuh"
#include "geometry.cuh"
#include "material.cuh"




__device__ float3_simple ray_march(object_simple* objects, int length, ray_simple ray, float max_travel)
{

    float3_simple start = ray.orig;
    for (float t = 0; t < max_travel;)
    {
        
        int index = -1;
        float dist = max_travel;

        start = ray.orig + unit_vector(ray.dir) * t;

        // for (int i = 0; i < length; i++)
        // {

        //     float d = objects[i].signed_distance(start);
        //     if (d < dist || index == -1)
        //     {
        //         index = i;
        //         dist = d;
        //     }

        // }

        index = 1;
        dist = max(-objects[0].signed_distance(start), objects[1].signed_distance(start));

        if (dist < 0.001)
        {

            switch (objects[index].material.type) {

                case MaterialType::CONSTANT: {
                    return objects[index].material.color;
                }

                case MaterialType::NORMAL:{
                    float3_simple normal = calculate_normal(start, objects, length);
                    return 0.5f * (normal + float3_simple{1, 1, 1});
                }

                case MaterialType::LAMBERTIAN: {
                    return objects[index].material.color;
                }

            }

        }

        t += dist;

    }

    // The sky !
    float3_simple unit_direction = unit_vector(ray.dir);
    float t = 0.5f * (unit_direction.y + 1.0f);

    return (1.0f - t*1.7f) * float3_simple{ 1, 1, 1 } + t * float3_simple{ 0, 0, 1 };

}




__global__ void renderKernel(unsigned char *image, int width, int height, int samples_per_pixel, int max_depth,
                             float cam_center_x, float cam_center_y, float cam_center_z, float pixel00_x,
                             float pixel00_y, float pixel00_z, float delta_u_x, float delta_u_y, float delta_u_z,
                             float delta_v_x, float delta_v_y, float delta_v_z)
{

    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;


    // Strict bounds checking
    if (x >= width || y >= height)
        return;

    int pixel_idx = y * width + x;
    int base_idx = pixel_idx * 3;

    // Double check bounds for memory access
    if (pixel_idx >= width * height || base_idx + 2 >= width * height * 3)
    {
        return;
    }


    material_simple normal = material_simple{ MaterialType::NORMAL, {} };

    material_simple red = material_simple{ MaterialType::CONSTANT, {1,0,0} };
    material_simple green = material_simple{ MaterialType::CONSTANT, {0,1,0} };
    material_simple blue = material_simple{ MaterialType::CONSTANT, {0,0,1} };


    // Create world
    const int length = 2;
    object_simple objects[length] =
    {
        //create_sphere({-3, -3, -10}, 1, red),
        //create_sphere({-3, -3, -5}, 1, normal),
        create_box({-10, -3, -5}, {4, 4, 4}, normal),
        create_sphere({-10, -3, -5}, 5, normal),
    };




    // Convert parameters to float3_simple
    float3_simple camera_center(cam_center_x, cam_center_y, cam_center_z);
    float3_simple pixel00_loc(pixel00_x, pixel00_y, pixel00_z);
    float3_simple pixel_delta_u(delta_u_x, delta_u_y, delta_u_z);
    float3_simple pixel_delta_v(delta_v_x, delta_v_y, delta_v_z);
    

    float3_simple pixel_color(0, 0, 0);

    float MAX_TRAVEL = 100;


    float3_simple mean_color(0, 0, 0);
    for (int s = 0; s < samples_per_pixel; s++)
    {
        
        float offset_x = 0;
        float offset_y = 0;

        float3_simple pixel_center = pixel00_loc + (x + offset_x) * pixel_delta_u + (y + offset_y) * pixel_delta_v;
        float3_simple ray_direction = pixel_center - camera_center;
        ray_simple ray(camera_center, unit_vector(ray_direction));

        // float3_simple start = camera_center;
        // for (int t = 0; t < MAX_TRAVEL;)
        // {
            
        //     int index = -1;
        //     int dist = MAX_TRAVEL;

        //     start = camera_center + unit_vector(ray_direction) * t;

        //     for (int i = 0; i < length; i++)
        //     {

        //         float d = objects[i].signed_distance(start);
        //         if (d < dist || index == -1)
        //         {
        //             index = i;
        //             dist = d;
        //         }

        //     }

        //     if (dist < 1)
        //     {

        //         mean_color = mean_color + objects[index].material.color;

        //         // if (index == 0)
        //         //     mean_color = mean_color + float3_simple(0, .5, .5);
        //         // else
        //         //     mean_color = mean_color + float3_simple(0, 1, 0);
        //         break;
        //     }

        //     t += dist;

        // }

        mean_color = mean_color + ray_march(objects, length, ray, MAX_TRAVEL);

    }

    pixel_color = mean_color / samples_per_pixel;

    // pixel_color = pixel_color + float3_simple(0.5, 0.5, 0.5);

    // Gamma correction (gamma=2)
    pixel_color.x = sqrtf(fmaxf(pixel_color.x, 0.0f));
    pixel_color.y = sqrtf(fmaxf(pixel_color.y, 0.0f));
    pixel_color.z = sqrtf(fmaxf(pixel_color.z, 0.0f));

    // Convert to bytes with clamping
    unsigned char r = (unsigned char)(255.0f * fminf(fmaxf(pixel_color.x, 0.0f), 1.0f));
    unsigned char g = (unsigned char)(255.0f * fminf(fmaxf(pixel_color.y, 0.0f), 1.0f));
    unsigned char b = (unsigned char)(255.0f * fminf(fmaxf(pixel_color.z, 0.0f), 1.0f));

    // Store in image buffer - each kernel writes to its own unique location
    image[base_idx] = r;
    image[base_idx + 1] = g;
    image[base_idx + 2] = b;
    
    // image[base_idx] = char((x * y) * 255 / 800);
    // image[base_idx + 1] = char((x * y) * 255 / 800);
    // image[base_idx + 2] = char((x * y) * 255 / 800);

}





extern "C" unsigned long long renderPixels(unsigned char *image, int width, int height, double cam_center_x,
                                       double cam_center_y, double cam_center_z, double pixel00_x, double pixel00_y,
                                       double pixel00_z, double delta_u_x, double delta_u_y, double delta_u_z,
                                       double delta_v_x, double delta_v_y, double delta_v_z, int samples_per_pixel,
                                       int max_depth)
{

    
    unsigned char *d_image;
    size_t image_size = width * height * 3 * sizeof(unsigned char);
    int num_pixels = width * height;

    cudaError_t malloc_err = cudaMalloc(&d_image, image_size);

    if (malloc_err != cudaSuccess)
    {
        printf("CUDA malloc error: %s\n", cudaGetErrorString(malloc_err));
        return 0;
    }

    // Set up grid and block dimensions for the tile
    dim3 block_size(32, 4);
    dim3 grid_size((width + block_size.x - 1) / block_size.x, (height + block_size.y - 1) / block_size.y);
    printf("Tile grid size: (%d, %d), Block size: (%d, %d)\n", grid_size.x, grid_size.y, block_size.x, block_size.y);


    renderKernel<<<grid_size, block_size>>>(d_image, width, height, samples_per_pixel, max_depth, (float)cam_center_x,
                                           (float)cam_center_y, (float)cam_center_z, (float)pixel00_x, (float)pixel00_y,
                                           (float)pixel00_z, (float)delta_u_x, (float)delta_u_y, (float)delta_u_z,
                                           (float)delta_v_x, (float)delta_v_y, (float)delta_v_z);


    // Check for kernel errors
    cudaError_t kernel_err = cudaGetLastError();
    if (kernel_err != cudaSuccess)
    {
        printf("CUDA kernel error: %s\n", cudaGetErrorString(kernel_err));
        cudaFree(d_image);
        return 0;
    }

    cudaDeviceSynchronize();

    // Copy result back to host
    cudaError_t copy_err = cudaMemcpy(image, d_image, image_size, cudaMemcpyDeviceToHost);
    if (copy_err != cudaSuccess)
    {
        printf("Memory copy error: %s\n", cudaGetErrorString(copy_err));
        cudaFree(d_image);
        return 0;
    }

    // Clean up
    cudaFree(d_image);

    
    return 0;

}