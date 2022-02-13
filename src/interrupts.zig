const regs = @import("devices/stm32f1.zig");

pub fn init() void {
    // Assign the entire priority field to priority rather than subpriority
    regs.SCB.AIRCR.modify(.{
        .VECTKEYSTAT = 0x5FA,
        .PRIGROUP = 0,
    });
}

pub const Interrupt = enum(u6) {
    WWDG = 0,
    PVD = 1,
    TAMPER = 2,
    RTC = 3,
    FLASH = 4,
    RCC = 5,
    EXTI0 = 6,
    EXTI1 = 7,
    EXTI2 = 8,
    EXTI3 = 9,
    EXTI4 = 10,
    DMA1_Channel1 = 11,
    DMA1_Channel2 = 12,
    DMA1_Channel3 = 13,
    DMA1_Channel4 = 14,
    DMA1_Channel5 = 15,
    DMA1_Channel6 = 16,
    DMA1_Channel7 = 17,
    ADC1_2 = 18,
    USB_HP_CAN_TX = 19,
    USB_LP_CAN_RX0 = 20,
    CAN_RX1 = 21,
    CAN_SCE = 22,
    EXTI9_5 = 23,
    TIM1_BRK = 24,
    TIM1_UP = 25,
    TIM1_TRG_COM = 26,
    TIM1_CC = 27,
    TIM2 = 28,
    TIM3 = 29,
    TIM4 = 30,
    I2C1_EV = 31,
    I2C1_ER = 32,
    I2C2_EV = 33,
    I2C2_ER = 34,
    SPI1 = 35,
    SPI2 = 36,
    USART1 = 37,
    USART2 = 38,
    USART3 = 39,
    EXTI15_10 = 40,
    RTCAlarm = 41,
    USBWakeup = 42,

    pub fn mask(comptime self: Interrupt) void {
        const nr = @enumToInt(self);
        const icer = switch (nr) {
            0...31 => regs.NVIC.ICER0,
            32...42 => regs.NVIC.ICER1,
        };
        const m = icer.read_raw();
        icer.write_raw(m | 1 << (nr % 32));
    }

    pub fn unmask(comptime self: Interrupt) void {
        const nr = @enumToInt(self);
        const iser = switch (nr) {
            0...31 => regs.NVIC.ISER0,
            32...42 => regs.NVIC.ISER1,
        };
        const m = iser.read_raw();
        iser.write_raw(m | 1 << (nr % 32));
    }

    pub fn get_priority(comptime self: Interrupt) void {
        const nr = @enumToInt(self);
        const ipr = switch (nr) {
            0...3 => regs.NVIC.IPR0,
            4...7 => regs.NVIC.IPR1,
            8...11 => regs.NVIC.IPR2,
            12...15 => regs.NVIC.IPR3,
            16...19 => regs.NVIC.IPR4,
            20...23 => regs.NVIC.IPR5,
            24...27 => regs.NVIC.IPR6,
            28...31 => regs.NVIC.IPR7,
            32...35 => regs.NVIC.IPR8,
            36...39 => regs.NVIC.IPR9,
            40...43 => regs.NVIC.IPR10,
        };
        const val = ipr.read();
        return switch (nr % 4) {
            0 => val.IPR_N0 >> 4,
            1 => val.IPR_N1 >> 4,
            2 => val.IPR_N2 >> 4,
            3 => val.IPR_N3 >> 4,
        };
    }

    pub fn set_priority(comptime self: Interrupt, priority: u4) void {
        const nr = @enumToInt(self);
        const ipr = switch (nr) {
            0...3 => regs.NVIC.IPR0,
            4...7 => regs.NVIC.IPR1,
            8...11 => regs.NVIC.IPR2,
            12...15 => regs.NVIC.IPR3,
            16...19 => regs.NVIC.IPR4,
            20...23 => regs.NVIC.IPR5,
            24...27 => regs.NVIC.IPR6,
            28...31 => regs.NVIC.IPR7,
            32...35 => regs.NVIC.IPR8,
            36...39 => regs.NVIC.IPR9,
            40...43 => regs.NVIC.IPR10,
        };
        switch (nr % 4) {
            0 => ipr.modify(.{ .IPR_N0 = priority << 4 }),
            1 => ipr.modify(.{ .IPR_N1 = priority << 4 }),
            2 => ipr.modify(.{ .IPR_N2 = @intCast(u8, priority) << 4 }),
            3 => ipr.modify(.{ .IPR_N3 = priority << 4 }),
            else => unreachable,
        }
    }
};
