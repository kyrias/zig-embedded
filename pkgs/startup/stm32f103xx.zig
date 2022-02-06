const startup = @import("lib.zig");
const Device = startup.Device;

const ISR = fn () callconv(.AAPCS) void;

fn Default_Handler() callconv(.AAPCS) void {
    while (true) {}
}

pub fn VectorTable(comptime reset_handler: ISR, comptime device: Device) type {
    return switch (device) {
        .STM32F103C8 => STM32F103C8VectorTable(reset_handler),
    };
}

pub fn STM32F103C8VectorTable(comptime reset_handler: ISR) type {
    return struct {
        const Self = @This();

        // Cortex-M3 interrupt lines
        Reset_Handler: ISR = reset_handler,
        NMI_Handler: ISR = Default_Handler,
        HardFault_Handler: ISR = Default_Handler,
        MemManage_Handler: ISR = Default_Handler,
        BusFault_Handler: ISR = Default_Handler,
        UsageFault_Handler: ISR = Default_Handler,
        reserved_7: usize = 0,
        reserved_8: usize = 0,
        reserved_9: usize = 0,
        reserved_10: usize = 0,
        SVC_Handler: ISR = Default_Handler,
        DebugMon_Handler: ISR = Default_Handler,
        reserved_13: usize = 0,
        PendSV_Handler: ISR = Default_Handler,
        SysTick_Handler: ISR = Default_Handler,

        // STM32F103C8 interrupt lines
        WWDG_IRQHandler: ISR = Default_Handler,
        PVD_IRQHandler: ISR = Default_Handler,
        TAMPER_IRQHandler: ISR = Default_Handler,
        RTC_IRQHandler: ISR = Default_Handler,
        FLASH_IRQHandler: ISR = Default_Handler,
        RCC_IRQHandler: ISR = Default_Handler,
        EXTI0_IRQHandler: ISR = Default_Handler,
        EXTI1_IRQHandler: ISR = Default_Handler,
        EXTI2_IRQHandler: ISR = Default_Handler,
        EXTI3_IRQHandler: ISR = Default_Handler,
        EXTI4_IRQHandler: ISR = Default_Handler,
        DMA1_Channel1_IRQHandler: ISR = Default_Handler,
        DMA1_Channel2_IRQHandler: ISR = Default_Handler,
        DMA1_Channel3_IRQHandler: ISR = Default_Handler,
        DMA1_Channel4_IRQHandler: ISR = Default_Handler,
        DMA1_Channel5_IRQHandler: ISR = Default_Handler,
        DMA1_Channel6_IRQHandler: ISR = Default_Handler,
        DMA1_Channel7_IRQHandler: ISR = Default_Handler,
        ADC1_2_IRQHandler: ISR = Default_Handler,
        USB_HP_CAN1_TX_IRQHandler: ISR = Default_Handler,
        USB_LP_CAN1_RX0_IRQHandler: ISR = Default_Handler,
        CAN1_RX1_IRQHandler: ISR = Default_Handler,
        CAN1_SCE_IRQHandler: ISR = Default_Handler,
        EXTI9_5_IRQHandler: ISR = Default_Handler,
        TIM1_BRK_IRQHandler: ISR = Default_Handler,
        TIM1_UP_IRQHandler: ISR = Default_Handler,
        TIM1_TRG_COM_IRQHandler: ISR = Default_Handler,
        TIM1_CC_IRQHandler: ISR = Default_Handler,
        TIM2_IRQHandler: ISR = Default_Handler,
        TIM3_IRQHandler: ISR = Default_Handler,
        TIM4_IRQHandler: ISR = Default_Handler,
        I2C1_EV_IRQHandler: ISR = Default_Handler,
        I2C1_ER_IRQHandler: ISR = Default_Handler,
        I2C2_EV_IRQHandler: ISR = Default_Handler,
        I2C2_ER_IRQHandler: ISR = Default_Handler,
        SPI1_IRQHandler: ISR = Default_Handler,
        SPI2_IRQHandler: ISR = Default_Handler,
        USART1_IRQHandler: ISR = Default_Handler,
        USART2_IRQHandler: ISR = Default_Handler,
        USART3_IRQHandler: ISR = Default_Handler,
        EXTI15_10_IRQHandler: ISR = Default_Handler,
        RTC_Alarm_IRQHandler: ISR = Default_Handler,
        USBWakeUp_IRQHandler: ISR = Default_Handler,

        // Interrupt lines not available on the STM32F103C8
        unavailable_59: usize = 0, // TIM8_BRK
        unavailable_60: usize = 0, // TIM8_UP
        unavailable_61: usize = 0, // TIM8_TRG_COM
        unavailable_62: usize = 0, // TIM8_CC
        unavailable_63: usize = 0, // ADC3
        unavailable_64: usize = 0, // FSMC
        unavailable_65: usize = 0, // SDIO
        unavailable_66: usize = 0, // TIM5
        unavailable_67: usize = 0, // SPI3
        unavailable_68: usize = 0, // UART4
        unavailable_69: usize = 0, // UART5
        unavailable_70: usize = 0, // TIM6
        unavailable_71: usize = 0, // TIM7
        unavailable_72: usize = 0, // DMA2_Channel1
        unavailable_73: usize = 0, // DMA2_Channel2
        unavailable_74: usize = 0, // DMA2_Channel3
        unavailable_75: usize = 0, // DMA2_Channel4_5

        pub fn init(overrides: anytype) Self {
            var table: Self = .{};

            const info = @typeInfo(@TypeOf(overrides));
            inline for (info.Struct.fields) |field| {
                if (@TypeOf(@field(table, field.name)) != ISR) {
                    @compileError("tried to set a reserved or unavailale vector table entry");
                }
                @field(table, field.name) = @field(overrides, field.name);
            }

            return table;
        }
    };
}
