.global __init_mmu
.global set_ttbr0_el1
.global set_mair_el1
.global set_tcr_el1
.global set_sctlr_el1
.global tlb_flush

.section .text

__init_mmu:
	// 1. Kill MMU, Cache (SCTLR_EL1 수정)
	mrs x0, sctlr_el1
	bic x0, x0, #(1 << 0)  // M bit
	bic x0, x0, #(1 << 2)  // C bit
	bic x0, x0, #(1 << 12) // I bit
	msr sctlr_el1, x0
	isb

	// 2. Invalidate I-Cache (명령어 캐시 비우기)
	ic  iallu
	dsb nsh
	isb

	// 3. Invalidate TLB (주소 변환 캐시 비우기)
	// MMU 끄고 나서 혹시 모를 잔재를 확실히 제거
	tlbi vmalle1
	dsb  nsh
	isb

	ret

set_ttbr0_el1:
	msr ttbr0_el1, x0
	isb
	ret

set_mair_el1:
	msr mair_el1, x0
	isb
	ret

set_tcr_el1:
	msr tcr_el1, x0
	isb
	ret

set_sctlr_el1:
	msr sctlr_el1, x0
	isb
	ret

tlb_flush:
	tlbi vmalle1
	dsb  sy
	isb
	ret
