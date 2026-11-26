

#include "utils.h"
#include "vec3.h"
#include "tracer.h"


class Camera
{

    public:

        int width;
        int height;
        int channels;

        double vfov = 35.0;
        // Vec3 lookfrom = Vec3(-1, 2, 5);
        // Vec3 lookat = Vec3(-2, -0.5, -1);
        Vec3 lookfrom = Vec3(10, 5, 10);
        Vec3 lookat = Vec3(0, 0, 0);
        Vec3 vup = Vec3(0, 1, 0);

        Camera(Vec3 center, int width, int height, int channels)
            : camera_center(center), width(width), height(height), channels(channels)
        {
            initialize();
        }


        void render(std::vector<unsigned char> &image)
        {

            // TODO : Sphere Tracer !

            renderPixels(image.data(), width, height, camera_center.x(), camera_center.y(), camera_center.z(),
          pixel00_loc.x(), pixel00_loc.y(), pixel00_loc.z(), pixel_delta_u.x(), pixel_delta_u.y(), pixel_delta_u.z(),
          pixel_delta_v.x(), pixel_delta_v.y(), pixel_delta_v.z(), 1, 5);

        }



    private:

        Vec3 camera_center;
        Vec3 pixel00_loc;
        Vec3 pixel_delta_u;
        Vec3 pixel_delta_v;
        Vec3 u, v, w;


        void initialize()
        {
            camera_center = lookfrom;

            // Determine viewport dimensions
            auto focal_length = (lookfrom - lookat).length();
            auto theta = utils::degrees_to_radians(vfov);
            auto h = tan(theta / 2);

            auto viewport_height = 2 * h * focal_length;
            auto viewport_width = viewport_height * (double(width) / height);

            // Compute camera basis vectors
            w = unit_vector(lookfrom - lookat);
            u = unit_vector(cross(vup, w));
            v = cross(w, u);

            // Calculate the vectors across the horizontal and down the vertical viewport edges
            auto viewport_u = viewport_width * u;
            auto viewport_v = viewport_height * -v;

            // Calculate the horizontal and vertical delta vectors from pixel to pixel
            pixel_delta_u = viewport_u / width;
            pixel_delta_v = viewport_v / height;

            // Calculate the location of the upper left pixel
            auto viewport_upper_left = camera_center - (focal_length * w) - viewport_u / 2 - viewport_v / 2;
            pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);
        }




};