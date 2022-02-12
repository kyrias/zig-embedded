const startup = @import("lib.zig");
const Device = startup.Device;

const ISR = fn () callconv(.AAPCS) void;

fn makeDefault(comptime str: [:0]const u8) fn () callconv(.AAPCS) void {
    return struct {
        fn defaultHandler() callconv(.AAPCS) void {
            const arg = str;
            const SYS_WRITE0: usize = 0x04;
            asm volatile (
                \\BKPT #0xAB
                :
                : [SYS_WRITE0] "{r0}" (SYS_WRITE0),
                  [arg] "{r1}" (arg),
                : "r0"
            );
            while (true) {}
        }
    }.defaultHandler;
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
        NMI_Handler: ISR = makeDefault("NMI"),
        HardFault_Handler: ISR = makeDefault("HardFault"),
        MemManage_Handler: ISR = makeDefault("MemManage"),
        BusFault_Handler: ISR = makeDefault("BusFault"),
        UsageFault_Handler: ISR = makeDefault("UsageFault"),
        reserved_7: usize = 0,
        reserved_8: usize = 0,
        reserved_9: usize = 0,
        reserved_10: usize = 0,
        SVC_Handler: ISR = makeDefault("SVC"),
        DebugMon_Handler: ISR = makeDefault("DebugMon"),
        reserved_13: usize = 0,
        PendSV_Handler: ISR = makeDefault("PendSV"),
        SysTick_Handler: ISR = makeDefault("SysTick"),

        // STM32F103C8 interrupt lines
        WWDG_IRQHandler: ISR = makeDefault("WWDG"),
        PVD_IRQHandler: ISR = makeDefault("PVD"),
        TAMPER_IRQHandler: ISR = makeDefault("TAMPER"),
        RTC_IRQHandler: ISR = makeDefault("RTC"),
        FLASH_IRQHandler: ISR = makeDefault("FLASH"),
        RCC_IRQHandler: ISR = makeDefault("RTC"),
        EXTI0_IRQHandler: ISR = makeDefault("EXTI0"),
        EXTI1_IRQHandler: ISR = makeDefault("EXTI1"),
        EXTI2_IRQHandler: ISR = makeDefault("EXTI2"),
        EXTI3_IRQHandler: ISR = makeDefault("EXTI3"),
        EXTI4_IRQHandler: ISR = makeDefault("EXTI4"),
        DMA1_Channel1_IRQHandler: ISR = makeDefault("DMA1_Channel1"),
        DMA1_Channel2_IRQHandler: ISR = makeDefault("DMA1_Channel2"),
        DMA1_Channel3_IRQHandler: ISR = makeDefault("DMA1_Channel3"),
        DMA1_Channel4_IRQHandler: ISR = makeDefault("DMA1_Channel4"),
        DMA1_Channel5_IRQHandler: ISR = makeDefault("DMA1_Channel5"),
        DMA1_Channel6_IRQHandler: ISR = makeDefault("DMA1_Channel6"),
        DMA1_Channel7_IRQHandler: ISR = makeDefault("DMA1_Channel7"),
        ADC1_2_IRQHandler: ISR = makeDefault("ADC1_2"),
        USB_HP_CAN1_TX_IRQHandler: ISR = makeDefault("USB_HP_CAN1_TX"),
        USB_LP_CAN1_RX0_IRQHandler: ISR = makeDefault("USB_LP_CAN1_RX0"),
        CAN1_RX1_IRQHandler: ISR = makeDefault("CAN1_RX1"),
        CAN1_SCE_IRQHandler: ISR = makeDefault("CAN1_SCE"),
        EXTI9_5_IRQHandler: ISR = makeDefault("EXTI9_5"),
        TIM1_BRK_IRQHandler: ISR = makeDefault("TIM1_BRK"),
        TIM1_UP_IRQHandler: ISR = makeDefault("TIM1_UP"),
        TIM1_TRG_COM_IRQHandler: ISR = makeDefault("TIM1_TRG_COM"),
        TIM1_CC_IRQHandler: ISR = makeDefault("TIM1_CC"),
        TIM2_IRQHandler: ISR = makeDefault("TIM2"),
        TIM3_IRQHandler: ISR = makeDefault("TIM3"),
        TIM4_IRQHandler: ISR = makeDefault("TIM4"),
        I2C1_EV_IRQHandler: ISR = makeDefault("I2C1_EV"),
        I2C1_ER_IRQHandler: ISR = makeDefault("I2C1_ER"),
        I2C2_EV_IRQHandler: ISR = makeDefault("I2C2_EV"),
        I2C2_ER_IRQHandler: ISR = makeDefault("I2C2_ER"),
        SPI1_IRQHandler: ISR = makeDefault("SPI1"),
        SPI2_IRQHandler: ISR = makeDefault("SPI2"),
        USART1_IRQHandler: ISR = makeDefault("USART1"),
        USART2_IRQHandler: ISR = makeDefault("USART2"),
        USART3_IRQHandler: ISR = makeDefault("USART3"),
        EXTI15_10_IRQHandler: ISR = makeDefault("EXTI15_10"),
        RTC_Alarm_IRQHandler: ISR = makeDefault("RTC_Alarm"),
        USBWakeUp_IRQHandler: ISR = makeDefault("USBWakeUp"),

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
                    @compileError("tried to set a reserved or unavailable vector table entry");
                }
                @field(table, field.name) = @field(overrides, field.name);
            }

            return table;
        }
    };
}
