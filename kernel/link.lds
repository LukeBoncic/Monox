OUTPUT_FORMAT("elf64-x86-64")
ENTRY(start)

PHDRS
{
	text PT_LOAD FLAGS(5); /* R + X */
	data PT_LOAD FLAGS(6); /* R + W */
}

SECTIONS
{
	. = 0xffff800000200000;

	.text : {
		*(.text*)
	} :text

	.rodata : {
		*(.rodata*)
	} :text

	. = ALIGN(16);

	.data : {
		*(.data*)
	} :data

	.bss : {
		PROVIDE(bss_start = .);
		*(.bss*)
		*(COMMON)
		PROVIDE(bss_end = .);
	} :data

	PROVIDE(end = .);
}
