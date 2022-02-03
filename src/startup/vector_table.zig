const Isr = fn () callconv(.AAPCS) void;

export var vector_table linksection(".vector_table") = [75]?Isr{
    // Cortex-M3 interrupt lines
    Reset_Handler,
    NMI_Handler,
    HardFault_Handler,
    MemManage_Handler,
    BusFault_Handler,
    UsageFault_Handler,
    null, // Reserved
    null, // Reserved
    null, // Reserved
    null, // Reserved
    SVC_Handler,
    DebugMon_Handler,
    null, // Reserved
    PendSV_Handler,
    SysTick_Handler,

    // STM32F103xx interrupt lines
    WWDG_IRQHandler,
    PVD_IRQHandler,
    TAMPER_IRQHandler,
    RTC_IRQHandler,
    FLASH_IRQHandler,
    RCC_IRQHandler,
    EXTI0_IRQHandler,
    EXTI1_IRQHandler,
    EXTI2_IRQHandler,
    EXTI3_IRQHandler,
    EXTI4_IRQHandler,
    DMA1_Channel1_IRQHandler,
    DMA1_Channel2_IRQHandler,
    DMA1_Channel3_IRQHandler,
    DMA1_Channel4_IRQHandler,
    DMA1_Channel5_IRQHandler,
    DMA1_Channel6_IRQHandler,
    DMA1_Channel7_IRQHandler,
    ADC1_2_IRQHandler,
    USB_HP_CAN1_TX_IRQHandler,
    USB_LP_CAN1_RX0_IRQHandler,
    CAN1_RX1_IRQHandler,
    CAN1_SCE_IRQHandler,
    EXTI9_5_IRQHandler,
    TIM1_BRK_IRQHandler,
    TIM1_UP_IRQHandler,
    TIM1_TRG_COM_IRQHandler,
    TIM1_CC_IRQHandler,
    TIM2_IRQHandler,
    TIM3_IRQHandler,
    TIM4_IRQHandler,
    I2C1_EV_IRQHandler,
    I2C1_ER_IRQHandler,
    I2C2_EV_IRQHandler,
    I2C2_ER_IRQHandler,
    SPI1_IRQHandler,
    SPI2_IRQHandler,
    USART1_IRQHandler,
    USART2_IRQHandler,
    USART3_IRQHandler,
    EXTI15_10_IRQHandler,
    RTC_Alarm_IRQHandler,
    USBWakeUp_IRQHandler,

    // Interrupt lines not available on the STM32F103C8
    null, // TIM8_BRK
    null, // TIM8_UP
    null, // TIM8_TRG_COM
    null, // TIM8_CC
    null, // ADC3
    null, // FSMC
    null, // SDIO
    null, // TIM5
    null, // SPI3
    null, // UART4
    null, // UART5
    null, // TIM6
    null, // TIM7
    null, // DMA2_Channel1
    null, // DMA2_Channel2
    null, // DMA2_Channel3
    null, // DMA2_Channel4_5
};

extern fn Reset_Handler() callconv(.AAPCS) void;
extern fn NMI_Handler() callconv(.AAPCS) void;
extern fn HardFault_Handler() callconv(.AAPCS) void;
extern fn MemManage_Handler() callconv(.AAPCS) void;
extern fn BusFault_Handler() callconv(.AAPCS) void;
extern fn UsageFault_Handler() callconv(.AAPCS) void;
extern fn SVC_Handler() callconv(.AAPCS) void;
extern fn DebugMon_Handler() callconv(.AAPCS) void;
extern fn PendSV_Handler() callconv(.AAPCS) void;
extern fn SysTick_Handler() callconv(.AAPCS) void;

extern fn WWDG_IRQHandler() callconv(.AAPCS) void;
extern fn PVD_IRQHandler() callconv(.AAPCS) void;
extern fn TAMPER_IRQHandler() callconv(.AAPCS) void;
extern fn RTC_IRQHandler() callconv(.AAPCS) void;
extern fn FLASH_IRQHandler() callconv(.AAPCS) void;
extern fn RCC_IRQHandler() callconv(.AAPCS) void;
extern fn EXTI0_IRQHandler() callconv(.AAPCS) void;
extern fn EXTI1_IRQHandler() callconv(.AAPCS) void;
extern fn EXTI2_IRQHandler() callconv(.AAPCS) void;
extern fn EXTI3_IRQHandler() callconv(.AAPCS) void;
extern fn EXTI4_IRQHandler() callconv(.AAPCS) void;
extern fn DMA1_Channel1_IRQHandler() callconv(.AAPCS) void;
extern fn DMA1_Channel2_IRQHandler() callconv(.AAPCS) void;
extern fn DMA1_Channel3_IRQHandler() callconv(.AAPCS) void;
extern fn DMA1_Channel4_IRQHandler() callconv(.AAPCS) void;
extern fn DMA1_Channel5_IRQHandler() callconv(.AAPCS) void;
extern fn DMA1_Channel6_IRQHandler() callconv(.AAPCS) void;
extern fn DMA1_Channel7_IRQHandler() callconv(.AAPCS) void;
extern fn ADC1_2_IRQHandler() callconv(.AAPCS) void;
extern fn USB_HP_CAN1_TX_IRQHandler() callconv(.AAPCS) void;
extern fn USB_LP_CAN1_RX0_IRQHandler() callconv(.AAPCS) void;
extern fn CAN1_RX1_IRQHandler() callconv(.AAPCS) void;
extern fn CAN1_SCE_IRQHandler() callconv(.AAPCS) void;
extern fn EXTI9_5_IRQHandler() callconv(.AAPCS) void;
extern fn TIM1_BRK_IRQHandler() callconv(.AAPCS) void;
extern fn TIM1_UP_IRQHandler() callconv(.AAPCS) void;
extern fn TIM1_TRG_COM_IRQHandler() callconv(.AAPCS) void;
extern fn TIM1_CC_IRQHandler() callconv(.AAPCS) void;
extern fn TIM2_IRQHandler() callconv(.AAPCS) void;
extern fn TIM3_IRQHandler() callconv(.AAPCS) void;
extern fn TIM4_IRQHandler() callconv(.AAPCS) void;
extern fn I2C1_EV_IRQHandler() callconv(.AAPCS) void;
extern fn I2C1_ER_IRQHandler() callconv(.AAPCS) void;
extern fn I2C2_EV_IRQHandler() callconv(.AAPCS) void;
extern fn I2C2_ER_IRQHandler() callconv(.AAPCS) void;
extern fn SPI1_IRQHandler() callconv(.AAPCS) void;
extern fn SPI2_IRQHandler() callconv(.AAPCS) void;
extern fn USART1_IRQHandler() callconv(.AAPCS) void;
extern fn USART2_IRQHandler() callconv(.AAPCS) void;
extern fn USART3_IRQHandler() callconv(.AAPCS) void;
extern fn EXTI15_10_IRQHandler() callconv(.AAPCS) void;
extern fn RTC_Alarm_IRQHandler() callconv(.AAPCS) void;
extern fn USBWakeUp_IRQHandler() callconv(.AAPCS) void;
