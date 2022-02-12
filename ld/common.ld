ENTRY(Reset_Handler)


__ram_end = ORIGIN(RAM) + LENGTH(RAM);


SECTIONS
{
	/**
	 * Vector table
	 */

	.vector_table : {
		LONG(__stack_start)
		KEEP (*(.vector_table))
	} >FLASH


	/**
	 * Text
	 */

	.text : {
		. = ALIGN(4);
		*(.text .text.*)
	} >FLASH

	.rodata : {
		. = ALIGN(4);
		*(.rodata .rodata.*)
	} >FLASH

	.ARM.extab : {
		*(.ARM.extab*)
	} > FLASH

	.ARM.exidx : {
		/* Only export these symbols if they're referenced. */
		PROVIDE(__exidx_start = .);
		*(.ARM.exidx*)
		PROVIDE(__exidx_end = .);
	} > FLASH


	/**
	 * Data
	 */

	.data : {
		. = ALIGN(4);
		__data_vma_start = . ;
		*(.data .data.*)

		__data_vma_end = . ;
		. = ALIGN(4);
	} >RAM AT>FLASH

	__data_lma_size = SIZEOF(.data);
	__data_lma_start = LOADADDR(.data);
	__data_lma_end = __data_lma_start + __data_lma_size;


	/**
	 * BSS
	 */

	.bss (NOLOAD) : {
		. = ALIGN(4);
		__bss_start = . ;
		*(.bss*)
		*(COMMON)

		__bss_end = . ;
		__bss_size = SIZEOF(.bss);
		. = ALIGN(4);
	} >RAM


	/**
	 * Runtime memory areas
	 */

	/* Heap is 1KB. */
	__heap_size = 0x400;

	.heap (NOLOAD) : {
		. = ALIGN(4);
		__heap_start = . ;
		. = . + 0x400;

		/* Align to 8-bytes since the stack needs to be 8-byte aligned */
		. = ALIGN(8);
		__heap_end = . ;
	} >RAM


	__stack_size = __ram_end - __heap_end;

	.stack (NOLOAD) : {
		/* The AAPCS says that the SP has to be 8-byte aligned in public
		   interfaces. */
		. = ALIGN(8);
		__stack_end = . ;
		. = . + __stack_size;
		__stack_start = . ;
	} >RAM
}
