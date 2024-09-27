
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16 # 80203ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	167000ef          	jal	80200988 <memset>

    cons_init();  // init the console
    80200026:	146000ef          	jal	8020016c <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	97658593          	addi	a1,a1,-1674 # 802009a0 <etext+0x6>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	98e50513          	addi	a0,a0,-1650 # 802009c0 <etext+0x26>
    8020003a:	030000ef          	jal	8020006a <cprintf>

    print_kerninfo();
    8020003e:	060000ef          	jal	8020009e <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13a000ef          	jal	8020017c <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e4000ef          	jal	8020012a <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	12c000ef          	jal	80200176 <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	116000ef          	jal	8020016e <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40
int cprintf(const char *fmt, ...) {
    80200070:	f42e                	sd	a1,40(sp)
    80200072:	f832                	sd	a2,48(sp)
    80200074:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200076:	862a                	mv	a2,a0
    80200078:	004c                	addi	a1,sp,4
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fd650513          	addi	a0,a0,-42 # 80200050 <cputch>
    80200082:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200084:	ec06                	sd	ra,24(sp)
    80200086:	e0ba                	sd	a4,64(sp)
    80200088:	e4be                	sd	a5,72(sp)
    8020008a:	e8c2                	sd	a6,80(sp)
    8020008c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020008e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200090:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200092:	512000ef          	jal	802005a4 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200096:	60e2                	ld	ra,24(sp)
    80200098:	4512                	lw	a0,4(sp)
    8020009a:	6125                	addi	sp,sp,96
    8020009c:	8082                	ret

000000008020009e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    8020009e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a0:	00001517          	auipc	a0,0x1
    802000a4:	92850513          	addi	a0,a0,-1752 # 802009c8 <etext+0x2e>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	93250513          	addi	a0,a0,-1742 # 802009e8 <etext+0x4e>
    802000be:	fadff0ef          	jal	8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	8d858593          	addi	a1,a1,-1832 # 8020099a <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	93e50513          	addi	a0,a0,-1730 # 80200a08 <etext+0x6e>
    802000d2:	f99ff0ef          	jal	8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f3a58593          	addi	a1,a1,-198 # 80204010 <ticks>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	94a50513          	addi	a0,a0,-1718 # 80200a28 <etext+0x8e>
    802000e6:	f85ff0ef          	jal	8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f3e58593          	addi	a1,a1,-194 # 80204028 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	95650513          	addi	a0,a0,-1706 # 80200a48 <etext+0xae>
    802000fa:	f71ff0ef          	jal	8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    802000fe:	00004797          	auipc	a5,0x4
    80200102:	32978793          	addi	a5,a5,809 # 80204427 <end+0x3ff>
    80200106:	00000717          	auipc	a4,0x0
    8020010a:	f0470713          	addi	a4,a4,-252 # 8020000a <kern_init>
    8020010e:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200110:	43f7d593          	srai	a1,a5,0x3f
}
    80200114:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200116:	3ff5f593          	andi	a1,a1,1023
    8020011a:	95be                	add	a1,a1,a5
    8020011c:	85a9                	srai	a1,a1,0xa
    8020011e:	00001517          	auipc	a0,0x1
    80200122:	94a50513          	addi	a0,a0,-1718 # 80200a68 <etext+0xce>
}
    80200126:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200128:	b789                	j	8020006a <cprintf>

000000008020012a <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012a:	1141                	addi	sp,sp,-16
    8020012c:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020012e:	02000793          	li	a5,32
    80200132:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200136:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013a:	67e1                	lui	a5,0x18
    8020013c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200140:	953e                	add	a0,a0,a5
    80200142:	7f6000ef          	jal	80200938 <sbi_set_timer>
}
    80200146:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200148:	00004797          	auipc	a5,0x4
    8020014c:	ec07b423          	sd	zero,-312(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200150:	00001517          	auipc	a0,0x1
    80200154:	94850513          	addi	a0,a0,-1720 # 80200a98 <etext+0xfe>
}
    80200158:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015a:	bf01                	j	8020006a <cprintf>

000000008020015c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020015c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200160:	67e1                	lui	a5,0x18
    80200162:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200166:	953e                	add	a0,a0,a5
    80200168:	7d00006f          	j	80200938 <sbi_set_timer>

000000008020016c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020016c:	8082                	ret

000000008020016e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020016e:	0ff57513          	zext.b	a0,a0
    80200172:	7ac0006f          	j	8020091e <sbi_console_putchar>

0000000080200176 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200176:	100167f3          	csrrsi	a5,sstatus,2
    8020017a:	8082                	ret

000000008020017c <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200180:	00000797          	auipc	a5,0x0
    80200184:	30078793          	addi	a5,a5,768 # 80200480 <__alltraps>
    80200188:	10579073          	csrw	stvec,a5
}
    8020018c:	8082                	ret

000000008020018e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200190:	1141                	addi	sp,sp,-16
    80200192:	e022                	sd	s0,0(sp)
    80200194:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	00001517          	auipc	a0,0x1
    8020019a:	92250513          	addi	a0,a0,-1758 # 80200ab8 <etext+0x11e>
void print_regs(struct pushregs *gpr) {
    8020019e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	ecbff0ef          	jal	8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a4:	640c                	ld	a1,8(s0)
    802001a6:	00001517          	auipc	a0,0x1
    802001aa:	92a50513          	addi	a0,a0,-1750 # 80200ad0 <etext+0x136>
    802001ae:	ebdff0ef          	jal	8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b2:	680c                	ld	a1,16(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	93450513          	addi	a0,a0,-1740 # 80200ae8 <etext+0x14e>
    802001bc:	eafff0ef          	jal	8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c0:	6c0c                	ld	a1,24(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	93e50513          	addi	a0,a0,-1730 # 80200b00 <etext+0x166>
    802001ca:	ea1ff0ef          	jal	8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001ce:	700c                	ld	a1,32(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	94850513          	addi	a0,a0,-1720 # 80200b18 <etext+0x17e>
    802001d8:	e93ff0ef          	jal	8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001dc:	740c                	ld	a1,40(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	95250513          	addi	a0,a0,-1710 # 80200b30 <etext+0x196>
    802001e6:	e85ff0ef          	jal	8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ea:	780c                	ld	a1,48(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	95c50513          	addi	a0,a0,-1700 # 80200b48 <etext+0x1ae>
    802001f4:	e77ff0ef          	jal	8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f8:	7c0c                	ld	a1,56(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	96650513          	addi	a0,a0,-1690 # 80200b60 <etext+0x1c6>
    80200202:	e69ff0ef          	jal	8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200206:	602c                	ld	a1,64(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	97050513          	addi	a0,a0,-1680 # 80200b78 <etext+0x1de>
    80200210:	e5bff0ef          	jal	8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200214:	642c                	ld	a1,72(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	97a50513          	addi	a0,a0,-1670 # 80200b90 <etext+0x1f6>
    8020021e:	e4dff0ef          	jal	8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200222:	682c                	ld	a1,80(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	98450513          	addi	a0,a0,-1660 # 80200ba8 <etext+0x20e>
    8020022c:	e3fff0ef          	jal	8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200230:	6c2c                	ld	a1,88(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	98e50513          	addi	a0,a0,-1650 # 80200bc0 <etext+0x226>
    8020023a:	e31ff0ef          	jal	8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020023e:	702c                	ld	a1,96(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	99850513          	addi	a0,a0,-1640 # 80200bd8 <etext+0x23e>
    80200248:	e23ff0ef          	jal	8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024c:	742c                	ld	a1,104(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	9a250513          	addi	a0,a0,-1630 # 80200bf0 <etext+0x256>
    80200256:	e15ff0ef          	jal	8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025a:	782c                	ld	a1,112(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	9ac50513          	addi	a0,a0,-1620 # 80200c08 <etext+0x26e>
    80200264:	e07ff0ef          	jal	8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200268:	7c2c                	ld	a1,120(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	9b650513          	addi	a0,a0,-1610 # 80200c20 <etext+0x286>
    80200272:	df9ff0ef          	jal	8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200276:	604c                	ld	a1,128(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	9c050513          	addi	a0,a0,-1600 # 80200c38 <etext+0x29e>
    80200280:	debff0ef          	jal	8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200284:	644c                	ld	a1,136(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	9ca50513          	addi	a0,a0,-1590 # 80200c50 <etext+0x2b6>
    8020028e:	dddff0ef          	jal	8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200292:	684c                	ld	a1,144(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	9d450513          	addi	a0,a0,-1580 # 80200c68 <etext+0x2ce>
    8020029c:	dcfff0ef          	jal	8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a0:	6c4c                	ld	a1,152(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	9de50513          	addi	a0,a0,-1570 # 80200c80 <etext+0x2e6>
    802002aa:	dc1ff0ef          	jal	8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ae:	704c                	ld	a1,160(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	9e850513          	addi	a0,a0,-1560 # 80200c98 <etext+0x2fe>
    802002b8:	db3ff0ef          	jal	8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002bc:	744c                	ld	a1,168(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	9f250513          	addi	a0,a0,-1550 # 80200cb0 <etext+0x316>
    802002c6:	da5ff0ef          	jal	8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ca:	784c                	ld	a1,176(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	9fc50513          	addi	a0,a0,-1540 # 80200cc8 <etext+0x32e>
    802002d4:	d97ff0ef          	jal	8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d8:	7c4c                	ld	a1,184(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	a0650513          	addi	a0,a0,-1530 # 80200ce0 <etext+0x346>
    802002e2:	d89ff0ef          	jal	8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e6:	606c                	ld	a1,192(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	a1050513          	addi	a0,a0,-1520 # 80200cf8 <etext+0x35e>
    802002f0:	d7bff0ef          	jal	8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f4:	646c                	ld	a1,200(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	a1a50513          	addi	a0,a0,-1510 # 80200d10 <etext+0x376>
    802002fe:	d6dff0ef          	jal	8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200302:	686c                	ld	a1,208(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	a2450513          	addi	a0,a0,-1500 # 80200d28 <etext+0x38e>
    8020030c:	d5fff0ef          	jal	8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200310:	6c6c                	ld	a1,216(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	a2e50513          	addi	a0,a0,-1490 # 80200d40 <etext+0x3a6>
    8020031a:	d51ff0ef          	jal	8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020031e:	706c                	ld	a1,224(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	a3850513          	addi	a0,a0,-1480 # 80200d58 <etext+0x3be>
    80200328:	d43ff0ef          	jal	8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032c:	746c                	ld	a1,232(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	a4250513          	addi	a0,a0,-1470 # 80200d70 <etext+0x3d6>
    80200336:	d35ff0ef          	jal	8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033a:	786c                	ld	a1,240(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	a4c50513          	addi	a0,a0,-1460 # 80200d88 <etext+0x3ee>
    80200344:	d27ff0ef          	jal	8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200348:	7c6c                	ld	a1,248(s0)
}
    8020034a:	6402                	ld	s0,0(sp)
    8020034c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034e:	00001517          	auipc	a0,0x1
    80200352:	a5250513          	addi	a0,a0,-1454 # 80200da0 <etext+0x406>
}
    80200356:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	bb09                	j	8020006a <cprintf>

000000008020035a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035a:	1141                	addi	sp,sp,-16
    8020035c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020035e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200360:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200362:	00001517          	auipc	a0,0x1
    80200366:	a5650513          	addi	a0,a0,-1450 # 80200db8 <etext+0x41e>
void print_trapframe(struct trapframe *tf) {
    8020036a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	cffff0ef          	jal	8020006a <cprintf>
    print_regs(&tf->gpr);
    80200370:	8522                	mv	a0,s0
    80200372:	e1dff0ef          	jal	8020018e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200376:	10043583          	ld	a1,256(s0)
    8020037a:	00001517          	auipc	a0,0x1
    8020037e:	a5650513          	addi	a0,a0,-1450 # 80200dd0 <etext+0x436>
    80200382:	ce9ff0ef          	jal	8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200386:	10843583          	ld	a1,264(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	a5e50513          	addi	a0,a0,-1442 # 80200de8 <etext+0x44e>
    80200392:	cd9ff0ef          	jal	8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200396:	11043583          	ld	a1,272(s0)
    8020039a:	00001517          	auipc	a0,0x1
    8020039e:	a6650513          	addi	a0,a0,-1434 # 80200e00 <etext+0x466>
    802003a2:	cc9ff0ef          	jal	8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a6:	11843583          	ld	a1,280(s0)
}
    802003aa:	6402                	ld	s0,0(sp)
    802003ac:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ae:	00001517          	auipc	a0,0x1
    802003b2:	a6a50513          	addi	a0,a0,-1430 # 80200e18 <etext+0x47e>
}
    802003b6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	b94d                	j	8020006a <cprintf>

00000000802003ba <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
    802003ba:	11853783          	ld	a5,280(a0)
    802003be:	472d                	li	a4,11
    802003c0:	0786                	slli	a5,a5,0x1
    802003c2:	8385                	srli	a5,a5,0x1
    802003c4:	08f76263          	bltu	a4,a5,80200448 <interrupt_handler+0x8e>
    802003c8:	00001717          	auipc	a4,0x1
    802003cc:	bcc70713          	addi	a4,a4,-1076 # 80200f94 <etext+0x5fa>
    802003d0:	078a                	slli	a5,a5,0x2
    802003d2:	97ba                	add	a5,a5,a4
    802003d4:	439c                	lw	a5,0(a5)
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003da:	00001517          	auipc	a0,0x1
    802003de:	ab650513          	addi	a0,a0,-1354 # 80200e90 <etext+0x4f6>
    802003e2:	b161                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	a8c50513          	addi	a0,a0,-1396 # 80200e70 <etext+0x4d6>
    802003ec:	b9bd                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	a4250513          	addi	a0,a0,-1470 # 80200e30 <etext+0x496>
    802003f6:	b995                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	a5850513          	addi	a0,a0,-1448 # 80200e50 <etext+0x4b6>
    80200400:	b1ad                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200402:	1141                	addi	sp,sp,-16
    80200404:	e022                	sd	s0,0(sp)
    80200406:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */

            clock_set_next_event();
    80200408:	d55ff0ef          	jal	8020015c <clock_set_next_event>
            ticks++;
    8020040c:	00004797          	auipc	a5,0x4
    80200410:	c0478793          	addi	a5,a5,-1020 # 80204010 <ticks>
    80200414:	6398                	ld	a4,0(a5)
    80200416:	00004417          	auipc	s0,0x4
    8020041a:	c0240413          	addi	s0,s0,-1022 # 80204018 <num>
    8020041e:	0705                	addi	a4,a4,1
    80200420:	e398                	sd	a4,0(a5)
            if(ticks % TICK_NUM == 0){
    80200422:	639c                	ld	a5,0(a5)
    80200424:	06400713          	li	a4,100
    80200428:	02e7f7b3          	remu	a5,a5,a4
    8020042c:	cf99                	beqz	a5,8020044a <interrupt_handler+0x90>
                print_ticks();
                num++;
            }
            if(num ==10)
    8020042e:	6018                	ld	a4,0(s0)
    80200430:	47a9                	li	a5,10
    80200432:	02f70863          	beq	a4,a5,80200462 <interrupt_handler+0xa8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200436:	60a2                	ld	ra,8(sp)
    80200438:	6402                	ld	s0,0(sp)
    8020043a:	0141                	addi	sp,sp,16
    8020043c:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020043e:	00001517          	auipc	a0,0x1
    80200442:	a8250513          	addi	a0,a0,-1406 # 80200ec0 <etext+0x526>
    80200446:	b115                	j	8020006a <cprintf>
            print_trapframe(tf);
    80200448:	bf09                	j	8020035a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020044a:	06400593          	li	a1,100
    8020044e:	00001517          	auipc	a0,0x1
    80200452:	a6250513          	addi	a0,a0,-1438 # 80200eb0 <etext+0x516>
    80200456:	c15ff0ef          	jal	8020006a <cprintf>
                num++;
    8020045a:	601c                	ld	a5,0(s0)
    8020045c:	0785                	addi	a5,a5,1
    8020045e:	e01c                	sd	a5,0(s0)
    80200460:	b7f9                	j	8020042e <interrupt_handler+0x74>
}
    80200462:	6402                	ld	s0,0(sp)
    80200464:	60a2                	ld	ra,8(sp)
    80200466:	0141                	addi	sp,sp,16
                sbi_shutdown();
    80200468:	a1ed                	j	80200952 <sbi_shutdown>

000000008020046a <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020046a:	11853783          	ld	a5,280(a0)
    8020046e:	0007c763          	bltz	a5,8020047c <trap+0x12>
    switch (tf->cause) {
    80200472:	472d                	li	a4,11
    80200474:	00f76363          	bltu	a4,a5,8020047a <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200478:	8082                	ret
            print_trapframe(tf);
    8020047a:	b5c5                	j	8020035a <print_trapframe>
        interrupt_handler(tf);
    8020047c:	bf3d                	j	802003ba <interrupt_handler>
	...

0000000080200480 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200480:	14011073          	csrw	sscratch,sp
    80200484:	712d                	addi	sp,sp,-288
    80200486:	e002                	sd	zero,0(sp)
    80200488:	e406                	sd	ra,8(sp)
    8020048a:	ec0e                	sd	gp,24(sp)
    8020048c:	f012                	sd	tp,32(sp)
    8020048e:	f416                	sd	t0,40(sp)
    80200490:	f81a                	sd	t1,48(sp)
    80200492:	fc1e                	sd	t2,56(sp)
    80200494:	e0a2                	sd	s0,64(sp)
    80200496:	e4a6                	sd	s1,72(sp)
    80200498:	e8aa                	sd	a0,80(sp)
    8020049a:	ecae                	sd	a1,88(sp)
    8020049c:	f0b2                	sd	a2,96(sp)
    8020049e:	f4b6                	sd	a3,104(sp)
    802004a0:	f8ba                	sd	a4,112(sp)
    802004a2:	fcbe                	sd	a5,120(sp)
    802004a4:	e142                	sd	a6,128(sp)
    802004a6:	e546                	sd	a7,136(sp)
    802004a8:	e94a                	sd	s2,144(sp)
    802004aa:	ed4e                	sd	s3,152(sp)
    802004ac:	f152                	sd	s4,160(sp)
    802004ae:	f556                	sd	s5,168(sp)
    802004b0:	f95a                	sd	s6,176(sp)
    802004b2:	fd5e                	sd	s7,184(sp)
    802004b4:	e1e2                	sd	s8,192(sp)
    802004b6:	e5e6                	sd	s9,200(sp)
    802004b8:	e9ea                	sd	s10,208(sp)
    802004ba:	edee                	sd	s11,216(sp)
    802004bc:	f1f2                	sd	t3,224(sp)
    802004be:	f5f6                	sd	t4,232(sp)
    802004c0:	f9fa                	sd	t5,240(sp)
    802004c2:	fdfe                	sd	t6,248(sp)
    802004c4:	14001473          	csrrw	s0,sscratch,zero
    802004c8:	100024f3          	csrr	s1,sstatus
    802004cc:	14102973          	csrr	s2,sepc
    802004d0:	143029f3          	csrr	s3,stval
    802004d4:	14202a73          	csrr	s4,scause
    802004d8:	e822                	sd	s0,16(sp)
    802004da:	e226                	sd	s1,256(sp)
    802004dc:	e64a                	sd	s2,264(sp)
    802004de:	ea4e                	sd	s3,272(sp)
    802004e0:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802004e2:	850a                	mv	a0,sp
    jal trap
    802004e4:	f87ff0ef          	jal	8020046a <trap>

00000000802004e8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802004e8:	6492                	ld	s1,256(sp)
    802004ea:	6932                	ld	s2,264(sp)
    802004ec:	10049073          	csrw	sstatus,s1
    802004f0:	14191073          	csrw	sepc,s2
    802004f4:	60a2                	ld	ra,8(sp)
    802004f6:	61e2                	ld	gp,24(sp)
    802004f8:	7202                	ld	tp,32(sp)
    802004fa:	72a2                	ld	t0,40(sp)
    802004fc:	7342                	ld	t1,48(sp)
    802004fe:	73e2                	ld	t2,56(sp)
    80200500:	6406                	ld	s0,64(sp)
    80200502:	64a6                	ld	s1,72(sp)
    80200504:	6546                	ld	a0,80(sp)
    80200506:	65e6                	ld	a1,88(sp)
    80200508:	7606                	ld	a2,96(sp)
    8020050a:	76a6                	ld	a3,104(sp)
    8020050c:	7746                	ld	a4,112(sp)
    8020050e:	77e6                	ld	a5,120(sp)
    80200510:	680a                	ld	a6,128(sp)
    80200512:	68aa                	ld	a7,136(sp)
    80200514:	694a                	ld	s2,144(sp)
    80200516:	69ea                	ld	s3,152(sp)
    80200518:	7a0a                	ld	s4,160(sp)
    8020051a:	7aaa                	ld	s5,168(sp)
    8020051c:	7b4a                	ld	s6,176(sp)
    8020051e:	7bea                	ld	s7,184(sp)
    80200520:	6c0e                	ld	s8,192(sp)
    80200522:	6cae                	ld	s9,200(sp)
    80200524:	6d4e                	ld	s10,208(sp)
    80200526:	6dee                	ld	s11,216(sp)
    80200528:	7e0e                	ld	t3,224(sp)
    8020052a:	7eae                	ld	t4,232(sp)
    8020052c:	7f4e                	ld	t5,240(sp)
    8020052e:	7fee                	ld	t6,248(sp)
    80200530:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    80200532:	10200073          	sret

0000000080200536 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200536:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020053a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    8020053c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200540:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200542:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200546:	f022                	sd	s0,32(sp)
    80200548:	ec26                	sd	s1,24(sp)
    8020054a:	e84a                	sd	s2,16(sp)
    8020054c:	f406                	sd	ra,40(sp)
    8020054e:	84aa                	mv	s1,a0
    80200550:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200552:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200556:	2a01                	sext.w	s4,s4
    if (num >= base) {
    80200558:	05067063          	bgeu	a2,a6,80200598 <printnum+0x62>
    8020055c:	e44e                	sd	s3,8(sp)
    8020055e:	89be                	mv	s3,a5
        while (-- width > 0)
    80200560:	4785                	li	a5,1
    80200562:	00e7d763          	bge	a5,a4,80200570 <printnum+0x3a>
            putch(padc, putdat);
    80200566:	85ca                	mv	a1,s2
    80200568:	854e                	mv	a0,s3
        while (-- width > 0)
    8020056a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020056c:	9482                	jalr	s1
        while (-- width > 0)
    8020056e:	fc65                	bnez	s0,80200566 <printnum+0x30>
    80200570:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200572:	1a02                	slli	s4,s4,0x20
    80200574:	020a5a13          	srli	s4,s4,0x20
    80200578:	00001797          	auipc	a5,0x1
    8020057c:	96878793          	addi	a5,a5,-1688 # 80200ee0 <etext+0x546>
    80200580:	97d2                	add	a5,a5,s4
}
    80200582:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200584:	0007c503          	lbu	a0,0(a5)
}
    80200588:	70a2                	ld	ra,40(sp)
    8020058a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020058c:	85ca                	mv	a1,s2
    8020058e:	87a6                	mv	a5,s1
}
    80200590:	6942                	ld	s2,16(sp)
    80200592:	64e2                	ld	s1,24(sp)
    80200594:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200596:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200598:	03065633          	divu	a2,a2,a6
    8020059c:	8722                	mv	a4,s0
    8020059e:	f99ff0ef          	jal	80200536 <printnum>
    802005a2:	bfc1                	j	80200572 <printnum+0x3c>

00000000802005a4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005a4:	7119                	addi	sp,sp,-128
    802005a6:	f4a6                	sd	s1,104(sp)
    802005a8:	f0ca                	sd	s2,96(sp)
    802005aa:	ecce                	sd	s3,88(sp)
    802005ac:	e8d2                	sd	s4,80(sp)
    802005ae:	e4d6                	sd	s5,72(sp)
    802005b0:	e0da                	sd	s6,64(sp)
    802005b2:	f862                	sd	s8,48(sp)
    802005b4:	fc86                	sd	ra,120(sp)
    802005b6:	f8a2                	sd	s0,112(sp)
    802005b8:	fc5e                	sd	s7,56(sp)
    802005ba:	f466                	sd	s9,40(sp)
    802005bc:	f06a                	sd	s10,32(sp)
    802005be:	ec6e                	sd	s11,24(sp)
    802005c0:	892a                	mv	s2,a0
    802005c2:	84ae                	mv	s1,a1
    802005c4:	8c32                	mv	s8,a2
    802005c6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005c8:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802005cc:	05500b13          	li	s6,85
    802005d0:	00001a97          	auipc	s5,0x1
    802005d4:	9f4a8a93          	addi	s5,s5,-1548 # 80200fc4 <etext+0x62a>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005d8:	000c4503          	lbu	a0,0(s8)
    802005dc:	001c0413          	addi	s0,s8,1
    802005e0:	01350a63          	beq	a0,s3,802005f4 <vprintfmt+0x50>
            if (ch == '\0') {
    802005e4:	cd0d                	beqz	a0,8020061e <vprintfmt+0x7a>
            putch(ch, putdat);
    802005e6:	85a6                	mv	a1,s1
    802005e8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005ea:	00044503          	lbu	a0,0(s0)
    802005ee:	0405                	addi	s0,s0,1
    802005f0:	ff351ae3          	bne	a0,s3,802005e4 <vprintfmt+0x40>
        char padc = ' ';
    802005f4:	02000d93          	li	s11,32
        lflag = altflag = 0;
    802005f8:	4b81                	li	s7,0
    802005fa:	4601                	li	a2,0
        width = precision = -1;
    802005fc:	5d7d                	li	s10,-1
    802005fe:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200600:	00044683          	lbu	a3,0(s0)
    80200604:	00140c13          	addi	s8,s0,1
    80200608:	fdd6859b          	addiw	a1,a3,-35
    8020060c:	0ff5f593          	zext.b	a1,a1
    80200610:	02bb6663          	bltu	s6,a1,8020063c <vprintfmt+0x98>
    80200614:	058a                	slli	a1,a1,0x2
    80200616:	95d6                	add	a1,a1,s5
    80200618:	4198                	lw	a4,0(a1)
    8020061a:	9756                	add	a4,a4,s5
    8020061c:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020061e:	70e6                	ld	ra,120(sp)
    80200620:	7446                	ld	s0,112(sp)
    80200622:	74a6                	ld	s1,104(sp)
    80200624:	7906                	ld	s2,96(sp)
    80200626:	69e6                	ld	s3,88(sp)
    80200628:	6a46                	ld	s4,80(sp)
    8020062a:	6aa6                	ld	s5,72(sp)
    8020062c:	6b06                	ld	s6,64(sp)
    8020062e:	7be2                	ld	s7,56(sp)
    80200630:	7c42                	ld	s8,48(sp)
    80200632:	7ca2                	ld	s9,40(sp)
    80200634:	7d02                	ld	s10,32(sp)
    80200636:	6de2                	ld	s11,24(sp)
    80200638:	6109                	addi	sp,sp,128
    8020063a:	8082                	ret
            putch('%', putdat);
    8020063c:	85a6                	mv	a1,s1
    8020063e:	02500513          	li	a0,37
    80200642:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200644:	fff44703          	lbu	a4,-1(s0)
    80200648:	02500793          	li	a5,37
    8020064c:	8c22                	mv	s8,s0
    8020064e:	f8f705e3          	beq	a4,a5,802005d8 <vprintfmt+0x34>
    80200652:	02500713          	li	a4,37
    80200656:	ffec4783          	lbu	a5,-2(s8)
    8020065a:	1c7d                	addi	s8,s8,-1
    8020065c:	fee79de3          	bne	a5,a4,80200656 <vprintfmt+0xb2>
    80200660:	bfa5                	j	802005d8 <vprintfmt+0x34>
                ch = *fmt;
    80200662:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
    80200666:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
    80200668:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
    8020066c:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
    80200670:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
    80200674:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
    80200676:	02b76563          	bltu	a4,a1,802006a0 <vprintfmt+0xfc>
    8020067a:	4525                	li	a0,9
                ch = *fmt;
    8020067c:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
    80200680:	002d171b          	slliw	a4,s10,0x2
    80200684:	01a7073b          	addw	a4,a4,s10
    80200688:	0017171b          	slliw	a4,a4,0x1
    8020068c:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
    8020068e:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
    80200692:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200694:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
    80200698:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
    8020069c:	feb570e3          	bgeu	a0,a1,8020067c <vprintfmt+0xd8>
            if (width < 0)
    802006a0:	f60cd0e3          	bgez	s9,80200600 <vprintfmt+0x5c>
                width = precision, precision = -1;
    802006a4:	8cea                	mv	s9,s10
    802006a6:	5d7d                	li	s10,-1
    802006a8:	bfa1                	j	80200600 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
    802006aa:	8db6                	mv	s11,a3
    802006ac:	8462                	mv	s0,s8
    802006ae:	bf89                	j	80200600 <vprintfmt+0x5c>
    802006b0:	8462                	mv	s0,s8
            altflag = 1;
    802006b2:	4b85                	li	s7,1
            goto reswitch;
    802006b4:	b7b1                	j	80200600 <vprintfmt+0x5c>
    if (lflag >= 2) {
    802006b6:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802006b8:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    802006bc:	00c7c463          	blt	a5,a2,802006c4 <vprintfmt+0x120>
    else if (lflag) {
    802006c0:	1a060163          	beqz	a2,80200862 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
    802006c4:	000a3603          	ld	a2,0(s4)
    802006c8:	46c1                	li	a3,16
    802006ca:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
    802006cc:	000d879b          	sext.w	a5,s11
    802006d0:	8766                	mv	a4,s9
    802006d2:	85a6                	mv	a1,s1
    802006d4:	854a                	mv	a0,s2
    802006d6:	e61ff0ef          	jal	80200536 <printnum>
            break;
    802006da:	bdfd                	j	802005d8 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
    802006dc:	000a2503          	lw	a0,0(s4)
    802006e0:	85a6                	mv	a1,s1
    802006e2:	0a21                	addi	s4,s4,8
    802006e4:	9902                	jalr	s2
            break;
    802006e6:	bdcd                	j	802005d8 <vprintfmt+0x34>
    if (lflag >= 2) {
    802006e8:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802006ea:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    802006ee:	00c7c463          	blt	a5,a2,802006f6 <vprintfmt+0x152>
    else if (lflag) {
    802006f2:	16060363          	beqz	a2,80200858 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
    802006f6:	000a3603          	ld	a2,0(s4)
    802006fa:	46a9                	li	a3,10
    802006fc:	8a3a                	mv	s4,a4
    802006fe:	b7f9                	j	802006cc <vprintfmt+0x128>
            putch('0', putdat);
    80200700:	85a6                	mv	a1,s1
    80200702:	03000513          	li	a0,48
    80200706:	9902                	jalr	s2
            putch('x', putdat);
    80200708:	85a6                	mv	a1,s1
    8020070a:	07800513          	li	a0,120
    8020070e:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200710:	000a3603          	ld	a2,0(s4)
            goto number;
    80200714:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200716:	0a21                	addi	s4,s4,8
            goto number;
    80200718:	bf55                	j	802006cc <vprintfmt+0x128>
            putch(ch, putdat);
    8020071a:	85a6                	mv	a1,s1
    8020071c:	02500513          	li	a0,37
    80200720:	9902                	jalr	s2
            break;
    80200722:	bd5d                	j	802005d8 <vprintfmt+0x34>
            precision = va_arg(ap, int);
    80200724:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200728:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
    8020072a:	0a21                	addi	s4,s4,8
            goto process_precision;
    8020072c:	bf95                	j	802006a0 <vprintfmt+0xfc>
    if (lflag >= 2) {
    8020072e:	4785                	li	a5,1
            precision = va_arg(ap, int);
    80200730:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    80200734:	00c7c463          	blt	a5,a2,8020073c <vprintfmt+0x198>
    else if (lflag) {
    80200738:	10060b63          	beqz	a2,8020084e <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
    8020073c:	000a3603          	ld	a2,0(s4)
    80200740:	46a1                	li	a3,8
    80200742:	8a3a                	mv	s4,a4
    80200744:	b761                	j	802006cc <vprintfmt+0x128>
            if (width < 0)
    80200746:	fffcc793          	not	a5,s9
    8020074a:	97fd                	srai	a5,a5,0x3f
    8020074c:	00fcf7b3          	and	a5,s9,a5
    80200750:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
    80200754:	8462                	mv	s0,s8
            goto reswitch;
    80200756:	b56d                	j	80200600 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200758:	000a3403          	ld	s0,0(s4)
    8020075c:	008a0793          	addi	a5,s4,8
    80200760:	e43e                	sd	a5,8(sp)
    80200762:	12040063          	beqz	s0,80200882 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
    80200766:	0d905963          	blez	s9,80200838 <vprintfmt+0x294>
    8020076a:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020076e:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
    80200772:	12fd9763          	bne	s11,a5,802008a0 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200776:	00044783          	lbu	a5,0(s0)
    8020077a:	0007851b          	sext.w	a0,a5
    8020077e:	cb9d                	beqz	a5,802007b4 <vprintfmt+0x210>
    80200780:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200782:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200786:	000d4563          	bltz	s10,80200790 <vprintfmt+0x1ec>
    8020078a:	3d7d                	addiw	s10,s10,-1
    8020078c:	028d0263          	beq	s10,s0,802007b0 <vprintfmt+0x20c>
                    putch('?', putdat);
    80200790:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200792:	0c0b8d63          	beqz	s7,8020086c <vprintfmt+0x2c8>
    80200796:	3781                	addiw	a5,a5,-32
    80200798:	0cfdfa63          	bgeu	s11,a5,8020086c <vprintfmt+0x2c8>
                    putch('?', putdat);
    8020079c:	03f00513          	li	a0,63
    802007a0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007a2:	000a4783          	lbu	a5,0(s4)
    802007a6:	3cfd                	addiw	s9,s9,-1
    802007a8:	0a05                	addi	s4,s4,1
    802007aa:	0007851b          	sext.w	a0,a5
    802007ae:	ffe1                	bnez	a5,80200786 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
    802007b0:	01905963          	blez	s9,802007c2 <vprintfmt+0x21e>
                putch(' ', putdat);
    802007b4:	85a6                	mv	a1,s1
    802007b6:	02000513          	li	a0,32
            for (; width > 0; width --) {
    802007ba:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
    802007bc:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007be:	fe0c9be3          	bnez	s9,802007b4 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007c2:	6a22                	ld	s4,8(sp)
    802007c4:	bd11                	j	802005d8 <vprintfmt+0x34>
    if (lflag >= 2) {
    802007c6:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802007c8:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
    802007cc:	00c7c363          	blt	a5,a2,802007d2 <vprintfmt+0x22e>
    else if (lflag) {
    802007d0:	ce25                	beqz	a2,80200848 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
    802007d2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    802007d6:	08044d63          	bltz	s0,80200870 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
    802007da:	8622                	mv	a2,s0
    802007dc:	8a5e                	mv	s4,s7
    802007de:	46a9                	li	a3,10
    802007e0:	b5f5                	j	802006cc <vprintfmt+0x128>
            if (err < 0) {
    802007e2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007e6:	4619                	li	a2,6
            if (err < 0) {
    802007e8:	41f7d71b          	sraiw	a4,a5,0x1f
    802007ec:	8fb9                	xor	a5,a5,a4
    802007ee:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007f2:	02d64663          	blt	a2,a3,8020081e <vprintfmt+0x27a>
    802007f6:	00369713          	slli	a4,a3,0x3
    802007fa:	00001797          	auipc	a5,0x1
    802007fe:	92678793          	addi	a5,a5,-1754 # 80201120 <error_string>
    80200802:	97ba                	add	a5,a5,a4
    80200804:	639c                	ld	a5,0(a5)
    80200806:	cf81                	beqz	a5,8020081e <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
    80200808:	86be                	mv	a3,a5
    8020080a:	00000617          	auipc	a2,0x0
    8020080e:	70660613          	addi	a2,a2,1798 # 80200f10 <etext+0x576>
    80200812:	85a6                	mv	a1,s1
    80200814:	854a                	mv	a0,s2
    80200816:	0e8000ef          	jal	802008fe <printfmt>
            err = va_arg(ap, int);
    8020081a:	0a21                	addi	s4,s4,8
    8020081c:	bb75                	j	802005d8 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
    8020081e:	00000617          	auipc	a2,0x0
    80200822:	6e260613          	addi	a2,a2,1762 # 80200f00 <etext+0x566>
    80200826:	85a6                	mv	a1,s1
    80200828:	854a                	mv	a0,s2
    8020082a:	0d4000ef          	jal	802008fe <printfmt>
            err = va_arg(ap, int);
    8020082e:	0a21                	addi	s4,s4,8
    80200830:	b365                	j	802005d8 <vprintfmt+0x34>
            lflag ++;
    80200832:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200834:	8462                	mv	s0,s8
            goto reswitch;
    80200836:	b3e9                	j	80200600 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200838:	00044783          	lbu	a5,0(s0)
    8020083c:	0007851b          	sext.w	a0,a5
    80200840:	d3c9                	beqz	a5,802007c2 <vprintfmt+0x21e>
    80200842:	00140a13          	addi	s4,s0,1
    80200846:	bf2d                	j	80200780 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
    80200848:	000a2403          	lw	s0,0(s4)
    8020084c:	b769                	j	802007d6 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
    8020084e:	000a6603          	lwu	a2,0(s4)
    80200852:	46a1                	li	a3,8
    80200854:	8a3a                	mv	s4,a4
    80200856:	bd9d                	j	802006cc <vprintfmt+0x128>
    80200858:	000a6603          	lwu	a2,0(s4)
    8020085c:	46a9                	li	a3,10
    8020085e:	8a3a                	mv	s4,a4
    80200860:	b5b5                	j	802006cc <vprintfmt+0x128>
    80200862:	000a6603          	lwu	a2,0(s4)
    80200866:	46c1                	li	a3,16
    80200868:	8a3a                	mv	s4,a4
    8020086a:	b58d                	j	802006cc <vprintfmt+0x128>
                    putch(ch, putdat);
    8020086c:	9902                	jalr	s2
    8020086e:	bf15                	j	802007a2 <vprintfmt+0x1fe>
                putch('-', putdat);
    80200870:	85a6                	mv	a1,s1
    80200872:	02d00513          	li	a0,45
    80200876:	9902                	jalr	s2
                num = -(long long)num;
    80200878:	40800633          	neg	a2,s0
    8020087c:	8a5e                	mv	s4,s7
    8020087e:	46a9                	li	a3,10
    80200880:	b5b1                	j	802006cc <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
    80200882:	01905663          	blez	s9,8020088e <vprintfmt+0x2ea>
    80200886:	02d00793          	li	a5,45
    8020088a:	04fd9263          	bne	s11,a5,802008ce <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020088e:	02800793          	li	a5,40
    80200892:	00000a17          	auipc	s4,0x0
    80200896:	667a0a13          	addi	s4,s4,1639 # 80200ef9 <etext+0x55f>
    8020089a:	02800513          	li	a0,40
    8020089e:	b5cd                	j	80200780 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008a0:	85ea                	mv	a1,s10
    802008a2:	8522                	mv	a0,s0
    802008a4:	0c8000ef          	jal	8020096c <strnlen>
    802008a8:	40ac8cbb          	subw	s9,s9,a0
    802008ac:	01905963          	blez	s9,802008be <vprintfmt+0x31a>
                    putch(padc, putdat);
    802008b0:	2d81                	sext.w	s11,s11
    802008b2:	85a6                	mv	a1,s1
    802008b4:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008b6:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
    802008b8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008ba:	fe0c9ce3          	bnez	s9,802008b2 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008be:	00044783          	lbu	a5,0(s0)
    802008c2:	0007851b          	sext.w	a0,a5
    802008c6:	ea079de3          	bnez	a5,80200780 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
    802008ca:	6a22                	ld	s4,8(sp)
    802008cc:	b331                	j	802005d8 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008ce:	85ea                	mv	a1,s10
    802008d0:	00000517          	auipc	a0,0x0
    802008d4:	62850513          	addi	a0,a0,1576 # 80200ef8 <etext+0x55e>
    802008d8:	094000ef          	jal	8020096c <strnlen>
    802008dc:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
    802008e0:	00000417          	auipc	s0,0x0
    802008e4:	61840413          	addi	s0,s0,1560 # 80200ef8 <etext+0x55e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008e8:	00000a17          	auipc	s4,0x0
    802008ec:	611a0a13          	addi	s4,s4,1553 # 80200ef9 <etext+0x55f>
    802008f0:	02800793          	li	a5,40
    802008f4:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008f8:	fb904ce3          	bgtz	s9,802008b0 <vprintfmt+0x30c>
    802008fc:	b551                	j	80200780 <vprintfmt+0x1dc>

00000000802008fe <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802008fe:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200900:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200904:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200906:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200908:	ec06                	sd	ra,24(sp)
    8020090a:	f83a                	sd	a4,48(sp)
    8020090c:	fc3e                	sd	a5,56(sp)
    8020090e:	e0c2                	sd	a6,64(sp)
    80200910:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200912:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200914:	c91ff0ef          	jal	802005a4 <vprintfmt>
}
    80200918:	60e2                	ld	ra,24(sp)
    8020091a:	6161                	addi	sp,sp,80
    8020091c:	8082                	ret

000000008020091e <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    8020091e:	4781                	li	a5,0
    80200920:	00003717          	auipc	a4,0x3
    80200924:	6e873703          	ld	a4,1768(a4) # 80204008 <SBI_CONSOLE_PUTCHAR>
    80200928:	88ba                	mv	a7,a4
    8020092a:	852a                	mv	a0,a0
    8020092c:	85be                	mv	a1,a5
    8020092e:	863e                	mv	a2,a5
    80200930:	00000073          	ecall
    80200934:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200936:	8082                	ret

0000000080200938 <sbi_set_timer>:
    __asm__ volatile (
    80200938:	4781                	li	a5,0
    8020093a:	00003717          	auipc	a4,0x3
    8020093e:	6e673703          	ld	a4,1766(a4) # 80204020 <SBI_SET_TIMER>
    80200942:	88ba                	mv	a7,a4
    80200944:	852a                	mv	a0,a0
    80200946:	85be                	mv	a1,a5
    80200948:	863e                	mv	a2,a5
    8020094a:	00000073          	ecall
    8020094e:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200950:	8082                	ret

0000000080200952 <sbi_shutdown>:
    __asm__ volatile (
    80200952:	4781                	li	a5,0
    80200954:	00003717          	auipc	a4,0x3
    80200958:	6ac73703          	ld	a4,1708(a4) # 80204000 <SBI_SHUTDOWN>
    8020095c:	88ba                	mv	a7,a4
    8020095e:	853e                	mv	a0,a5
    80200960:	85be                	mv	a1,a5
    80200962:	863e                	mv	a2,a5
    80200964:	00000073          	ecall
    80200968:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    8020096a:	8082                	ret

000000008020096c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    8020096c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    8020096e:	e589                	bnez	a1,80200978 <strnlen+0xc>
    80200970:	a811                	j	80200984 <strnlen+0x18>
        cnt ++;
    80200972:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200974:	00f58863          	beq	a1,a5,80200984 <strnlen+0x18>
    80200978:	00f50733          	add	a4,a0,a5
    8020097c:	00074703          	lbu	a4,0(a4)
    80200980:	fb6d                	bnez	a4,80200972 <strnlen+0x6>
    80200982:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200984:	852e                	mv	a0,a1
    80200986:	8082                	ret

0000000080200988 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200988:	ca01                	beqz	a2,80200998 <memset+0x10>
    8020098a:	962a                	add	a2,a2,a0
    char *p = s;
    8020098c:	87aa                	mv	a5,a0
        *p ++ = c;
    8020098e:	0785                	addi	a5,a5,1
    80200990:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200994:	fef61de3          	bne	a2,a5,8020098e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200998:	8082                	ret
