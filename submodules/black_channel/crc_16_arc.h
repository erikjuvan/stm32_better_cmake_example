////////////////////////////////////////////////////////////////////////////////
// COPYRIGHT (c) 2021
// EMSISO
// All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/**
* @file     crc_16_arc.h
* @brief    CRC-16/ARC implementation.
* @author   Matej Otic
* @date     03.06.2021
* @version  V1.0.0
*/
////////////////////////////////////////////////////////////////////////////////
/**
* @addtogroup CRC_16_ARC_API
* @{ <!-- BEGIN GROUP -->
*
* Following module is part of API which is available to the user of CRC Module.
*/
////////////////////////////////////////////////////////////////////////////////

#ifndef __CRC_16_ARC_H
#define __CRC_16_ARC_H

////////////////////////////////////////////////////////////////////////////////
// Includes
////////////////////////////////////////////////////////////////////////////////
#include <stdint.h>

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////
uint16_t crc_16_arc_calculate(const uint8_t* pu8_data, uint16_t size);

#endif // __CRC_16_ARC_H
////////////////////////////////////////////////////////////////////////////////
/**
* @} <!-- END GROUP -->
*/
////////////////////////////////////////////////////////////////////////////////
