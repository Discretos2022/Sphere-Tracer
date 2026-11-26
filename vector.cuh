#pragma once

#include <cmath>
#include <cstdlib>


//==============================================================================
// VECTOR 3D STRUCTURE AND FUNCTIONS
//==============================================================================

/**
 * Simple 3D vector structure optimized for CUDA
 * Provides basic vector operations for ray tracing computations
 */

struct float3_simple
{
   float x, y, z;
   __device__ __host__ float3_simple() : x(0), y(0), z(0) {}
   __device__ __host__ float3_simple(float x_, float y_, float z_) : x(x_), y(y_), z(z_) {}

   __device__ __host__ float3_simple operator+(const float3_simple &other) const
   {
      return float3_simple(x + other.x, y + other.y, z + other.z);
   }

   __device__ __host__ float3_simple operator-(const float3_simple &other) const
   {
      return float3_simple(x - other.x, y - other.y, z - other.z);
   }

   __device__ __host__ float3_simple operator*(float t) const { return float3_simple(x * t, y * t, z * t); }

   __device__ __host__ float3_simple operator/(float t) const { return float3_simple(x / t, y / t, z / t); }

   __device__ __host__ float3_simple operator-() const { return float3_simple(-x, -y, -z); }

   __device__ __host__ float length() const { return sqrtf(x * x + y * y + z * z); }

   __device__ __host__ float length_squared() const { return x * x + y * y + z * z; }
};

__device__ __host__ float3_simple operator*(float t, const float3_simple &v) { return v * t; }

/** Compute dot product of two vectors */
__device__ __host__ float dot(const float3_simple &a, const float3_simple &b)
{
   return a.x * b.x + a.y * b.y + a.z * b.z;
}

/** Compute cross product of two vectors */
__device__ __host__ float3_simple cross(const float3_simple &a, const float3_simple &b)
{
   return float3_simple(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

/** Normalize a vector to unit length */
__device__ __host__ float3_simple unit_vector(const float3_simple &v) { return v / v.length(); }


/** Return the maximum of two vectors */
__device__ __host__ float3_simple max(const float3_simple &a, const float3_simple &b) { return { max(a.x, b.x), max(a.y, b.y), max(a.z, b.z) }; }

/** Return the minimum of two vectors */
__device__ __host__ float3_simple min(const float3_simple &a, const float3_simple &b) { return { min(a.x, b.x), min(a.y, b.y), min(a.z, b.z) }; }

/** Return the absolute of a vector */
__device__ __host__ float3_simple abs(const float3_simple &v) { return { abs(v.x), abs(v.y), abs(v.z) }; }