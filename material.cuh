#pragma once

#include <cstdint>
#include "vector.cuh"


enum class MaterialType : uint8_t
{

    CONSTANT,
    NORMAL,
    LAMBERTIAN,

};



struct material_simple
{

    MaterialType type;
    float3_simple color;

};