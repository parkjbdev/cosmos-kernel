// src/start.S
// AArch64 bare metal 부트 엔트리

.section .text.boot
.global  _start

.extern kmain
.extern __bss_start
.extern __bss_end
.extern __init_mmu

_start:
	// Disable Interrupt (DAIF 세트)
	msr DAIFSet, #0b1111

	bl __init_mmu

	// 스택 포인터 설정 (임시로 DRAM 상단 근처로 가정)
	// KERNEL_LOAD_ADDR + 16MB 정도 예시
	ldr x0, =0x41000000
	mov sp, x0

	// .bss 영역 0으로 클리어
	ldr x1, =__bss_start
	ldr x2, =__bss_end

bss_clear_loop:
	cmp  x1, x2
	b.ge bss_clear_done
	str  xzr, [x1], #8  // 8바이트씩 0으로 채우기
	b    bss_clear_loop

bss_clear_done:
	// C 엔트리로 진입
	bl kmain

1:  // kmain 반환 시 그냥 멈춰있기
	wfe
	b 1b
