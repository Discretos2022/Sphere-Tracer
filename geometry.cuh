
#pragma once

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include "enum.cuh"
#include "vector.cuh"
#include "material.cuh"


//==============================================================================
// RAY TRACING DATA STRUCTURES AND FUNCTIONS
//==============================================================================

/**
 * Simple ray structure for ray tracing calculations
 */
struct ray_simple
{
   float3_simple orig, dir; ///< Ray origin and direction

   __device__ __host__ ray_simple() {}
   __device__ __host__ ray_simple(const float3_simple &origin, const float3_simple &direction)
       : orig(origin), dir(direction)
   {
   }

   /** Get point along ray at parameter t */
   __device__ __host__ float3_simple at(float t) const { return orig + t * dir; }
};

/** Convert a normal to a debug RGB color */
__device__ __host__ inline float3_simple normal_to_color(const float3_simple &n)
{
   return float3_simple(0.5f * (n.x + 1.0f), 0.5f * (n.y + 1.0f), 0.5f * (n.z + 1.0f));
}




//==============================================================================
// SDF FUNCTIONS
//==============================================================================


/** Return the SDF value with a sphere */
__device__ __host__ inline float sdf_sphere(float3_simple p, float3_simple center, float radius)
{ 
   float3_simple v = center - p;
   return v.length() - radius;
}

/** Return the SDF value with a box */
__device__ __host__ inline float sdf_box(float3_simple p, float3_simple center, float3_simple size)
{ 
   float3_simple offset = abs(p - center) - size;

   float unsigned_dst = max(offset, {0, 0, 0}).length();

   float3_simple m = min(offset, {0, 0, 0});

   float max_1 = max(m.x, m.y);
   float dst_inside_box = max(m.z, max_1);

   return unsigned_dst + dst_inside_box;
}

/** Return the max value */
__device__ __host__ inline float smooth_max(float a, float b, float k)
{
   return log(exp(k * a) + exp(k * b)) / k;
}

/** Return the min value */
__device__ __host__ inline float smooth_min(float a, float b, float k)
{
   return -smooth_max(-a, -b, k);
}




//==============================================================================
// GEOMETRY STRUCTURES AND FUNCTIONS
//==============================================================================


/**
 * Simple object structure for sphere tracing calculations
 */
struct object_simple
{
   GeometryType type;
   float3_simple center;
   
   // Sphere
   float radius;
   
   // Box
   float3_simple size;

   material_simple material;
   
   __device__ __host__ float signed_distance(float3_simple p) const
   { 
      switch (type)
      {
         case GeometryType::SPHERE:
            return sdf_sphere(p, center, radius);

         case GeometryType::BOX:
            return sdf_box(p, center, size);

      }

      return 0;
   }
   
};

__device__ __host__ inline object_simple create_sphere(float3_simple center, float radius, material_simple material)
{
   return object_simple{ GeometryType::SPHERE, center, radius, {}, material };
}

__device__ __host__ inline object_simple create_box(float3_simple center, float3_simple size, material_simple material)
{
   return object_simple{ GeometryType::BOX, center, 0, size, material };
}



//==============================================================================
// WORLD STRUCTURE AND FUNCTIONS
//==============================================================================

/** Return the SDF value with a box */
__device__ __host__ inline float sdf_world(float3_simple p, object_simple* objects, int length)
{ 
   
   float dist = 1000; // Une grande valeur
   for (int i = 0; i < length; i++)
   {

      float d = objects[i].signed_distance(p);
      if (d < dist)
      {
         dist = d;
      }

   }

   return dist;
}


/** Return normal of surface at this point */
__device__ __host__ inline float3_simple calculate_normal(float3_simple p, object_simple* objects, int length)
{
   const float EPS = 0.001;

   float3_simple v1 = {
      sdf_world(p + float3_simple{ EPS, 0.0, 0.0 }, objects, length),
      sdf_world(p + float3_simple{ 0.0, EPS, 0.0 }, objects, length),
      sdf_world(p + float3_simple{ 0.0, 0.0, EPS }, objects, length)
   };

   float3_simple v2 = {
      sdf_world(p - float3_simple{ EPS, 0.0, 0.0 }, objects, length),
      sdf_world(p - float3_simple{ 0.0, EPS, 0.0 }, objects, length),
      sdf_world(p - float3_simple{ 0.0, 0.0, EPS }, objects, length)
   };

   return unit_vector(v1 - v2);
}


// struct world_simple
// {
//     float3_simple center;
//     float radius;

//     __device__ __host__ float signed_distance(float3_simple p) const
//     { 
//         float3_simple v = center - p;
//         return v.length() - radius;
//     }


// };