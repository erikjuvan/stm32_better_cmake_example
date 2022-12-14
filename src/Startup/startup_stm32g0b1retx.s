/**
  ******************************************************************************
  * @file      startup_stm32g070xx.s
  * @author    MCD Application Team
  * @brief     STM32G070xx devices vector table GCC toolchain.
  *            This module performs:
  *                - Set the initial SP
  *                - Set the initial PC == Safe_Reset_Handler,
  *                - Set the vector table entries with the exceptions ISR address
  *                - Branches to main in the C library (which eventually
  *                  calls main()).
  *            After Reset the Cortex-M0+ processor is in Thread mode,
  *            priority is Privileged, and the Stack is set to Main.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2018 STMicroelectronics. All rights reserved.
  *
  * This software component is licensed by ST under Apache License, Version 2.0,
  * the "License"; You may not use this file except in compliance with the
  * License. You may obtain a copy of the License at:
  *                        opensource.org/licenses/Apache-2.0
  *
  ******************************************************************************
  */

.syntax unified
.cpu cortex-m0plus
.fpu softvfp
.thumb

.global g_pfnVectors
.global Default_Handler
.global Startup_Copy_Handler
.global Safe_Reset_Handler
.global Jump_To_Main

/* start address for the initialization values of the .data section.
defined in linker script */
.word _sidata
/* start address for the .data section. defined in linker script */
.word _sdata
/* end address for the .data section. defined in linker script */
.word _edata
/* start address for the .bss section. defined in linker script */
.word _sbss
/* end address for the .bss section. defined in linker script */
.word _ebss


///////////////////////////////////////////////////////////////////////////////
/**
 * @brief  Copy the data segment initializers from flash to SRAM,
 *         it is called at startup and after SRAM initial self test.
 * @param  None
 * @retval : None
*/

  .section  .text.Startup_Copy_Handler
  .type  Startup_Copy_Handler, %function
Startup_Copy_Handler:
/* Copy the data segment initializers from flash to SRAM */
  movs r1, #0
  b LoopCopyDataInit

CopyDataInit:
  ldr r3, =_sidata
  ldr r3, [r3, r1]
  str r3, [r0, r1]
  adds r1, r1, #4

LoopCopyDataInit:
  ldr r0, =_sdata
  ldr r3, =_edata
  adds r2, r0, r1
  cmp r2, r3
  bcc CopyDataInit
  ldr r2, =_sbss
  b LoopFillZerobss

/* Zero fill the bss segment. */
FillZerobss:
  movs r3, #0
  str  r3, [r2]
  adds r2, r2, #4

LoopFillZerobss:
  ldr r3, = _ebss
  cmp r2, r3
  bcc FillZerobss
  bx  lr

.size  Startup_Copy_Handler, .-Startup_Copy_Handler


///////////////////////////////////////////////////////////////////////////////
/**
 * @brief  Zero fill the whole RAM (both SAFE and USER)
 * @param  None
 * @retval None
*/

  .section  .text.Zero_Fill_Ram
  .type  Zero_Fill_Ram, %function
Zero_Fill_Ram:

  ldr r2, =_ram_start
  ldr r4, =_ram_end
  movs r3, #0
  b LoopFillZeroRam

FillZeroRam:
  str  r3, [r2]
  adds r2, r2, #4

LoopFillZeroRam:
  cmp r2, r4
  bcc FillZeroRam
  bx lr

.size  Zero_Fill_Ram, .-Zero_Fill_Ram



///////////////////////////////////////////////////////////////////////////////
/**
 * @brief  This is the code that gets called when the processor first
 *          starts execution following a reset event. Only the absolutely
 *          necessary set is performed, after which the application
 *          supplied main() routine is called.
 * @param  None
 * @retval None
*/

  .section .text.Safe_Reset_Handler
  .type Safe_Reset_Handler, %function
Safe_Reset_Handler:

  // set stack pointer
  ldr r0, =_estack
  mov sp, r0

  // Copy the data segment initializers from flash to SRAM
  bl Startup_Copy_Handler

  // Call the clock system intitialization function
  bl SystemInit

  // Call static constructors
  bl __libc_init_array

  // STL startup enabled
  // Run STL start-up procedures and checks
  // If it ends ok then continues in Jump_To_Main
  bl STL_StartUp

  b . // should never reach this point

.size Safe_Reset_Handler, .-Safe_Reset_Handler



  .section .text.Jump_To_Main
  .type Jump_To_Main, %function
Jump_To_Main:

  bl Safe_Main

  b . // should never reach this point

.size Jump_To_Main, .-Jump_To_Main



///////////////////////////////////////////////////////////////////////////////


/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt.  This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 *
 * @param  None
 * @retval None
*/
  .section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b Infinite_Loop
  .size Default_Handler, .-Default_Handler


/******************************************************************************
*
* The minimal vector table for a Cortex M0.  Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
*
******************************************************************************/
  .section .isr_vector,"a",%progbits
  .type g_pfnVectors, %object
  .size g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
  .word _estack
  .word Safe_Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word SVC_Handler
  .word 0
  .word 0
  .word PendSV_Handler
  .word SysTick_Handler
  .word WWDG_IRQHandler                                 /* Window WatchDog                                   */
  .word PVD_VDDIO2_IRQHandler                           /* PVD through EXTI Line detect                      */
  .word RTC_TAMP_IRQHandler                             /* RTC through the EXTI line                         */
  .word FLASH_IRQHandler                                /* FLASH                                             */
  .word RCC_CRS_IRQHandler                              /* RCC & CRS                                         */
  .word EXTI0_1_IRQHandler                              /* EXTI Line 0 and 1                                 */
  .word EXTI2_3_IRQHandler                              /* EXTI Line 2 and 3                                 */
  .word EXTI4_15_IRQHandler                             /* EXTI Line 4 to 15                                 */
  .word USB_UCPD1_2_IRQHandler                          /* USB, UCPD1, UCPD2                                 */
  .word DMA1_Channel1_IRQHandler                        /* DMA1 Channel 1                                    */
  .word DMA1_Channel2_3_IRQHandler                      /* DMA1 Channel 2 and Channel 3                      */
  .word DMA1_Ch4_7_DMA2_Ch1_5_DMAMUX1_OVR_IRQHandler    /* DMA1 Ch4 to Ch7, DMA2 Ch1 to Ch5, DMAMUX1 overrun */
  .word ADC1_COMP_IRQHandler                            /* ADC1, COMP1 and COMP2                             */
  .word TIM1_BRK_UP_TRG_COM_IRQHandler                  /* TIM1 Break, Update, Trigger and Commutation       */
  .word TIM1_CC_IRQHandler                              /* TIM1 Capture Compare                              */
  .word TIM2_IRQHandler                                 /* TIM2                                              */
  .word TIM3_TIM4_IRQHandler                            /* TIM3, TIM4                                        */
  .word TIM6_DAC_LPTIM1_IRQHandler                      /* TIM6, DAC and LPTIM1                              */
  .word TIM7_LPTIM2_IRQHandler                          /* TIM7 and LPTIM2                                   */
  .word TIM14_IRQHandler                                /* TIM14                                             */
  .word TIM15_IRQHandler                                /* TIM15                                             */
  .word TIM16_FDCAN_IT0_IRQHandler                      /* TIM16 & FDCAN1_IT0 & FDCAN2_IT0                   */
  .word TIM17_FDCAN_IT1_IRQHandler                      /* TIM17 & FDCAN1_IT1 & FDCAN2_IT1                   */
  .word I2C1_IRQHandler                                 /* I2C1                                              */
  .word I2C2_3_IRQHandler                               /* I2C2, I2C3                                        */
  .word SPI1_IRQHandler                                 /* SPI1                                              */
  .word SPI2_3_IRQHandler                               /* SPI2, SPI3                                        */
  .word USART1_IRQHandler                               /* USART1                                            */
  .word USART2_LPUART2_IRQHandler                       /* USART2 & LPUART2                                  */
  .word USART3_4_5_6_LPUART1_IRQHandler                 /* USART3, USART4, USART5, USART6, LPUART1           */
  .word CEC_IRQHandler                                  /* CEC                                               */

/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler.
* As they are weak aliases, any function with the same name will override
* this definition.
*
*******************************************************************************/

  .weak      NMI_Handler
  .thumb_set NMI_Handler,Default_Handler

  .weak      HardFault_Handler
  .thumb_set HardFault_Handler,Default_Handler

  .weak      SVC_Handler
  .thumb_set SVC_Handler,Default_Handler

  .weak      PendSV_Handler
  .thumb_set PendSV_Handler,Default_Handler

  .weak      SysTick_Handler
  .thumb_set SysTick_Handler,Default_Handler

  .weak      WWDG_IRQHandler
  .thumb_set WWDG_IRQHandler,Default_Handler

  .weak      PVD_VDDIO2_IRQHandler
  .thumb_set PVD_VDDIO2_IRQHandler,Default_Handler

  .weak      RTC_TAMP_IRQHandler
  .thumb_set RTC_TAMP_IRQHandler,Default_Handler

  .weak      FLASH_IRQHandler
  .thumb_set FLASH_IRQHandler,Default_Handler

  .weak      RCC_CRS_IRQHandler
  .thumb_set RCC_CRS_IRQHandler,Default_Handler

  .weak      EXTI0_1_IRQHandler
  .thumb_set EXTI0_1_IRQHandler,Default_Handler

  .weak      EXTI2_3_IRQHandler
  .thumb_set EXTI2_3_IRQHandler,Default_Handler

  .weak      EXTI4_15_IRQHandler
  .thumb_set EXTI4_15_IRQHandler,Default_Handler

  .weak      USB_UCPD1_2_IRQHandler
  .thumb_set USB_UCPD1_2_IRQHandler,Default_Handler

  .weak      DMA1_Channel1_IRQHandler
  .thumb_set DMA1_Channel1_IRQHandler,Default_Handler

  .weak      DMA1_Channel2_3_IRQHandler
  .thumb_set DMA1_Channel2_3_IRQHandler,Default_Handler

  .weak      DMA1_Ch4_7_DMA2_Ch1_5_DMAMUX1_OVR_IRQHandler
  .thumb_set DMA1_Ch4_7_DMA2_Ch1_5_DMAMUX1_OVR_IRQHandler,Default_Handler

  .weak      ADC1_COMP_IRQHandler
  .thumb_set ADC1_COMP_IRQHandler,Default_Handler

  .weak      TIM1_BRK_UP_TRG_COM_IRQHandler
  .thumb_set TIM1_BRK_UP_TRG_COM_IRQHandler,Default_Handler

  .weak      TIM1_CC_IRQHandler
  .thumb_set TIM1_CC_IRQHandler,Default_Handler

  .weak      TIM2_IRQHandler
  .thumb_set TIM2_IRQHandler,Default_Handler

  .weak      TIM3_TIM4_IRQHandler
  .thumb_set TIM3_TIM4_IRQHandler,Default_Handler

  .weak      TIM6_DAC_LPTIM1_IRQHandler
  .thumb_set TIM6_DAC_LPTIM1_IRQHandler,Default_Handler

  .weak      TIM7_LPTIM2_IRQHandler
  .thumb_set TIM7_LPTIM2_IRQHandler,Default_Handler

  .weak      TIM14_IRQHandler
  .thumb_set TIM14_IRQHandler,Default_Handler

  .weak      TIM15_IRQHandler
  .thumb_set TIM15_IRQHandler,Default_Handler

  .weak      TIM16_FDCAN_IT0_IRQHandler
  .thumb_set TIM16_FDCAN_IT0_IRQHandler,Default_Handler

  .weak      TIM17_FDCAN_IT1_IRQHandler
  .thumb_set TIM17_FDCAN_IT1_IRQHandler,Default_Handler

  .weak      I2C1_IRQHandler
  .thumb_set I2C1_IRQHandler,Default_Handler

  .weak      I2C2_3_IRQHandler
  .thumb_set I2C2_3_IRQHandler,Default_Handler

  .weak      SPI1_IRQHandler
  .thumb_set SPI1_IRQHandler,Default_Handler

  .weak      SPI2_3_IRQHandler
  .thumb_set SPI2_3_IRQHandler,Default_Handler

  .weak      USART1_IRQHandler
  .thumb_set USART1_IRQHandler,Default_Handler

  .weak      USART2_LPUART2_IRQHandler
  .thumb_set USART2_LPUART2_IRQHandler,Default_Handler

  .weak      USART3_4_5_6_LPUART1_IRQHandler
  .thumb_set USART3_4_5_6_LPUART1_IRQHandler,Default_Handler

  .weak      CEC_IRQHandler
  .thumb_set CEC_IRQHandler,Default_Handler

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/

