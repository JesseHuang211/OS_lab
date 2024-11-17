
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0211570 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc0208ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	4a0040ef          	jal	ffffffffc02044ea <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	4ca58593          	addi	a1,a1,1226 # ffffffffc0204518 <etext+0x4>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	4e250513          	addi	a0,a0,1250 # ffffffffc0204538 <etext+0x24>
ffffffffc020005e:	05c000ef          	jal	ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	09e000ef          	jal	ffffffffc0200100 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	29b010ef          	jal	ffffffffc0201b00 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4e8000ef          	jal	ffffffffc0200552 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	702030ef          	jal	ffffffffc0203770 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	40e000ef          	jal	ffffffffc0200480 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	127020ef          	jal	ffffffffc020299c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	344000ef          	jal	ffffffffc02003be <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	388000ef          	jal	ffffffffc0200410 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	779030ef          	jal	ffffffffc0204026 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	f42e                	sd	a1,40(sp)
ffffffffc02000c2:	f832                	sd	a2,48(sp)
ffffffffc02000c4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c6:	862a                	mv	a2,a0
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	00000517          	auipc	a0,0x0
ffffffffc02000ce:	fb650513          	addi	a0,a0,-74 # ffffffffc0200080 <cputch>
ffffffffc02000d2:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d4:	ec06                	sd	ra,24(sp)
ffffffffc02000d6:	e0ba                	sd	a4,64(sp)
ffffffffc02000d8:	e4be                	sd	a5,72(sp)
ffffffffc02000da:	e8c2                	sd	a6,80(sp)
ffffffffc02000dc:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000de:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e0:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e2:	745030ef          	jal	ffffffffc0204026 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e6:	60e2                	ld	ra,24(sp)
ffffffffc02000e8:	4512                	lw	a0,4(sp)
ffffffffc02000ea:	6125                	addi	sp,sp,96
ffffffffc02000ec:	8082                	ret

ffffffffc02000ee <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ee:	a60d                	j	ffffffffc0200410 <cons_putc>

ffffffffc02000f0 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f0:	1141                	addi	sp,sp,-16
ffffffffc02000f2:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f4:	350000ef          	jal	ffffffffc0200444 <cons_getc>
ffffffffc02000f8:	dd75                	beqz	a0,ffffffffc02000f4 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fa:	60a2                	ld	ra,8(sp)
ffffffffc02000fc:	0141                	addi	sp,sp,16
ffffffffc02000fe:	8082                	ret

ffffffffc0200100 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200100:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200102:	00004517          	auipc	a0,0x4
ffffffffc0200106:	43e50513          	addi	a0,a0,1086 # ffffffffc0204540 <etext+0x2c>
void print_kerninfo(void) {
ffffffffc020010a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010c:	fafff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200110:	00000597          	auipc	a1,0x0
ffffffffc0200114:	f2258593          	addi	a1,a1,-222 # ffffffffc0200032 <kern_init>
ffffffffc0200118:	00004517          	auipc	a0,0x4
ffffffffc020011c:	44850513          	addi	a0,a0,1096 # ffffffffc0204560 <etext+0x4c>
ffffffffc0200120:	f9bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200124:	00004597          	auipc	a1,0x4
ffffffffc0200128:	3f058593          	addi	a1,a1,1008 # ffffffffc0204514 <etext>
ffffffffc020012c:	00004517          	auipc	a0,0x4
ffffffffc0200130:	45450513          	addi	a0,a0,1108 # ffffffffc0204580 <etext+0x6c>
ffffffffc0200134:	f87ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200138:	0000a597          	auipc	a1,0xa
ffffffffc020013c:	f0858593          	addi	a1,a1,-248 # ffffffffc020a040 <ide>
ffffffffc0200140:	00004517          	auipc	a0,0x4
ffffffffc0200144:	46050513          	addi	a0,a0,1120 # ffffffffc02045a0 <etext+0x8c>
ffffffffc0200148:	f73ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014c:	00011597          	auipc	a1,0x11
ffffffffc0200150:	42458593          	addi	a1,a1,1060 # ffffffffc0211570 <end>
ffffffffc0200154:	00004517          	auipc	a0,0x4
ffffffffc0200158:	46c50513          	addi	a0,a0,1132 # ffffffffc02045c0 <etext+0xac>
ffffffffc020015c:	f5fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200160:	00012797          	auipc	a5,0x12
ffffffffc0200164:	80f78793          	addi	a5,a5,-2033 # ffffffffc021196f <end+0x3ff>
ffffffffc0200168:	00000717          	auipc	a4,0x0
ffffffffc020016c:	eca70713          	addi	a4,a4,-310 # ffffffffc0200032 <kern_init>
ffffffffc0200170:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200172:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200176:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200178:	3ff5f593          	andi	a1,a1,1023
ffffffffc020017c:	95be                	add	a1,a1,a5
ffffffffc020017e:	85a9                	srai	a1,a1,0xa
ffffffffc0200180:	00004517          	auipc	a0,0x4
ffffffffc0200184:	46050513          	addi	a0,a0,1120 # ffffffffc02045e0 <etext+0xcc>
}
ffffffffc0200188:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018a:	bf05                	j	ffffffffc02000ba <cprintf>

ffffffffc020018c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020018c:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc020018e:	00004617          	auipc	a2,0x4
ffffffffc0200192:	48260613          	addi	a2,a2,1154 # ffffffffc0204610 <etext+0xfc>
ffffffffc0200196:	04e00593          	li	a1,78
ffffffffc020019a:	00004517          	auipc	a0,0x4
ffffffffc020019e:	48e50513          	addi	a0,a0,1166 # ffffffffc0204628 <etext+0x114>
void print_stackframe(void) {
ffffffffc02001a2:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a4:	1bc000ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02001a8 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001a8:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001aa:	00004617          	auipc	a2,0x4
ffffffffc02001ae:	49660613          	addi	a2,a2,1174 # ffffffffc0204640 <etext+0x12c>
ffffffffc02001b2:	00004597          	auipc	a1,0x4
ffffffffc02001b6:	4ae58593          	addi	a1,a1,1198 # ffffffffc0204660 <etext+0x14c>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	4ae50513          	addi	a0,a0,1198 # ffffffffc0204668 <etext+0x154>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c2:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c4:	ef7ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02001c8:	00004617          	auipc	a2,0x4
ffffffffc02001cc:	4b060613          	addi	a2,a2,1200 # ffffffffc0204678 <etext+0x164>
ffffffffc02001d0:	00004597          	auipc	a1,0x4
ffffffffc02001d4:	4d058593          	addi	a1,a1,1232 # ffffffffc02046a0 <etext+0x18c>
ffffffffc02001d8:	00004517          	auipc	a0,0x4
ffffffffc02001dc:	49050513          	addi	a0,a0,1168 # ffffffffc0204668 <etext+0x154>
ffffffffc02001e0:	edbff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02001e4:	00004617          	auipc	a2,0x4
ffffffffc02001e8:	4cc60613          	addi	a2,a2,1228 # ffffffffc02046b0 <etext+0x19c>
ffffffffc02001ec:	00004597          	auipc	a1,0x4
ffffffffc02001f0:	4e458593          	addi	a1,a1,1252 # ffffffffc02046d0 <etext+0x1bc>
ffffffffc02001f4:	00004517          	auipc	a0,0x4
ffffffffc02001f8:	47450513          	addi	a0,a0,1140 # ffffffffc0204668 <etext+0x154>
ffffffffc02001fc:	ebfff0ef          	jal	ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200200:	60a2                	ld	ra,8(sp)
ffffffffc0200202:	4501                	li	a0,0
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
ffffffffc020020a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020020c:	ef5ff0ef          	jal	ffffffffc0200100 <print_kerninfo>
    return 0;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	4501                	li	a0,0
ffffffffc0200214:	0141                	addi	sp,sp,16
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200218:	1141                	addi	sp,sp,-16
ffffffffc020021a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020021c:	f71ff0ef          	jal	ffffffffc020018c <print_stackframe>
    return 0;
}
ffffffffc0200220:	60a2                	ld	ra,8(sp)
ffffffffc0200222:	4501                	li	a0,0
ffffffffc0200224:	0141                	addi	sp,sp,16
ffffffffc0200226:	8082                	ret

ffffffffc0200228 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200228:	7115                	addi	sp,sp,-224
ffffffffc020022a:	f15a                	sd	s6,160(sp)
ffffffffc020022c:	8b2a                	mv	s6,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020022e:	00004517          	auipc	a0,0x4
ffffffffc0200232:	4b250513          	addi	a0,a0,1202 # ffffffffc02046e0 <etext+0x1cc>
kmonitor(struct trapframe *tf) {
ffffffffc0200236:	ed86                	sd	ra,216(sp)
ffffffffc0200238:	e9a2                	sd	s0,208(sp)
ffffffffc020023a:	e5a6                	sd	s1,200(sp)
ffffffffc020023c:	e1ca                	sd	s2,192(sp)
ffffffffc020023e:	fd4e                	sd	s3,184(sp)
ffffffffc0200240:	f952                	sd	s4,176(sp)
ffffffffc0200242:	f556                	sd	s5,168(sp)
ffffffffc0200244:	ed5e                	sd	s7,152(sp)
ffffffffc0200246:	e962                	sd	s8,144(sp)
ffffffffc0200248:	e566                	sd	s9,136(sp)
ffffffffc020024a:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020024c:	e6fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200250:	00004517          	auipc	a0,0x4
ffffffffc0200254:	4b850513          	addi	a0,a0,1208 # ffffffffc0204708 <etext+0x1f4>
ffffffffc0200258:	e63ff0ef          	jal	ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc020025c:	000b0563          	beqz	s6,ffffffffc0200266 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200260:	855a                	mv	a0,s6
ffffffffc0200262:	4da000ef          	jal	ffffffffc020073c <print_trapframe>
ffffffffc0200266:	00006c17          	auipc	s8,0x6
ffffffffc020026a:	e4ac0c13          	addi	s8,s8,-438 # ffffffffc02060b0 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc020026e:	00006917          	auipc	s2,0x6
ffffffffc0200272:	82290913          	addi	s2,s2,-2014 # ffffffffc0205a90 <etext+0x157c>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200276:	00004497          	auipc	s1,0x4
ffffffffc020027a:	4ba48493          	addi	s1,s1,1210 # ffffffffc0204730 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc020027e:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200280:	00004a97          	auipc	s5,0x4
ffffffffc0200284:	4b8a8a93          	addi	s5,s5,1208 # ffffffffc0204738 <etext+0x224>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200288:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020028a:	00004b97          	auipc	s7,0x4
ffffffffc020028e:	4ceb8b93          	addi	s7,s7,1230 # ffffffffc0204758 <etext+0x244>
        if ((buf = readline("")) != NULL) {
ffffffffc0200292:	854a                	mv	a0,s2
ffffffffc0200294:	10c040ef          	jal	ffffffffc02043a0 <readline>
ffffffffc0200298:	842a                	mv	s0,a0
ffffffffc020029a:	dd65                	beqz	a0,ffffffffc0200292 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020029c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a0:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a2:	e59d                	bnez	a1,ffffffffc02002d0 <kmonitor+0xa8>
    if (argc == 0) {
ffffffffc02002a4:	fe0c87e3          	beqz	s9,ffffffffc0200292 <kmonitor+0x6a>
ffffffffc02002a8:	00006d17          	auipc	s10,0x6
ffffffffc02002ac:	e08d0d13          	addi	s10,s10,-504 # ffffffffc02060b0 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002b2:	6582                	ld	a1,0(sp)
ffffffffc02002b4:	000d3503          	ld	a0,0(s10)
ffffffffc02002b8:	1e4040ef          	jal	ffffffffc020449c <strcmp>
ffffffffc02002bc:	c53d                	beqz	a0,ffffffffc020032a <kmonitor+0x102>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002be:	2405                	addiw	s0,s0,1
ffffffffc02002c0:	0d61                	addi	s10,s10,24
ffffffffc02002c2:	ff4418e3          	bne	s0,s4,ffffffffc02002b2 <kmonitor+0x8a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002c6:	6582                	ld	a1,0(sp)
ffffffffc02002c8:	855e                	mv	a0,s7
ffffffffc02002ca:	df1ff0ef          	jal	ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02002ce:	b7d1                	j	ffffffffc0200292 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d0:	8526                	mv	a0,s1
ffffffffc02002d2:	202040ef          	jal	ffffffffc02044d4 <strchr>
ffffffffc02002d6:	c901                	beqz	a0,ffffffffc02002e6 <kmonitor+0xbe>
ffffffffc02002d8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02002dc:	00040023          	sb	zero,0(s0)
ffffffffc02002e0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e2:	d1e9                	beqz	a1,ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc02002e4:	b7f5                	j	ffffffffc02002d0 <kmonitor+0xa8>
        if (*buf == '\0') {
ffffffffc02002e6:	00044783          	lbu	a5,0(s0)
ffffffffc02002ea:	dfcd                	beqz	a5,ffffffffc02002a4 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ec:	033c8a63          	beq	s9,s3,ffffffffc0200320 <kmonitor+0xf8>
        argv[argc ++] = buf;
ffffffffc02002f0:	003c9793          	slli	a5,s9,0x3
ffffffffc02002f4:	08078793          	addi	a5,a5,128
ffffffffc02002f8:	978a                	add	a5,a5,sp
ffffffffc02002fa:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002fe:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200302:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200304:	e591                	bnez	a1,ffffffffc0200310 <kmonitor+0xe8>
ffffffffc0200306:	bf79                	j	ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc0200308:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020030c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020030e:	d9d9                	beqz	a1,ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc0200310:	8526                	mv	a0,s1
ffffffffc0200312:	1c2040ef          	jal	ffffffffc02044d4 <strchr>
ffffffffc0200316:	d96d                	beqz	a0,ffffffffc0200308 <kmonitor+0xe0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00044583          	lbu	a1,0(s0)
ffffffffc020031c:	d5c1                	beqz	a1,ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc020031e:	bf4d                	j	ffffffffc02002d0 <kmonitor+0xa8>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200320:	45c1                	li	a1,16
ffffffffc0200322:	8556                	mv	a0,s5
ffffffffc0200324:	d97ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0200328:	b7e1                	j	ffffffffc02002f0 <kmonitor+0xc8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020032a:	00141793          	slli	a5,s0,0x1
ffffffffc020032e:	97a2                	add	a5,a5,s0
ffffffffc0200330:	078e                	slli	a5,a5,0x3
ffffffffc0200332:	97e2                	add	a5,a5,s8
ffffffffc0200334:	6b9c                	ld	a5,16(a5)
ffffffffc0200336:	865a                	mv	a2,s6
ffffffffc0200338:	002c                	addi	a1,sp,8
ffffffffc020033a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020033e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200340:	f40559e3          	bgez	a0,ffffffffc0200292 <kmonitor+0x6a>
}
ffffffffc0200344:	60ee                	ld	ra,216(sp)
ffffffffc0200346:	644e                	ld	s0,208(sp)
ffffffffc0200348:	64ae                	ld	s1,200(sp)
ffffffffc020034a:	690e                	ld	s2,192(sp)
ffffffffc020034c:	79ea                	ld	s3,184(sp)
ffffffffc020034e:	7a4a                	ld	s4,176(sp)
ffffffffc0200350:	7aaa                	ld	s5,168(sp)
ffffffffc0200352:	7b0a                	ld	s6,160(sp)
ffffffffc0200354:	6bea                	ld	s7,152(sp)
ffffffffc0200356:	6c4a                	ld	s8,144(sp)
ffffffffc0200358:	6caa                	ld	s9,136(sp)
ffffffffc020035a:	6d0a                	ld	s10,128(sp)
ffffffffc020035c:	612d                	addi	sp,sp,224
ffffffffc020035e:	8082                	ret

ffffffffc0200360 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200360:	00011317          	auipc	t1,0x11
ffffffffc0200364:	19830313          	addi	t1,t1,408 # ffffffffc02114f8 <is_panic>
ffffffffc0200368:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020036c:	715d                	addi	sp,sp,-80
ffffffffc020036e:	ec06                	sd	ra,24(sp)
ffffffffc0200370:	f436                	sd	a3,40(sp)
ffffffffc0200372:	f83a                	sd	a4,48(sp)
ffffffffc0200374:	fc3e                	sd	a5,56(sp)
ffffffffc0200376:	e0c2                	sd	a6,64(sp)
ffffffffc0200378:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020037a:	020e1c63          	bnez	t3,ffffffffc02003b2 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020037e:	4785                	li	a5,1
ffffffffc0200380:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	103c                	addi	a5,sp,40
ffffffffc0200388:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020038a:	862e                	mv	a2,a1
ffffffffc020038c:	85aa                	mv	a1,a0
ffffffffc020038e:	00004517          	auipc	a0,0x4
ffffffffc0200392:	3e250513          	addi	a0,a0,994 # ffffffffc0204770 <etext+0x25c>
    va_start(ap, fmt);
ffffffffc0200396:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200398:	d23ff0ef          	jal	ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020039c:	65a2                	ld	a1,8(sp)
ffffffffc020039e:	8522                	mv	a0,s0
ffffffffc02003a0:	cfbff0ef          	jal	ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003a4:	00005517          	auipc	a0,0x5
ffffffffc02003a8:	23c50513          	addi	a0,a0,572 # ffffffffc02055e0 <etext+0x10cc>
ffffffffc02003ac:	d0fff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02003b0:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003b2:	12a000ef          	jal	ffffffffc02004dc <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003b6:	4501                	li	a0,0
ffffffffc02003b8:	e71ff0ef          	jal	ffffffffc0200228 <kmonitor>
    while (1) {
ffffffffc02003bc:	bfed                	j	ffffffffc02003b6 <__panic+0x56>

ffffffffc02003be <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003be:	67e1                	lui	a5,0x18
ffffffffc02003c0:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003c4:	00011717          	auipc	a4,0x11
ffffffffc02003c8:	12f73e23          	sd	a5,316(a4) # ffffffffc0211500 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003cc:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003d0:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003d2:	953e                	add	a0,a0,a5
ffffffffc02003d4:	4601                	li	a2,0
ffffffffc02003d6:	4881                	li	a7,0
ffffffffc02003d8:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003dc:	02000793          	li	a5,32
ffffffffc02003e0:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003e4:	00004517          	auipc	a0,0x4
ffffffffc02003e8:	3ac50513          	addi	a0,a0,940 # ffffffffc0204790 <etext+0x27c>
    ticks = 0;
ffffffffc02003ec:	00011797          	auipc	a5,0x11
ffffffffc02003f0:	1007be23          	sd	zero,284(a5) # ffffffffc0211508 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f4:	b1d9                	j	ffffffffc02000ba <cprintf>

ffffffffc02003f6 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003f6:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003fa:	00011797          	auipc	a5,0x11
ffffffffc02003fe:	1067b783          	ld	a5,262(a5) # ffffffffc0211500 <timebase>
ffffffffc0200402:	953e                	add	a0,a0,a5
ffffffffc0200404:	4581                	li	a1,0
ffffffffc0200406:	4601                	li	a2,0
ffffffffc0200408:	4881                	li	a7,0
ffffffffc020040a:	00000073          	ecall
ffffffffc020040e:	8082                	ret

ffffffffc0200410 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200410:	100027f3          	csrr	a5,sstatus
ffffffffc0200414:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200416:	0ff57513          	zext.b	a0,a0
ffffffffc020041a:	e799                	bnez	a5,ffffffffc0200428 <cons_putc+0x18>
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	4885                	li	a7,1
ffffffffc0200422:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200426:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200428:	1101                	addi	sp,sp,-32
ffffffffc020042a:	ec06                	sd	ra,24(sp)
ffffffffc020042c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020042e:	0ae000ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0200432:	6522                	ld	a0,8(sp)
ffffffffc0200434:	4581                	li	a1,0
ffffffffc0200436:	4601                	li	a2,0
ffffffffc0200438:	4885                	li	a7,1
ffffffffc020043a:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020043e:	60e2                	ld	ra,24(sp)
ffffffffc0200440:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200442:	a851                	j	ffffffffc02004d6 <intr_enable>

ffffffffc0200444 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200444:	100027f3          	csrr	a5,sstatus
ffffffffc0200448:	8b89                	andi	a5,a5,2
ffffffffc020044a:	eb89                	bnez	a5,ffffffffc020045c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020044c:	4501                	li	a0,0
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4889                	li	a7,2
ffffffffc0200454:	00000073          	ecall
ffffffffc0200458:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020045a:	8082                	ret
int cons_getc(void) {
ffffffffc020045c:	1101                	addi	sp,sp,-32
ffffffffc020045e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200460:	07c000ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0200464:	4501                	li	a0,0
ffffffffc0200466:	4581                	li	a1,0
ffffffffc0200468:	4601                	li	a2,0
ffffffffc020046a:	4889                	li	a7,2
ffffffffc020046c:	00000073          	ecall
ffffffffc0200470:	2501                	sext.w	a0,a0
ffffffffc0200472:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200474:	062000ef          	jal	ffffffffc02004d6 <intr_enable>
}
ffffffffc0200478:	60e2                	ld	ra,24(sp)
ffffffffc020047a:	6522                	ld	a0,8(sp)
ffffffffc020047c:	6105                	addi	sp,sp,32
ffffffffc020047e:	8082                	ret

ffffffffc0200480 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200482:	00253513          	sltiu	a0,a0,2
ffffffffc0200486:	8082                	ret

ffffffffc0200488 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200488:	03800513          	li	a0,56
ffffffffc020048c:	8082                	ret

ffffffffc020048e <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020048e:	0000a797          	auipc	a5,0xa
ffffffffc0200492:	bb278793          	addi	a5,a5,-1102 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200496:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020049a:	1141                	addi	sp,sp,-16
ffffffffc020049c:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020049e:	95be                	add	a1,a1,a5
ffffffffc02004a0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004a4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a6:	056040ef          	jal	ffffffffc02044fc <memcpy>
    return 0;
}
ffffffffc02004aa:	60a2                	ld	ra,8(sp)
ffffffffc02004ac:	4501                	li	a0,0
ffffffffc02004ae:	0141                	addi	sp,sp,16
ffffffffc02004b0:	8082                	ret

ffffffffc02004b2 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004b2:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004b6:	0000a517          	auipc	a0,0xa
ffffffffc02004ba:	b8a50513          	addi	a0,a0,-1142 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004be:	1141                	addi	sp,sp,-16
ffffffffc02004c0:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c2:	953e                	add	a0,a0,a5
ffffffffc02004c4:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004c8:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ca:	032040ef          	jal	ffffffffc02044fc <memcpy>
    return 0;
}
ffffffffc02004ce:	60a2                	ld	ra,8(sp)
ffffffffc02004d0:	4501                	li	a0,0
ffffffffc02004d2:	0141                	addi	sp,sp,16
ffffffffc02004d4:	8082                	ret

ffffffffc02004d6 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004d6:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004da:	8082                	ret

ffffffffc02004dc <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004dc:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004e0:	8082                	ret

ffffffffc02004e2 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004e2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e6:	1141                	addi	sp,sp,-16
ffffffffc02004e8:	e022                	sd	s0,0(sp)
ffffffffc02004ea:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004ec:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004f0:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f4:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004f6:	04b00613          	li	a2,75
ffffffffc02004fa:	e399                	bnez	a5,ffffffffc0200500 <pgfault_handler+0x1e>
ffffffffc02004fc:	05500613          	li	a2,85
ffffffffc0200500:	11843703          	ld	a4,280(s0)
ffffffffc0200504:	47bd                	li	a5,15
ffffffffc0200506:	05200693          	li	a3,82
ffffffffc020050a:	00f71463          	bne	a4,a5,ffffffffc0200512 <pgfault_handler+0x30>
ffffffffc020050e:	05700693          	li	a3,87
ffffffffc0200512:	00004517          	auipc	a0,0x4
ffffffffc0200516:	29e50513          	addi	a0,a0,670 # ffffffffc02047b0 <etext+0x29c>
ffffffffc020051a:	ba1ff0ef          	jal	ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020051e:	00011517          	auipc	a0,0x11
ffffffffc0200522:	04a53503          	ld	a0,74(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0200526:	c911                	beqz	a0,ffffffffc020053a <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200528:	11043603          	ld	a2,272(s0)
ffffffffc020052c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200530:	6402                	ld	s0,0(sp)
ffffffffc0200532:	60a2                	ld	ra,8(sp)
ffffffffc0200534:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200536:	0290306f          	j	ffffffffc0203d5e <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020053a:	00004617          	auipc	a2,0x4
ffffffffc020053e:	29660613          	addi	a2,a2,662 # ffffffffc02047d0 <etext+0x2bc>
ffffffffc0200542:	07800593          	li	a1,120
ffffffffc0200546:	00004517          	auipc	a0,0x4
ffffffffc020054a:	2a250513          	addi	a0,a0,674 # ffffffffc02047e8 <etext+0x2d4>
ffffffffc020054e:	e13ff0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0200552 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200552:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200556:	00000797          	auipc	a5,0x0
ffffffffc020055a:	48a78793          	addi	a5,a5,1162 # ffffffffc02009e0 <__alltraps>
ffffffffc020055e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200562:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200566:	000407b7          	lui	a5,0x40
ffffffffc020056a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020056e:	8082                	ret

ffffffffc0200570 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200570:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
ffffffffc0200574:	e022                	sd	s0,0(sp)
ffffffffc0200576:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200578:	00004517          	auipc	a0,0x4
ffffffffc020057c:	28850513          	addi	a0,a0,648 # ffffffffc0204800 <etext+0x2ec>
void print_regs(struct pushregs *gpr) {
ffffffffc0200580:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	b39ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200586:	640c                	ld	a1,8(s0)
ffffffffc0200588:	00004517          	auipc	a0,0x4
ffffffffc020058c:	29050513          	addi	a0,a0,656 # ffffffffc0204818 <etext+0x304>
ffffffffc0200590:	b2bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200594:	680c                	ld	a1,16(s0)
ffffffffc0200596:	00004517          	auipc	a0,0x4
ffffffffc020059a:	29a50513          	addi	a0,a0,666 # ffffffffc0204830 <etext+0x31c>
ffffffffc020059e:	b1dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005a2:	6c0c                	ld	a1,24(s0)
ffffffffc02005a4:	00004517          	auipc	a0,0x4
ffffffffc02005a8:	2a450513          	addi	a0,a0,676 # ffffffffc0204848 <etext+0x334>
ffffffffc02005ac:	b0fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005b0:	700c                	ld	a1,32(s0)
ffffffffc02005b2:	00004517          	auipc	a0,0x4
ffffffffc02005b6:	2ae50513          	addi	a0,a0,686 # ffffffffc0204860 <etext+0x34c>
ffffffffc02005ba:	b01ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005be:	740c                	ld	a1,40(s0)
ffffffffc02005c0:	00004517          	auipc	a0,0x4
ffffffffc02005c4:	2b850513          	addi	a0,a0,696 # ffffffffc0204878 <etext+0x364>
ffffffffc02005c8:	af3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005cc:	780c                	ld	a1,48(s0)
ffffffffc02005ce:	00004517          	auipc	a0,0x4
ffffffffc02005d2:	2c250513          	addi	a0,a0,706 # ffffffffc0204890 <etext+0x37c>
ffffffffc02005d6:	ae5ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005da:	7c0c                	ld	a1,56(s0)
ffffffffc02005dc:	00004517          	auipc	a0,0x4
ffffffffc02005e0:	2cc50513          	addi	a0,a0,716 # ffffffffc02048a8 <etext+0x394>
ffffffffc02005e4:	ad7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005e8:	602c                	ld	a1,64(s0)
ffffffffc02005ea:	00004517          	auipc	a0,0x4
ffffffffc02005ee:	2d650513          	addi	a0,a0,726 # ffffffffc02048c0 <etext+0x3ac>
ffffffffc02005f2:	ac9ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005f6:	642c                	ld	a1,72(s0)
ffffffffc02005f8:	00004517          	auipc	a0,0x4
ffffffffc02005fc:	2e050513          	addi	a0,a0,736 # ffffffffc02048d8 <etext+0x3c4>
ffffffffc0200600:	abbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200604:	682c                	ld	a1,80(s0)
ffffffffc0200606:	00004517          	auipc	a0,0x4
ffffffffc020060a:	2ea50513          	addi	a0,a0,746 # ffffffffc02048f0 <etext+0x3dc>
ffffffffc020060e:	aadff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200612:	6c2c                	ld	a1,88(s0)
ffffffffc0200614:	00004517          	auipc	a0,0x4
ffffffffc0200618:	2f450513          	addi	a0,a0,756 # ffffffffc0204908 <etext+0x3f4>
ffffffffc020061c:	a9fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200620:	702c                	ld	a1,96(s0)
ffffffffc0200622:	00004517          	auipc	a0,0x4
ffffffffc0200626:	2fe50513          	addi	a0,a0,766 # ffffffffc0204920 <etext+0x40c>
ffffffffc020062a:	a91ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020062e:	742c                	ld	a1,104(s0)
ffffffffc0200630:	00004517          	auipc	a0,0x4
ffffffffc0200634:	30850513          	addi	a0,a0,776 # ffffffffc0204938 <etext+0x424>
ffffffffc0200638:	a83ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020063c:	782c                	ld	a1,112(s0)
ffffffffc020063e:	00004517          	auipc	a0,0x4
ffffffffc0200642:	31250513          	addi	a0,a0,786 # ffffffffc0204950 <etext+0x43c>
ffffffffc0200646:	a75ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020064a:	7c2c                	ld	a1,120(s0)
ffffffffc020064c:	00004517          	auipc	a0,0x4
ffffffffc0200650:	31c50513          	addi	a0,a0,796 # ffffffffc0204968 <etext+0x454>
ffffffffc0200654:	a67ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200658:	604c                	ld	a1,128(s0)
ffffffffc020065a:	00004517          	auipc	a0,0x4
ffffffffc020065e:	32650513          	addi	a0,a0,806 # ffffffffc0204980 <etext+0x46c>
ffffffffc0200662:	a59ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200666:	644c                	ld	a1,136(s0)
ffffffffc0200668:	00004517          	auipc	a0,0x4
ffffffffc020066c:	33050513          	addi	a0,a0,816 # ffffffffc0204998 <etext+0x484>
ffffffffc0200670:	a4bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200674:	684c                	ld	a1,144(s0)
ffffffffc0200676:	00004517          	auipc	a0,0x4
ffffffffc020067a:	33a50513          	addi	a0,a0,826 # ffffffffc02049b0 <etext+0x49c>
ffffffffc020067e:	a3dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200682:	6c4c                	ld	a1,152(s0)
ffffffffc0200684:	00004517          	auipc	a0,0x4
ffffffffc0200688:	34450513          	addi	a0,a0,836 # ffffffffc02049c8 <etext+0x4b4>
ffffffffc020068c:	a2fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200690:	704c                	ld	a1,160(s0)
ffffffffc0200692:	00004517          	auipc	a0,0x4
ffffffffc0200696:	34e50513          	addi	a0,a0,846 # ffffffffc02049e0 <etext+0x4cc>
ffffffffc020069a:	a21ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020069e:	744c                	ld	a1,168(s0)
ffffffffc02006a0:	00004517          	auipc	a0,0x4
ffffffffc02006a4:	35850513          	addi	a0,a0,856 # ffffffffc02049f8 <etext+0x4e4>
ffffffffc02006a8:	a13ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006ac:	784c                	ld	a1,176(s0)
ffffffffc02006ae:	00004517          	auipc	a0,0x4
ffffffffc02006b2:	36250513          	addi	a0,a0,866 # ffffffffc0204a10 <etext+0x4fc>
ffffffffc02006b6:	a05ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006ba:	7c4c                	ld	a1,184(s0)
ffffffffc02006bc:	00004517          	auipc	a0,0x4
ffffffffc02006c0:	36c50513          	addi	a0,a0,876 # ffffffffc0204a28 <etext+0x514>
ffffffffc02006c4:	9f7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006c8:	606c                	ld	a1,192(s0)
ffffffffc02006ca:	00004517          	auipc	a0,0x4
ffffffffc02006ce:	37650513          	addi	a0,a0,886 # ffffffffc0204a40 <etext+0x52c>
ffffffffc02006d2:	9e9ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006d6:	646c                	ld	a1,200(s0)
ffffffffc02006d8:	00004517          	auipc	a0,0x4
ffffffffc02006dc:	38050513          	addi	a0,a0,896 # ffffffffc0204a58 <etext+0x544>
ffffffffc02006e0:	9dbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006e4:	686c                	ld	a1,208(s0)
ffffffffc02006e6:	00004517          	auipc	a0,0x4
ffffffffc02006ea:	38a50513          	addi	a0,a0,906 # ffffffffc0204a70 <etext+0x55c>
ffffffffc02006ee:	9cdff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006f2:	6c6c                	ld	a1,216(s0)
ffffffffc02006f4:	00004517          	auipc	a0,0x4
ffffffffc02006f8:	39450513          	addi	a0,a0,916 # ffffffffc0204a88 <etext+0x574>
ffffffffc02006fc:	9bfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200700:	706c                	ld	a1,224(s0)
ffffffffc0200702:	00004517          	auipc	a0,0x4
ffffffffc0200706:	39e50513          	addi	a0,a0,926 # ffffffffc0204aa0 <etext+0x58c>
ffffffffc020070a:	9b1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020070e:	746c                	ld	a1,232(s0)
ffffffffc0200710:	00004517          	auipc	a0,0x4
ffffffffc0200714:	3a850513          	addi	a0,a0,936 # ffffffffc0204ab8 <etext+0x5a4>
ffffffffc0200718:	9a3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020071c:	786c                	ld	a1,240(s0)
ffffffffc020071e:	00004517          	auipc	a0,0x4
ffffffffc0200722:	3b250513          	addi	a0,a0,946 # ffffffffc0204ad0 <etext+0x5bc>
ffffffffc0200726:	995ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020072a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020072c:	6402                	ld	s0,0(sp)
ffffffffc020072e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	3b850513          	addi	a0,a0,952 # ffffffffc0204ae8 <etext+0x5d4>
}
ffffffffc0200738:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073a:	b241                	j	ffffffffc02000ba <cprintf>

ffffffffc020073c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020073c:	1141                	addi	sp,sp,-16
ffffffffc020073e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200740:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200742:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200744:	00004517          	auipc	a0,0x4
ffffffffc0200748:	3bc50513          	addi	a0,a0,956 # ffffffffc0204b00 <etext+0x5ec>
void print_trapframe(struct trapframe *tf) {
ffffffffc020074c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020074e:	96dff0ef          	jal	ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200752:	8522                	mv	a0,s0
ffffffffc0200754:	e1dff0ef          	jal	ffffffffc0200570 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200758:	10043583          	ld	a1,256(s0)
ffffffffc020075c:	00004517          	auipc	a0,0x4
ffffffffc0200760:	3bc50513          	addi	a0,a0,956 # ffffffffc0204b18 <etext+0x604>
ffffffffc0200764:	957ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200768:	10843583          	ld	a1,264(s0)
ffffffffc020076c:	00004517          	auipc	a0,0x4
ffffffffc0200770:	3c450513          	addi	a0,a0,964 # ffffffffc0204b30 <etext+0x61c>
ffffffffc0200774:	947ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200778:	11043583          	ld	a1,272(s0)
ffffffffc020077c:	00004517          	auipc	a0,0x4
ffffffffc0200780:	3cc50513          	addi	a0,a0,972 # ffffffffc0204b48 <etext+0x634>
ffffffffc0200784:	937ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200788:	11843583          	ld	a1,280(s0)
}
ffffffffc020078c:	6402                	ld	s0,0(sp)
ffffffffc020078e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200790:	00004517          	auipc	a0,0x4
ffffffffc0200794:	3d050513          	addi	a0,a0,976 # ffffffffc0204b60 <etext+0x64c>
}
ffffffffc0200798:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	921ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc020079e <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc020079e:	11853783          	ld	a5,280(a0)
ffffffffc02007a2:	472d                	li	a4,11
ffffffffc02007a4:	0786                	slli	a5,a5,0x1
ffffffffc02007a6:	8385                	srli	a5,a5,0x1
ffffffffc02007a8:	06f76c63          	bltu	a4,a5,ffffffffc0200820 <interrupt_handler+0x82>
ffffffffc02007ac:	00006717          	auipc	a4,0x6
ffffffffc02007b0:	94c70713          	addi	a4,a4,-1716 # ffffffffc02060f8 <commands+0x48>
ffffffffc02007b4:	078a                	slli	a5,a5,0x2
ffffffffc02007b6:	97ba                	add	a5,a5,a4
ffffffffc02007b8:	439c                	lw	a5,0(a5)
ffffffffc02007ba:	97ba                	add	a5,a5,a4
ffffffffc02007bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007be:	00004517          	auipc	a0,0x4
ffffffffc02007c2:	41a50513          	addi	a0,a0,1050 # ffffffffc0204bd8 <etext+0x6c4>
ffffffffc02007c6:	8f5ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204bb8 <etext+0x6a4>
ffffffffc02007d2:	8e9ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	3a250513          	addi	a0,a0,930 # ffffffffc0204b78 <etext+0x664>
ffffffffc02007de:	8ddff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	3b650513          	addi	a0,a0,950 # ffffffffc0204b98 <etext+0x684>
ffffffffc02007ea:	8d1ff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007ee:	1141                	addi	sp,sp,-16
ffffffffc02007f0:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02007f2:	c05ff0ef          	jal	ffffffffc02003f6 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02007f6:	00011697          	auipc	a3,0x11
ffffffffc02007fa:	d1268693          	addi	a3,a3,-750 # ffffffffc0211508 <ticks>
ffffffffc02007fe:	629c                	ld	a5,0(a3)
ffffffffc0200800:	06400713          	li	a4,100
ffffffffc0200804:	0785                	addi	a5,a5,1 # 40001 <kern_entry-0xffffffffc01bffff>
ffffffffc0200806:	02e7f733          	remu	a4,a5,a4
ffffffffc020080a:	e29c                	sd	a5,0(a3)
ffffffffc020080c:	cb19                	beqz	a4,ffffffffc0200822 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020080e:	60a2                	ld	ra,8(sp)
ffffffffc0200810:	0141                	addi	sp,sp,16
ffffffffc0200812:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200814:	00004517          	auipc	a0,0x4
ffffffffc0200818:	3f450513          	addi	a0,a0,1012 # ffffffffc0204c08 <etext+0x6f4>
ffffffffc020081c:	89fff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200820:	bf31                	j	ffffffffc020073c <print_trapframe>
}
ffffffffc0200822:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200824:	06400593          	li	a1,100
ffffffffc0200828:	00004517          	auipc	a0,0x4
ffffffffc020082c:	3d050513          	addi	a0,a0,976 # ffffffffc0204bf8 <etext+0x6e4>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200832:	889ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200836 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200836:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020083a:	1101                	addi	sp,sp,-32
ffffffffc020083c:	e822                	sd	s0,16(sp)
ffffffffc020083e:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200840:	473d                	li	a4,15
void exception_handler(struct trapframe *tf) {
ffffffffc0200842:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200844:	14f76d63          	bltu	a4,a5,ffffffffc020099e <exception_handler+0x168>
ffffffffc0200848:	00006717          	auipc	a4,0x6
ffffffffc020084c:	8e070713          	addi	a4,a4,-1824 # ffffffffc0206128 <commands+0x78>
ffffffffc0200850:	078a                	slli	a5,a5,0x2
ffffffffc0200852:	97ba                	add	a5,a5,a4
ffffffffc0200854:	439c                	lw	a5,0(a5)
ffffffffc0200856:	97ba                	add	a5,a5,a4
ffffffffc0200858:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020085a:	00004517          	auipc	a0,0x4
ffffffffc020085e:	56e50513          	addi	a0,a0,1390 # ffffffffc0204dc8 <etext+0x8b4>
ffffffffc0200862:	e426                	sd	s1,8(sp)
ffffffffc0200864:	857ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200868:	8522                	mv	a0,s0
ffffffffc020086a:	c79ff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc020086e:	84aa                	mv	s1,a0
ffffffffc0200870:	12051c63          	bnez	a0,ffffffffc02009a8 <exception_handler+0x172>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200874:	60e2                	ld	ra,24(sp)
ffffffffc0200876:	6442                	ld	s0,16(sp)
ffffffffc0200878:	64a2                	ld	s1,8(sp)
ffffffffc020087a:	6105                	addi	sp,sp,32
ffffffffc020087c:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020087e:	00004517          	auipc	a0,0x4
ffffffffc0200882:	3aa50513          	addi	a0,a0,938 # ffffffffc0204c28 <etext+0x714>
}
ffffffffc0200886:	6442                	ld	s0,16(sp)
ffffffffc0200888:	60e2                	ld	ra,24(sp)
ffffffffc020088a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc020088c:	82fff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	3b850513          	addi	a0,a0,952 # ffffffffc0204c48 <etext+0x734>
ffffffffc0200898:	b7fd                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020089a:	00004517          	auipc	a0,0x4
ffffffffc020089e:	3ce50513          	addi	a0,a0,974 # ffffffffc0204c68 <etext+0x754>
ffffffffc02008a2:	b7d5                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	3dc50513          	addi	a0,a0,988 # ffffffffc0204c80 <etext+0x76c>
ffffffffc02008ac:	bfe9                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	3e250513          	addi	a0,a0,994 # ffffffffc0204c90 <etext+0x77c>
ffffffffc02008b6:	bfc1                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	3f850513          	addi	a0,a0,1016 # ffffffffc0204cb0 <etext+0x79c>
ffffffffc02008c0:	e426                	sd	s1,8(sp)
ffffffffc02008c2:	ff8ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008c6:	8522                	mv	a0,s0
ffffffffc02008c8:	c1bff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc02008cc:	84aa                	mv	s1,a0
ffffffffc02008ce:	d15d                	beqz	a0,ffffffffc0200874 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008d0:	8522                	mv	a0,s0
ffffffffc02008d2:	e6bff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008d6:	86a6                	mv	a3,s1
ffffffffc02008d8:	00004617          	auipc	a2,0x4
ffffffffc02008dc:	3f060613          	addi	a2,a2,1008 # ffffffffc0204cc8 <etext+0x7b4>
ffffffffc02008e0:	0ca00593          	li	a1,202
ffffffffc02008e4:	00004517          	auipc	a0,0x4
ffffffffc02008e8:	f0450513          	addi	a0,a0,-252 # ffffffffc02047e8 <etext+0x2d4>
ffffffffc02008ec:	a75ff0ef          	jal	ffffffffc0200360 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	3f850513          	addi	a0,a0,1016 # ffffffffc0204ce8 <etext+0x7d4>
ffffffffc02008f8:	b779                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02008fa:	00004517          	auipc	a0,0x4
ffffffffc02008fe:	40650513          	addi	a0,a0,1030 # ffffffffc0204d00 <etext+0x7ec>
ffffffffc0200902:	e426                	sd	s1,8(sp)
ffffffffc0200904:	fb6ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200908:	8522                	mv	a0,s0
ffffffffc020090a:	bd9ff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc020090e:	84aa                	mv	s1,a0
ffffffffc0200910:	d135                	beqz	a0,ffffffffc0200874 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200912:	8522                	mv	a0,s0
ffffffffc0200914:	e29ff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200918:	86a6                	mv	a3,s1
ffffffffc020091a:	00004617          	auipc	a2,0x4
ffffffffc020091e:	3ae60613          	addi	a2,a2,942 # ffffffffc0204cc8 <etext+0x7b4>
ffffffffc0200922:	0d400593          	li	a1,212
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	ec250513          	addi	a0,a0,-318 # ffffffffc02047e8 <etext+0x2d4>
ffffffffc020092e:	a33ff0ef          	jal	ffffffffc0200360 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	3e650513          	addi	a0,a0,998 # ffffffffc0204d18 <etext+0x804>
ffffffffc020093a:	b7b1                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204d38 <etext+0x824>
ffffffffc0200944:	b789                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	41250513          	addi	a0,a0,1042 # ffffffffc0204d58 <etext+0x844>
ffffffffc020094e:	bf25                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	42850513          	addi	a0,a0,1064 # ffffffffc0204d78 <etext+0x864>
ffffffffc0200958:	b73d                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	43e50513          	addi	a0,a0,1086 # ffffffffc0204d98 <etext+0x884>
ffffffffc0200962:	b715                	j	ffffffffc0200886 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200964:	00004517          	auipc	a0,0x4
ffffffffc0200968:	44c50513          	addi	a0,a0,1100 # ffffffffc0204db0 <etext+0x89c>
ffffffffc020096c:	e426                	sd	s1,8(sp)
ffffffffc020096e:	f4cff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200972:	8522                	mv	a0,s0
ffffffffc0200974:	b6fff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc0200978:	84aa                	mv	s1,a0
ffffffffc020097a:	ee050de3          	beqz	a0,ffffffffc0200874 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020097e:	8522                	mv	a0,s0
ffffffffc0200980:	dbdff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200984:	86a6                	mv	a3,s1
ffffffffc0200986:	00004617          	auipc	a2,0x4
ffffffffc020098a:	34260613          	addi	a2,a2,834 # ffffffffc0204cc8 <etext+0x7b4>
ffffffffc020098e:	0ea00593          	li	a1,234
ffffffffc0200992:	00004517          	auipc	a0,0x4
ffffffffc0200996:	e5650513          	addi	a0,a0,-426 # ffffffffc02047e8 <etext+0x2d4>
ffffffffc020099a:	9c7ff0ef          	jal	ffffffffc0200360 <__panic>
            print_trapframe(tf);
ffffffffc020099e:	8522                	mv	a0,s0
}
ffffffffc02009a0:	6442                	ld	s0,16(sp)
ffffffffc02009a2:	60e2                	ld	ra,24(sp)
ffffffffc02009a4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009a6:	bb59                	j	ffffffffc020073c <print_trapframe>
                print_trapframe(tf);
ffffffffc02009a8:	8522                	mv	a0,s0
ffffffffc02009aa:	d93ff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ae:	86a6                	mv	a3,s1
ffffffffc02009b0:	00004617          	auipc	a2,0x4
ffffffffc02009b4:	31860613          	addi	a2,a2,792 # ffffffffc0204cc8 <etext+0x7b4>
ffffffffc02009b8:	0f100593          	li	a1,241
ffffffffc02009bc:	00004517          	auipc	a0,0x4
ffffffffc02009c0:	e2c50513          	addi	a0,a0,-468 # ffffffffc02047e8 <etext+0x2d4>
ffffffffc02009c4:	99dff0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02009c8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009c8:	11853783          	ld	a5,280(a0)
ffffffffc02009cc:	0007c363          	bltz	a5,ffffffffc02009d2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009d0:	b59d                	j	ffffffffc0200836 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009d2:	b3f1                	j	ffffffffc020079e <interrupt_handler>
	...

ffffffffc02009e0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009e0:	14011073          	csrw	sscratch,sp
ffffffffc02009e4:	712d                	addi	sp,sp,-288
ffffffffc02009e6:	e406                	sd	ra,8(sp)
ffffffffc02009e8:	ec0e                	sd	gp,24(sp)
ffffffffc02009ea:	f012                	sd	tp,32(sp)
ffffffffc02009ec:	f416                	sd	t0,40(sp)
ffffffffc02009ee:	f81a                	sd	t1,48(sp)
ffffffffc02009f0:	fc1e                	sd	t2,56(sp)
ffffffffc02009f2:	e0a2                	sd	s0,64(sp)
ffffffffc02009f4:	e4a6                	sd	s1,72(sp)
ffffffffc02009f6:	e8aa                	sd	a0,80(sp)
ffffffffc02009f8:	ecae                	sd	a1,88(sp)
ffffffffc02009fa:	f0b2                	sd	a2,96(sp)
ffffffffc02009fc:	f4b6                	sd	a3,104(sp)
ffffffffc02009fe:	f8ba                	sd	a4,112(sp)
ffffffffc0200a00:	fcbe                	sd	a5,120(sp)
ffffffffc0200a02:	e142                	sd	a6,128(sp)
ffffffffc0200a04:	e546                	sd	a7,136(sp)
ffffffffc0200a06:	e94a                	sd	s2,144(sp)
ffffffffc0200a08:	ed4e                	sd	s3,152(sp)
ffffffffc0200a0a:	f152                	sd	s4,160(sp)
ffffffffc0200a0c:	f556                	sd	s5,168(sp)
ffffffffc0200a0e:	f95a                	sd	s6,176(sp)
ffffffffc0200a10:	fd5e                	sd	s7,184(sp)
ffffffffc0200a12:	e1e2                	sd	s8,192(sp)
ffffffffc0200a14:	e5e6                	sd	s9,200(sp)
ffffffffc0200a16:	e9ea                	sd	s10,208(sp)
ffffffffc0200a18:	edee                	sd	s11,216(sp)
ffffffffc0200a1a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a1c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a1e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a20:	fdfe                	sd	t6,248(sp)
ffffffffc0200a22:	14002473          	csrr	s0,sscratch
ffffffffc0200a26:	100024f3          	csrr	s1,sstatus
ffffffffc0200a2a:	14102973          	csrr	s2,sepc
ffffffffc0200a2e:	143029f3          	csrr	s3,stval
ffffffffc0200a32:	14202a73          	csrr	s4,scause
ffffffffc0200a36:	e822                	sd	s0,16(sp)
ffffffffc0200a38:	e226                	sd	s1,256(sp)
ffffffffc0200a3a:	e64a                	sd	s2,264(sp)
ffffffffc0200a3c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a3e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a40:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a42:	f87ff0ef          	jal	ffffffffc02009c8 <trap>

ffffffffc0200a46 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a46:	6492                	ld	s1,256(sp)
ffffffffc0200a48:	6932                	ld	s2,264(sp)
ffffffffc0200a4a:	10049073          	csrw	sstatus,s1
ffffffffc0200a4e:	14191073          	csrw	sepc,s2
ffffffffc0200a52:	60a2                	ld	ra,8(sp)
ffffffffc0200a54:	61e2                	ld	gp,24(sp)
ffffffffc0200a56:	7202                	ld	tp,32(sp)
ffffffffc0200a58:	72a2                	ld	t0,40(sp)
ffffffffc0200a5a:	7342                	ld	t1,48(sp)
ffffffffc0200a5c:	73e2                	ld	t2,56(sp)
ffffffffc0200a5e:	6406                	ld	s0,64(sp)
ffffffffc0200a60:	64a6                	ld	s1,72(sp)
ffffffffc0200a62:	6546                	ld	a0,80(sp)
ffffffffc0200a64:	65e6                	ld	a1,88(sp)
ffffffffc0200a66:	7606                	ld	a2,96(sp)
ffffffffc0200a68:	76a6                	ld	a3,104(sp)
ffffffffc0200a6a:	7746                	ld	a4,112(sp)
ffffffffc0200a6c:	77e6                	ld	a5,120(sp)
ffffffffc0200a6e:	680a                	ld	a6,128(sp)
ffffffffc0200a70:	68aa                	ld	a7,136(sp)
ffffffffc0200a72:	694a                	ld	s2,144(sp)
ffffffffc0200a74:	69ea                	ld	s3,152(sp)
ffffffffc0200a76:	7a0a                	ld	s4,160(sp)
ffffffffc0200a78:	7aaa                	ld	s5,168(sp)
ffffffffc0200a7a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a7c:	7bea                	ld	s7,184(sp)
ffffffffc0200a7e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a80:	6cae                	ld	s9,200(sp)
ffffffffc0200a82:	6d4e                	ld	s10,208(sp)
ffffffffc0200a84:	6dee                	ld	s11,216(sp)
ffffffffc0200a86:	7e0e                	ld	t3,224(sp)
ffffffffc0200a88:	7eae                	ld	t4,232(sp)
ffffffffc0200a8a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a8c:	7fee                	ld	t6,248(sp)
ffffffffc0200a8e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200a90:	10200073          	sret
	...

ffffffffc0200aa0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200aa0:	00010797          	auipc	a5,0x10
ffffffffc0200aa4:	5a078793          	addi	a5,a5,1440 # ffffffffc0211040 <free_area>
ffffffffc0200aa8:	e79c                	sd	a5,8(a5)
ffffffffc0200aaa:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aac:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ab0:	8082                	ret

ffffffffc0200ab2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ab2:	00010517          	auipc	a0,0x10
ffffffffc0200ab6:	59e56503          	lwu	a0,1438(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200aba:	8082                	ret

ffffffffc0200abc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200abc:	715d                	addi	sp,sp,-80
ffffffffc0200abe:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ac0:	00010417          	auipc	s0,0x10
ffffffffc0200ac4:	58040413          	addi	s0,s0,1408 # ffffffffc0211040 <free_area>
ffffffffc0200ac8:	641c                	ld	a5,8(s0)
ffffffffc0200aca:	e486                	sd	ra,72(sp)
ffffffffc0200acc:	fc26                	sd	s1,56(sp)
ffffffffc0200ace:	f84a                	sd	s2,48(sp)
ffffffffc0200ad0:	f44e                	sd	s3,40(sp)
ffffffffc0200ad2:	f052                	sd	s4,32(sp)
ffffffffc0200ad4:	ec56                	sd	s5,24(sp)
ffffffffc0200ad6:	e85a                	sd	s6,16(sp)
ffffffffc0200ad8:	e45e                	sd	s7,8(sp)
ffffffffc0200ada:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200adc:	2e878063          	beq	a5,s0,ffffffffc0200dbc <default_check+0x300>
    int count = 0, total = 0;
ffffffffc0200ae0:	4481                	li	s1,0
ffffffffc0200ae2:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ae4:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ae8:	8b09                	andi	a4,a4,2
ffffffffc0200aea:	2c070d63          	beqz	a4,ffffffffc0200dc4 <default_check+0x308>
        count ++, total += p->property;
ffffffffc0200aee:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200af2:	679c                	ld	a5,8(a5)
ffffffffc0200af4:	2905                	addiw	s2,s2,1
ffffffffc0200af6:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200af8:	fe8796e3          	bne	a5,s0,ffffffffc0200ae4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200afc:	89a6                	mv	s3,s1
ffffffffc0200afe:	395000ef          	jal	ffffffffc0201692 <nr_free_pages>
ffffffffc0200b02:	73351163          	bne	a0,s3,ffffffffc0201224 <default_check+0x768>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b06:	4505                	li	a0,1
ffffffffc0200b08:	2bb000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200b0c:	8a2a                	mv	s4,a0
ffffffffc0200b0e:	44050b63          	beqz	a0,ffffffffc0200f64 <default_check+0x4a8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b12:	4505                	li	a0,1
ffffffffc0200b14:	2af000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200b18:	89aa                	mv	s3,a0
ffffffffc0200b1a:	72050563          	beqz	a0,ffffffffc0201244 <default_check+0x788>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b1e:	4505                	li	a0,1
ffffffffc0200b20:	2a3000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200b24:	8aaa                	mv	s5,a0
ffffffffc0200b26:	4a050f63          	beqz	a0,ffffffffc0200fe4 <default_check+0x528>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b2a:	2b3a0d63          	beq	s4,s3,ffffffffc0200de4 <default_check+0x328>
ffffffffc0200b2e:	2aaa0b63          	beq	s4,a0,ffffffffc0200de4 <default_check+0x328>
ffffffffc0200b32:	2aa98963          	beq	s3,a0,ffffffffc0200de4 <default_check+0x328>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b36:	000a2783          	lw	a5,0(s4)
ffffffffc0200b3a:	2c079563          	bnez	a5,ffffffffc0200e04 <default_check+0x348>
ffffffffc0200b3e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b42:	2c079163          	bnez	a5,ffffffffc0200e04 <default_check+0x348>
ffffffffc0200b46:	411c                	lw	a5,0(a0)
ffffffffc0200b48:	2a079e63          	bnez	a5,ffffffffc0200e04 <default_check+0x348>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b4c:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0200b50:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc0200b54:	07b2                	slli	a5,a5,0xc
ffffffffc0200b56:	e3978793          	addi	a5,a5,-455
ffffffffc0200b5a:	07b2                	slli	a5,a5,0xc
ffffffffc0200b5c:	00011717          	auipc	a4,0x11
ffffffffc0200b60:	9dc73703          	ld	a4,-1572(a4) # ffffffffc0211538 <pages>
ffffffffc0200b64:	e3978793          	addi	a5,a5,-455
ffffffffc0200b68:	40ea06b3          	sub	a3,s4,a4
ffffffffc0200b6c:	07b2                	slli	a5,a5,0xc
ffffffffc0200b6e:	868d                	srai	a3,a3,0x3
ffffffffc0200b70:	e3978793          	addi	a5,a5,-455
ffffffffc0200b74:	02f686b3          	mul	a3,a3,a5
ffffffffc0200b78:	00005597          	auipc	a1,0x5
ffffffffc0200b7c:	7b85b583          	ld	a1,1976(a1) # ffffffffc0206330 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b80:	00011617          	auipc	a2,0x11
ffffffffc0200b84:	9b063603          	ld	a2,-1616(a2) # ffffffffc0211530 <npage>
ffffffffc0200b88:	0632                	slli	a2,a2,0xc
ffffffffc0200b8a:	96ae                	add	a3,a3,a1

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b8c:	06b2                	slli	a3,a3,0xc
ffffffffc0200b8e:	28c6fb63          	bgeu	a3,a2,ffffffffc0200e24 <default_check+0x368>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b92:	40e986b3          	sub	a3,s3,a4
ffffffffc0200b96:	868d                	srai	a3,a3,0x3
ffffffffc0200b98:	02f686b3          	mul	a3,a3,a5
ffffffffc0200b9c:	96ae                	add	a3,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b9e:	06b2                	slli	a3,a3,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ba0:	4cc6f263          	bgeu	a3,a2,ffffffffc0201064 <default_check+0x5a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba4:	40e50733          	sub	a4,a0,a4
ffffffffc0200ba8:	870d                	srai	a4,a4,0x3
ffffffffc0200baa:	02f707b3          	mul	a5,a4,a5
ffffffffc0200bae:	97ae                	add	a5,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bb0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bb2:	30c7f963          	bgeu	a5,a2,ffffffffc0200ec4 <default_check+0x408>
    assert(alloc_page() == NULL);
ffffffffc0200bb6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bb8:	00043c03          	ld	s8,0(s0)
ffffffffc0200bbc:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bc0:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200bc4:	e400                	sd	s0,8(s0)
ffffffffc0200bc6:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200bc8:	00010797          	auipc	a5,0x10
ffffffffc0200bcc:	4807a423          	sw	zero,1160(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bd0:	1f3000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200bd4:	2c051863          	bnez	a0,ffffffffc0200ea4 <default_check+0x3e8>
    free_page(p0);
ffffffffc0200bd8:	4585                	li	a1,1
ffffffffc0200bda:	8552                	mv	a0,s4
ffffffffc0200bdc:	277000ef          	jal	ffffffffc0201652 <free_pages>
    free_page(p1);
ffffffffc0200be0:	4585                	li	a1,1
ffffffffc0200be2:	854e                	mv	a0,s3
ffffffffc0200be4:	26f000ef          	jal	ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200be8:	4585                	li	a1,1
ffffffffc0200bea:	8556                	mv	a0,s5
ffffffffc0200bec:	267000ef          	jal	ffffffffc0201652 <free_pages>
    assert(nr_free == 3);
ffffffffc0200bf0:	4818                	lw	a4,16(s0)
ffffffffc0200bf2:	478d                	li	a5,3
ffffffffc0200bf4:	28f71863          	bne	a4,a5,ffffffffc0200e84 <default_check+0x3c8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bf8:	4505                	li	a0,1
ffffffffc0200bfa:	1c9000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200bfe:	89aa                	mv	s3,a0
ffffffffc0200c00:	26050263          	beqz	a0,ffffffffc0200e64 <default_check+0x3a8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c04:	4505                	li	a0,1
ffffffffc0200c06:	1bd000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200c0a:	8aaa                	mv	s5,a0
ffffffffc0200c0c:	3a050c63          	beqz	a0,ffffffffc0200fc4 <default_check+0x508>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c10:	4505                	li	a0,1
ffffffffc0200c12:	1b1000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200c16:	8a2a                	mv	s4,a0
ffffffffc0200c18:	38050663          	beqz	a0,ffffffffc0200fa4 <default_check+0x4e8>
    assert(alloc_page() == NULL);
ffffffffc0200c1c:	4505                	li	a0,1
ffffffffc0200c1e:	1a5000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200c22:	36051163          	bnez	a0,ffffffffc0200f84 <default_check+0x4c8>
    free_page(p0);
ffffffffc0200c26:	4585                	li	a1,1
ffffffffc0200c28:	854e                	mv	a0,s3
ffffffffc0200c2a:	229000ef          	jal	ffffffffc0201652 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c2e:	641c                	ld	a5,8(s0)
ffffffffc0200c30:	20878a63          	beq	a5,s0,ffffffffc0200e44 <default_check+0x388>
    assert((p = alloc_page()) == p0);
ffffffffc0200c34:	4505                	li	a0,1
ffffffffc0200c36:	18d000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200c3a:	30a99563          	bne	s3,a0,ffffffffc0200f44 <default_check+0x488>
    assert(alloc_page() == NULL);
ffffffffc0200c3e:	4505                	li	a0,1
ffffffffc0200c40:	183000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200c44:	2e051063          	bnez	a0,ffffffffc0200f24 <default_check+0x468>
    assert(nr_free == 0);
ffffffffc0200c48:	481c                	lw	a5,16(s0)
ffffffffc0200c4a:	2a079d63          	bnez	a5,ffffffffc0200f04 <default_check+0x448>
    free_page(p);
ffffffffc0200c4e:	854e                	mv	a0,s3
ffffffffc0200c50:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c52:	01843023          	sd	s8,0(s0)
ffffffffc0200c56:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c5a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c5e:	1f5000ef          	jal	ffffffffc0201652 <free_pages>
    free_page(p1);
ffffffffc0200c62:	4585                	li	a1,1
ffffffffc0200c64:	8556                	mv	a0,s5
ffffffffc0200c66:	1ed000ef          	jal	ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200c6a:	4585                	li	a1,1
ffffffffc0200c6c:	8552                	mv	a0,s4
ffffffffc0200c6e:	1e5000ef          	jal	ffffffffc0201652 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c72:	4515                	li	a0,5
ffffffffc0200c74:	14f000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200c78:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c7a:	26050563          	beqz	a0,ffffffffc0200ee4 <default_check+0x428>
ffffffffc0200c7e:	651c                	ld	a5,8(a0)
ffffffffc0200c80:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c82:	8b85                	andi	a5,a5,1
ffffffffc0200c84:	54079063          	bnez	a5,ffffffffc02011c4 <default_check+0x708>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c88:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c8a:	00043b03          	ld	s6,0(s0)
ffffffffc0200c8e:	00843a83          	ld	s5,8(s0)
ffffffffc0200c92:	e000                	sd	s0,0(s0)
ffffffffc0200c94:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c96:	12d000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200c9a:	50051563          	bnez	a0,ffffffffc02011a4 <default_check+0x6e8>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200c9e:	09098a13          	addi	s4,s3,144
ffffffffc0200ca2:	8552                	mv	a0,s4
ffffffffc0200ca4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ca6:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200caa:	00010797          	auipc	a5,0x10
ffffffffc0200cae:	3a07a323          	sw	zero,934(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cb2:	1a1000ef          	jal	ffffffffc0201652 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cb6:	4511                	li	a0,4
ffffffffc0200cb8:	10b000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200cbc:	4c051463          	bnez	a0,ffffffffc0201184 <default_check+0x6c8>
ffffffffc0200cc0:	0989b783          	ld	a5,152(s3)
ffffffffc0200cc4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200cc6:	8b85                	andi	a5,a5,1
ffffffffc0200cc8:	48078e63          	beqz	a5,ffffffffc0201164 <default_check+0x6a8>
ffffffffc0200ccc:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cd0:	478d                	li	a5,3
ffffffffc0200cd2:	48f71963          	bne	a4,a5,ffffffffc0201164 <default_check+0x6a8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cd6:	450d                	li	a0,3
ffffffffc0200cd8:	0eb000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200cdc:	8c2a                	mv	s8,a0
ffffffffc0200cde:	46050363          	beqz	a0,ffffffffc0201144 <default_check+0x688>
    assert(alloc_page() == NULL);
ffffffffc0200ce2:	4505                	li	a0,1
ffffffffc0200ce4:	0df000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200ce8:	42051e63          	bnez	a0,ffffffffc0201124 <default_check+0x668>
    assert(p0 + 2 == p1);
ffffffffc0200cec:	418a1c63          	bne	s4,s8,ffffffffc0201104 <default_check+0x648>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200cf0:	4585                	li	a1,1
ffffffffc0200cf2:	854e                	mv	a0,s3
ffffffffc0200cf4:	15f000ef          	jal	ffffffffc0201652 <free_pages>
    free_pages(p1, 3);
ffffffffc0200cf8:	458d                	li	a1,3
ffffffffc0200cfa:	8552                	mv	a0,s4
ffffffffc0200cfc:	157000ef          	jal	ffffffffc0201652 <free_pages>
ffffffffc0200d00:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d04:	04898c13          	addi	s8,s3,72
ffffffffc0200d08:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d0a:	8b85                	andi	a5,a5,1
ffffffffc0200d0c:	3c078c63          	beqz	a5,ffffffffc02010e4 <default_check+0x628>
ffffffffc0200d10:	0189a703          	lw	a4,24(s3)
ffffffffc0200d14:	4785                	li	a5,1
ffffffffc0200d16:	3cf71763          	bne	a4,a5,ffffffffc02010e4 <default_check+0x628>
ffffffffc0200d1a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d1e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d20:	8b85                	andi	a5,a5,1
ffffffffc0200d22:	3a078163          	beqz	a5,ffffffffc02010c4 <default_check+0x608>
ffffffffc0200d26:	018a2703          	lw	a4,24(s4)
ffffffffc0200d2a:	478d                	li	a5,3
ffffffffc0200d2c:	38f71c63          	bne	a4,a5,ffffffffc02010c4 <default_check+0x608>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d30:	4505                	li	a0,1
ffffffffc0200d32:	091000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200d36:	36a99763          	bne	s3,a0,ffffffffc02010a4 <default_check+0x5e8>
    free_page(p0);
ffffffffc0200d3a:	4585                	li	a1,1
ffffffffc0200d3c:	117000ef          	jal	ffffffffc0201652 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d40:	4509                	li	a0,2
ffffffffc0200d42:	081000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200d46:	32aa1f63          	bne	s4,a0,ffffffffc0201084 <default_check+0x5c8>

    free_pages(p0, 2);
ffffffffc0200d4a:	4589                	li	a1,2
ffffffffc0200d4c:	107000ef          	jal	ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200d50:	4585                	li	a1,1
ffffffffc0200d52:	8562                	mv	a0,s8
ffffffffc0200d54:	0ff000ef          	jal	ffffffffc0201652 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d58:	4515                	li	a0,5
ffffffffc0200d5a:	069000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200d5e:	89aa                	mv	s3,a0
ffffffffc0200d60:	48050263          	beqz	a0,ffffffffc02011e4 <default_check+0x728>
    assert(alloc_page() == NULL);
ffffffffc0200d64:	4505                	li	a0,1
ffffffffc0200d66:	05d000ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0200d6a:	2c051d63          	bnez	a0,ffffffffc0201044 <default_check+0x588>

    assert(nr_free == 0);
ffffffffc0200d6e:	481c                	lw	a5,16(s0)
ffffffffc0200d70:	2a079a63          	bnez	a5,ffffffffc0201024 <default_check+0x568>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d74:	4595                	li	a1,5
ffffffffc0200d76:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d78:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d7c:	01643023          	sd	s6,0(s0)
ffffffffc0200d80:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200d84:	0cf000ef          	jal	ffffffffc0201652 <free_pages>
    return listelm->next;
ffffffffc0200d88:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d8a:	00878963          	beq	a5,s0,ffffffffc0200d9c <default_check+0x2e0>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d8e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d92:	679c                	ld	a5,8(a5)
ffffffffc0200d94:	397d                	addiw	s2,s2,-1
ffffffffc0200d96:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d98:	fe879be3          	bne	a5,s0,ffffffffc0200d8e <default_check+0x2d2>
    }
    assert(count == 0);
ffffffffc0200d9c:	26091463          	bnez	s2,ffffffffc0201004 <default_check+0x548>
    assert(total == 0);
ffffffffc0200da0:	46049263          	bnez	s1,ffffffffc0201204 <default_check+0x748>
}
ffffffffc0200da4:	60a6                	ld	ra,72(sp)
ffffffffc0200da6:	6406                	ld	s0,64(sp)
ffffffffc0200da8:	74e2                	ld	s1,56(sp)
ffffffffc0200daa:	7942                	ld	s2,48(sp)
ffffffffc0200dac:	79a2                	ld	s3,40(sp)
ffffffffc0200dae:	7a02                	ld	s4,32(sp)
ffffffffc0200db0:	6ae2                	ld	s5,24(sp)
ffffffffc0200db2:	6b42                	ld	s6,16(sp)
ffffffffc0200db4:	6ba2                	ld	s7,8(sp)
ffffffffc0200db6:	6c02                	ld	s8,0(sp)
ffffffffc0200db8:	6161                	addi	sp,sp,80
ffffffffc0200dba:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dbc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dbe:	4481                	li	s1,0
ffffffffc0200dc0:	4901                	li	s2,0
ffffffffc0200dc2:	bb35                	j	ffffffffc0200afe <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200dc4:	00004697          	auipc	a3,0x4
ffffffffc0200dc8:	01c68693          	addi	a3,a3,28 # ffffffffc0204de0 <etext+0x8cc>
ffffffffc0200dcc:	00004617          	auipc	a2,0x4
ffffffffc0200dd0:	02460613          	addi	a2,a2,36 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200dd4:	0f000593          	li	a1,240
ffffffffc0200dd8:	00004517          	auipc	a0,0x4
ffffffffc0200ddc:	03050513          	addi	a0,a0,48 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200de0:	d80ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200de4:	00004697          	auipc	a3,0x4
ffffffffc0200de8:	0bc68693          	addi	a3,a3,188 # ffffffffc0204ea0 <etext+0x98c>
ffffffffc0200dec:	00004617          	auipc	a2,0x4
ffffffffc0200df0:	00460613          	addi	a2,a2,4 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200df4:	0bd00593          	li	a1,189
ffffffffc0200df8:	00004517          	auipc	a0,0x4
ffffffffc0200dfc:	01050513          	addi	a0,a0,16 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200e00:	d60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e04:	00004697          	auipc	a3,0x4
ffffffffc0200e08:	0c468693          	addi	a3,a3,196 # ffffffffc0204ec8 <etext+0x9b4>
ffffffffc0200e0c:	00004617          	auipc	a2,0x4
ffffffffc0200e10:	fe460613          	addi	a2,a2,-28 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200e14:	0be00593          	li	a1,190
ffffffffc0200e18:	00004517          	auipc	a0,0x4
ffffffffc0200e1c:	ff050513          	addi	a0,a0,-16 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200e20:	d40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e24:	00004697          	auipc	a3,0x4
ffffffffc0200e28:	0e468693          	addi	a3,a3,228 # ffffffffc0204f08 <etext+0x9f4>
ffffffffc0200e2c:	00004617          	auipc	a2,0x4
ffffffffc0200e30:	fc460613          	addi	a2,a2,-60 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200e34:	0c000593          	li	a1,192
ffffffffc0200e38:	00004517          	auipc	a0,0x4
ffffffffc0200e3c:	fd050513          	addi	a0,a0,-48 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200e40:	d20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e44:	00004697          	auipc	a3,0x4
ffffffffc0200e48:	14c68693          	addi	a3,a3,332 # ffffffffc0204f90 <etext+0xa7c>
ffffffffc0200e4c:	00004617          	auipc	a2,0x4
ffffffffc0200e50:	fa460613          	addi	a2,a2,-92 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200e54:	0d900593          	li	a1,217
ffffffffc0200e58:	00004517          	auipc	a0,0x4
ffffffffc0200e5c:	fb050513          	addi	a0,a0,-80 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200e60:	d00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e64:	00004697          	auipc	a3,0x4
ffffffffc0200e68:	fdc68693          	addi	a3,a3,-36 # ffffffffc0204e40 <etext+0x92c>
ffffffffc0200e6c:	00004617          	auipc	a2,0x4
ffffffffc0200e70:	f8460613          	addi	a2,a2,-124 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200e74:	0d200593          	li	a1,210
ffffffffc0200e78:	00004517          	auipc	a0,0x4
ffffffffc0200e7c:	f9050513          	addi	a0,a0,-112 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200e80:	ce0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free == 3);
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	0fc68693          	addi	a3,a3,252 # ffffffffc0204f80 <etext+0xa6c>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	f6460613          	addi	a2,a2,-156 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200e94:	0d000593          	li	a1,208
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	f7050513          	addi	a0,a0,-144 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200ea0:	cc0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	0c468693          	addi	a3,a3,196 # ffffffffc0204f68 <etext+0xa54>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	f4460613          	addi	a2,a2,-188 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200eb4:	0cb00593          	li	a1,203
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	f5050513          	addi	a0,a0,-176 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200ec0:	ca0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	08468693          	addi	a3,a3,132 # ffffffffc0204f48 <etext+0xa34>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	f2460613          	addi	a2,a2,-220 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200ed4:	0c200593          	li	a1,194
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	f3050513          	addi	a0,a0,-208 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200ee0:	c80ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(p0 != NULL);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	0f468693          	addi	a3,a3,244 # ffffffffc0204fd8 <etext+0xac4>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	f0460613          	addi	a2,a2,-252 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200ef4:	0f800593          	li	a1,248
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	f1050513          	addi	a0,a0,-240 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200f00:	c60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free == 0);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	0c468693          	addi	a3,a3,196 # ffffffffc0204fc8 <etext+0xab4>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	ee460613          	addi	a2,a2,-284 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200f14:	0df00593          	li	a1,223
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	ef050513          	addi	a0,a0,-272 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200f20:	c40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	04468693          	addi	a3,a3,68 # ffffffffc0204f68 <etext+0xa54>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	ec460613          	addi	a2,a2,-316 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200f34:	0dd00593          	li	a1,221
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	ed050513          	addi	a0,a0,-304 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200f40:	c20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	06468693          	addi	a3,a3,100 # ffffffffc0204fa8 <etext+0xa94>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	ea460613          	addi	a2,a2,-348 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200f54:	0dc00593          	li	a1,220
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	eb050513          	addi	a0,a0,-336 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200f60:	c00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	edc68693          	addi	a3,a3,-292 # ffffffffc0204e40 <etext+0x92c>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	e8460613          	addi	a2,a2,-380 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200f74:	0b900593          	li	a1,185
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	e9050513          	addi	a0,a0,-368 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200f80:	be0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	fe468693          	addi	a3,a3,-28 # ffffffffc0204f68 <etext+0xa54>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	e6460613          	addi	a2,a2,-412 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200f94:	0d600593          	li	a1,214
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	e7050513          	addi	a0,a0,-400 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200fa0:	bc0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	edc68693          	addi	a3,a3,-292 # ffffffffc0204e80 <etext+0x96c>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	e4460613          	addi	a2,a2,-444 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200fb4:	0d400593          	li	a1,212
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	e5050513          	addi	a0,a0,-432 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200fc0:	ba0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	e9c68693          	addi	a3,a3,-356 # ffffffffc0204e60 <etext+0x94c>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	e2460613          	addi	a2,a2,-476 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200fd4:	0d300593          	li	a1,211
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	e3050513          	addi	a0,a0,-464 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0200fe0:	b80ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	e9c68693          	addi	a3,a3,-356 # ffffffffc0204e80 <etext+0x96c>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	e0460613          	addi	a2,a2,-508 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0200ff4:	0bb00593          	li	a1,187
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	e1050513          	addi	a0,a0,-496 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201000:	b60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(count == 0);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	12468693          	addi	a3,a3,292 # ffffffffc0205128 <etext+0xc14>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	de460613          	addi	a2,a2,-540 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201014:	12500593          	li	a1,293
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	df050513          	addi	a0,a0,-528 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201020:	b40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free == 0);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	fa468693          	addi	a3,a3,-92 # ffffffffc0204fc8 <etext+0xab4>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	dc460613          	addi	a2,a2,-572 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201034:	11a00593          	li	a1,282
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	dd050513          	addi	a0,a0,-560 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201040:	b20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	f2468693          	addi	a3,a3,-220 # ffffffffc0204f68 <etext+0xa54>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	da460613          	addi	a2,a2,-604 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201054:	11800593          	li	a1,280
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	db050513          	addi	a0,a0,-592 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201060:	b00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	ec468693          	addi	a3,a3,-316 # ffffffffc0204f28 <etext+0xa14>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	d8460613          	addi	a2,a2,-636 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201074:	0c100593          	li	a1,193
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	d9050513          	addi	a0,a0,-624 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201080:	ae0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	06468693          	addi	a3,a3,100 # ffffffffc02050e8 <etext+0xbd4>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	d6460613          	addi	a2,a2,-668 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201094:	11200593          	li	a1,274
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	d7050513          	addi	a0,a0,-656 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02010a0:	ac0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	02468693          	addi	a3,a3,36 # ffffffffc02050c8 <etext+0xbb4>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	d4460613          	addi	a2,a2,-700 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02010b4:	11000593          	li	a1,272
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	d5050513          	addi	a0,a0,-688 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02010c0:	aa0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	fdc68693          	addi	a3,a3,-36 # ffffffffc02050a0 <etext+0xb8c>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	d2460613          	addi	a2,a2,-732 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02010d4:	10e00593          	li	a1,270
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	d3050513          	addi	a0,a0,-720 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02010e0:	a80ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	f9468693          	addi	a3,a3,-108 # ffffffffc0205078 <etext+0xb64>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	d0460613          	addi	a2,a2,-764 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02010f4:	10d00593          	li	a1,269
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	d1050513          	addi	a0,a0,-752 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201100:	a60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	f6468693          	addi	a3,a3,-156 # ffffffffc0205068 <etext+0xb54>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	ce460613          	addi	a2,a2,-796 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201114:	10800593          	li	a1,264
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	cf050513          	addi	a0,a0,-784 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201120:	a40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	e4468693          	addi	a3,a3,-444 # ffffffffc0204f68 <etext+0xa54>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	cc460613          	addi	a2,a2,-828 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201134:	10700593          	li	a1,263
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	cd050513          	addi	a0,a0,-816 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201140:	a20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	f0468693          	addi	a3,a3,-252 # ffffffffc0205048 <etext+0xb34>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	ca460613          	addi	a2,a2,-860 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201154:	10600593          	li	a1,262
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	cb050513          	addi	a0,a0,-848 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201160:	a00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	eb468693          	addi	a3,a3,-332 # ffffffffc0205018 <etext+0xb04>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	c8460613          	addi	a2,a2,-892 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201174:	10500593          	li	a1,261
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	c9050513          	addi	a0,a0,-880 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201180:	9e0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	e7c68693          	addi	a3,a3,-388 # ffffffffc0205000 <etext+0xaec>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	c6460613          	addi	a2,a2,-924 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201194:	10400593          	li	a1,260
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	c7050513          	addi	a0,a0,-912 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02011a0:	9c0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	dc468693          	addi	a3,a3,-572 # ffffffffc0204f68 <etext+0xa54>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	c4460613          	addi	a2,a2,-956 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02011b4:	0fe00593          	li	a1,254
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	c5050513          	addi	a0,a0,-944 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02011c0:	9a0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	e2468693          	addi	a3,a3,-476 # ffffffffc0204fe8 <etext+0xad4>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	c2460613          	addi	a2,a2,-988 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02011d4:	0f900593          	li	a1,249
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	c3050513          	addi	a0,a0,-976 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02011e0:	980ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	f2468693          	addi	a3,a3,-220 # ffffffffc0205108 <etext+0xbf4>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	c0460613          	addi	a2,a2,-1020 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02011f4:	11700593          	li	a1,279
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	c1050513          	addi	a0,a0,-1008 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201200:	960ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(total == 0);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	f3468693          	addi	a3,a3,-204 # ffffffffc0205138 <etext+0xc24>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	be460613          	addi	a2,a2,-1052 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201214:	12600593          	li	a1,294
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201220:	940ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0204e20 <etext+0x90c>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	bc460613          	addi	a2,a2,-1084 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201234:	0f300593          	li	a1,243
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	bd050513          	addi	a0,a0,-1072 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201240:	920ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	c1c68693          	addi	a3,a3,-996 # ffffffffc0204e60 <etext+0x94c>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	ba460613          	addi	a2,a2,-1116 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201254:	0ba00593          	li	a1,186
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	bb050513          	addi	a0,a0,-1104 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201260:	900ff0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0201264 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201264:	1141                	addi	sp,sp,-16
ffffffffc0201266:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201268:	14058a63          	beqz	a1,ffffffffc02013bc <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020126c:	00359713          	slli	a4,a1,0x3
ffffffffc0201270:	972e                	add	a4,a4,a1
ffffffffc0201272:	070e                	slli	a4,a4,0x3
ffffffffc0201274:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201278:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020127a:	c30d                	beqz	a4,ffffffffc020129c <default_free_pages+0x38>
ffffffffc020127c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020127e:	8b05                	andi	a4,a4,1
ffffffffc0201280:	10071e63          	bnez	a4,ffffffffc020139c <default_free_pages+0x138>
ffffffffc0201284:	6798                	ld	a4,8(a5)
ffffffffc0201286:	8b09                	andi	a4,a4,2
ffffffffc0201288:	10071a63          	bnez	a4,ffffffffc020139c <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020128c:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201290:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201294:	04878793          	addi	a5,a5,72
ffffffffc0201298:	fed792e3          	bne	a5,a3,ffffffffc020127c <default_free_pages+0x18>
    base->property = n;
ffffffffc020129c:	2581                	sext.w	a1,a1
ffffffffc020129e:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012a0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012a4:	4789                	li	a5,2
ffffffffc02012a6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012aa:	00010697          	auipc	a3,0x10
ffffffffc02012ae:	d9668693          	addi	a3,a3,-618 # ffffffffc0211040 <free_area>
ffffffffc02012b2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012b4:	669c                	ld	a5,8(a3)
ffffffffc02012b6:	9f2d                	addw	a4,a4,a1
ffffffffc02012b8:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012ba:	0ad78563          	beq	a5,a3,ffffffffc0201364 <default_free_pages+0x100>
            struct Page* page = le2page(le, page_link);
ffffffffc02012be:	fe078713          	addi	a4,a5,-32
ffffffffc02012c2:	4581                	li	a1,0
ffffffffc02012c4:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02012c8:	00e56a63          	bltu	a0,a4,ffffffffc02012dc <default_free_pages+0x78>
    return listelm->next;
ffffffffc02012cc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012ce:	06d70263          	beq	a4,a3,ffffffffc0201332 <default_free_pages+0xce>
    struct Page *p = base;
ffffffffc02012d2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012d4:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012d8:	fee57ae3          	bgeu	a0,a4,ffffffffc02012cc <default_free_pages+0x68>
ffffffffc02012dc:	c199                	beqz	a1,ffffffffc02012e2 <default_free_pages+0x7e>
ffffffffc02012de:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012e2:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012e4:	e390                	sd	a2,0(a5)
ffffffffc02012e6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012e8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02012ea:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012ec:	02d70063          	beq	a4,a3,ffffffffc020130c <default_free_pages+0xa8>
        if (p + p->property == base) {
ffffffffc02012f0:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02012f4:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02012f8:	02081613          	slli	a2,a6,0x20
ffffffffc02012fc:	9201                	srli	a2,a2,0x20
ffffffffc02012fe:	00361793          	slli	a5,a2,0x3
ffffffffc0201302:	97b2                	add	a5,a5,a2
ffffffffc0201304:	078e                	slli	a5,a5,0x3
ffffffffc0201306:	97ae                	add	a5,a5,a1
ffffffffc0201308:	02f50f63          	beq	a0,a5,ffffffffc0201346 <default_free_pages+0xe2>
    return listelm->next;
ffffffffc020130c:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc020130e:	00d70f63          	beq	a4,a3,ffffffffc020132c <default_free_pages+0xc8>
        if (base + base->property == p) {
ffffffffc0201312:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201314:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0201318:	02059613          	slli	a2,a1,0x20
ffffffffc020131c:	9201                	srli	a2,a2,0x20
ffffffffc020131e:	00361793          	slli	a5,a2,0x3
ffffffffc0201322:	97b2                	add	a5,a5,a2
ffffffffc0201324:	078e                	slli	a5,a5,0x3
ffffffffc0201326:	97aa                	add	a5,a5,a0
ffffffffc0201328:	04f68a63          	beq	a3,a5,ffffffffc020137c <default_free_pages+0x118>
}
ffffffffc020132c:	60a2                	ld	ra,8(sp)
ffffffffc020132e:	0141                	addi	sp,sp,16
ffffffffc0201330:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201332:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201334:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201336:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201338:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020133a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020133c:	02d70d63          	beq	a4,a3,ffffffffc0201376 <default_free_pages+0x112>
ffffffffc0201340:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201342:	87ba                	mv	a5,a4
ffffffffc0201344:	bf41                	j	ffffffffc02012d4 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201346:	4d1c                	lw	a5,24(a0)
ffffffffc0201348:	010787bb          	addw	a5,a5,a6
ffffffffc020134c:	fef72c23          	sw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201350:	57f5                	li	a5,-3
ffffffffc0201352:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201356:	7110                	ld	a2,32(a0)
ffffffffc0201358:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020135a:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020135c:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc020135e:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201360:	e390                	sd	a2,0(a5)
ffffffffc0201362:	b775                	j	ffffffffc020130e <default_free_pages+0xaa>
}
ffffffffc0201364:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201366:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020136a:	e398                	sd	a4,0(a5)
ffffffffc020136c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020136e:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201370:	f11c                	sd	a5,32(a0)
}
ffffffffc0201372:	0141                	addi	sp,sp,16
ffffffffc0201374:	8082                	ret
ffffffffc0201376:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201378:	873e                	mv	a4,a5
ffffffffc020137a:	bf8d                	j	ffffffffc02012ec <default_free_pages+0x88>
            base->property += p->property;
ffffffffc020137c:	ff872783          	lw	a5,-8(a4)
ffffffffc0201380:	fe870693          	addi	a3,a4,-24
ffffffffc0201384:	9fad                	addw	a5,a5,a1
ffffffffc0201386:	cd1c                	sw	a5,24(a0)
ffffffffc0201388:	57f5                	li	a5,-3
ffffffffc020138a:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020138e:	6314                	ld	a3,0(a4)
ffffffffc0201390:	671c                	ld	a5,8(a4)
}
ffffffffc0201392:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201394:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201396:	e394                	sd	a3,0(a5)
ffffffffc0201398:	0141                	addi	sp,sp,16
ffffffffc020139a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020139c:	00004697          	auipc	a3,0x4
ffffffffc02013a0:	db468693          	addi	a3,a3,-588 # ffffffffc0205150 <etext+0xc3c>
ffffffffc02013a4:	00004617          	auipc	a2,0x4
ffffffffc02013a8:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02013ac:	08300593          	li	a1,131
ffffffffc02013b0:	00004517          	auipc	a0,0x4
ffffffffc02013b4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02013b8:	fa9fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(n > 0);
ffffffffc02013bc:	00004697          	auipc	a3,0x4
ffffffffc02013c0:	d8c68693          	addi	a3,a3,-628 # ffffffffc0205148 <etext+0xc34>
ffffffffc02013c4:	00004617          	auipc	a2,0x4
ffffffffc02013c8:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02013cc:	08000593          	li	a1,128
ffffffffc02013d0:	00004517          	auipc	a0,0x4
ffffffffc02013d4:	a3850513          	addi	a0,a0,-1480 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc02013d8:	f89fe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02013dc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013dc:	c959                	beqz	a0,ffffffffc0201472 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013de:	00010617          	auipc	a2,0x10
ffffffffc02013e2:	c6260613          	addi	a2,a2,-926 # ffffffffc0211040 <free_area>
ffffffffc02013e6:	4a0c                	lw	a1,16(a2)
ffffffffc02013e8:	86aa                	mv	a3,a0
ffffffffc02013ea:	02059793          	slli	a5,a1,0x20
ffffffffc02013ee:	9381                	srli	a5,a5,0x20
ffffffffc02013f0:	00a7eb63          	bltu	a5,a0,ffffffffc0201406 <default_alloc_pages+0x2a>
    list_entry_t *le = &free_list;
ffffffffc02013f4:	87b2                	mv	a5,a2
ffffffffc02013f6:	a029                	j	ffffffffc0201400 <default_alloc_pages+0x24>
        if (p->property >= n) {
ffffffffc02013f8:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02013fc:	00d77763          	bgeu	a4,a3,ffffffffc020140a <default_alloc_pages+0x2e>
    return listelm->next;
ffffffffc0201400:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201402:	fec79be3          	bne	a5,a2,ffffffffc02013f8 <default_alloc_pages+0x1c>
        return NULL;
ffffffffc0201406:	4501                	li	a0,0
}
ffffffffc0201408:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc020140a:	6798                	ld	a4,8(a5)
    return listelm->prev;
ffffffffc020140c:	0007b803          	ld	a6,0(a5)
        if (page->property > n) {
ffffffffc0201410:	ff87a883          	lw	a7,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201414:	fe078513          	addi	a0,a5,-32
    prev->next = next;
ffffffffc0201418:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020141c:	01073023          	sd	a6,0(a4)
        if (page->property > n) {
ffffffffc0201420:	02089713          	slli	a4,a7,0x20
ffffffffc0201424:	9301                	srli	a4,a4,0x20
            p->property = page->property - n;
ffffffffc0201426:	0006831b          	sext.w	t1,a3
        if (page->property > n) {
ffffffffc020142a:	02e6fc63          	bgeu	a3,a4,ffffffffc0201462 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020142e:	00369713          	slli	a4,a3,0x3
ffffffffc0201432:	9736                	add	a4,a4,a3
ffffffffc0201434:	070e                	slli	a4,a4,0x3
ffffffffc0201436:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201438:	406888bb          	subw	a7,a7,t1
ffffffffc020143c:	01172c23          	sw	a7,24(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201440:	4689                	li	a3,2
ffffffffc0201442:	00870593          	addi	a1,a4,8
ffffffffc0201446:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020144a:	00883683          	ld	a3,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc020144e:	02070893          	addi	a7,a4,32
        nr_free -= n;
ffffffffc0201452:	4a0c                	lw	a1,16(a2)
    prev->next = next->prev = elm;
ffffffffc0201454:	0116b023          	sd	a7,0(a3)
ffffffffc0201458:	01183423          	sd	a7,8(a6)
    elm->next = next;
ffffffffc020145c:	f714                	sd	a3,40(a4)
    elm->prev = prev;
ffffffffc020145e:	03073023          	sd	a6,32(a4)
ffffffffc0201462:	406585bb          	subw	a1,a1,t1
ffffffffc0201466:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201468:	5775                	li	a4,-3
ffffffffc020146a:	17a1                	addi	a5,a5,-24
ffffffffc020146c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201470:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201472:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201474:	00004697          	auipc	a3,0x4
ffffffffc0201478:	cd468693          	addi	a3,a3,-812 # ffffffffc0205148 <etext+0xc34>
ffffffffc020147c:	00004617          	auipc	a2,0x4
ffffffffc0201480:	97460613          	addi	a2,a2,-1676 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0201484:	06200593          	li	a1,98
ffffffffc0201488:	00004517          	auipc	a0,0x4
ffffffffc020148c:	98050513          	addi	a0,a0,-1664 # ffffffffc0204e08 <etext+0x8f4>
default_alloc_pages(size_t n) {
ffffffffc0201490:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201492:	ecffe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0201496 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201496:	1141                	addi	sp,sp,-16
ffffffffc0201498:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020149a:	c9e1                	beqz	a1,ffffffffc020156a <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020149c:	00359713          	slli	a4,a1,0x3
ffffffffc02014a0:	972e                	add	a4,a4,a1
ffffffffc02014a2:	070e                	slli	a4,a4,0x3
ffffffffc02014a4:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02014a8:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02014aa:	cf11                	beqz	a4,ffffffffc02014c6 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014ac:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014ae:	8b05                	andi	a4,a4,1
ffffffffc02014b0:	cf49                	beqz	a4,ffffffffc020154a <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014b2:	0007ac23          	sw	zero,24(a5)
ffffffffc02014b6:	0007b423          	sd	zero,8(a5)
ffffffffc02014ba:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014be:	04878793          	addi	a5,a5,72
ffffffffc02014c2:	fed795e3          	bne	a5,a3,ffffffffc02014ac <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014c6:	2581                	sext.w	a1,a1
ffffffffc02014c8:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014ca:	4789                	li	a5,2
ffffffffc02014cc:	00850713          	addi	a4,a0,8
ffffffffc02014d0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014d4:	00010697          	auipc	a3,0x10
ffffffffc02014d8:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0211040 <free_area>
ffffffffc02014dc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014de:	669c                	ld	a5,8(a3)
ffffffffc02014e0:	9f2d                	addw	a4,a4,a1
ffffffffc02014e2:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02014e4:	04d78663          	beq	a5,a3,ffffffffc0201530 <default_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc02014e8:	fe078713          	addi	a4,a5,-32
ffffffffc02014ec:	4581                	li	a1,0
ffffffffc02014ee:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02014f2:	00e56a63          	bltu	a0,a4,ffffffffc0201506 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02014f6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014f8:	02d70263          	beq	a4,a3,ffffffffc020151c <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc02014fc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02014fe:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201502:	fee57ae3          	bgeu	a0,a4,ffffffffc02014f6 <default_init_memmap+0x60>
ffffffffc0201506:	c199                	beqz	a1,ffffffffc020150c <default_init_memmap+0x76>
ffffffffc0201508:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020150c:	6398                	ld	a4,0(a5)
}
ffffffffc020150e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201510:	e390                	sd	a2,0(a5)
ffffffffc0201512:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201514:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201516:	f118                	sd	a4,32(a0)
ffffffffc0201518:	0141                	addi	sp,sp,16
ffffffffc020151a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020151c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020151e:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201520:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201522:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0201524:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201526:	00d70e63          	beq	a4,a3,ffffffffc0201542 <default_init_memmap+0xac>
ffffffffc020152a:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020152c:	87ba                	mv	a5,a4
ffffffffc020152e:	bfc1                	j	ffffffffc02014fe <default_init_memmap+0x68>
}
ffffffffc0201530:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201532:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201536:	e398                	sd	a4,0(a5)
ffffffffc0201538:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020153a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020153c:	f11c                	sd	a5,32(a0)
}
ffffffffc020153e:	0141                	addi	sp,sp,16
ffffffffc0201540:	8082                	ret
ffffffffc0201542:	60a2                	ld	ra,8(sp)
ffffffffc0201544:	e290                	sd	a2,0(a3)
ffffffffc0201546:	0141                	addi	sp,sp,16
ffffffffc0201548:	8082                	ret
        assert(PageReserved(p));
ffffffffc020154a:	00004697          	auipc	a3,0x4
ffffffffc020154e:	c2e68693          	addi	a3,a3,-978 # ffffffffc0205178 <etext+0xc64>
ffffffffc0201552:	00004617          	auipc	a2,0x4
ffffffffc0201556:	89e60613          	addi	a2,a2,-1890 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020155a:	04900593          	li	a1,73
ffffffffc020155e:	00004517          	auipc	a0,0x4
ffffffffc0201562:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201566:	dfbfe0ef          	jal	ffffffffc0200360 <__panic>
    assert(n > 0);
ffffffffc020156a:	00004697          	auipc	a3,0x4
ffffffffc020156e:	bde68693          	addi	a3,a3,-1058 # ffffffffc0205148 <etext+0xc34>
ffffffffc0201572:	00004617          	auipc	a2,0x4
ffffffffc0201576:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020157a:	04600593          	li	a1,70
ffffffffc020157e:	00004517          	auipc	a0,0x4
ffffffffc0201582:	88a50513          	addi	a0,a0,-1910 # ffffffffc0204e08 <etext+0x8f4>
ffffffffc0201586:	ddbfe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020158a <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc020158a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020158c:	00004617          	auipc	a2,0x4
ffffffffc0201590:	c1460613          	addi	a2,a2,-1004 # ffffffffc02051a0 <etext+0xc8c>
ffffffffc0201594:	06500593          	li	a1,101
ffffffffc0201598:	00004517          	auipc	a0,0x4
ffffffffc020159c:	c2850513          	addi	a0,a0,-984 # ffffffffc02051c0 <etext+0xcac>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015a0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015a2:	dbffe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02015a6 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015a6:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	c2860613          	addi	a2,a2,-984 # ffffffffc02051d0 <etext+0xcbc>
ffffffffc02015b0:	07000593          	li	a1,112
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	c0c50513          	addi	a0,a0,-1012 # ffffffffc02051c0 <etext+0xcac>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015bc:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015be:	da3fe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02015c2 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015c2:	7139                	addi	sp,sp,-64
ffffffffc02015c4:	f426                	sd	s1,40(sp)
ffffffffc02015c6:	f04a                	sd	s2,32(sp)
ffffffffc02015c8:	ec4e                	sd	s3,24(sp)
ffffffffc02015ca:	e852                	sd	s4,16(sp)
ffffffffc02015cc:	e456                	sd	s5,8(sp)
ffffffffc02015ce:	e05a                	sd	s6,0(sp)
ffffffffc02015d0:	fc06                	sd	ra,56(sp)
ffffffffc02015d2:	f822                	sd	s0,48(sp)
ffffffffc02015d4:	84aa                	mv	s1,a0
ffffffffc02015d6:	00010917          	auipc	s2,0x10
ffffffffc02015da:	f3a90913          	addi	s2,s2,-198 # ffffffffc0211510 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015de:	4a05                	li	s4,1
ffffffffc02015e0:	00010a97          	auipc	s5,0x10
ffffffffc02015e4:	f64a8a93          	addi	s5,s5,-156 # ffffffffc0211544 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02015e8:	0005099b          	sext.w	s3,a0
ffffffffc02015ec:	00010b17          	auipc	s6,0x10
ffffffffc02015f0:	f7cb0b13          	addi	s6,s6,-132 # ffffffffc0211568 <check_mm_struct>
ffffffffc02015f4:	a015                	j	ffffffffc0201618 <alloc_pages+0x56>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02015f6:	00093783          	ld	a5,0(s2)
ffffffffc02015fa:	6f9c                	ld	a5,24(a5)
ffffffffc02015fc:	9782                	jalr	a5
ffffffffc02015fe:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201600:	4601                	li	a2,0
ffffffffc0201602:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201604:	ec05                	bnez	s0,ffffffffc020163c <alloc_pages+0x7a>
ffffffffc0201606:	029a6b63          	bltu	s4,s1,ffffffffc020163c <alloc_pages+0x7a>
ffffffffc020160a:	000aa783          	lw	a5,0(s5)
ffffffffc020160e:	c79d                	beqz	a5,ffffffffc020163c <alloc_pages+0x7a>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201610:	000b3503          	ld	a0,0(s6)
ffffffffc0201614:	23d010ef          	jal	ffffffffc0203050 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201618:	100027f3          	csrr	a5,sstatus
ffffffffc020161c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020161e:	8526                	mv	a0,s1
ffffffffc0201620:	dbf9                	beqz	a5,ffffffffc02015f6 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201622:	ebbfe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0201626:	00093783          	ld	a5,0(s2)
ffffffffc020162a:	8526                	mv	a0,s1
ffffffffc020162c:	6f9c                	ld	a5,24(a5)
ffffffffc020162e:	9782                	jalr	a5
ffffffffc0201630:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201632:	ea5fe0ef          	jal	ffffffffc02004d6 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201636:	4601                	li	a2,0
ffffffffc0201638:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020163a:	d471                	beqz	s0,ffffffffc0201606 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020163c:	70e2                	ld	ra,56(sp)
ffffffffc020163e:	8522                	mv	a0,s0
ffffffffc0201640:	7442                	ld	s0,48(sp)
ffffffffc0201642:	74a2                	ld	s1,40(sp)
ffffffffc0201644:	7902                	ld	s2,32(sp)
ffffffffc0201646:	69e2                	ld	s3,24(sp)
ffffffffc0201648:	6a42                	ld	s4,16(sp)
ffffffffc020164a:	6aa2                	ld	s5,8(sp)
ffffffffc020164c:	6b02                	ld	s6,0(sp)
ffffffffc020164e:	6121                	addi	sp,sp,64
ffffffffc0201650:	8082                	ret

ffffffffc0201652 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201652:	100027f3          	csrr	a5,sstatus
ffffffffc0201656:	8b89                	andi	a5,a5,2
ffffffffc0201658:	e799                	bnez	a5,ffffffffc0201666 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020165a:	00010797          	auipc	a5,0x10
ffffffffc020165e:	eb67b783          	ld	a5,-330(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0201662:	739c                	ld	a5,32(a5)
ffffffffc0201664:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201666:	1101                	addi	sp,sp,-32
ffffffffc0201668:	ec06                	sd	ra,24(sp)
ffffffffc020166a:	e822                	sd	s0,16(sp)
ffffffffc020166c:	e426                	sd	s1,8(sp)
ffffffffc020166e:	842a                	mv	s0,a0
ffffffffc0201670:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201672:	e6bfe0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201676:	00010797          	auipc	a5,0x10
ffffffffc020167a:	e9a7b783          	ld	a5,-358(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc020167e:	739c                	ld	a5,32(a5)
ffffffffc0201680:	85a6                	mv	a1,s1
ffffffffc0201682:	8522                	mv	a0,s0
ffffffffc0201684:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201686:	6442                	ld	s0,16(sp)
ffffffffc0201688:	60e2                	ld	ra,24(sp)
ffffffffc020168a:	64a2                	ld	s1,8(sp)
ffffffffc020168c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020168e:	e49fe06f          	j	ffffffffc02004d6 <intr_enable>

ffffffffc0201692 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201692:	100027f3          	csrr	a5,sstatus
ffffffffc0201696:	8b89                	andi	a5,a5,2
ffffffffc0201698:	e799                	bnez	a5,ffffffffc02016a6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020169a:	00010797          	auipc	a5,0x10
ffffffffc020169e:	e767b783          	ld	a5,-394(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02016a2:	779c                	ld	a5,40(a5)
ffffffffc02016a4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016a6:	1141                	addi	sp,sp,-16
ffffffffc02016a8:	e406                	sd	ra,8(sp)
ffffffffc02016aa:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016ac:	e31fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016b0:	00010797          	auipc	a5,0x10
ffffffffc02016b4:	e607b783          	ld	a5,-416(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02016b8:	779c                	ld	a5,40(a5)
ffffffffc02016ba:	9782                	jalr	a5
ffffffffc02016bc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016be:	e19fe0ef          	jal	ffffffffc02004d6 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016c2:	60a2                	ld	ra,8(sp)
ffffffffc02016c4:	8522                	mv	a0,s0
ffffffffc02016c6:	6402                	ld	s0,0(sp)
ffffffffc02016c8:	0141                	addi	sp,sp,16
ffffffffc02016ca:	8082                	ret

ffffffffc02016cc <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016cc:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016d0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016d4:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016d6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016d8:	f052                	sd	s4,32(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016da:	00f50a33          	add	s4,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016de:	000a3683          	ld	a3,0(s4)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016e2:	f84a                	sd	s2,48(sp)
ffffffffc02016e4:	f44e                	sd	s3,40(sp)
ffffffffc02016e6:	ec56                	sd	s5,24(sp)
ffffffffc02016e8:	e486                	sd	ra,72(sp)
ffffffffc02016ea:	e0a2                	sd	s0,64(sp)
ffffffffc02016ec:	e85a                	sd	s6,16(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016ee:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f2:	892e                	mv	s2,a1
ffffffffc02016f4:	8ab2                	mv	s5,a2
ffffffffc02016f6:	00010997          	auipc	s3,0x10
ffffffffc02016fa:	e3a98993          	addi	s3,s3,-454 # ffffffffc0211530 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016fe:	efc1                	bnez	a5,ffffffffc0201796 <get_pte+0xca>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201700:	18060663          	beqz	a2,ffffffffc020188c <get_pte+0x1c0>
ffffffffc0201704:	4505                	li	a0,1
ffffffffc0201706:	ebdff0ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc020170a:	842a                	mv	s0,a0
ffffffffc020170c:	18050063          	beqz	a0,ffffffffc020188c <get_pte+0x1c0>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201710:	fc26                	sd	s1,56(sp)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201712:	f8e394b7          	lui	s1,0xf8e39
ffffffffc0201716:	e3948493          	addi	s1,s1,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc020171a:	e45e                	sd	s7,8(sp)
ffffffffc020171c:	04b2                	slli	s1,s1,0xc
ffffffffc020171e:	00010b97          	auipc	s7,0x10
ffffffffc0201722:	e1ab8b93          	addi	s7,s7,-486 # ffffffffc0211538 <pages>
ffffffffc0201726:	000bb503          	ld	a0,0(s7)
ffffffffc020172a:	e3948493          	addi	s1,s1,-455
ffffffffc020172e:	04b2                	slli	s1,s1,0xc
ffffffffc0201730:	e3948493          	addi	s1,s1,-455
ffffffffc0201734:	40a40533          	sub	a0,s0,a0
ffffffffc0201738:	04b2                	slli	s1,s1,0xc
ffffffffc020173a:	850d                	srai	a0,a0,0x3
ffffffffc020173c:	e3948493          	addi	s1,s1,-455
ffffffffc0201740:	02950533          	mul	a0,a0,s1
ffffffffc0201744:	00080b37          	lui	s6,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201748:	00010997          	auipc	s3,0x10
ffffffffc020174c:	de898993          	addi	s3,s3,-536 # ffffffffc0211530 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201750:	4785                	li	a5,1
ffffffffc0201752:	0009b703          	ld	a4,0(s3)
ffffffffc0201756:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201758:	955a                	add	a0,a0,s6
ffffffffc020175a:	00c51793          	slli	a5,a0,0xc
ffffffffc020175e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201760:	0532                	slli	a0,a0,0xc
ffffffffc0201762:	16e7ff63          	bgeu	a5,a4,ffffffffc02018e0 <get_pte+0x214>
ffffffffc0201766:	00010797          	auipc	a5,0x10
ffffffffc020176a:	dc27b783          	ld	a5,-574(a5) # ffffffffc0211528 <va_pa_offset>
ffffffffc020176e:	953e                	add	a0,a0,a5
ffffffffc0201770:	6605                	lui	a2,0x1
ffffffffc0201772:	4581                	li	a1,0
ffffffffc0201774:	577020ef          	jal	ffffffffc02044ea <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201778:	000bb783          	ld	a5,0(s7)
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020177c:	6ba2                	ld	s7,8(sp)
ffffffffc020177e:	40f406b3          	sub	a3,s0,a5
ffffffffc0201782:	868d                	srai	a3,a3,0x3
ffffffffc0201784:	029686b3          	mul	a3,a3,s1
ffffffffc0201788:	74e2                	ld	s1,56(sp)
ffffffffc020178a:	96da                	add	a3,a3,s6

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020178c:	06aa                	slli	a3,a3,0xa
ffffffffc020178e:	0116e693          	ori	a3,a3,17
ffffffffc0201792:	00da3023          	sd	a3,0(s4)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201796:	77fd                	lui	a5,0xfffff
ffffffffc0201798:	068a                	slli	a3,a3,0x2
ffffffffc020179a:	0009b703          	ld	a4,0(s3)
ffffffffc020179e:	8efd                	and	a3,a3,a5
ffffffffc02017a0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017a4:	0ee7f663          	bgeu	a5,a4,ffffffffc0201890 <get_pte+0x1c4>
ffffffffc02017a8:	00010b17          	auipc	s6,0x10
ffffffffc02017ac:	d80b0b13          	addi	s6,s6,-640 # ffffffffc0211528 <va_pa_offset>
ffffffffc02017b0:	000b3603          	ld	a2,0(s6)
ffffffffc02017b4:	01595793          	srli	a5,s2,0x15
ffffffffc02017b8:	1ff7f793          	andi	a5,a5,511
ffffffffc02017bc:	96b2                	add	a3,a3,a2
ffffffffc02017be:	078e                	slli	a5,a5,0x3
ffffffffc02017c0:	00f68433          	add	s0,a3,a5
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017c4:	6014                	ld	a3,0(s0)
ffffffffc02017c6:	0016f793          	andi	a5,a3,1
ffffffffc02017ca:	e7d1                	bnez	a5,ffffffffc0201856 <get_pte+0x18a>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017cc:	0c0a8063          	beqz	s5,ffffffffc020188c <get_pte+0x1c0>
ffffffffc02017d0:	4505                	li	a0,1
ffffffffc02017d2:	fc26                	sd	s1,56(sp)
ffffffffc02017d4:	defff0ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc02017d8:	84aa                	mv	s1,a0
ffffffffc02017da:	c945                	beqz	a0,ffffffffc020188a <get_pte+0x1be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017dc:	f8e39a37          	lui	s4,0xf8e39
ffffffffc02017e0:	e39a0a13          	addi	s4,s4,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc02017e4:	e45e                	sd	s7,8(sp)
ffffffffc02017e6:	0a32                	slli	s4,s4,0xc
ffffffffc02017e8:	00010b97          	auipc	s7,0x10
ffffffffc02017ec:	d50b8b93          	addi	s7,s7,-688 # ffffffffc0211538 <pages>
ffffffffc02017f0:	000bb683          	ld	a3,0(s7)
ffffffffc02017f4:	e39a0a13          	addi	s4,s4,-455
ffffffffc02017f8:	0a32                	slli	s4,s4,0xc
ffffffffc02017fa:	e39a0a13          	addi	s4,s4,-455
ffffffffc02017fe:	40d506b3          	sub	a3,a0,a3
ffffffffc0201802:	0a32                	slli	s4,s4,0xc
ffffffffc0201804:	868d                	srai	a3,a3,0x3
ffffffffc0201806:	e39a0a13          	addi	s4,s4,-455
ffffffffc020180a:	034686b3          	mul	a3,a3,s4
ffffffffc020180e:	00080ab7          	lui	s5,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201812:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201814:	0009b703          	ld	a4,0(s3)
ffffffffc0201818:	c11c                	sw	a5,0(a0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020181a:	96d6                	add	a3,a3,s5
ffffffffc020181c:	00c69793          	slli	a5,a3,0xc
ffffffffc0201820:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201822:	06b2                	slli	a3,a3,0xc
ffffffffc0201824:	0ae7f263          	bgeu	a5,a4,ffffffffc02018c8 <get_pte+0x1fc>
ffffffffc0201828:	000b3503          	ld	a0,0(s6)
ffffffffc020182c:	6605                	lui	a2,0x1
ffffffffc020182e:	4581                	li	a1,0
ffffffffc0201830:	9536                	add	a0,a0,a3
ffffffffc0201832:	4b9020ef          	jal	ffffffffc02044ea <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201836:	000bb783          	ld	a5,0(s7)
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020183a:	6ba2                	ld	s7,8(sp)
ffffffffc020183c:	40f486b3          	sub	a3,s1,a5
ffffffffc0201840:	868d                	srai	a3,a3,0x3
ffffffffc0201842:	034686b3          	mul	a3,a3,s4
ffffffffc0201846:	74e2                	ld	s1,56(sp)
ffffffffc0201848:	96d6                	add	a3,a3,s5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020184a:	06aa                	slli	a3,a3,0xa
ffffffffc020184c:	0116e693          	ori	a3,a3,17
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201850:	e014                	sd	a3,0(s0)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201852:	0009b703          	ld	a4,0(s3)
ffffffffc0201856:	77fd                	lui	a5,0xfffff
ffffffffc0201858:	068a                	slli	a3,a3,0x2
ffffffffc020185a:	8efd                	and	a3,a3,a5
ffffffffc020185c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201860:	04e7f663          	bgeu	a5,a4,ffffffffc02018ac <get_pte+0x1e0>
ffffffffc0201864:	000b3783          	ld	a5,0(s6)
ffffffffc0201868:	00c95913          	srli	s2,s2,0xc
ffffffffc020186c:	1ff97913          	andi	s2,s2,511
ffffffffc0201870:	96be                	add	a3,a3,a5
ffffffffc0201872:	090e                	slli	s2,s2,0x3
ffffffffc0201874:	01268533          	add	a0,a3,s2
}
ffffffffc0201878:	60a6                	ld	ra,72(sp)
ffffffffc020187a:	6406                	ld	s0,64(sp)
ffffffffc020187c:	7942                	ld	s2,48(sp)
ffffffffc020187e:	79a2                	ld	s3,40(sp)
ffffffffc0201880:	7a02                	ld	s4,32(sp)
ffffffffc0201882:	6ae2                	ld	s5,24(sp)
ffffffffc0201884:	6b42                	ld	s6,16(sp)
ffffffffc0201886:	6161                	addi	sp,sp,80
ffffffffc0201888:	8082                	ret
ffffffffc020188a:	74e2                	ld	s1,56(sp)
            return NULL;
ffffffffc020188c:	4501                	li	a0,0
ffffffffc020188e:	b7ed                	j	ffffffffc0201878 <get_pte+0x1ac>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201890:	00004617          	auipc	a2,0x4
ffffffffc0201894:	96860613          	addi	a2,a2,-1688 # ffffffffc02051f8 <etext+0xce4>
ffffffffc0201898:	10200593          	li	a1,258
ffffffffc020189c:	00004517          	auipc	a0,0x4
ffffffffc02018a0:	98450513          	addi	a0,a0,-1660 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02018a4:	fc26                	sd	s1,56(sp)
ffffffffc02018a6:	e45e                	sd	s7,8(sp)
ffffffffc02018a8:	ab9fe0ef          	jal	ffffffffc0200360 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018ac:	00004617          	auipc	a2,0x4
ffffffffc02018b0:	94c60613          	addi	a2,a2,-1716 # ffffffffc02051f8 <etext+0xce4>
ffffffffc02018b4:	10f00593          	li	a1,271
ffffffffc02018b8:	00004517          	auipc	a0,0x4
ffffffffc02018bc:	96850513          	addi	a0,a0,-1688 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02018c0:	fc26                	sd	s1,56(sp)
ffffffffc02018c2:	e45e                	sd	s7,8(sp)
ffffffffc02018c4:	a9dfe0ef          	jal	ffffffffc0200360 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018c8:	00004617          	auipc	a2,0x4
ffffffffc02018cc:	93060613          	addi	a2,a2,-1744 # ffffffffc02051f8 <etext+0xce4>
ffffffffc02018d0:	10b00593          	li	a1,267
ffffffffc02018d4:	00004517          	auipc	a0,0x4
ffffffffc02018d8:	94c50513          	addi	a0,a0,-1716 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02018dc:	a85fe0ef          	jal	ffffffffc0200360 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018e0:	86aa                	mv	a3,a0
ffffffffc02018e2:	00004617          	auipc	a2,0x4
ffffffffc02018e6:	91660613          	addi	a2,a2,-1770 # ffffffffc02051f8 <etext+0xce4>
ffffffffc02018ea:	0ff00593          	li	a1,255
ffffffffc02018ee:	00004517          	auipc	a0,0x4
ffffffffc02018f2:	93250513          	addi	a0,a0,-1742 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02018f6:	a6bfe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02018fa <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018fa:	1141                	addi	sp,sp,-16
ffffffffc02018fc:	e022                	sd	s0,0(sp)
ffffffffc02018fe:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201900:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201902:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201904:	dc9ff0ef          	jal	ffffffffc02016cc <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201908:	c011                	beqz	s0,ffffffffc020190c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020190a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020190c:	c511                	beqz	a0,ffffffffc0201918 <get_page+0x1e>
ffffffffc020190e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201910:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201912:	0017f713          	andi	a4,a5,1
ffffffffc0201916:	e709                	bnez	a4,ffffffffc0201920 <get_page+0x26>
}
ffffffffc0201918:	60a2                	ld	ra,8(sp)
ffffffffc020191a:	6402                	ld	s0,0(sp)
ffffffffc020191c:	0141                	addi	sp,sp,16
ffffffffc020191e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201920:	078a                	slli	a5,a5,0x2
ffffffffc0201922:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201924:	00010717          	auipc	a4,0x10
ffffffffc0201928:	c0c73703          	ld	a4,-1012(a4) # ffffffffc0211530 <npage>
ffffffffc020192c:	02e7f263          	bgeu	a5,a4,ffffffffc0201950 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201930:	fff80737          	lui	a4,0xfff80
ffffffffc0201934:	97ba                	add	a5,a5,a4
ffffffffc0201936:	60a2                	ld	ra,8(sp)
ffffffffc0201938:	6402                	ld	s0,0(sp)
ffffffffc020193a:	00379713          	slli	a4,a5,0x3
ffffffffc020193e:	97ba                	add	a5,a5,a4
ffffffffc0201940:	00010517          	auipc	a0,0x10
ffffffffc0201944:	bf853503          	ld	a0,-1032(a0) # ffffffffc0211538 <pages>
ffffffffc0201948:	078e                	slli	a5,a5,0x3
ffffffffc020194a:	953e                	add	a0,a0,a5
ffffffffc020194c:	0141                	addi	sp,sp,16
ffffffffc020194e:	8082                	ret
ffffffffc0201950:	c3bff0ef          	jal	ffffffffc020158a <pa2page.part.0>

ffffffffc0201954 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201954:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201956:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201958:	ec06                	sd	ra,24(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020195a:	d73ff0ef          	jal	ffffffffc02016cc <get_pte>
    if (ptep != NULL) {
ffffffffc020195e:	c901                	beqz	a0,ffffffffc020196e <page_remove+0x1a>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201960:	611c                	ld	a5,0(a0)
ffffffffc0201962:	e822                	sd	s0,16(sp)
ffffffffc0201964:	842a                	mv	s0,a0
ffffffffc0201966:	0017f713          	andi	a4,a5,1
ffffffffc020196a:	e709                	bnez	a4,ffffffffc0201974 <page_remove+0x20>
ffffffffc020196c:	6442                	ld	s0,16(sp)
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc020196e:	60e2                	ld	ra,24(sp)
ffffffffc0201970:	6105                	addi	sp,sp,32
ffffffffc0201972:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201974:	078a                	slli	a5,a5,0x2
ffffffffc0201976:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201978:	00010717          	auipc	a4,0x10
ffffffffc020197c:	bb873703          	ld	a4,-1096(a4) # ffffffffc0211530 <npage>
ffffffffc0201980:	06e7f563          	bgeu	a5,a4,ffffffffc02019ea <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0201984:	fff80737          	lui	a4,0xfff80
ffffffffc0201988:	97ba                	add	a5,a5,a4
ffffffffc020198a:	00379713          	slli	a4,a5,0x3
ffffffffc020198e:	97ba                	add	a5,a5,a4
ffffffffc0201990:	078e                	slli	a5,a5,0x3
ffffffffc0201992:	00010517          	auipc	a0,0x10
ffffffffc0201996:	ba653503          	ld	a0,-1114(a0) # ffffffffc0211538 <pages>
ffffffffc020199a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020199c:	411c                	lw	a5,0(a0)
ffffffffc020199e:	fff7871b          	addiw	a4,a5,-1 # ffffffffffffefff <end+0x3fdeda8f>
ffffffffc02019a2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02019a4:	cb09                	beqz	a4,ffffffffc02019b6 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02019a6:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019aa:	12000073          	sfence.vma
ffffffffc02019ae:	6442                	ld	s0,16(sp)
}
ffffffffc02019b0:	60e2                	ld	ra,24(sp)
ffffffffc02019b2:	6105                	addi	sp,sp,32
ffffffffc02019b4:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b6:	100027f3          	csrr	a5,sstatus
ffffffffc02019ba:	8b89                	andi	a5,a5,2
ffffffffc02019bc:	eb89                	bnez	a5,ffffffffc02019ce <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019be:	00010797          	auipc	a5,0x10
ffffffffc02019c2:	b527b783          	ld	a5,-1198(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02019c6:	739c                	ld	a5,32(a5)
ffffffffc02019c8:	4585                	li	a1,1
ffffffffc02019ca:	9782                	jalr	a5
    if (flag) {
ffffffffc02019cc:	bfe9                	j	ffffffffc02019a6 <page_remove+0x52>
        intr_disable();
ffffffffc02019ce:	e42a                	sd	a0,8(sp)
ffffffffc02019d0:	b0dfe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc02019d4:	00010797          	auipc	a5,0x10
ffffffffc02019d8:	b3c7b783          	ld	a5,-1220(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02019dc:	739c                	ld	a5,32(a5)
ffffffffc02019de:	6522                	ld	a0,8(sp)
ffffffffc02019e0:	4585                	li	a1,1
ffffffffc02019e2:	9782                	jalr	a5
        intr_enable();
ffffffffc02019e4:	af3fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02019e8:	bf7d                	j	ffffffffc02019a6 <page_remove+0x52>
ffffffffc02019ea:	ba1ff0ef          	jal	ffffffffc020158a <pa2page.part.0>

ffffffffc02019ee <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019ee:	7179                	addi	sp,sp,-48
ffffffffc02019f0:	87b2                	mv	a5,a2
ffffffffc02019f2:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019f4:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019f6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019f8:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019fa:	ec26                	sd	s1,24(sp)
ffffffffc02019fc:	f406                	sd	ra,40(sp)
ffffffffc02019fe:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a00:	ccdff0ef          	jal	ffffffffc02016cc <get_pte>
    if (ptep == NULL) {
ffffffffc0201a04:	c975                	beqz	a0,ffffffffc0201af8 <page_insert+0x10a>
    page->ref += 1;
ffffffffc0201a06:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a08:	611c                	ld	a5,0(a0)
ffffffffc0201a0a:	e44e                	sd	s3,8(sp)
ffffffffc0201a0c:	0016871b          	addiw	a4,a3,1
ffffffffc0201a10:	c018                	sw	a4,0(s0)
ffffffffc0201a12:	0017f713          	andi	a4,a5,1
ffffffffc0201a16:	89aa                	mv	s3,a0
ffffffffc0201a18:	eb21                	bnez	a4,ffffffffc0201a68 <page_insert+0x7a>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a1a:	00010717          	auipc	a4,0x10
ffffffffc0201a1e:	b1e73703          	ld	a4,-1250(a4) # ffffffffc0211538 <pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a22:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0201a26:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc0201a2a:	07b2                	slli	a5,a5,0xc
ffffffffc0201a2c:	e3978793          	addi	a5,a5,-455
ffffffffc0201a30:	07b2                	slli	a5,a5,0xc
ffffffffc0201a32:	e3978793          	addi	a5,a5,-455
ffffffffc0201a36:	8c19                	sub	s0,s0,a4
ffffffffc0201a38:	07b2                	slli	a5,a5,0xc
ffffffffc0201a3a:	840d                	srai	s0,s0,0x3
ffffffffc0201a3c:	e3978793          	addi	a5,a5,-455
ffffffffc0201a40:	02f407b3          	mul	a5,s0,a5
ffffffffc0201a44:	00080737          	lui	a4,0x80
ffffffffc0201a48:	97ba                	add	a5,a5,a4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a4a:	07aa                	slli	a5,a5,0xa
ffffffffc0201a4c:	8cdd                	or	s1,s1,a5
ffffffffc0201a4e:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a52:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a56:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a5a:	69a2                	ld	s3,8(sp)
ffffffffc0201a5c:	4501                	li	a0,0
}
ffffffffc0201a5e:	70a2                	ld	ra,40(sp)
ffffffffc0201a60:	7402                	ld	s0,32(sp)
ffffffffc0201a62:	64e2                	ld	s1,24(sp)
ffffffffc0201a64:	6145                	addi	sp,sp,48
ffffffffc0201a66:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a68:	078a                	slli	a5,a5,0x2
ffffffffc0201a6a:	e84a                	sd	s2,16(sp)
ffffffffc0201a6c:	e052                	sd	s4,0(sp)
ffffffffc0201a6e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a70:	00010717          	auipc	a4,0x10
ffffffffc0201a74:	ac073703          	ld	a4,-1344(a4) # ffffffffc0211530 <npage>
ffffffffc0201a78:	08e7f263          	bgeu	a5,a4,ffffffffc0201afc <page_insert+0x10e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a7c:	fff80737          	lui	a4,0xfff80
ffffffffc0201a80:	97ba                	add	a5,a5,a4
ffffffffc0201a82:	00010a17          	auipc	s4,0x10
ffffffffc0201a86:	ab6a0a13          	addi	s4,s4,-1354 # ffffffffc0211538 <pages>
ffffffffc0201a8a:	000a3703          	ld	a4,0(s4)
ffffffffc0201a8e:	00379913          	slli	s2,a5,0x3
ffffffffc0201a92:	993e                	add	s2,s2,a5
ffffffffc0201a94:	090e                	slli	s2,s2,0x3
ffffffffc0201a96:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0201a98:	03240263          	beq	s0,s2,ffffffffc0201abc <page_insert+0xce>
    page->ref -= 1;
ffffffffc0201a9c:	00092783          	lw	a5,0(s2)
ffffffffc0201aa0:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201aa4:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201aa8:	cf11                	beqz	a4,ffffffffc0201ac4 <page_insert+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201aaa:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201aae:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ab2:	000a3703          	ld	a4,0(s4)
ffffffffc0201ab6:	6942                	ld	s2,16(sp)
ffffffffc0201ab8:	6a02                	ld	s4,0(sp)
}
ffffffffc0201aba:	b7a5                	j	ffffffffc0201a22 <page_insert+0x34>
    return page->ref;
ffffffffc0201abc:	6942                	ld	s2,16(sp)
ffffffffc0201abe:	6a02                	ld	s4,0(sp)
    page->ref -= 1;
ffffffffc0201ac0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ac2:	b785                	j	ffffffffc0201a22 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ac4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ac8:	8b89                	andi	a5,a5,2
ffffffffc0201aca:	eb91                	bnez	a5,ffffffffc0201ade <page_insert+0xf0>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201acc:	00010797          	auipc	a5,0x10
ffffffffc0201ad0:	a447b783          	ld	a5,-1468(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0201ad4:	739c                	ld	a5,32(a5)
ffffffffc0201ad6:	4585                	li	a1,1
ffffffffc0201ad8:	854a                	mv	a0,s2
ffffffffc0201ada:	9782                	jalr	a5
    if (flag) {
ffffffffc0201adc:	b7f9                	j	ffffffffc0201aaa <page_insert+0xbc>
        intr_disable();
ffffffffc0201ade:	9fffe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0201ae2:	00010797          	auipc	a5,0x10
ffffffffc0201ae6:	a2e7b783          	ld	a5,-1490(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0201aea:	739c                	ld	a5,32(a5)
ffffffffc0201aec:	4585                	li	a1,1
ffffffffc0201aee:	854a                	mv	a0,s2
ffffffffc0201af0:	9782                	jalr	a5
        intr_enable();
ffffffffc0201af2:	9e5fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0201af6:	bf55                	j	ffffffffc0201aaa <page_insert+0xbc>
        return -E_NO_MEM;
ffffffffc0201af8:	5571                	li	a0,-4
ffffffffc0201afa:	b795                	j	ffffffffc0201a5e <page_insert+0x70>
ffffffffc0201afc:	a8fff0ef          	jal	ffffffffc020158a <pa2page.part.0>

ffffffffc0201b00 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b00:	00004797          	auipc	a5,0x4
ffffffffc0201b04:	66878793          	addi	a5,a5,1640 # ffffffffc0206168 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b08:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b0a:	7159                	addi	sp,sp,-112
ffffffffc0201b0c:	f486                	sd	ra,104(sp)
ffffffffc0201b0e:	eca6                	sd	s1,88(sp)
ffffffffc0201b10:	e4ce                	sd	s3,72(sp)
ffffffffc0201b12:	f85a                	sd	s6,48(sp)
ffffffffc0201b14:	f45e                	sd	s7,40(sp)
ffffffffc0201b16:	f0a2                	sd	s0,96(sp)
ffffffffc0201b18:	e8ca                	sd	s2,80(sp)
ffffffffc0201b1a:	e0d2                	sd	s4,64(sp)
ffffffffc0201b1c:	fc56                	sd	s5,56(sp)
ffffffffc0201b1e:	f062                	sd	s8,32(sp)
ffffffffc0201b20:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b22:	00010b97          	auipc	s7,0x10
ffffffffc0201b26:	9eeb8b93          	addi	s7,s7,-1554 # ffffffffc0211510 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b2a:	00003517          	auipc	a0,0x3
ffffffffc0201b2e:	70650513          	addi	a0,a0,1798 # ffffffffc0205230 <etext+0xd1c>
    pmm_manager = &default_pmm_manager;
ffffffffc0201b32:	00fbb023          	sd	a5,0(s7)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b36:	d84fe0ef          	jal	ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b3a:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b3e:	00010997          	auipc	s3,0x10
ffffffffc0201b42:	9ea98993          	addi	s3,s3,-1558 # ffffffffc0211528 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b46:	00010497          	auipc	s1,0x10
ffffffffc0201b4a:	9ea48493          	addi	s1,s1,-1558 # ffffffffc0211530 <npage>
    pmm_manager->init();
ffffffffc0201b4e:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b50:	00010b17          	auipc	s6,0x10
ffffffffc0201b54:	9e8b0b13          	addi	s6,s6,-1560 # ffffffffc0211538 <pages>
    pmm_manager->init();
ffffffffc0201b58:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b5a:	57f5                	li	a5,-3
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b5c:	4645                	li	a2,17
ffffffffc0201b5e:	40100593          	li	a1,1025
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b62:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b64:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b68:	066e                	slli	a2,a2,0x1b
ffffffffc0201b6a:	05d6                	slli	a1,a1,0x15
ffffffffc0201b6c:	00003517          	auipc	a0,0x3
ffffffffc0201b70:	6dc50513          	addi	a0,a0,1756 # ffffffffc0205248 <etext+0xd34>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b74:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b78:	d42fe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b7c:	00003517          	auipc	a0,0x3
ffffffffc0201b80:	6fc50513          	addi	a0,a0,1788 # ffffffffc0205278 <etext+0xd64>
ffffffffc0201b84:	d36fe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b88:	46c5                	li	a3,17
ffffffffc0201b8a:	06ee                	slli	a3,a3,0x1b
ffffffffc0201b8c:	40100613          	li	a2,1025
ffffffffc0201b90:	16fd                	addi	a3,a3,-1 # 7dfffff <kern_entry-0xffffffffb8400001>
ffffffffc0201b92:	0656                	slli	a2,a2,0x15
ffffffffc0201b94:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b98:	00003517          	auipc	a0,0x3
ffffffffc0201b9c:	6f850513          	addi	a0,a0,1784 # ffffffffc0205290 <etext+0xd7c>
ffffffffc0201ba0:	d1afe0ef          	jal	ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201ba4:	777d                	lui	a4,0xfffff
ffffffffc0201ba6:	00011797          	auipc	a5,0x11
ffffffffc0201baa:	9c978793          	addi	a5,a5,-1591 # ffffffffc021256f <end+0xfff>
ffffffffc0201bae:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201bb0:	00088737          	lui	a4,0x88
ffffffffc0201bb4:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bb6:	00fb3023          	sd	a5,0(s6)
ffffffffc0201bba:	4705                	li	a4,1
ffffffffc0201bbc:	07a1                	addi	a5,a5,8
ffffffffc0201bbe:	40e7b02f          	amoor.d	zero,a4,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bc2:	04800693          	li	a3,72
ffffffffc0201bc6:	4505                	li	a0,1
ffffffffc0201bc8:	fff805b7          	lui	a1,0xfff80
        SetPageReserved(pages + i);
ffffffffc0201bcc:	000b3783          	ld	a5,0(s6)
ffffffffc0201bd0:	97b6                	add	a5,a5,a3
ffffffffc0201bd2:	07a1                	addi	a5,a5,8
ffffffffc0201bd4:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bd8:	609c                	ld	a5,0(s1)
ffffffffc0201bda:	0705                	addi	a4,a4,1 # 88001 <kern_entry-0xffffffffc0177fff>
ffffffffc0201bdc:	04868693          	addi	a3,a3,72
ffffffffc0201be0:	00b78633          	add	a2,a5,a1
ffffffffc0201be4:	fec764e3          	bltu	a4,a2,ffffffffc0201bcc <pmm_init+0xcc>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201be8:	000b3503          	ld	a0,0(s6)
ffffffffc0201bec:	00379693          	slli	a3,a5,0x3
ffffffffc0201bf0:	96be                	add	a3,a3,a5
ffffffffc0201bf2:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bf6:	972a                	add	a4,a4,a0
ffffffffc0201bf8:	068e                	slli	a3,a3,0x3
ffffffffc0201bfa:	96ba                	add	a3,a3,a4
ffffffffc0201bfc:	c0200737          	lui	a4,0xc0200
ffffffffc0201c00:	68e6e563          	bltu	a3,a4,ffffffffc020228a <pmm_init+0x78a>
ffffffffc0201c04:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c08:	4645                	li	a2,17
ffffffffc0201c0a:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c0c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c0e:	50c6e363          	bltu	a3,a2,ffffffffc0202114 <pmm_init+0x614>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c12:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c16:	00010917          	auipc	s2,0x10
ffffffffc0201c1a:	90a90913          	addi	s2,s2,-1782 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c1e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c20:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c22:	00003517          	auipc	a0,0x3
ffffffffc0201c26:	6be50513          	addi	a0,a0,1726 # ffffffffc02052e0 <etext+0xdcc>
ffffffffc0201c2a:	c90fe0ef          	jal	ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c2e:	00007697          	auipc	a3,0x7
ffffffffc0201c32:	3d268693          	addi	a3,a3,978 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c36:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c3a:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c3e:	22f6eee3          	bltu	a3,a5,ffffffffc020267a <pmm_init+0xb7a>
ffffffffc0201c42:	0009b783          	ld	a5,0(s3)
ffffffffc0201c46:	8e9d                	sub	a3,a3,a5
ffffffffc0201c48:	00010797          	auipc	a5,0x10
ffffffffc0201c4c:	8cd7b823          	sd	a3,-1840(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c50:	100027f3          	csrr	a5,sstatus
ffffffffc0201c54:	8b89                	andi	a5,a5,2
ffffffffc0201c56:	4e079863          	bnez	a5,ffffffffc0202146 <pmm_init+0x646>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c5a:	000bb783          	ld	a5,0(s7)
ffffffffc0201c5e:	779c                	ld	a5,40(a5)
ffffffffc0201c60:	9782                	jalr	a5
ffffffffc0201c62:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c64:	6098                	ld	a4,0(s1)
ffffffffc0201c66:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c6a:	83b1                	srli	a5,a5,0xc
ffffffffc0201c6c:	66e7eb63          	bltu	a5,a4,ffffffffc02022e2 <pmm_init+0x7e2>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c70:	00093503          	ld	a0,0(s2)
ffffffffc0201c74:	64050763          	beqz	a0,ffffffffc02022c2 <pmm_init+0x7c2>
ffffffffc0201c78:	03451793          	slli	a5,a0,0x34
ffffffffc0201c7c:	64079363          	bnez	a5,ffffffffc02022c2 <pmm_init+0x7c2>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c80:	4601                	li	a2,0
ffffffffc0201c82:	4581                	li	a1,0
ffffffffc0201c84:	c77ff0ef          	jal	ffffffffc02018fa <get_page>
ffffffffc0201c88:	6a051f63          	bnez	a0,ffffffffc0202346 <pmm_init+0x846>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c8c:	4505                	li	a0,1
ffffffffc0201c8e:	935ff0ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0201c92:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c94:	00093503          	ld	a0,0(s2)
ffffffffc0201c98:	4681                	li	a3,0
ffffffffc0201c9a:	4601                	li	a2,0
ffffffffc0201c9c:	85d2                	mv	a1,s4
ffffffffc0201c9e:	d51ff0ef          	jal	ffffffffc02019ee <page_insert>
ffffffffc0201ca2:	68051263          	bnez	a0,ffffffffc0202326 <pmm_init+0x826>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201ca6:	00093503          	ld	a0,0(s2)
ffffffffc0201caa:	4601                	li	a2,0
ffffffffc0201cac:	4581                	li	a1,0
ffffffffc0201cae:	a1fff0ef          	jal	ffffffffc02016cc <get_pte>
ffffffffc0201cb2:	64050a63          	beqz	a0,ffffffffc0202306 <pmm_init+0x806>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cb6:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cb8:	0017f713          	andi	a4,a5,1
ffffffffc0201cbc:	64070363          	beqz	a4,ffffffffc0202302 <pmm_init+0x802>
    if (PPN(pa) >= npage) {
ffffffffc0201cc0:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201cc2:	078a                	slli	a5,a5,0x2
ffffffffc0201cc4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cc6:	5ac7f063          	bgeu	a5,a2,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cca:	fff80737          	lui	a4,0xfff80
ffffffffc0201cce:	97ba                	add	a5,a5,a4
ffffffffc0201cd0:	000b3683          	ld	a3,0(s6)
ffffffffc0201cd4:	00379713          	slli	a4,a5,0x3
ffffffffc0201cd8:	97ba                	add	a5,a5,a4
ffffffffc0201cda:	078e                	slli	a5,a5,0x3
ffffffffc0201cdc:	97b6                	add	a5,a5,a3
ffffffffc0201cde:	58fa1663          	bne	s4,a5,ffffffffc020226a <pmm_init+0x76a>
    assert(page_ref(p1) == 1);
ffffffffc0201ce2:	000a2703          	lw	a4,0(s4)
ffffffffc0201ce6:	4785                	li	a5,1
ffffffffc0201ce8:	1cf711e3          	bne	a4,a5,ffffffffc02026aa <pmm_init+0xbaa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201cec:	00093503          	ld	a0,0(s2)
ffffffffc0201cf0:	77fd                	lui	a5,0xfffff
ffffffffc0201cf2:	6114                	ld	a3,0(a0)
ffffffffc0201cf4:	068a                	slli	a3,a3,0x2
ffffffffc0201cf6:	8efd                	and	a3,a3,a5
ffffffffc0201cf8:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201cfc:	18c77be3          	bgeu	a4,a2,ffffffffc0202692 <pmm_init+0xb92>
ffffffffc0201d00:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d04:	96e2                	add	a3,a3,s8
ffffffffc0201d06:	0006ba83          	ld	s5,0(a3)
ffffffffc0201d0a:	0a8a                	slli	s5,s5,0x2
ffffffffc0201d0c:	00fafab3          	and	s5,s5,a5
ffffffffc0201d10:	00cad793          	srli	a5,s5,0xc
ffffffffc0201d14:	6ac7f963          	bgeu	a5,a2,ffffffffc02023c6 <pmm_init+0x8c6>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d18:	4601                	li	a2,0
ffffffffc0201d1a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d1c:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d1e:	9afff0ef          	jal	ffffffffc02016cc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d22:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d24:	69851163          	bne	a0,s8,ffffffffc02023a6 <pmm_init+0x8a6>

    p2 = alloc_page();
ffffffffc0201d28:	4505                	li	a0,1
ffffffffc0201d2a:	899ff0ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0201d2e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d30:	00093503          	ld	a0,0(s2)
ffffffffc0201d34:	46d1                	li	a3,20
ffffffffc0201d36:	6605                	lui	a2,0x1
ffffffffc0201d38:	85d6                	mv	a1,s5
ffffffffc0201d3a:	cb5ff0ef          	jal	ffffffffc02019ee <page_insert>
ffffffffc0201d3e:	64051463          	bnez	a0,ffffffffc0202386 <pmm_init+0x886>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d42:	00093503          	ld	a0,0(s2)
ffffffffc0201d46:	4601                	li	a2,0
ffffffffc0201d48:	6585                	lui	a1,0x1
ffffffffc0201d4a:	983ff0ef          	jal	ffffffffc02016cc <get_pte>
ffffffffc0201d4e:	60050c63          	beqz	a0,ffffffffc0202366 <pmm_init+0x866>
    assert(*ptep & PTE_U);
ffffffffc0201d52:	611c                	ld	a5,0(a0)
ffffffffc0201d54:	0107f713          	andi	a4,a5,16
ffffffffc0201d58:	76070463          	beqz	a4,ffffffffc02024c0 <pmm_init+0x9c0>
    assert(*ptep & PTE_W);
ffffffffc0201d5c:	8b91                	andi	a5,a5,4
ffffffffc0201d5e:	74078163          	beqz	a5,ffffffffc02024a0 <pmm_init+0x9a0>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d62:	00093503          	ld	a0,0(s2)
ffffffffc0201d66:	611c                	ld	a5,0(a0)
ffffffffc0201d68:	8bc1                	andi	a5,a5,16
ffffffffc0201d6a:	70078b63          	beqz	a5,ffffffffc0202480 <pmm_init+0x980>
    assert(page_ref(p2) == 1);
ffffffffc0201d6e:	000aa703          	lw	a4,0(s5) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0201d72:	4785                	li	a5,1
ffffffffc0201d74:	6ef71663          	bne	a4,a5,ffffffffc0202460 <pmm_init+0x960>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d78:	4681                	li	a3,0
ffffffffc0201d7a:	6605                	lui	a2,0x1
ffffffffc0201d7c:	85d2                	mv	a1,s4
ffffffffc0201d7e:	c71ff0ef          	jal	ffffffffc02019ee <page_insert>
ffffffffc0201d82:	6a051f63          	bnez	a0,ffffffffc0202440 <pmm_init+0x940>
    assert(page_ref(p1) == 2);
ffffffffc0201d86:	000a2703          	lw	a4,0(s4)
ffffffffc0201d8a:	4789                	li	a5,2
ffffffffc0201d8c:	68f71a63          	bne	a4,a5,ffffffffc0202420 <pmm_init+0x920>
    assert(page_ref(p2) == 0);
ffffffffc0201d90:	000aa783          	lw	a5,0(s5)
ffffffffc0201d94:	66079663          	bnez	a5,ffffffffc0202400 <pmm_init+0x900>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d98:	00093503          	ld	a0,0(s2)
ffffffffc0201d9c:	4601                	li	a2,0
ffffffffc0201d9e:	6585                	lui	a1,0x1
ffffffffc0201da0:	92dff0ef          	jal	ffffffffc02016cc <get_pte>
ffffffffc0201da4:	62050e63          	beqz	a0,ffffffffc02023e0 <pmm_init+0x8e0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201da8:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201daa:	00177793          	andi	a5,a4,1
ffffffffc0201dae:	54078a63          	beqz	a5,ffffffffc0202302 <pmm_init+0x802>
    if (PPN(pa) >= npage) {
ffffffffc0201db2:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201db4:	00271793          	slli	a5,a4,0x2
ffffffffc0201db8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dba:	4ad7f663          	bgeu	a5,a3,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dbe:	fff806b7          	lui	a3,0xfff80
ffffffffc0201dc2:	97b6                	add	a5,a5,a3
ffffffffc0201dc4:	000b3603          	ld	a2,0(s6)
ffffffffc0201dc8:	00379693          	slli	a3,a5,0x3
ffffffffc0201dcc:	97b6                	add	a5,a5,a3
ffffffffc0201dce:	078e                	slli	a5,a5,0x3
ffffffffc0201dd0:	97b2                	add	a5,a5,a2
ffffffffc0201dd2:	76fa1763          	bne	s4,a5,ffffffffc0202540 <pmm_init+0xa40>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dd6:	8b41                	andi	a4,a4,16
ffffffffc0201dd8:	74071463          	bnez	a4,ffffffffc0202520 <pmm_init+0xa20>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201ddc:	00093503          	ld	a0,0(s2)
ffffffffc0201de0:	4581                	li	a1,0
ffffffffc0201de2:	b73ff0ef          	jal	ffffffffc0201954 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201de6:	000a2703          	lw	a4,0(s4)
ffffffffc0201dea:	4785                	li	a5,1
ffffffffc0201dec:	70f71a63          	bne	a4,a5,ffffffffc0202500 <pmm_init+0xa00>
    assert(page_ref(p2) == 0);
ffffffffc0201df0:	000aa783          	lw	a5,0(s5)
ffffffffc0201df4:	6e079663          	bnez	a5,ffffffffc02024e0 <pmm_init+0x9e0>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201df8:	00093503          	ld	a0,0(s2)
ffffffffc0201dfc:	6585                	lui	a1,0x1
ffffffffc0201dfe:	b57ff0ef          	jal	ffffffffc0201954 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e02:	000a2783          	lw	a5,0(s4)
ffffffffc0201e06:	7a079a63          	bnez	a5,ffffffffc02025ba <pmm_init+0xaba>
    assert(page_ref(p2) == 0);
ffffffffc0201e0a:	000aa783          	lw	a5,0(s5)
ffffffffc0201e0e:	78079663          	bnez	a5,ffffffffc020259a <pmm_init+0xa9a>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e12:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201e16:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e18:	000a3783          	ld	a5,0(s4)
ffffffffc0201e1c:	078a                	slli	a5,a5,0x2
ffffffffc0201e1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e20:	44c7f363          	bgeu	a5,a2,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e24:	fff80737          	lui	a4,0xfff80
ffffffffc0201e28:	97ba                	add	a5,a5,a4
ffffffffc0201e2a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e2e:	000b3503          	ld	a0,0(s6)
ffffffffc0201e32:	973e                	add	a4,a4,a5
ffffffffc0201e34:	070e                	slli	a4,a4,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e36:	00e507b3          	add	a5,a0,a4
ffffffffc0201e3a:	4394                	lw	a3,0(a5)
ffffffffc0201e3c:	4785                	li	a5,1
ffffffffc0201e3e:	72f69e63          	bne	a3,a5,ffffffffc020257a <pmm_init+0xa7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e42:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0201e46:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc0201e4a:	07b2                	slli	a5,a5,0xc
ffffffffc0201e4c:	e3978793          	addi	a5,a5,-455
ffffffffc0201e50:	07b2                	slli	a5,a5,0xc
ffffffffc0201e52:	e3978793          	addi	a5,a5,-455
ffffffffc0201e56:	07b2                	slli	a5,a5,0xc
ffffffffc0201e58:	870d                	srai	a4,a4,0x3
ffffffffc0201e5a:	e3978793          	addi	a5,a5,-455
ffffffffc0201e5e:	02f707b3          	mul	a5,a4,a5
ffffffffc0201e62:	00080737          	lui	a4,0x80
ffffffffc0201e66:	97ba                	add	a5,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e68:	00c79693          	slli	a3,a5,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e6c:	6ec7fb63          	bgeu	a5,a2,ffffffffc0202562 <pmm_init+0xa62>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e70:	0009b783          	ld	a5,0(s3)
ffffffffc0201e74:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e76:	639c                	ld	a5,0(a5)
ffffffffc0201e78:	078a                	slli	a5,a5,0x2
ffffffffc0201e7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e7c:	3ec7f563          	bgeu	a5,a2,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e80:	8f99                	sub	a5,a5,a4
ffffffffc0201e82:	00379713          	slli	a4,a5,0x3
ffffffffc0201e86:	97ba                	add	a5,a5,a4
ffffffffc0201e88:	078e                	slli	a5,a5,0x3
ffffffffc0201e8a:	953e                	add	a0,a0,a5
ffffffffc0201e8c:	100027f3          	csrr	a5,sstatus
ffffffffc0201e90:	8b89                	andi	a5,a5,2
ffffffffc0201e92:	30079463          	bnez	a5,ffffffffc020219a <pmm_init+0x69a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e96:	000bb783          	ld	a5,0(s7)
ffffffffc0201e9a:	4585                	li	a1,1
ffffffffc0201e9c:	739c                	ld	a5,32(a5)
ffffffffc0201e9e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201ea4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea6:	078a                	slli	a5,a5,0x2
ffffffffc0201ea8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eaa:	3ae7fe63          	bgeu	a5,a4,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eae:	fff80737          	lui	a4,0xfff80
ffffffffc0201eb2:	97ba                	add	a5,a5,a4
ffffffffc0201eb4:	000b3503          	ld	a0,0(s6)
ffffffffc0201eb8:	00379713          	slli	a4,a5,0x3
ffffffffc0201ebc:	97ba                	add	a5,a5,a4
ffffffffc0201ebe:	078e                	slli	a5,a5,0x3
ffffffffc0201ec0:	953e                	add	a0,a0,a5
ffffffffc0201ec2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ec6:	8b89                	andi	a5,a5,2
ffffffffc0201ec8:	2a079d63          	bnez	a5,ffffffffc0202182 <pmm_init+0x682>
ffffffffc0201ecc:	000bb783          	ld	a5,0(s7)
ffffffffc0201ed0:	4585                	li	a1,1
ffffffffc0201ed2:	739c                	ld	a5,32(a5)
ffffffffc0201ed4:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201ed6:	00093783          	ld	a5,0(s2)
ffffffffc0201eda:	0007b023          	sd	zero,0(a5)
ffffffffc0201ede:	100027f3          	csrr	a5,sstatus
ffffffffc0201ee2:	8b89                	andi	a5,a5,2
ffffffffc0201ee4:	28079563          	bnez	a5,ffffffffc020216e <pmm_init+0x66e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ee8:	000bb783          	ld	a5,0(s7)
ffffffffc0201eec:	779c                	ld	a5,40(a5)
ffffffffc0201eee:	9782                	jalr	a5
ffffffffc0201ef0:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201ef2:	77441463          	bne	s0,s4,ffffffffc020265a <pmm_init+0xb5a>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ef6:	00003517          	auipc	a0,0x3
ffffffffc0201efa:	6d250513          	addi	a0,a0,1746 # ffffffffc02055c8 <etext+0x10b4>
ffffffffc0201efe:	9bcfe0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0201f02:	100027f3          	csrr	a5,sstatus
ffffffffc0201f06:	8b89                	andi	a5,a5,2
ffffffffc0201f08:	24079963          	bnez	a5,ffffffffc020215a <pmm_init+0x65a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201f0c:	000bb783          	ld	a5,0(s7)
ffffffffc0201f10:	779c                	ld	a5,40(a5)
ffffffffc0201f12:	9782                	jalr	a5
ffffffffc0201f14:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f16:	6098                	ld	a4,0(s1)
ffffffffc0201f18:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f1c:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f1e:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f22:	6a05                	lui	s4,0x1
ffffffffc0201f24:	02f47c63          	bgeu	s0,a5,ffffffffc0201f5c <pmm_init+0x45c>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f28:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f2c:	00093503          	ld	a0,0(s2)
ffffffffc0201f30:	2ce7fe63          	bgeu	a5,a4,ffffffffc020220c <pmm_init+0x70c>
ffffffffc0201f34:	0009b583          	ld	a1,0(s3)
ffffffffc0201f38:	4601                	li	a2,0
ffffffffc0201f3a:	95a2                	add	a1,a1,s0
ffffffffc0201f3c:	f90ff0ef          	jal	ffffffffc02016cc <get_pte>
ffffffffc0201f40:	30050363          	beqz	a0,ffffffffc0202246 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f44:	611c                	ld	a5,0(a0)
ffffffffc0201f46:	078a                	slli	a5,a5,0x2
ffffffffc0201f48:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f4c:	2c879d63          	bne	a5,s0,ffffffffc0202226 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f50:	6098                	ld	a4,0(s1)
ffffffffc0201f52:	9452                	add	s0,s0,s4
ffffffffc0201f54:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f58:	fcf468e3          	bltu	s0,a5,ffffffffc0201f28 <pmm_init+0x428>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f5c:	00093783          	ld	a5,0(s2)
ffffffffc0201f60:	639c                	ld	a5,0(a5)
ffffffffc0201f62:	6c079c63          	bnez	a5,ffffffffc020263a <pmm_init+0xb3a>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f66:	4505                	li	a0,1
ffffffffc0201f68:	e5aff0ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0201f6c:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f6e:	00093503          	ld	a0,0(s2)
ffffffffc0201f72:	4699                	li	a3,6
ffffffffc0201f74:	10000613          	li	a2,256
ffffffffc0201f78:	85d2                	mv	a1,s4
ffffffffc0201f7a:	a75ff0ef          	jal	ffffffffc02019ee <page_insert>
ffffffffc0201f7e:	68051e63          	bnez	a0,ffffffffc020261a <pmm_init+0xb1a>
    assert(page_ref(p) == 1);
ffffffffc0201f82:	000a2703          	lw	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201f86:	4785                	li	a5,1
ffffffffc0201f88:	66f71963          	bne	a4,a5,ffffffffc02025fa <pmm_init+0xafa>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f8c:	00093503          	ld	a0,0(s2)
ffffffffc0201f90:	6605                	lui	a2,0x1
ffffffffc0201f92:	4699                	li	a3,6
ffffffffc0201f94:	10060613          	addi	a2,a2,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f98:	85d2                	mv	a1,s4
ffffffffc0201f9a:	a55ff0ef          	jal	ffffffffc02019ee <page_insert>
ffffffffc0201f9e:	62051e63          	bnez	a0,ffffffffc02025da <pmm_init+0xada>
    assert(page_ref(p) == 2);
ffffffffc0201fa2:	000a2703          	lw	a4,0(s4)
ffffffffc0201fa6:	4789                	li	a5,2
ffffffffc0201fa8:	76f71163          	bne	a4,a5,ffffffffc020270a <pmm_init+0xc0a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fac:	00003597          	auipc	a1,0x3
ffffffffc0201fb0:	75458593          	addi	a1,a1,1876 # ffffffffc0205700 <etext+0x11ec>
ffffffffc0201fb4:	10000513          	li	a0,256
ffffffffc0201fb8:	4d2020ef          	jal	ffffffffc020448a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fbc:	6585                	lui	a1,0x1
ffffffffc0201fbe:	10058593          	addi	a1,a1,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201fc2:	10000513          	li	a0,256
ffffffffc0201fc6:	4d6020ef          	jal	ffffffffc020449c <strcmp>
ffffffffc0201fca:	72051063          	bnez	a0,ffffffffc02026ea <pmm_init+0xbea>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fce:	f8e39437          	lui	s0,0xf8e39
ffffffffc0201fd2:	e3940413          	addi	s0,s0,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc0201fd6:	0432                	slli	s0,s0,0xc
ffffffffc0201fd8:	000b3683          	ld	a3,0(s6)
ffffffffc0201fdc:	e3940413          	addi	s0,s0,-455
ffffffffc0201fe0:	0432                	slli	s0,s0,0xc
ffffffffc0201fe2:	e3940413          	addi	s0,s0,-455
ffffffffc0201fe6:	40da06b3          	sub	a3,s4,a3
ffffffffc0201fea:	0432                	slli	s0,s0,0xc
ffffffffc0201fec:	868d                	srai	a3,a3,0x3
ffffffffc0201fee:	e3940413          	addi	s0,s0,-455
ffffffffc0201ff2:	028686b3          	mul	a3,a3,s0
ffffffffc0201ff6:	00080cb7          	lui	s9,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ffa:	6098                	ld	a4,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ffc:	96e6                	add	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ffe:	00c69793          	slli	a5,a3,0xc
ffffffffc0202002:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202004:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202006:	54e7fe63          	bgeu	a5,a4,ffffffffc0202562 <pmm_init+0xa62>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020200a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020200e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202012:	97b6                	add	a5,a5,a3
ffffffffc0202014:	10078023          	sb	zero,256(a5)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202018:	43c020ef          	jal	ffffffffc0204454 <strlen>
ffffffffc020201c:	6a051763          	bnez	a0,ffffffffc02026ca <pmm_init+0xbca>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202020:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202024:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202026:	000ab783          	ld	a5,0(s5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc020202a:	078a                	slli	a5,a5,0x2
ffffffffc020202c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020202e:	22c7fc63          	bgeu	a5,a2,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202032:	419787b3          	sub	a5,a5,s9
ffffffffc0202036:	00379713          	slli	a4,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020203a:	97ba                	add	a5,a5,a4
ffffffffc020203c:	028787b3          	mul	a5,a5,s0
ffffffffc0202040:	97e6                	add	a5,a5,s9
    return page2ppn(page) << PGSHIFT;
ffffffffc0202042:	00c79413          	slli	s0,a5,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202046:	50c7fd63          	bgeu	a5,a2,ffffffffc0202560 <pmm_init+0xa60>
ffffffffc020204a:	0009b783          	ld	a5,0(s3)
ffffffffc020204e:	943e                	add	s0,s0,a5
ffffffffc0202050:	100027f3          	csrr	a5,sstatus
ffffffffc0202054:	8b89                	andi	a5,a5,2
ffffffffc0202056:	1a079063          	bnez	a5,ffffffffc02021f6 <pmm_init+0x6f6>
    { pmm_manager->free_pages(base, n); }
ffffffffc020205a:	000bb783          	ld	a5,0(s7)
ffffffffc020205e:	4585                	li	a1,1
ffffffffc0202060:	8552                	mv	a0,s4
ffffffffc0202062:	739c                	ld	a5,32(a5)
ffffffffc0202064:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202066:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202068:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020206a:	078a                	slli	a5,a5,0x2
ffffffffc020206c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020206e:	1ee7fc63          	bgeu	a5,a4,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202072:	fff80737          	lui	a4,0xfff80
ffffffffc0202076:	97ba                	add	a5,a5,a4
ffffffffc0202078:	000b3503          	ld	a0,0(s6)
ffffffffc020207c:	00379713          	slli	a4,a5,0x3
ffffffffc0202080:	97ba                	add	a5,a5,a4
ffffffffc0202082:	078e                	slli	a5,a5,0x3
ffffffffc0202084:	953e                	add	a0,a0,a5
ffffffffc0202086:	100027f3          	csrr	a5,sstatus
ffffffffc020208a:	8b89                	andi	a5,a5,2
ffffffffc020208c:	14079963          	bnez	a5,ffffffffc02021de <pmm_init+0x6de>
ffffffffc0202090:	000bb783          	ld	a5,0(s7)
ffffffffc0202094:	4585                	li	a1,1
ffffffffc0202096:	739c                	ld	a5,32(a5)
ffffffffc0202098:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020209a:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020209e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020a0:	078a                	slli	a5,a5,0x2
ffffffffc02020a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020a4:	1ce7f163          	bgeu	a5,a4,ffffffffc0202266 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02020a8:	fff80737          	lui	a4,0xfff80
ffffffffc02020ac:	97ba                	add	a5,a5,a4
ffffffffc02020ae:	000b3503          	ld	a0,0(s6)
ffffffffc02020b2:	00379713          	slli	a4,a5,0x3
ffffffffc02020b6:	97ba                	add	a5,a5,a4
ffffffffc02020b8:	078e                	slli	a5,a5,0x3
ffffffffc02020ba:	953e                	add	a0,a0,a5
ffffffffc02020bc:	100027f3          	csrr	a5,sstatus
ffffffffc02020c0:	8b89                	andi	a5,a5,2
ffffffffc02020c2:	10079263          	bnez	a5,ffffffffc02021c6 <pmm_init+0x6c6>
ffffffffc02020c6:	000bb783          	ld	a5,0(s7)
ffffffffc02020ca:	4585                	li	a1,1
ffffffffc02020cc:	739c                	ld	a5,32(a5)
ffffffffc02020ce:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02020d0:	00093783          	ld	a5,0(s2)
ffffffffc02020d4:	0007b023          	sd	zero,0(a5)
ffffffffc02020d8:	100027f3          	csrr	a5,sstatus
ffffffffc02020dc:	8b89                	andi	a5,a5,2
ffffffffc02020de:	0c079a63          	bnez	a5,ffffffffc02021b2 <pmm_init+0x6b2>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020e2:	000bb783          	ld	a5,0(s7)
ffffffffc02020e6:	779c                	ld	a5,40(a5)
ffffffffc02020e8:	9782                	jalr	a5
ffffffffc02020ea:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02020ec:	1a8c1b63          	bne	s8,s0,ffffffffc02022a2 <pmm_init+0x7a2>
}
ffffffffc02020f0:	7406                	ld	s0,96(sp)
ffffffffc02020f2:	70a6                	ld	ra,104(sp)
ffffffffc02020f4:	64e6                	ld	s1,88(sp)
ffffffffc02020f6:	6946                	ld	s2,80(sp)
ffffffffc02020f8:	69a6                	ld	s3,72(sp)
ffffffffc02020fa:	6a06                	ld	s4,64(sp)
ffffffffc02020fc:	7ae2                	ld	s5,56(sp)
ffffffffc02020fe:	7b42                	ld	s6,48(sp)
ffffffffc0202100:	7ba2                	ld	s7,40(sp)
ffffffffc0202102:	7c02                	ld	s8,32(sp)
ffffffffc0202104:	6ce2                	ld	s9,24(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202106:	00003517          	auipc	a0,0x3
ffffffffc020210a:	67250513          	addi	a0,a0,1650 # ffffffffc0205778 <etext+0x1264>
}
ffffffffc020210e:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202110:	fabfd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202114:	6705                	lui	a4,0x1
ffffffffc0202116:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0202118:	96ba                	add	a3,a3,a4
ffffffffc020211a:	777d                	lui	a4,0xfffff
ffffffffc020211c:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc020211e:	00c75693          	srli	a3,a4,0xc
ffffffffc0202122:	14f6f263          	bgeu	a3,a5,ffffffffc0202266 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202126:	000bb583          	ld	a1,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020212a:	fff807b7          	lui	a5,0xfff80
ffffffffc020212e:	96be                	add	a3,a3,a5
ffffffffc0202130:	00369793          	slli	a5,a3,0x3
ffffffffc0202134:	97b6                	add	a5,a5,a3
ffffffffc0202136:	6994                	ld	a3,16(a1)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202138:	8e19                	sub	a2,a2,a4
ffffffffc020213a:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020213c:	00c65593          	srli	a1,a2,0xc
ffffffffc0202140:	953e                	add	a0,a0,a5
ffffffffc0202142:	9682                	jalr	a3
}
ffffffffc0202144:	b4f9                	j	ffffffffc0201c12 <pmm_init+0x112>
        intr_disable();
ffffffffc0202146:	b96fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020214a:	000bb783          	ld	a5,0(s7)
ffffffffc020214e:	779c                	ld	a5,40(a5)
ffffffffc0202150:	9782                	jalr	a5
ffffffffc0202152:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202154:	b82fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0202158:	b631                	j	ffffffffc0201c64 <pmm_init+0x164>
        intr_disable();
ffffffffc020215a:	b82fe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc020215e:	000bb783          	ld	a5,0(s7)
ffffffffc0202162:	779c                	ld	a5,40(a5)
ffffffffc0202164:	9782                	jalr	a5
ffffffffc0202166:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202168:	b6efe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc020216c:	b36d                	j	ffffffffc0201f16 <pmm_init+0x416>
        intr_disable();
ffffffffc020216e:	b6efe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0202172:	000bb783          	ld	a5,0(s7)
ffffffffc0202176:	779c                	ld	a5,40(a5)
ffffffffc0202178:	9782                	jalr	a5
ffffffffc020217a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020217c:	b5afe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0202180:	bb8d                	j	ffffffffc0201ef2 <pmm_init+0x3f2>
ffffffffc0202182:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202184:	b58fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202188:	000bb783          	ld	a5,0(s7)
ffffffffc020218c:	6522                	ld	a0,8(sp)
ffffffffc020218e:	4585                	li	a1,1
ffffffffc0202190:	739c                	ld	a5,32(a5)
ffffffffc0202192:	9782                	jalr	a5
        intr_enable();
ffffffffc0202194:	b42fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0202198:	bb3d                	j	ffffffffc0201ed6 <pmm_init+0x3d6>
ffffffffc020219a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020219c:	b40fe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc02021a0:	000bb783          	ld	a5,0(s7)
ffffffffc02021a4:	6522                	ld	a0,8(sp)
ffffffffc02021a6:	4585                	li	a1,1
ffffffffc02021a8:	739c                	ld	a5,32(a5)
ffffffffc02021aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02021ac:	b2afe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021b0:	b9c5                	j	ffffffffc0201ea0 <pmm_init+0x3a0>
        intr_disable();
ffffffffc02021b2:	b2afe0ef          	jal	ffffffffc02004dc <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02021b6:	000bb783          	ld	a5,0(s7)
ffffffffc02021ba:	779c                	ld	a5,40(a5)
ffffffffc02021bc:	9782                	jalr	a5
ffffffffc02021be:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02021c0:	b16fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021c4:	b725                	j	ffffffffc02020ec <pmm_init+0x5ec>
ffffffffc02021c6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021c8:	b14fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02021cc:	000bb783          	ld	a5,0(s7)
ffffffffc02021d0:	6522                	ld	a0,8(sp)
ffffffffc02021d2:	4585                	li	a1,1
ffffffffc02021d4:	739c                	ld	a5,32(a5)
ffffffffc02021d6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021d8:	afefe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021dc:	bdd5                	j	ffffffffc02020d0 <pmm_init+0x5d0>
ffffffffc02021de:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021e0:	afcfe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc02021e4:	000bb783          	ld	a5,0(s7)
ffffffffc02021e8:	6522                	ld	a0,8(sp)
ffffffffc02021ea:	4585                	li	a1,1
ffffffffc02021ec:	739c                	ld	a5,32(a5)
ffffffffc02021ee:	9782                	jalr	a5
        intr_enable();
ffffffffc02021f0:	ae6fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021f4:	b55d                	j	ffffffffc020209a <pmm_init+0x59a>
        intr_disable();
ffffffffc02021f6:	ae6fe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc02021fa:	000bb783          	ld	a5,0(s7)
ffffffffc02021fe:	4585                	li	a1,1
ffffffffc0202200:	8552                	mv	a0,s4
ffffffffc0202202:	739c                	ld	a5,32(a5)
ffffffffc0202204:	9782                	jalr	a5
        intr_enable();
ffffffffc0202206:	ad0fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc020220a:	bdb1                	j	ffffffffc0202066 <pmm_init+0x566>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020220c:	86a2                	mv	a3,s0
ffffffffc020220e:	00003617          	auipc	a2,0x3
ffffffffc0202212:	fea60613          	addi	a2,a2,-22 # ffffffffc02051f8 <etext+0xce4>
ffffffffc0202216:	1cd00593          	li	a1,461
ffffffffc020221a:	00003517          	auipc	a0,0x3
ffffffffc020221e:	00650513          	addi	a0,a0,6 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202222:	93efe0ef          	jal	ffffffffc0200360 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202226:	00003697          	auipc	a3,0x3
ffffffffc020222a:	40268693          	addi	a3,a3,1026 # ffffffffc0205628 <etext+0x1114>
ffffffffc020222e:	00003617          	auipc	a2,0x3
ffffffffc0202232:	bc260613          	addi	a2,a2,-1086 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202236:	1ce00593          	li	a1,462
ffffffffc020223a:	00003517          	auipc	a0,0x3
ffffffffc020223e:	fe650513          	addi	a0,a0,-26 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202242:	91efe0ef          	jal	ffffffffc0200360 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202246:	00003697          	auipc	a3,0x3
ffffffffc020224a:	3a268693          	addi	a3,a3,930 # ffffffffc02055e8 <etext+0x10d4>
ffffffffc020224e:	00003617          	auipc	a2,0x3
ffffffffc0202252:	ba260613          	addi	a2,a2,-1118 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202256:	1cd00593          	li	a1,461
ffffffffc020225a:	00003517          	auipc	a0,0x3
ffffffffc020225e:	fc650513          	addi	a0,a0,-58 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202262:	8fefe0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0202266:	b24ff0ef          	jal	ffffffffc020158a <pa2page.part.0>
    assert(pte2page(*ptep) == p1);
ffffffffc020226a:	00003697          	auipc	a3,0x3
ffffffffc020226e:	17668693          	addi	a3,a3,374 # ffffffffc02053e0 <etext+0xecc>
ffffffffc0202272:	00003617          	auipc	a2,0x3
ffffffffc0202276:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020227a:	19b00593          	li	a1,411
ffffffffc020227e:	00003517          	auipc	a0,0x3
ffffffffc0202282:	fa250513          	addi	a0,a0,-94 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202286:	8dafe0ef          	jal	ffffffffc0200360 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020228a:	00003617          	auipc	a2,0x3
ffffffffc020228e:	02e60613          	addi	a2,a2,46 # ffffffffc02052b8 <etext+0xda4>
ffffffffc0202292:	07700593          	li	a1,119
ffffffffc0202296:	00003517          	auipc	a0,0x3
ffffffffc020229a:	f8a50513          	addi	a0,a0,-118 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020229e:	8c2fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02022a2:	00003697          	auipc	a3,0x3
ffffffffc02022a6:	30668693          	addi	a3,a3,774 # ffffffffc02055a8 <etext+0x1094>
ffffffffc02022aa:	00003617          	auipc	a2,0x3
ffffffffc02022ae:	b4660613          	addi	a2,a2,-1210 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02022b2:	1e800593          	li	a1,488
ffffffffc02022b6:	00003517          	auipc	a0,0x3
ffffffffc02022ba:	f6a50513          	addi	a0,a0,-150 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02022be:	8a2fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02022c2:	00003697          	auipc	a3,0x3
ffffffffc02022c6:	05e68693          	addi	a3,a3,94 # ffffffffc0205320 <etext+0xe0c>
ffffffffc02022ca:	00003617          	auipc	a2,0x3
ffffffffc02022ce:	b2660613          	addi	a2,a2,-1242 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02022d2:	19300593          	li	a1,403
ffffffffc02022d6:	00003517          	auipc	a0,0x3
ffffffffc02022da:	f4a50513          	addi	a0,a0,-182 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02022de:	882fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02022e2:	00003697          	auipc	a3,0x3
ffffffffc02022e6:	01e68693          	addi	a3,a3,30 # ffffffffc0205300 <etext+0xdec>
ffffffffc02022ea:	00003617          	auipc	a2,0x3
ffffffffc02022ee:	b0660613          	addi	a2,a2,-1274 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02022f2:	19200593          	li	a1,402
ffffffffc02022f6:	00003517          	auipc	a0,0x3
ffffffffc02022fa:	f2a50513          	addi	a0,a0,-214 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02022fe:	862fe0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0202302:	aa4ff0ef          	jal	ffffffffc02015a6 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202306:	00003697          	auipc	a3,0x3
ffffffffc020230a:	0aa68693          	addi	a3,a3,170 # ffffffffc02053b0 <etext+0xe9c>
ffffffffc020230e:	00003617          	auipc	a2,0x3
ffffffffc0202312:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202316:	19a00593          	li	a1,410
ffffffffc020231a:	00003517          	auipc	a0,0x3
ffffffffc020231e:	f0650513          	addi	a0,a0,-250 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202322:	83efe0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202326:	00003697          	auipc	a3,0x3
ffffffffc020232a:	05a68693          	addi	a3,a3,90 # ffffffffc0205380 <etext+0xe6c>
ffffffffc020232e:	00003617          	auipc	a2,0x3
ffffffffc0202332:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202336:	19800593          	li	a1,408
ffffffffc020233a:	00003517          	auipc	a0,0x3
ffffffffc020233e:	ee650513          	addi	a0,a0,-282 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202342:	81efe0ef          	jal	ffffffffc0200360 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202346:	00003697          	auipc	a3,0x3
ffffffffc020234a:	01268693          	addi	a3,a3,18 # ffffffffc0205358 <etext+0xe44>
ffffffffc020234e:	00003617          	auipc	a2,0x3
ffffffffc0202352:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202356:	19400593          	li	a1,404
ffffffffc020235a:	00003517          	auipc	a0,0x3
ffffffffc020235e:	ec650513          	addi	a0,a0,-314 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202362:	ffffd0ef          	jal	ffffffffc0200360 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202366:	00003697          	auipc	a3,0x3
ffffffffc020236a:	10a68693          	addi	a3,a3,266 # ffffffffc0205470 <etext+0xf5c>
ffffffffc020236e:	00003617          	auipc	a2,0x3
ffffffffc0202372:	a8260613          	addi	a2,a2,-1406 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202376:	1a400593          	li	a1,420
ffffffffc020237a:	00003517          	auipc	a0,0x3
ffffffffc020237e:	ea650513          	addi	a0,a0,-346 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202382:	fdffd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202386:	00003697          	auipc	a3,0x3
ffffffffc020238a:	0b268693          	addi	a3,a3,178 # ffffffffc0205438 <etext+0xf24>
ffffffffc020238e:	00003617          	auipc	a2,0x3
ffffffffc0202392:	a6260613          	addi	a2,a2,-1438 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202396:	1a300593          	li	a1,419
ffffffffc020239a:	00003517          	auipc	a0,0x3
ffffffffc020239e:	e8650513          	addi	a0,a0,-378 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02023a2:	fbffd0ef          	jal	ffffffffc0200360 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02023a6:	00003697          	auipc	a3,0x3
ffffffffc02023aa:	06a68693          	addi	a3,a3,106 # ffffffffc0205410 <etext+0xefc>
ffffffffc02023ae:	00003617          	auipc	a2,0x3
ffffffffc02023b2:	a4260613          	addi	a2,a2,-1470 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02023b6:	1a000593          	li	a1,416
ffffffffc02023ba:	00003517          	auipc	a0,0x3
ffffffffc02023be:	e6650513          	addi	a0,a0,-410 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02023c2:	f9ffd0ef          	jal	ffffffffc0200360 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02023c6:	86d6                	mv	a3,s5
ffffffffc02023c8:	00003617          	auipc	a2,0x3
ffffffffc02023cc:	e3060613          	addi	a2,a2,-464 # ffffffffc02051f8 <etext+0xce4>
ffffffffc02023d0:	19f00593          	li	a1,415
ffffffffc02023d4:	00003517          	auipc	a0,0x3
ffffffffc02023d8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02023dc:	f85fd0ef          	jal	ffffffffc0200360 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02023e0:	00003697          	auipc	a3,0x3
ffffffffc02023e4:	09068693          	addi	a3,a3,144 # ffffffffc0205470 <etext+0xf5c>
ffffffffc02023e8:	00003617          	auipc	a2,0x3
ffffffffc02023ec:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02023f0:	1ad00593          	li	a1,429
ffffffffc02023f4:	00003517          	auipc	a0,0x3
ffffffffc02023f8:	e2c50513          	addi	a0,a0,-468 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02023fc:	f65fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202400:	00003697          	auipc	a3,0x3
ffffffffc0202404:	13868693          	addi	a3,a3,312 # ffffffffc0205538 <etext+0x1024>
ffffffffc0202408:	00003617          	auipc	a2,0x3
ffffffffc020240c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202410:	1ac00593          	li	a1,428
ffffffffc0202414:	00003517          	auipc	a0,0x3
ffffffffc0202418:	e0c50513          	addi	a0,a0,-500 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020241c:	f45fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202420:	00003697          	auipc	a3,0x3
ffffffffc0202424:	10068693          	addi	a3,a3,256 # ffffffffc0205520 <etext+0x100c>
ffffffffc0202428:	00003617          	auipc	a2,0x3
ffffffffc020242c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202430:	1ab00593          	li	a1,427
ffffffffc0202434:	00003517          	auipc	a0,0x3
ffffffffc0202438:	dec50513          	addi	a0,a0,-532 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020243c:	f25fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202440:	00003697          	auipc	a3,0x3
ffffffffc0202444:	0b068693          	addi	a3,a3,176 # ffffffffc02054f0 <etext+0xfdc>
ffffffffc0202448:	00003617          	auipc	a2,0x3
ffffffffc020244c:	9a860613          	addi	a2,a2,-1624 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202450:	1aa00593          	li	a1,426
ffffffffc0202454:	00003517          	auipc	a0,0x3
ffffffffc0202458:	dcc50513          	addi	a0,a0,-564 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020245c:	f05fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202460:	00003697          	auipc	a3,0x3
ffffffffc0202464:	07868693          	addi	a3,a3,120 # ffffffffc02054d8 <etext+0xfc4>
ffffffffc0202468:	00003617          	auipc	a2,0x3
ffffffffc020246c:	98860613          	addi	a2,a2,-1656 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202470:	1a800593          	li	a1,424
ffffffffc0202474:	00003517          	auipc	a0,0x3
ffffffffc0202478:	dac50513          	addi	a0,a0,-596 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020247c:	ee5fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202480:	00003697          	auipc	a3,0x3
ffffffffc0202484:	04068693          	addi	a3,a3,64 # ffffffffc02054c0 <etext+0xfac>
ffffffffc0202488:	00003617          	auipc	a2,0x3
ffffffffc020248c:	96860613          	addi	a2,a2,-1688 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202490:	1a700593          	li	a1,423
ffffffffc0202494:	00003517          	auipc	a0,0x3
ffffffffc0202498:	d8c50513          	addi	a0,a0,-628 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020249c:	ec5fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02024a0:	00003697          	auipc	a3,0x3
ffffffffc02024a4:	01068693          	addi	a3,a3,16 # ffffffffc02054b0 <etext+0xf9c>
ffffffffc02024a8:	00003617          	auipc	a2,0x3
ffffffffc02024ac:	94860613          	addi	a2,a2,-1720 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02024b0:	1a600593          	li	a1,422
ffffffffc02024b4:	00003517          	auipc	a0,0x3
ffffffffc02024b8:	d6c50513          	addi	a0,a0,-660 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02024bc:	ea5fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02024c0:	00003697          	auipc	a3,0x3
ffffffffc02024c4:	fe068693          	addi	a3,a3,-32 # ffffffffc02054a0 <etext+0xf8c>
ffffffffc02024c8:	00003617          	auipc	a2,0x3
ffffffffc02024cc:	92860613          	addi	a2,a2,-1752 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02024d0:	1a500593          	li	a1,421
ffffffffc02024d4:	00003517          	auipc	a0,0x3
ffffffffc02024d8:	d4c50513          	addi	a0,a0,-692 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02024dc:	e85fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024e0:	00003697          	auipc	a3,0x3
ffffffffc02024e4:	05868693          	addi	a3,a3,88 # ffffffffc0205538 <etext+0x1024>
ffffffffc02024e8:	00003617          	auipc	a2,0x3
ffffffffc02024ec:	90860613          	addi	a2,a2,-1784 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02024f0:	1b300593          	li	a1,435
ffffffffc02024f4:	00003517          	auipc	a0,0x3
ffffffffc02024f8:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02024fc:	e65fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202500:	00003697          	auipc	a3,0x3
ffffffffc0202504:	ef868693          	addi	a3,a3,-264 # ffffffffc02053f8 <etext+0xee4>
ffffffffc0202508:	00003617          	auipc	a2,0x3
ffffffffc020250c:	8e860613          	addi	a2,a2,-1816 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202510:	1b200593          	li	a1,434
ffffffffc0202514:	00003517          	auipc	a0,0x3
ffffffffc0202518:	d0c50513          	addi	a0,a0,-756 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020251c:	e45fd0ef          	jal	ffffffffc0200360 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202520:	00003697          	auipc	a3,0x3
ffffffffc0202524:	03068693          	addi	a3,a3,48 # ffffffffc0205550 <etext+0x103c>
ffffffffc0202528:	00003617          	auipc	a2,0x3
ffffffffc020252c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202530:	1af00593          	li	a1,431
ffffffffc0202534:	00003517          	auipc	a0,0x3
ffffffffc0202538:	cec50513          	addi	a0,a0,-788 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020253c:	e25fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202540:	00003697          	auipc	a3,0x3
ffffffffc0202544:	ea068693          	addi	a3,a3,-352 # ffffffffc02053e0 <etext+0xecc>
ffffffffc0202548:	00003617          	auipc	a2,0x3
ffffffffc020254c:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202550:	1ae00593          	li	a1,430
ffffffffc0202554:	00003517          	auipc	a0,0x3
ffffffffc0202558:	ccc50513          	addi	a0,a0,-820 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020255c:	e05fd0ef          	jal	ffffffffc0200360 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202560:	86a2                	mv	a3,s0
ffffffffc0202562:	00003617          	auipc	a2,0x3
ffffffffc0202566:	c9660613          	addi	a2,a2,-874 # ffffffffc02051f8 <etext+0xce4>
ffffffffc020256a:	06a00593          	li	a1,106
ffffffffc020256e:	00003517          	auipc	a0,0x3
ffffffffc0202572:	c5250513          	addi	a0,a0,-942 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0202576:	debfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020257a:	00003697          	auipc	a3,0x3
ffffffffc020257e:	00668693          	addi	a3,a3,6 # ffffffffc0205580 <etext+0x106c>
ffffffffc0202582:	00003617          	auipc	a2,0x3
ffffffffc0202586:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020258a:	1b900593          	li	a1,441
ffffffffc020258e:	00003517          	auipc	a0,0x3
ffffffffc0202592:	c9250513          	addi	a0,a0,-878 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202596:	dcbfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020259a:	00003697          	auipc	a3,0x3
ffffffffc020259e:	f9e68693          	addi	a3,a3,-98 # ffffffffc0205538 <etext+0x1024>
ffffffffc02025a2:	00003617          	auipc	a2,0x3
ffffffffc02025a6:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02025aa:	1b700593          	li	a1,439
ffffffffc02025ae:	00003517          	auipc	a0,0x3
ffffffffc02025b2:	c7250513          	addi	a0,a0,-910 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02025b6:	dabfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02025ba:	00003697          	auipc	a3,0x3
ffffffffc02025be:	fae68693          	addi	a3,a3,-82 # ffffffffc0205568 <etext+0x1054>
ffffffffc02025c2:	00003617          	auipc	a2,0x3
ffffffffc02025c6:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02025ca:	1b600593          	li	a1,438
ffffffffc02025ce:	00003517          	auipc	a0,0x3
ffffffffc02025d2:	c5250513          	addi	a0,a0,-942 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02025d6:	d8bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025da:	00003697          	auipc	a3,0x3
ffffffffc02025de:	0ce68693          	addi	a3,a3,206 # ffffffffc02056a8 <etext+0x1194>
ffffffffc02025e2:	00003617          	auipc	a2,0x3
ffffffffc02025e6:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02025ea:	1d800593          	li	a1,472
ffffffffc02025ee:	00003517          	auipc	a0,0x3
ffffffffc02025f2:	c3250513          	addi	a0,a0,-974 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02025f6:	d6bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025fa:	00003697          	auipc	a3,0x3
ffffffffc02025fe:	09668693          	addi	a3,a3,150 # ffffffffc0205690 <etext+0x117c>
ffffffffc0202602:	00002617          	auipc	a2,0x2
ffffffffc0202606:	7ee60613          	addi	a2,a2,2030 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020260a:	1d700593          	li	a1,471
ffffffffc020260e:	00003517          	auipc	a0,0x3
ffffffffc0202612:	c1250513          	addi	a0,a0,-1006 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202616:	d4bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020261a:	00003697          	auipc	a3,0x3
ffffffffc020261e:	03e68693          	addi	a3,a3,62 # ffffffffc0205658 <etext+0x1144>
ffffffffc0202622:	00002617          	auipc	a2,0x2
ffffffffc0202626:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020262a:	1d600593          	li	a1,470
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202636:	d2bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020263a:	00003697          	auipc	a3,0x3
ffffffffc020263e:	00668693          	addi	a3,a3,6 # ffffffffc0205640 <etext+0x112c>
ffffffffc0202642:	00002617          	auipc	a2,0x2
ffffffffc0202646:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020264a:	1d200593          	li	a1,466
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	bd250513          	addi	a0,a0,-1070 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202656:	d0bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020265a:	00003697          	auipc	a3,0x3
ffffffffc020265e:	f4e68693          	addi	a3,a3,-178 # ffffffffc02055a8 <etext+0x1094>
ffffffffc0202662:	00002617          	auipc	a2,0x2
ffffffffc0202666:	78e60613          	addi	a2,a2,1934 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020266a:	1c000593          	li	a1,448
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	bb250513          	addi	a0,a0,-1102 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202676:	cebfd0ef          	jal	ffffffffc0200360 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020267a:	00003617          	auipc	a2,0x3
ffffffffc020267e:	c3e60613          	addi	a2,a2,-962 # ffffffffc02052b8 <etext+0xda4>
ffffffffc0202682:	0bd00593          	li	a1,189
ffffffffc0202686:	00003517          	auipc	a0,0x3
ffffffffc020268a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0205220 <etext+0xd0c>
ffffffffc020268e:	cd3fd0ef          	jal	ffffffffc0200360 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202692:	00003617          	auipc	a2,0x3
ffffffffc0202696:	b6660613          	addi	a2,a2,-1178 # ffffffffc02051f8 <etext+0xce4>
ffffffffc020269a:	19e00593          	li	a1,414
ffffffffc020269e:	00003517          	auipc	a0,0x3
ffffffffc02026a2:	b8250513          	addi	a0,a0,-1150 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02026a6:	cbbfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02026aa:	00003697          	auipc	a3,0x3
ffffffffc02026ae:	d4e68693          	addi	a3,a3,-690 # ffffffffc02053f8 <etext+0xee4>
ffffffffc02026b2:	00002617          	auipc	a2,0x2
ffffffffc02026b6:	73e60613          	addi	a2,a2,1854 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02026ba:	19c00593          	li	a1,412
ffffffffc02026be:	00003517          	auipc	a0,0x3
ffffffffc02026c2:	b6250513          	addi	a0,a0,-1182 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02026c6:	c9bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02026ca:	00003697          	auipc	a3,0x3
ffffffffc02026ce:	08668693          	addi	a3,a3,134 # ffffffffc0205750 <etext+0x123c>
ffffffffc02026d2:	00002617          	auipc	a2,0x2
ffffffffc02026d6:	71e60613          	addi	a2,a2,1822 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02026da:	1e000593          	li	a1,480
ffffffffc02026de:	00003517          	auipc	a0,0x3
ffffffffc02026e2:	b4250513          	addi	a0,a0,-1214 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02026e6:	c7bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02026ea:	00003697          	auipc	a3,0x3
ffffffffc02026ee:	02e68693          	addi	a3,a3,46 # ffffffffc0205718 <etext+0x1204>
ffffffffc02026f2:	00002617          	auipc	a2,0x2
ffffffffc02026f6:	6fe60613          	addi	a2,a2,1790 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02026fa:	1dd00593          	li	a1,477
ffffffffc02026fe:	00003517          	auipc	a0,0x3
ffffffffc0202702:	b2250513          	addi	a0,a0,-1246 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202706:	c5bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020270a:	00003697          	auipc	a3,0x3
ffffffffc020270e:	fde68693          	addi	a3,a3,-34 # ffffffffc02056e8 <etext+0x11d4>
ffffffffc0202712:	00002617          	auipc	a2,0x2
ffffffffc0202716:	6de60613          	addi	a2,a2,1758 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020271a:	1d900593          	li	a1,473
ffffffffc020271e:	00003517          	auipc	a0,0x3
ffffffffc0202722:	b0250513          	addi	a0,a0,-1278 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202726:	c3bfd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020272a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc020272a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc020272e:	8082                	ret

ffffffffc0202730 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202730:	7179                	addi	sp,sp,-48
ffffffffc0202732:	e84a                	sd	s2,16(sp)
ffffffffc0202734:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202736:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202738:	ec26                	sd	s1,24(sp)
ffffffffc020273a:	e44e                	sd	s3,8(sp)
ffffffffc020273c:	f406                	sd	ra,40(sp)
ffffffffc020273e:	f022                	sd	s0,32(sp)
ffffffffc0202740:	84ae                	mv	s1,a1
ffffffffc0202742:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202744:	e7ffe0ef          	jal	ffffffffc02015c2 <alloc_pages>
    if (page != NULL) {
ffffffffc0202748:	c131                	beqz	a0,ffffffffc020278c <pgdir_alloc_page+0x5c>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020274a:	842a                	mv	s0,a0
ffffffffc020274c:	85aa                	mv	a1,a0
ffffffffc020274e:	86ce                	mv	a3,s3
ffffffffc0202750:	8626                	mv	a2,s1
ffffffffc0202752:	854a                	mv	a0,s2
ffffffffc0202754:	a9aff0ef          	jal	ffffffffc02019ee <page_insert>
ffffffffc0202758:	ed11                	bnez	a0,ffffffffc0202774 <pgdir_alloc_page+0x44>
        if (swap_init_ok) {
ffffffffc020275a:	0000f797          	auipc	a5,0xf
ffffffffc020275e:	dea7a783          	lw	a5,-534(a5) # ffffffffc0211544 <swap_init_ok>
ffffffffc0202762:	e79d                	bnez	a5,ffffffffc0202790 <pgdir_alloc_page+0x60>
}
ffffffffc0202764:	70a2                	ld	ra,40(sp)
ffffffffc0202766:	8522                	mv	a0,s0
ffffffffc0202768:	7402                	ld	s0,32(sp)
ffffffffc020276a:	64e2                	ld	s1,24(sp)
ffffffffc020276c:	6942                	ld	s2,16(sp)
ffffffffc020276e:	69a2                	ld	s3,8(sp)
ffffffffc0202770:	6145                	addi	sp,sp,48
ffffffffc0202772:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202774:	100027f3          	csrr	a5,sstatus
ffffffffc0202778:	8b89                	andi	a5,a5,2
ffffffffc020277a:	eba9                	bnez	a5,ffffffffc02027cc <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc020277c:	0000f797          	auipc	a5,0xf
ffffffffc0202780:	d947b783          	ld	a5,-620(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0202784:	739c                	ld	a5,32(a5)
ffffffffc0202786:	4585                	li	a1,1
ffffffffc0202788:	8522                	mv	a0,s0
ffffffffc020278a:	9782                	jalr	a5
            return NULL;
ffffffffc020278c:	4401                	li	s0,0
ffffffffc020278e:	bfd9                	j	ffffffffc0202764 <pgdir_alloc_page+0x34>
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202790:	4681                	li	a3,0
ffffffffc0202792:	8622                	mv	a2,s0
ffffffffc0202794:	85a6                	mv	a1,s1
ffffffffc0202796:	0000f517          	auipc	a0,0xf
ffffffffc020279a:	dd253503          	ld	a0,-558(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc020279e:	0a7000ef          	jal	ffffffffc0203044 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02027a2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02027a4:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02027a6:	4785                	li	a5,1
ffffffffc02027a8:	faf70ee3          	beq	a4,a5,ffffffffc0202764 <pgdir_alloc_page+0x34>
ffffffffc02027ac:	00003697          	auipc	a3,0x3
ffffffffc02027b0:	fec68693          	addi	a3,a3,-20 # ffffffffc0205798 <etext+0x1284>
ffffffffc02027b4:	00002617          	auipc	a2,0x2
ffffffffc02027b8:	63c60613          	addi	a2,a2,1596 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02027bc:	17a00593          	li	a1,378
ffffffffc02027c0:	00003517          	auipc	a0,0x3
ffffffffc02027c4:	a6050513          	addi	a0,a0,-1440 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02027c8:	b99fd0ef          	jal	ffffffffc0200360 <__panic>
        intr_disable();
ffffffffc02027cc:	d11fd0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027d0:	0000f797          	auipc	a5,0xf
ffffffffc02027d4:	d407b783          	ld	a5,-704(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02027d8:	739c                	ld	a5,32(a5)
ffffffffc02027da:	8522                	mv	a0,s0
ffffffffc02027dc:	4585                	li	a1,1
ffffffffc02027de:	9782                	jalr	a5
            return NULL;
ffffffffc02027e0:	4401                	li	s0,0
        intr_enable();
ffffffffc02027e2:	cf5fd0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02027e6:	bfbd                	j	ffffffffc0202764 <pgdir_alloc_page+0x34>

ffffffffc02027e8 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02027e8:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ea:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02027ec:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ee:	fff50713          	addi	a4,a0,-1
ffffffffc02027f2:	17f9                	addi	a5,a5,-2 # 14ffe <kern_entry-0xffffffffc01eb002>
ffffffffc02027f4:	06e7e363          	bltu	a5,a4,ffffffffc020285a <kmalloc+0x72>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027f8:	6785                	lui	a5,0x1
ffffffffc02027fa:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02027fc:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027fe:	8131                	srli	a0,a0,0xc
ffffffffc0202800:	dc3fe0ef          	jal	ffffffffc02015c2 <alloc_pages>
    assert(base != NULL);
ffffffffc0202804:	c941                	beqz	a0,ffffffffc0202894 <kmalloc+0xac>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202806:	f8e397b7          	lui	a5,0xf8e39
ffffffffc020280a:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc020280e:	07b2                	slli	a5,a5,0xc
ffffffffc0202810:	e3978793          	addi	a5,a5,-455
ffffffffc0202814:	07b2                	slli	a5,a5,0xc
ffffffffc0202816:	0000f717          	auipc	a4,0xf
ffffffffc020281a:	d2273703          	ld	a4,-734(a4) # ffffffffc0211538 <pages>
ffffffffc020281e:	e3978793          	addi	a5,a5,-455
ffffffffc0202822:	8d19                	sub	a0,a0,a4
ffffffffc0202824:	07b2                	slli	a5,a5,0xc
ffffffffc0202826:	e3978793          	addi	a5,a5,-455
ffffffffc020282a:	850d                	srai	a0,a0,0x3
ffffffffc020282c:	02f50533          	mul	a0,a0,a5
ffffffffc0202830:	000807b7          	lui	a5,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202834:	0000f717          	auipc	a4,0xf
ffffffffc0202838:	cfc73703          	ld	a4,-772(a4) # ffffffffc0211530 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020283c:	953e                	add	a0,a0,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020283e:	00c51793          	slli	a5,a0,0xc
ffffffffc0202842:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202844:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202846:	02e7fa63          	bgeu	a5,a4,ffffffffc020287a <kmalloc+0x92>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020284a:	60a2                	ld	ra,8(sp)
ffffffffc020284c:	0000f797          	auipc	a5,0xf
ffffffffc0202850:	cdc7b783          	ld	a5,-804(a5) # ffffffffc0211528 <va_pa_offset>
ffffffffc0202854:	953e                	add	a0,a0,a5
ffffffffc0202856:	0141                	addi	sp,sp,16
ffffffffc0202858:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020285a:	00003697          	auipc	a3,0x3
ffffffffc020285e:	f5668693          	addi	a3,a3,-170 # ffffffffc02057b0 <etext+0x129c>
ffffffffc0202862:	00002617          	auipc	a2,0x2
ffffffffc0202866:	58e60613          	addi	a2,a2,1422 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020286a:	1f000593          	li	a1,496
ffffffffc020286e:	00003517          	auipc	a0,0x3
ffffffffc0202872:	9b250513          	addi	a0,a0,-1614 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202876:	aebfd0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc020287a:	86aa                	mv	a3,a0
ffffffffc020287c:	00003617          	auipc	a2,0x3
ffffffffc0202880:	97c60613          	addi	a2,a2,-1668 # ffffffffc02051f8 <etext+0xce4>
ffffffffc0202884:	06a00593          	li	a1,106
ffffffffc0202888:	00003517          	auipc	a0,0x3
ffffffffc020288c:	93850513          	addi	a0,a0,-1736 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0202890:	ad1fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(base != NULL);
ffffffffc0202894:	00003697          	auipc	a3,0x3
ffffffffc0202898:	f3c68693          	addi	a3,a3,-196 # ffffffffc02057d0 <etext+0x12bc>
ffffffffc020289c:	00002617          	auipc	a2,0x2
ffffffffc02028a0:	55460613          	addi	a2,a2,1364 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02028a4:	1f300593          	li	a1,499
ffffffffc02028a8:	00003517          	auipc	a0,0x3
ffffffffc02028ac:	97850513          	addi	a0,a0,-1672 # ffffffffc0205220 <etext+0xd0c>
ffffffffc02028b0:	ab1fd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02028b4 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc02028b4:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028b6:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc02028b8:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028ba:	fff58713          	addi	a4,a1,-1
ffffffffc02028be:	17f9                	addi	a5,a5,-2 # 14ffe <kern_entry-0xffffffffc01eb002>
ffffffffc02028c0:	0ae7ee63          	bltu	a5,a4,ffffffffc020297c <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc02028c4:	cd41                	beqz	a0,ffffffffc020295c <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02028c6:	6785                	lui	a5,0x1
ffffffffc02028c8:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02028ca:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028cc:	c02007b7          	lui	a5,0xc0200
ffffffffc02028d0:	81b1                	srli	a1,a1,0xc
ffffffffc02028d2:	06f56863          	bltu	a0,a5,ffffffffc0202942 <kfree+0x8e>
ffffffffc02028d6:	0000f797          	auipc	a5,0xf
ffffffffc02028da:	c527b783          	ld	a5,-942(a5) # ffffffffc0211528 <va_pa_offset>
ffffffffc02028de:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02028e0:	8131                	srli	a0,a0,0xc
ffffffffc02028e2:	0000f797          	auipc	a5,0xf
ffffffffc02028e6:	c4e7b783          	ld	a5,-946(a5) # ffffffffc0211530 <npage>
ffffffffc02028ea:	04f57a63          	bgeu	a0,a5,ffffffffc020293e <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc02028ee:	fff807b7          	lui	a5,0xfff80
ffffffffc02028f2:	953e                	add	a0,a0,a5
ffffffffc02028f4:	00351793          	slli	a5,a0,0x3
ffffffffc02028f8:	97aa                	add	a5,a5,a0
ffffffffc02028fa:	078e                	slli	a5,a5,0x3
ffffffffc02028fc:	0000f517          	auipc	a0,0xf
ffffffffc0202900:	c3c53503          	ld	a0,-964(a0) # ffffffffc0211538 <pages>
ffffffffc0202904:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202906:	100027f3          	csrr	a5,sstatus
ffffffffc020290a:	8b89                	andi	a5,a5,2
ffffffffc020290c:	eb89                	bnez	a5,ffffffffc020291e <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc020290e:	0000f797          	auipc	a5,0xf
ffffffffc0202912:	c027b783          	ld	a5,-1022(a5) # ffffffffc0211510 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202916:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0202918:	739c                	ld	a5,32(a5)
}
ffffffffc020291a:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc020291c:	8782                	jr	a5
        intr_disable();
ffffffffc020291e:	e42a                	sd	a0,8(sp)
ffffffffc0202920:	e02e                	sd	a1,0(sp)
ffffffffc0202922:	bbbfd0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0202926:	0000f797          	auipc	a5,0xf
ffffffffc020292a:	bea7b783          	ld	a5,-1046(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc020292e:	6582                	ld	a1,0(sp)
ffffffffc0202930:	6522                	ld	a0,8(sp)
ffffffffc0202932:	739c                	ld	a5,32(a5)
ffffffffc0202934:	9782                	jalr	a5
}
ffffffffc0202936:	60e2                	ld	ra,24(sp)
ffffffffc0202938:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020293a:	b9dfd06f          	j	ffffffffc02004d6 <intr_enable>
ffffffffc020293e:	c4dfe0ef          	jal	ffffffffc020158a <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202942:	86aa                	mv	a3,a0
ffffffffc0202944:	00003617          	auipc	a2,0x3
ffffffffc0202948:	97460613          	addi	a2,a2,-1676 # ffffffffc02052b8 <etext+0xda4>
ffffffffc020294c:	06c00593          	li	a1,108
ffffffffc0202950:	00003517          	auipc	a0,0x3
ffffffffc0202954:	87050513          	addi	a0,a0,-1936 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0202958:	a09fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(ptr != NULL);
ffffffffc020295c:	00003697          	auipc	a3,0x3
ffffffffc0202960:	e8468693          	addi	a3,a3,-380 # ffffffffc02057e0 <etext+0x12cc>
ffffffffc0202964:	00002617          	auipc	a2,0x2
ffffffffc0202968:	48c60613          	addi	a2,a2,1164 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020296c:	1fa00593          	li	a1,506
ffffffffc0202970:	00003517          	auipc	a0,0x3
ffffffffc0202974:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202978:	9e9fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020297c:	00003697          	auipc	a3,0x3
ffffffffc0202980:	e3468693          	addi	a3,a3,-460 # ffffffffc02057b0 <etext+0x129c>
ffffffffc0202984:	00002617          	auipc	a2,0x2
ffffffffc0202988:	46c60613          	addi	a2,a2,1132 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020298c:	1f900593          	li	a1,505
ffffffffc0202990:	00003517          	auipc	a0,0x3
ffffffffc0202994:	89050513          	addi	a0,a0,-1904 # ffffffffc0205220 <etext+0xd0c>
ffffffffc0202998:	9c9fd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020299c <swap_init>:

bool check_over_flag=false;

int
swap_init(void)
{
ffffffffc020299c:	7135                	addi	sp,sp,-160
ffffffffc020299e:	ed06                	sd	ra,152(sp)
     swapfs_init();
ffffffffc02029a0:	488010ef          	jal	ffffffffc0203e28 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02029a4:	0000f697          	auipc	a3,0xf
ffffffffc02029a8:	ba46b683          	ld	a3,-1116(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc02029ac:	010007b7          	lui	a5,0x1000
ffffffffc02029b0:	ff968713          	addi	a4,a3,-7
ffffffffc02029b4:	17e1                	addi	a5,a5,-8 # fffff8 <kern_entry-0xffffffffbf200008>
ffffffffc02029b6:	40e7e963          	bltu	a5,a4,ffffffffc0202dc8 <swap_init+0x42c>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02029ba:	00007797          	auipc	a5,0x7
ffffffffc02029be:	64678793          	addi	a5,a5,1606 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02029c2:	6798                	ld	a4,8(a5)
ffffffffc02029c4:	fcce                	sd	s3,120(sp)
ffffffffc02029c6:	f0da                	sd	s6,96(sp)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02029c8:	0000fb17          	auipc	s6,0xf
ffffffffc02029cc:	b88b0b13          	addi	s6,s6,-1144 # ffffffffc0211550 <sm>
ffffffffc02029d0:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02029d4:	9702                	jalr	a4
ffffffffc02029d6:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02029d8:	c519                	beqz	a0,ffffffffc02029e6 <swap_init+0x4a>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02029da:	60ea                	ld	ra,152(sp)
ffffffffc02029dc:	7b06                	ld	s6,96(sp)
ffffffffc02029de:	854e                	mv	a0,s3
ffffffffc02029e0:	79e6                	ld	s3,120(sp)
ffffffffc02029e2:	610d                	addi	sp,sp,160
ffffffffc02029e4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029e6:	000b3783          	ld	a5,0(s6)
ffffffffc02029ea:	00003517          	auipc	a0,0x3
ffffffffc02029ee:	e3650513          	addi	a0,a0,-458 # ffffffffc0205820 <etext+0x130c>
ffffffffc02029f2:	e922                	sd	s0,144(sp)
ffffffffc02029f4:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02029f6:	4785                	li	a5,1
ffffffffc02029f8:	e526                	sd	s1,136(sp)
ffffffffc02029fa:	e0ea                	sd	s10,64(sp)
ffffffffc02029fc:	0000f717          	auipc	a4,0xf
ffffffffc0202a00:	b4f72423          	sw	a5,-1208(a4) # ffffffffc0211544 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202a04:	e14a                	sd	s2,128(sp)
ffffffffc0202a06:	f8d2                	sd	s4,112(sp)
ffffffffc0202a08:	f4d6                	sd	s5,104(sp)
ffffffffc0202a0a:	ecde                	sd	s7,88(sp)
ffffffffc0202a0c:	e8e2                	sd	s8,80(sp)
ffffffffc0202a0e:	e4e6                	sd	s9,72(sp)
ffffffffc0202a10:	fc6e                	sd	s11,56(sp)
    return listelm->next;
ffffffffc0202a12:	0000e497          	auipc	s1,0xe
ffffffffc0202a16:	62e48493          	addi	s1,s1,1582 # ffffffffc0211040 <free_area>
ffffffffc0202a1a:	ea0fd0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0202a1e:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202a20:	4401                	li	s0,0
ffffffffc0202a22:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a24:	2e978863          	beq	a5,s1,ffffffffc0202d14 <swap_init+0x378>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202a28:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202a2c:	8b09                	andi	a4,a4,2
ffffffffc0202a2e:	2e070563          	beqz	a4,ffffffffc0202d18 <swap_init+0x37c>
        count ++, total += p->property;
ffffffffc0202a32:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202a36:	679c                	ld	a5,8(a5)
ffffffffc0202a38:	2d05                	addiw	s10,s10,1
ffffffffc0202a3a:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a3c:	fe9796e3          	bne	a5,s1,ffffffffc0202a28 <swap_init+0x8c>
     }
     assert(total == nr_free_pages());
ffffffffc0202a40:	8922                	mv	s2,s0
ffffffffc0202a42:	c51fe0ef          	jal	ffffffffc0201692 <nr_free_pages>
ffffffffc0202a46:	4b251963          	bne	a0,s2,ffffffffc0202ef8 <swap_init+0x55c>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202a4a:	8622                	mv	a2,s0
ffffffffc0202a4c:	85ea                	mv	a1,s10
ffffffffc0202a4e:	00003517          	auipc	a0,0x3
ffffffffc0202a52:	dea50513          	addi	a0,a0,-534 # ffffffffc0205838 <etext+0x1324>
ffffffffc0202a56:	e64fd0ef          	jal	ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202a5a:	35b000ef          	jal	ffffffffc02035b4 <mm_create>
ffffffffc0202a5e:	ec2a                	sd	a0,24(sp)
     assert(mm != NULL);
ffffffffc0202a60:	56050c63          	beqz	a0,ffffffffc0202fd8 <swap_init+0x63c>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a64:	0000f797          	auipc	a5,0xf
ffffffffc0202a68:	b0478793          	addi	a5,a5,-1276 # ffffffffc0211568 <check_mm_struct>
ffffffffc0202a6c:	6398                	ld	a4,0(a5)
ffffffffc0202a6e:	58071563          	bnez	a4,ffffffffc0202ff8 <swap_init+0x65c>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a72:	0000f697          	auipc	a3,0xf
ffffffffc0202a76:	aae6b683          	ld	a3,-1362(a3) # ffffffffc0211520 <boot_pgdir>
     check_mm_struct = mm;
ffffffffc0202a7a:	6662                	ld	a2,24(sp)
     assert(pgdir[0] == 0);
ffffffffc0202a7c:	6298                	ld	a4,0(a3)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a7e:	e836                	sd	a3,16(sp)
     check_mm_struct = mm;
ffffffffc0202a80:	e390                	sd	a2,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a82:	ee14                	sd	a3,24(a2)
     assert(pgdir[0] == 0);
ffffffffc0202a84:	40071a63          	bnez	a4,ffffffffc0202e98 <swap_init+0x4fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a88:	6599                	lui	a1,0x6
ffffffffc0202a8a:	460d                	li	a2,3
ffffffffc0202a8c:	6505                	lui	a0,0x1
ffffffffc0202a8e:	36f000ef          	jal	ffffffffc02035fc <vma_create>
ffffffffc0202a92:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a94:	42050263          	beqz	a0,ffffffffc0202eb8 <swap_init+0x51c>

     insert_vma_struct(mm, vma);
ffffffffc0202a98:	6962                	ld	s2,24(sp)
ffffffffc0202a9a:	854a                	mv	a0,s2
ffffffffc0202a9c:	3cf000ef          	jal	ffffffffc020366a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202aa0:	00003517          	auipc	a0,0x3
ffffffffc0202aa4:	e0850513          	addi	a0,a0,-504 # ffffffffc02058a8 <etext+0x1394>
ffffffffc0202aa8:	e12fd0ef          	jal	ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202aac:	01893503          	ld	a0,24(s2)
ffffffffc0202ab0:	4605                	li	a2,1
ffffffffc0202ab2:	6585                	lui	a1,0x1
ffffffffc0202ab4:	c19fe0ef          	jal	ffffffffc02016cc <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202ab8:	42050063          	beqz	a0,ffffffffc0202ed8 <swap_init+0x53c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202abc:	00003517          	auipc	a0,0x3
ffffffffc0202ac0:	e3c50513          	addi	a0,a0,-452 # ffffffffc02058f8 <etext+0x13e4>
ffffffffc0202ac4:	0000e917          	auipc	s2,0xe
ffffffffc0202ac8:	5b490913          	addi	s2,s2,1460 # ffffffffc0211078 <check_rp>
ffffffffc0202acc:	deefd0ef          	jal	ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ad0:	0000ea17          	auipc	s4,0xe
ffffffffc0202ad4:	5c8a0a13          	addi	s4,s4,1480 # ffffffffc0211098 <swap_out_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202ad8:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202ada:	4505                	li	a0,1
ffffffffc0202adc:	ae7fe0ef          	jal	ffffffffc02015c2 <alloc_pages>
ffffffffc0202ae0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202ae4:	2c050263          	beqz	a0,ffffffffc0202da8 <swap_init+0x40c>
ffffffffc0202ae8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202aea:	8b89                	andi	a5,a5,2
ffffffffc0202aec:	28079e63          	bnez	a5,ffffffffc0202d88 <swap_init+0x3ec>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202af0:	0c21                	addi	s8,s8,8
ffffffffc0202af2:	ff4c14e3          	bne	s8,s4,ffffffffc0202ada <swap_init+0x13e>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202af6:	609c                	ld	a5,0(s1)
ffffffffc0202af8:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202afc:	e084                	sd	s1,0(s1)
ffffffffc0202afe:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202b00:	489c                	lw	a5,16(s1)
ffffffffc0202b02:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202b04:	0000ec17          	auipc	s8,0xe
ffffffffc0202b08:	574c0c13          	addi	s8,s8,1396 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202b0c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202b0e:	0000e797          	auipc	a5,0xe
ffffffffc0202b12:	5407a123          	sw	zero,1346(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202b16:	000c3503          	ld	a0,0(s8)
ffffffffc0202b1a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b1c:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202b1e:	b35fe0ef          	jal	ffffffffc0201652 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b22:	ff4c1ae3          	bne	s8,s4,ffffffffc0202b16 <swap_init+0x17a>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202b26:	0104ac03          	lw	s8,16(s1)
ffffffffc0202b2a:	4791                	li	a5,4
ffffffffc0202b2c:	4efc1663          	bne	s8,a5,ffffffffc0203018 <swap_init+0x67c>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202b30:	00003517          	auipc	a0,0x3
ffffffffc0202b34:	e5050513          	addi	a0,a0,-432 # ffffffffc0205980 <etext+0x146c>
ffffffffc0202b38:	d82fd0ef          	jal	ffffffffc02000ba <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202b3c:	0000f797          	auipc	a5,0xf
ffffffffc0202b40:	a207a223          	sw	zero,-1500(a5) # ffffffffc0211560 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b44:	6785                	lui	a5,0x1
ffffffffc0202b46:	4529                	li	a0,10
ffffffffc0202b48:	00a78023          	sb	a0,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202b4c:	0000f597          	auipc	a1,0xf
ffffffffc0202b50:	a145a583          	lw	a1,-1516(a1) # ffffffffc0211560 <pgfault_num>
ffffffffc0202b54:	4605                	li	a2,1
ffffffffc0202b56:	0000f797          	auipc	a5,0xf
ffffffffc0202b5a:	a0a78793          	addi	a5,a5,-1526 # ffffffffc0211560 <pgfault_num>
ffffffffc0202b5e:	42c59d63          	bne	a1,a2,ffffffffc0202f98 <swap_init+0x5fc>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b62:	6605                	lui	a2,0x1
ffffffffc0202b64:	00a60823          	sb	a0,16(a2) # 1010 <kern_entry-0xffffffffc01feff0>
     assert(pgfault_num==1);
ffffffffc0202b68:	4388                	lw	a0,0(a5)
ffffffffc0202b6a:	44b51763          	bne	a0,a1,ffffffffc0202fb8 <swap_init+0x61c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b6e:	6609                	lui	a2,0x2
ffffffffc0202b70:	45ad                	li	a1,11
ffffffffc0202b72:	00b60023          	sb	a1,0(a2) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202b76:	4390                	lw	a2,0(a5)
ffffffffc0202b78:	4809                	li	a6,2
ffffffffc0202b7a:	0006051b          	sext.w	a0,a2
ffffffffc0202b7e:	39061d63          	bne	a2,a6,ffffffffc0202f18 <swap_init+0x57c>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b82:	6609                	lui	a2,0x2
ffffffffc0202b84:	00b60823          	sb	a1,16(a2) # 2010 <kern_entry-0xffffffffc01fdff0>
     assert(pgfault_num==2);
ffffffffc0202b88:	438c                	lw	a1,0(a5)
ffffffffc0202b8a:	3aa59763          	bne	a1,a0,ffffffffc0202f38 <swap_init+0x59c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b8e:	660d                	lui	a2,0x3
ffffffffc0202b90:	45b1                	li	a1,12
ffffffffc0202b92:	00b60023          	sb	a1,0(a2) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202b96:	4390                	lw	a2,0(a5)
ffffffffc0202b98:	480d                	li	a6,3
ffffffffc0202b9a:	0006051b          	sext.w	a0,a2
ffffffffc0202b9e:	3b061d63          	bne	a2,a6,ffffffffc0202f58 <swap_init+0x5bc>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202ba2:	660d                	lui	a2,0x3
ffffffffc0202ba4:	00b60823          	sb	a1,16(a2) # 3010 <kern_entry-0xffffffffc01fcff0>
     assert(pgfault_num==3);
ffffffffc0202ba8:	438c                	lw	a1,0(a5)
ffffffffc0202baa:	3ca59763          	bne	a1,a0,ffffffffc0202f78 <swap_init+0x5dc>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202bae:	6611                	lui	a2,0x4
ffffffffc0202bb0:	45b5                	li	a1,13
ffffffffc0202bb2:	00b60023          	sb	a1,0(a2) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202bb6:	4390                	lw	a2,0(a5)
ffffffffc0202bb8:	0006051b          	sext.w	a0,a2
ffffffffc0202bbc:	25861e63          	bne	a2,s8,ffffffffc0202e18 <swap_init+0x47c>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202bc0:	6611                	lui	a2,0x4
ffffffffc0202bc2:	00b60823          	sb	a1,16(a2) # 4010 <kern_entry-0xffffffffc01fbff0>
     assert(pgfault_num==4);
ffffffffc0202bc6:	439c                	lw	a5,0(a5)
ffffffffc0202bc8:	26a79863          	bne	a5,a0,ffffffffc0202e38 <swap_init+0x49c>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202bcc:	489c                	lw	a5,16(s1)
ffffffffc0202bce:	28079563          	bnez	a5,ffffffffc0202e58 <swap_init+0x4bc>
ffffffffc0202bd2:	0000e797          	auipc	a5,0xe
ffffffffc0202bd6:	4ee78793          	addi	a5,a5,1262 # ffffffffc02110c0 <swap_in_seq_no>
ffffffffc0202bda:	0000e617          	auipc	a2,0xe
ffffffffc0202bde:	4be60613          	addi	a2,a2,1214 # ffffffffc0211098 <swap_out_seq_no>
ffffffffc0202be2:	0000e517          	auipc	a0,0xe
ffffffffc0202be6:	50650513          	addi	a0,a0,1286 # ffffffffc02110e8 <pra_list_head>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202bea:	55fd                	li	a1,-1
ffffffffc0202bec:	c38c                	sw	a1,0(a5)
ffffffffc0202bee:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202bf0:	0791                	addi	a5,a5,4
ffffffffc0202bf2:	0611                	addi	a2,a2,4
ffffffffc0202bf4:	fea79ce3          	bne	a5,a0,ffffffffc0202bec <swap_init+0x250>
ffffffffc0202bf8:	0000e817          	auipc	a6,0xe
ffffffffc0202bfc:	46080813          	addi	a6,a6,1120 # ffffffffc0211058 <check_ptep>
ffffffffc0202c00:	0000e897          	auipc	a7,0xe
ffffffffc0202c04:	47888893          	addi	a7,a7,1144 # ffffffffc0211078 <check_rp>
ffffffffc0202c08:	6a85                	lui	s5,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202c0a:	0000fb97          	auipc	s7,0xf
ffffffffc0202c0e:	926b8b93          	addi	s7,s7,-1754 # ffffffffc0211530 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c12:	0000fc17          	auipc	s8,0xf
ffffffffc0202c16:	926c0c13          	addi	s8,s8,-1754 # ffffffffc0211538 <pages>
ffffffffc0202c1a:	00003c97          	auipc	s9,0x3
ffffffffc0202c1e:	716c8c93          	addi	s9,s9,1814 # ffffffffc0206330 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c22:	6542                	ld	a0,16(sp)
         check_ptep[i]=0;
ffffffffc0202c24:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c28:	4601                	li	a2,0
ffffffffc0202c2a:	85d6                	mv	a1,s5
ffffffffc0202c2c:	e446                	sd	a7,8(sp)
         check_ptep[i]=0;
ffffffffc0202c2e:	e042                	sd	a6,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c30:	a9dfe0ef          	jal	ffffffffc02016cc <get_pte>
ffffffffc0202c34:	6802                	ld	a6,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202c36:	68a2                	ld	a7,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c38:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202c3c:	1a050e63          	beqz	a0,ffffffffc0202df8 <swap_init+0x45c>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c40:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202c42:	0017f613          	andi	a2,a5,1
ffffffffc0202c46:	10060963          	beqz	a2,ffffffffc0202d58 <swap_init+0x3bc>
    if (PPN(pa) >= npage) {
ffffffffc0202c4a:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c4e:	078a                	slli	a5,a5,0x2
ffffffffc0202c50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c52:	10c7ff63          	bgeu	a5,a2,ffffffffc0202d70 <swap_init+0x3d4>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c56:	000cb603          	ld	a2,0(s9)
ffffffffc0202c5a:	000c3503          	ld	a0,0(s8)
ffffffffc0202c5e:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c62:	8f91                	sub	a5,a5,a2
ffffffffc0202c64:	00379613          	slli	a2,a5,0x3
ffffffffc0202c68:	97b2                	add	a5,a5,a2
ffffffffc0202c6a:	078e                	slli	a5,a5,0x3
ffffffffc0202c6c:	6705                	lui	a4,0x1
ffffffffc0202c6e:	97aa                	add	a5,a5,a0
ffffffffc0202c70:	08a1                	addi	a7,a7,8
ffffffffc0202c72:	0821                	addi	a6,a6,8
ffffffffc0202c74:	9aba                	add	s5,s5,a4
ffffffffc0202c76:	0cff1163          	bne	t5,a5,ffffffffc0202d38 <swap_init+0x39c>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c7a:	6795                	lui	a5,0x5
ffffffffc0202c7c:	fafa93e3          	bne	s5,a5,ffffffffc0202c22 <swap_init+0x286>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c80:	00003517          	auipc	a0,0x3
ffffffffc0202c84:	da850513          	addi	a0,a0,-600 # ffffffffc0205a28 <etext+0x1514>
ffffffffc0202c88:	c32fd0ef          	jal	ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202c8c:	000b3783          	ld	a5,0(s6)

     check_over_flag=true;
ffffffffc0202c90:	4605                	li	a2,1
ffffffffc0202c92:	0000f597          	auipc	a1,0xf
ffffffffc0202c96:	8ac5a723          	sw	a2,-1874(a1) # ffffffffc0211540 <check_over_flag>
    int ret = sm->check_swap();
ffffffffc0202c9a:	7f9c                	ld	a5,56(a5)
ffffffffc0202c9c:	9782                	jalr	a5

     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202c9e:	1c051d63          	bnez	a0,ffffffffc0202e78 <swap_init+0x4dc>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202ca2:	00093503          	ld	a0,0(s2)
ffffffffc0202ca6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ca8:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202caa:	9a9fe0ef          	jal	ffffffffc0201652 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cae:	ff491ae3          	bne	s2,s4,ffffffffc0202ca2 <swap_init+0x306>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202cb2:	6562                	ld	a0,24(sp)
ffffffffc0202cb4:	287000ef          	jal	ffffffffc020373a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202cb8:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202cba:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202cbe:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202cc0:	7782                	ld	a5,32(sp)
ffffffffc0202cc2:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cc4:	009d8a63          	beq	s11,s1,ffffffffc0202cd8 <swap_init+0x33c>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202cc8:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202ccc:	008dbd83          	ld	s11,8(s11)
ffffffffc0202cd0:	3d7d                	addiw	s10,s10,-1
ffffffffc0202cd2:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cd4:	fe9d9ae3          	bne	s11,s1,ffffffffc0202cc8 <swap_init+0x32c>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202cd8:	8622                	mv	a2,s0
ffffffffc0202cda:	85ea                	mv	a1,s10
ffffffffc0202cdc:	00003517          	auipc	a0,0x3
ffffffffc0202ce0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0205a58 <etext+0x1544>
ffffffffc0202ce4:	bd6fd0ef          	jal	ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202ce8:	00003517          	auipc	a0,0x3
ffffffffc0202cec:	d9050513          	addi	a0,a0,-624 # ffffffffc0205a78 <etext+0x1564>
ffffffffc0202cf0:	bcafd0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc0202cf4:	60ea                	ld	ra,152(sp)
     cprintf("check_swap() succeeded!\n");
ffffffffc0202cf6:	644a                	ld	s0,144(sp)
ffffffffc0202cf8:	64aa                	ld	s1,136(sp)
ffffffffc0202cfa:	690a                	ld	s2,128(sp)
ffffffffc0202cfc:	7a46                	ld	s4,112(sp)
ffffffffc0202cfe:	7aa6                	ld	s5,104(sp)
ffffffffc0202d00:	6be6                	ld	s7,88(sp)
ffffffffc0202d02:	6c46                	ld	s8,80(sp)
ffffffffc0202d04:	6ca6                	ld	s9,72(sp)
ffffffffc0202d06:	6d06                	ld	s10,64(sp)
ffffffffc0202d08:	7de2                	ld	s11,56(sp)
}
ffffffffc0202d0a:	7b06                	ld	s6,96(sp)
ffffffffc0202d0c:	854e                	mv	a0,s3
ffffffffc0202d0e:	79e6                	ld	s3,120(sp)
ffffffffc0202d10:	610d                	addi	sp,sp,160
ffffffffc0202d12:	8082                	ret
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202d14:	4901                	li	s2,0
ffffffffc0202d16:	b335                	j	ffffffffc0202a42 <swap_init+0xa6>
        assert(PageProperty(p));
ffffffffc0202d18:	00002697          	auipc	a3,0x2
ffffffffc0202d1c:	0c868693          	addi	a3,a3,200 # ffffffffc0204de0 <etext+0x8cc>
ffffffffc0202d20:	00002617          	auipc	a2,0x2
ffffffffc0202d24:	0d060613          	addi	a2,a2,208 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202d28:	0bc00593          	li	a1,188
ffffffffc0202d2c:	00003517          	auipc	a0,0x3
ffffffffc0202d30:	ae450513          	addi	a0,a0,-1308 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202d34:	e2cfd0ef          	jal	ffffffffc0200360 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202d38:	00003697          	auipc	a3,0x3
ffffffffc0202d3c:	cc868693          	addi	a3,a3,-824 # ffffffffc0205a00 <etext+0x14ec>
ffffffffc0202d40:	00002617          	auipc	a2,0x2
ffffffffc0202d44:	0b060613          	addi	a2,a2,176 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202d48:	0fc00593          	li	a1,252
ffffffffc0202d4c:	00003517          	auipc	a0,0x3
ffffffffc0202d50:	ac450513          	addi	a0,a0,-1340 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202d54:	e0cfd0ef          	jal	ffffffffc0200360 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202d58:	00002617          	auipc	a2,0x2
ffffffffc0202d5c:	47860613          	addi	a2,a2,1144 # ffffffffc02051d0 <etext+0xcbc>
ffffffffc0202d60:	07000593          	li	a1,112
ffffffffc0202d64:	00002517          	auipc	a0,0x2
ffffffffc0202d68:	45c50513          	addi	a0,a0,1116 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0202d6c:	df4fd0ef          	jal	ffffffffc0200360 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d70:	00002617          	auipc	a2,0x2
ffffffffc0202d74:	43060613          	addi	a2,a2,1072 # ffffffffc02051a0 <etext+0xc8c>
ffffffffc0202d78:	06500593          	li	a1,101
ffffffffc0202d7c:	00002517          	auipc	a0,0x2
ffffffffc0202d80:	44450513          	addi	a0,a0,1092 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0202d84:	ddcfd0ef          	jal	ffffffffc0200360 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d88:	00003697          	auipc	a3,0x3
ffffffffc0202d8c:	bb068693          	addi	a3,a3,-1104 # ffffffffc0205938 <etext+0x1424>
ffffffffc0202d90:	00002617          	auipc	a2,0x2
ffffffffc0202d94:	06060613          	addi	a2,a2,96 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202d98:	0dd00593          	li	a1,221
ffffffffc0202d9c:	00003517          	auipc	a0,0x3
ffffffffc0202da0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202da4:	dbcfd0ef          	jal	ffffffffc0200360 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202da8:	00003697          	auipc	a3,0x3
ffffffffc0202dac:	b7868693          	addi	a3,a3,-1160 # ffffffffc0205920 <etext+0x140c>
ffffffffc0202db0:	00002617          	auipc	a2,0x2
ffffffffc0202db4:	04060613          	addi	a2,a2,64 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202db8:	0dc00593          	li	a1,220
ffffffffc0202dbc:	00003517          	auipc	a0,0x3
ffffffffc0202dc0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202dc4:	d9cfd0ef          	jal	ffffffffc0200360 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202dc8:	00003617          	auipc	a2,0x3
ffffffffc0202dcc:	a2860613          	addi	a2,a2,-1496 # ffffffffc02057f0 <etext+0x12dc>
ffffffffc0202dd0:	02900593          	li	a1,41
ffffffffc0202dd4:	00003517          	auipc	a0,0x3
ffffffffc0202dd8:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202ddc:	e922                	sd	s0,144(sp)
ffffffffc0202dde:	e526                	sd	s1,136(sp)
ffffffffc0202de0:	e14a                	sd	s2,128(sp)
ffffffffc0202de2:	fcce                	sd	s3,120(sp)
ffffffffc0202de4:	f8d2                	sd	s4,112(sp)
ffffffffc0202de6:	f4d6                	sd	s5,104(sp)
ffffffffc0202de8:	f0da                	sd	s6,96(sp)
ffffffffc0202dea:	ecde                	sd	s7,88(sp)
ffffffffc0202dec:	e8e2                	sd	s8,80(sp)
ffffffffc0202dee:	e4e6                	sd	s9,72(sp)
ffffffffc0202df0:	e0ea                	sd	s10,64(sp)
ffffffffc0202df2:	fc6e                	sd	s11,56(sp)
ffffffffc0202df4:	d6cfd0ef          	jal	ffffffffc0200360 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202df8:	00003697          	auipc	a3,0x3
ffffffffc0202dfc:	bf068693          	addi	a3,a3,-1040 # ffffffffc02059e8 <etext+0x14d4>
ffffffffc0202e00:	00002617          	auipc	a2,0x2
ffffffffc0202e04:	ff060613          	addi	a2,a2,-16 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202e08:	0fb00593          	li	a1,251
ffffffffc0202e0c:	00003517          	auipc	a0,0x3
ffffffffc0202e10:	a0450513          	addi	a0,a0,-1532 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202e14:	d4cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e18:	00003697          	auipc	a3,0x3
ffffffffc0202e1c:	bc068693          	addi	a3,a3,-1088 # ffffffffc02059d8 <etext+0x14c4>
ffffffffc0202e20:	00002617          	auipc	a2,0x2
ffffffffc0202e24:	fd060613          	addi	a2,a2,-48 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202e28:	09f00593          	li	a1,159
ffffffffc0202e2c:	00003517          	auipc	a0,0x3
ffffffffc0202e30:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202e34:	d2cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e38:	00003697          	auipc	a3,0x3
ffffffffc0202e3c:	ba068693          	addi	a3,a3,-1120 # ffffffffc02059d8 <etext+0x14c4>
ffffffffc0202e40:	00002617          	auipc	a2,0x2
ffffffffc0202e44:	fb060613          	addi	a2,a2,-80 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202e48:	0a100593          	li	a1,161
ffffffffc0202e4c:	00003517          	auipc	a0,0x3
ffffffffc0202e50:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202e54:	d0cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e58:	00002697          	auipc	a3,0x2
ffffffffc0202e5c:	17068693          	addi	a3,a3,368 # ffffffffc0204fc8 <etext+0xab4>
ffffffffc0202e60:	00002617          	auipc	a2,0x2
ffffffffc0202e64:	f9060613          	addi	a2,a2,-112 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202e68:	0f300593          	li	a1,243
ffffffffc0202e6c:	00003517          	auipc	a0,0x3
ffffffffc0202e70:	9a450513          	addi	a0,a0,-1628 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202e74:	cecfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(ret==0);
ffffffffc0202e78:	00003697          	auipc	a3,0x3
ffffffffc0202e7c:	bd868693          	addi	a3,a3,-1064 # ffffffffc0205a50 <etext+0x153c>
ffffffffc0202e80:	00002617          	auipc	a2,0x2
ffffffffc0202e84:	f7060613          	addi	a2,a2,-144 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202e88:	10500593          	li	a1,261
ffffffffc0202e8c:	00003517          	auipc	a0,0x3
ffffffffc0202e90:	98450513          	addi	a0,a0,-1660 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202e94:	cccfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e98:	00003697          	auipc	a3,0x3
ffffffffc0202e9c:	9f068693          	addi	a3,a3,-1552 # ffffffffc0205888 <etext+0x1374>
ffffffffc0202ea0:	00002617          	auipc	a2,0x2
ffffffffc0202ea4:	f5060613          	addi	a2,a2,-176 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202ea8:	0cc00593          	li	a1,204
ffffffffc0202eac:	00003517          	auipc	a0,0x3
ffffffffc0202eb0:	96450513          	addi	a0,a0,-1692 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202eb4:	cacfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(vma != NULL);
ffffffffc0202eb8:	00003697          	auipc	a3,0x3
ffffffffc0202ebc:	9e068693          	addi	a3,a3,-1568 # ffffffffc0205898 <etext+0x1384>
ffffffffc0202ec0:	00002617          	auipc	a2,0x2
ffffffffc0202ec4:	f3060613          	addi	a2,a2,-208 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202ec8:	0cf00593          	li	a1,207
ffffffffc0202ecc:	00003517          	auipc	a0,0x3
ffffffffc0202ed0:	94450513          	addi	a0,a0,-1724 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202ed4:	c8cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202ed8:	00003697          	auipc	a3,0x3
ffffffffc0202edc:	a0868693          	addi	a3,a3,-1528 # ffffffffc02058e0 <etext+0x13cc>
ffffffffc0202ee0:	00002617          	auipc	a2,0x2
ffffffffc0202ee4:	f1060613          	addi	a2,a2,-240 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202ee8:	0d700593          	li	a1,215
ffffffffc0202eec:	00003517          	auipc	a0,0x3
ffffffffc0202ef0:	92450513          	addi	a0,a0,-1756 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202ef4:	c6cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202ef8:	00002697          	auipc	a3,0x2
ffffffffc0202efc:	f2868693          	addi	a3,a3,-216 # ffffffffc0204e20 <etext+0x90c>
ffffffffc0202f00:	00002617          	auipc	a2,0x2
ffffffffc0202f04:	ef060613          	addi	a2,a2,-272 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202f08:	0bf00593          	li	a1,191
ffffffffc0202f0c:	00003517          	auipc	a0,0x3
ffffffffc0202f10:	90450513          	addi	a0,a0,-1788 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202f14:	c4cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f18:	00003697          	auipc	a3,0x3
ffffffffc0202f1c:	aa068693          	addi	a3,a3,-1376 # ffffffffc02059b8 <etext+0x14a4>
ffffffffc0202f20:	00002617          	auipc	a2,0x2
ffffffffc0202f24:	ed060613          	addi	a2,a2,-304 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202f28:	09700593          	li	a1,151
ffffffffc0202f2c:	00003517          	auipc	a0,0x3
ffffffffc0202f30:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202f34:	c2cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f38:	00003697          	auipc	a3,0x3
ffffffffc0202f3c:	a8068693          	addi	a3,a3,-1408 # ffffffffc02059b8 <etext+0x14a4>
ffffffffc0202f40:	00002617          	auipc	a2,0x2
ffffffffc0202f44:	eb060613          	addi	a2,a2,-336 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202f48:	09900593          	li	a1,153
ffffffffc0202f4c:	00003517          	auipc	a0,0x3
ffffffffc0202f50:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202f54:	c0cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f58:	00003697          	auipc	a3,0x3
ffffffffc0202f5c:	a7068693          	addi	a3,a3,-1424 # ffffffffc02059c8 <etext+0x14b4>
ffffffffc0202f60:	00002617          	auipc	a2,0x2
ffffffffc0202f64:	e9060613          	addi	a2,a2,-368 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202f68:	09b00593          	li	a1,155
ffffffffc0202f6c:	00003517          	auipc	a0,0x3
ffffffffc0202f70:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202f74:	becfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f78:	00003697          	auipc	a3,0x3
ffffffffc0202f7c:	a5068693          	addi	a3,a3,-1456 # ffffffffc02059c8 <etext+0x14b4>
ffffffffc0202f80:	00002617          	auipc	a2,0x2
ffffffffc0202f84:	e7060613          	addi	a2,a2,-400 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202f88:	09d00593          	li	a1,157
ffffffffc0202f8c:	00003517          	auipc	a0,0x3
ffffffffc0202f90:	88450513          	addi	a0,a0,-1916 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202f94:	bccfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f98:	00003697          	auipc	a3,0x3
ffffffffc0202f9c:	a1068693          	addi	a3,a3,-1520 # ffffffffc02059a8 <etext+0x1494>
ffffffffc0202fa0:	00002617          	auipc	a2,0x2
ffffffffc0202fa4:	e5060613          	addi	a2,a2,-432 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202fa8:	09300593          	li	a1,147
ffffffffc0202fac:	00003517          	auipc	a0,0x3
ffffffffc0202fb0:	86450513          	addi	a0,a0,-1948 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202fb4:	bacfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==1);
ffffffffc0202fb8:	00003697          	auipc	a3,0x3
ffffffffc0202fbc:	9f068693          	addi	a3,a3,-1552 # ffffffffc02059a8 <etext+0x1494>
ffffffffc0202fc0:	00002617          	auipc	a2,0x2
ffffffffc0202fc4:	e3060613          	addi	a2,a2,-464 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202fc8:	09500593          	li	a1,149
ffffffffc0202fcc:	00003517          	auipc	a0,0x3
ffffffffc0202fd0:	84450513          	addi	a0,a0,-1980 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202fd4:	b8cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(mm != NULL);
ffffffffc0202fd8:	00003697          	auipc	a3,0x3
ffffffffc0202fdc:	88868693          	addi	a3,a3,-1912 # ffffffffc0205860 <etext+0x134c>
ffffffffc0202fe0:	00002617          	auipc	a2,0x2
ffffffffc0202fe4:	e1060613          	addi	a2,a2,-496 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0202fe8:	0c400593          	li	a1,196
ffffffffc0202fec:	00003517          	auipc	a0,0x3
ffffffffc0202ff0:	82450513          	addi	a0,a0,-2012 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0202ff4:	b6cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202ff8:	00003697          	auipc	a3,0x3
ffffffffc0202ffc:	87868693          	addi	a3,a3,-1928 # ffffffffc0205870 <etext+0x135c>
ffffffffc0203000:	00002617          	auipc	a2,0x2
ffffffffc0203004:	df060613          	addi	a2,a2,-528 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203008:	0c700593          	li	a1,199
ffffffffc020300c:	00003517          	auipc	a0,0x3
ffffffffc0203010:	80450513          	addi	a0,a0,-2044 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0203014:	b4cfd0ef          	jal	ffffffffc0200360 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203018:	00003697          	auipc	a3,0x3
ffffffffc020301c:	94068693          	addi	a3,a3,-1728 # ffffffffc0205958 <etext+0x1444>
ffffffffc0203020:	00002617          	auipc	a2,0x2
ffffffffc0203024:	dd060613          	addi	a2,a2,-560 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203028:	0ea00593          	li	a1,234
ffffffffc020302c:	00002517          	auipc	a0,0x2
ffffffffc0203030:	7e450513          	addi	a0,a0,2020 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0203034:	b2cfd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203038 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203038:	0000e797          	auipc	a5,0xe
ffffffffc020303c:	5187b783          	ld	a5,1304(a5) # ffffffffc0211550 <sm>
ffffffffc0203040:	6b9c                	ld	a5,16(a5)
ffffffffc0203042:	8782                	jr	a5

ffffffffc0203044 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203044:	0000e797          	auipc	a5,0xe
ffffffffc0203048:	50c7b783          	ld	a5,1292(a5) # ffffffffc0211550 <sm>
ffffffffc020304c:	739c                	ld	a5,32(a5)
ffffffffc020304e:	8782                	jr	a5

ffffffffc0203050 <swap_out>:
{
ffffffffc0203050:	711d                	addi	sp,sp,-96
ffffffffc0203052:	ec86                	sd	ra,88(sp)
ffffffffc0203054:	e8a2                	sd	s0,80(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203056:	0e058663          	beqz	a1,ffffffffc0203142 <swap_out+0xf2>
ffffffffc020305a:	e0ca                	sd	s2,64(sp)
ffffffffc020305c:	fc4e                	sd	s3,56(sp)
ffffffffc020305e:	f852                	sd	s4,48(sp)
ffffffffc0203060:	f456                	sd	s5,40(sp)
ffffffffc0203062:	f05a                	sd	s6,32(sp)
ffffffffc0203064:	ec5e                	sd	s7,24(sp)
ffffffffc0203066:	e4a6                	sd	s1,72(sp)
ffffffffc0203068:	e862                	sd	s8,16(sp)
ffffffffc020306a:	8a2e                	mv	s4,a1
ffffffffc020306c:	892a                	mv	s2,a0
ffffffffc020306e:	8ab2                	mv	s5,a2
ffffffffc0203070:	4401                	li	s0,0
ffffffffc0203072:	0000e997          	auipc	s3,0xe
ffffffffc0203076:	4de98993          	addi	s3,s3,1246 # ffffffffc0211550 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020307a:	00003b17          	auipc	s6,0x3
ffffffffc020307e:	a7eb0b13          	addi	s6,s6,-1410 # ffffffffc0205af8 <etext+0x15e4>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203082:	00003b97          	auipc	s7,0x3
ffffffffc0203086:	a5eb8b93          	addi	s7,s7,-1442 # ffffffffc0205ae0 <etext+0x15cc>
ffffffffc020308a:	a825                	j	ffffffffc02030c2 <swap_out+0x72>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020308c:	67a2                	ld	a5,8(sp)
ffffffffc020308e:	8626                	mv	a2,s1
ffffffffc0203090:	85a2                	mv	a1,s0
ffffffffc0203092:	63b4                	ld	a3,64(a5)
ffffffffc0203094:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203096:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203098:	82b1                	srli	a3,a3,0xc
ffffffffc020309a:	0685                	addi	a3,a3,1
ffffffffc020309c:	81efd0ef          	jal	ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02030a0:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02030a2:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02030a4:	613c                	ld	a5,64(a0)
ffffffffc02030a6:	83b1                	srli	a5,a5,0xc
ffffffffc02030a8:	0785                	addi	a5,a5,1
ffffffffc02030aa:	07a2                	slli	a5,a5,0x8
ffffffffc02030ac:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02030b0:	da2fe0ef          	jal	ffffffffc0201652 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02030b4:	01893503          	ld	a0,24(s2)
ffffffffc02030b8:	85a6                	mv	a1,s1
ffffffffc02030ba:	e70ff0ef          	jal	ffffffffc020272a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02030be:	048a0d63          	beq	s4,s0,ffffffffc0203118 <swap_out+0xc8>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02030c2:	0009b783          	ld	a5,0(s3)
ffffffffc02030c6:	8656                	mv	a2,s5
ffffffffc02030c8:	002c                	addi	a1,sp,8
ffffffffc02030ca:	7b9c                	ld	a5,48(a5)
ffffffffc02030cc:	854a                	mv	a0,s2
ffffffffc02030ce:	9782                	jalr	a5
          if (r != 0) {
ffffffffc02030d0:	e12d                	bnez	a0,ffffffffc0203132 <swap_out+0xe2>
          v=page->pra_vaddr; 
ffffffffc02030d2:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030d4:	01893503          	ld	a0,24(s2)
ffffffffc02030d8:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02030da:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030dc:	85a6                	mv	a1,s1
ffffffffc02030de:	deefe0ef          	jal	ffffffffc02016cc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030e2:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030e4:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02030e6:	8b85                	andi	a5,a5,1
ffffffffc02030e8:	cfb9                	beqz	a5,ffffffffc0203146 <swap_out+0xf6>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02030ea:	65a2                	ld	a1,8(sp)
ffffffffc02030ec:	61bc                	ld	a5,64(a1)
ffffffffc02030ee:	83b1                	srli	a5,a5,0xc
ffffffffc02030f0:	0785                	addi	a5,a5,1
ffffffffc02030f2:	00879513          	slli	a0,a5,0x8
ffffffffc02030f6:	617000ef          	jal	ffffffffc0203f0c <swapfs_write>
ffffffffc02030fa:	d949                	beqz	a0,ffffffffc020308c <swap_out+0x3c>
                    cprintf("SWAP: failed to save\n");
ffffffffc02030fc:	855e                	mv	a0,s7
ffffffffc02030fe:	fbdfc0ef          	jal	ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203102:	0009b783          	ld	a5,0(s3)
ffffffffc0203106:	6622                	ld	a2,8(sp)
ffffffffc0203108:	4681                	li	a3,0
ffffffffc020310a:	739c                	ld	a5,32(a5)
ffffffffc020310c:	85a6                	mv	a1,s1
ffffffffc020310e:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203110:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203112:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203114:	fa8a17e3          	bne	s4,s0,ffffffffc02030c2 <swap_out+0x72>
ffffffffc0203118:	64a6                	ld	s1,72(sp)
ffffffffc020311a:	6906                	ld	s2,64(sp)
ffffffffc020311c:	79e2                	ld	s3,56(sp)
ffffffffc020311e:	7a42                	ld	s4,48(sp)
ffffffffc0203120:	7aa2                	ld	s5,40(sp)
ffffffffc0203122:	7b02                	ld	s6,32(sp)
ffffffffc0203124:	6be2                	ld	s7,24(sp)
ffffffffc0203126:	6c42                	ld	s8,16(sp)
}
ffffffffc0203128:	60e6                	ld	ra,88(sp)
ffffffffc020312a:	8522                	mv	a0,s0
ffffffffc020312c:	6446                	ld	s0,80(sp)
ffffffffc020312e:	6125                	addi	sp,sp,96
ffffffffc0203130:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203132:	85a2                	mv	a1,s0
ffffffffc0203134:	00003517          	auipc	a0,0x3
ffffffffc0203138:	96450513          	addi	a0,a0,-1692 # ffffffffc0205a98 <etext+0x1584>
ffffffffc020313c:	f7ffc0ef          	jal	ffffffffc02000ba <cprintf>
                  break;
ffffffffc0203140:	bfe1                	j	ffffffffc0203118 <swap_out+0xc8>
     for (i = 0; i != n; ++ i)
ffffffffc0203142:	4401                	li	s0,0
ffffffffc0203144:	b7d5                	j	ffffffffc0203128 <swap_out+0xd8>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203146:	00003697          	auipc	a3,0x3
ffffffffc020314a:	98268693          	addi	a3,a3,-1662 # ffffffffc0205ac8 <etext+0x15b4>
ffffffffc020314e:	00002617          	auipc	a2,0x2
ffffffffc0203152:	ca260613          	addi	a2,a2,-862 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203156:	06800593          	li	a1,104
ffffffffc020315a:	00002517          	auipc	a0,0x2
ffffffffc020315e:	6b650513          	addi	a0,a0,1718 # ffffffffc0205810 <etext+0x12fc>
ffffffffc0203162:	9fefd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203166 <swap_in>:
{
ffffffffc0203166:	7179                	addi	sp,sp,-48
ffffffffc0203168:	e84a                	sd	s2,16(sp)
ffffffffc020316a:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020316c:	4505                	li	a0,1
{
ffffffffc020316e:	ec26                	sd	s1,24(sp)
ffffffffc0203170:	e44e                	sd	s3,8(sp)
ffffffffc0203172:	f406                	sd	ra,40(sp)
ffffffffc0203174:	f022                	sd	s0,32(sp)
ffffffffc0203176:	84ae                	mv	s1,a1
ffffffffc0203178:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020317a:	c48fe0ef          	jal	ffffffffc02015c2 <alloc_pages>
     assert(result!=NULL);
ffffffffc020317e:	c129                	beqz	a0,ffffffffc02031c0 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203180:	842a                	mv	s0,a0
ffffffffc0203182:	01893503          	ld	a0,24(s2)
ffffffffc0203186:	4601                	li	a2,0
ffffffffc0203188:	85a6                	mv	a1,s1
ffffffffc020318a:	d42fe0ef          	jal	ffffffffc02016cc <get_pte>
ffffffffc020318e:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203190:	6108                	ld	a0,0(a0)
ffffffffc0203192:	85a2                	mv	a1,s0
ffffffffc0203194:	4cd000ef          	jal	ffffffffc0203e60 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203198:	00093583          	ld	a1,0(s2)
ffffffffc020319c:	8626                	mv	a2,s1
ffffffffc020319e:	00003517          	auipc	a0,0x3
ffffffffc02031a2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205b48 <etext+0x1634>
ffffffffc02031a6:	81a1                	srli	a1,a1,0x8
ffffffffc02031a8:	f13fc0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc02031ac:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02031ae:	0089b023          	sd	s0,0(s3)
}
ffffffffc02031b2:	7402                	ld	s0,32(sp)
ffffffffc02031b4:	64e2                	ld	s1,24(sp)
ffffffffc02031b6:	6942                	ld	s2,16(sp)
ffffffffc02031b8:	69a2                	ld	s3,8(sp)
ffffffffc02031ba:	4501                	li	a0,0
ffffffffc02031bc:	6145                	addi	sp,sp,48
ffffffffc02031be:	8082                	ret
     assert(result!=NULL);
ffffffffc02031c0:	00003697          	auipc	a3,0x3
ffffffffc02031c4:	97868693          	addi	a3,a3,-1672 # ffffffffc0205b38 <etext+0x1624>
ffffffffc02031c8:	00002617          	auipc	a2,0x2
ffffffffc02031cc:	c2860613          	addi	a2,a2,-984 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02031d0:	07e00593          	li	a1,126
ffffffffc02031d4:	00002517          	auipc	a0,0x2
ffffffffc02031d8:	63c50513          	addi	a0,a0,1596 # ffffffffc0205810 <etext+0x12fc>
ffffffffc02031dc:	984fd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02031e0 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02031e0:	4501                	li	a0,0
ffffffffc02031e2:	8082                	ret

ffffffffc02031e4 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02031e4:	4501                	li	a0,0
ffffffffc02031e6:	8082                	ret

ffffffffc02031e8 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02031e8:	4501                	li	a0,0
ffffffffc02031ea:	8082                	ret

ffffffffc02031ec <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02031ec:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031ee:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02031f0:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031f2:	678d                	lui	a5,0x3
ffffffffc02031f4:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02031f8:	0000e717          	auipc	a4,0xe
ffffffffc02031fc:	36872703          	lw	a4,872(a4) # ffffffffc0211560 <pgfault_num>
ffffffffc0203200:	4691                	li	a3,4
ffffffffc0203202:	0ad71663          	bne	a4,a3,ffffffffc02032ae <_clock_check_swap+0xc2>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203206:	6685                	lui	a3,0x1
ffffffffc0203208:	4629                	li	a2,10
ffffffffc020320a:	00c68023          	sb	a2,0(a3) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020320e:	0000e797          	auipc	a5,0xe
ffffffffc0203212:	35278793          	addi	a5,a5,850 # ffffffffc0211560 <pgfault_num>
    assert(pgfault_num==4);
ffffffffc0203216:	4394                	lw	a3,0(a5)
ffffffffc0203218:	0006861b          	sext.w	a2,a3
ffffffffc020321c:	20e69963          	bne	a3,a4,ffffffffc020342e <_clock_check_swap+0x242>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203220:	6711                	lui	a4,0x4
ffffffffc0203222:	46b5                	li	a3,13
ffffffffc0203224:	00d70023          	sb	a3,0(a4) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203228:	4398                	lw	a4,0(a5)
ffffffffc020322a:	0007069b          	sext.w	a3,a4
ffffffffc020322e:	1ec71063          	bne	a4,a2,ffffffffc020340e <_clock_check_swap+0x222>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203232:	6709                	lui	a4,0x2
ffffffffc0203234:	462d                	li	a2,11
ffffffffc0203236:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020323a:	4398                	lw	a4,0(a5)
ffffffffc020323c:	1ad71963          	bne	a4,a3,ffffffffc02033ee <_clock_check_swap+0x202>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203240:	6715                	lui	a4,0x5
ffffffffc0203242:	46b9                	li	a3,14
ffffffffc0203244:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203248:	4398                	lw	a4,0(a5)
ffffffffc020324a:	4615                	li	a2,5
ffffffffc020324c:	0007069b          	sext.w	a3,a4
ffffffffc0203250:	16c71f63          	bne	a4,a2,ffffffffc02033ce <_clock_check_swap+0x1e2>
    assert(pgfault_num==5);
ffffffffc0203254:	4398                	lw	a4,0(a5)
ffffffffc0203256:	0007061b          	sext.w	a2,a4
ffffffffc020325a:	14d71a63          	bne	a4,a3,ffffffffc02033ae <_clock_check_swap+0x1c2>
    assert(pgfault_num==5);
ffffffffc020325e:	4398                	lw	a4,0(a5)
ffffffffc0203260:	0007069b          	sext.w	a3,a4
ffffffffc0203264:	12c71563          	bne	a4,a2,ffffffffc020338e <_clock_check_swap+0x1a2>
    assert(pgfault_num==5);
ffffffffc0203268:	4398                	lw	a4,0(a5)
ffffffffc020326a:	0007061b          	sext.w	a2,a4
ffffffffc020326e:	10d71063          	bne	a4,a3,ffffffffc020336e <_clock_check_swap+0x182>
    assert(pgfault_num==5);
ffffffffc0203272:	4398                	lw	a4,0(a5)
ffffffffc0203274:	0007069b          	sext.w	a3,a4
ffffffffc0203278:	0cc71b63          	bne	a4,a2,ffffffffc020334e <_clock_check_swap+0x162>
    assert(pgfault_num==5);
ffffffffc020327c:	4398                	lw	a4,0(a5)
ffffffffc020327e:	0ad71863          	bne	a4,a3,ffffffffc020332e <_clock_check_swap+0x142>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203282:	6715                	lui	a4,0x5
ffffffffc0203284:	46b9                	li	a3,14
ffffffffc0203286:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020328a:	4394                	lw	a3,0(a5)
ffffffffc020328c:	4715                	li	a4,5
ffffffffc020328e:	08e69063          	bne	a3,a4,ffffffffc020330e <_clock_check_swap+0x122>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203292:	6705                	lui	a4,0x1
ffffffffc0203294:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203298:	4729                	li	a4,10
ffffffffc020329a:	04e69a63          	bne	a3,a4,ffffffffc02032ee <_clock_check_swap+0x102>
    assert(pgfault_num==6);
ffffffffc020329e:	4398                	lw	a4,0(a5)
ffffffffc02032a0:	4799                	li	a5,6
ffffffffc02032a2:	02f71663          	bne	a4,a5,ffffffffc02032ce <_clock_check_swap+0xe2>
}
ffffffffc02032a6:	60a2                	ld	ra,8(sp)
ffffffffc02032a8:	4501                	li	a0,0
ffffffffc02032aa:	0141                	addi	sp,sp,16
ffffffffc02032ac:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02032ae:	00002697          	auipc	a3,0x2
ffffffffc02032b2:	72a68693          	addi	a3,a3,1834 # ffffffffc02059d8 <etext+0x14c4>
ffffffffc02032b6:	00002617          	auipc	a2,0x2
ffffffffc02032ba:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02032be:	09a00593          	li	a1,154
ffffffffc02032c2:	00003517          	auipc	a0,0x3
ffffffffc02032c6:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205b88 <etext+0x1674>
ffffffffc02032ca:	896fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==6);
ffffffffc02032ce:	00003697          	auipc	a3,0x3
ffffffffc02032d2:	90a68693          	addi	a3,a3,-1782 # ffffffffc0205bd8 <etext+0x16c4>
ffffffffc02032d6:	00002617          	auipc	a2,0x2
ffffffffc02032da:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02032de:	0b100593          	li	a1,177
ffffffffc02032e2:	00003517          	auipc	a0,0x3
ffffffffc02032e6:	8a650513          	addi	a0,a0,-1882 # ffffffffc0205b88 <etext+0x1674>
ffffffffc02032ea:	876fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032ee:	00003697          	auipc	a3,0x3
ffffffffc02032f2:	8c268693          	addi	a3,a3,-1854 # ffffffffc0205bb0 <etext+0x169c>
ffffffffc02032f6:	00002617          	auipc	a2,0x2
ffffffffc02032fa:	afa60613          	addi	a2,a2,-1286 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02032fe:	0af00593          	li	a1,175
ffffffffc0203302:	00003517          	auipc	a0,0x3
ffffffffc0203306:	88650513          	addi	a0,a0,-1914 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020330a:	856fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020330e:	00003697          	auipc	a3,0x3
ffffffffc0203312:	89268693          	addi	a3,a3,-1902 # ffffffffc0205ba0 <etext+0x168c>
ffffffffc0203316:	00002617          	auipc	a2,0x2
ffffffffc020331a:	ada60613          	addi	a2,a2,-1318 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020331e:	0ae00593          	li	a1,174
ffffffffc0203322:	00003517          	auipc	a0,0x3
ffffffffc0203326:	86650513          	addi	a0,a0,-1946 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020332a:	836fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020332e:	00003697          	auipc	a3,0x3
ffffffffc0203332:	87268693          	addi	a3,a3,-1934 # ffffffffc0205ba0 <etext+0x168c>
ffffffffc0203336:	00002617          	auipc	a2,0x2
ffffffffc020333a:	aba60613          	addi	a2,a2,-1350 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020333e:	0ac00593          	li	a1,172
ffffffffc0203342:	00003517          	auipc	a0,0x3
ffffffffc0203346:	84650513          	addi	a0,a0,-1978 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020334a:	816fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020334e:	00003697          	auipc	a3,0x3
ffffffffc0203352:	85268693          	addi	a3,a3,-1966 # ffffffffc0205ba0 <etext+0x168c>
ffffffffc0203356:	00002617          	auipc	a2,0x2
ffffffffc020335a:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020335e:	0aa00593          	li	a1,170
ffffffffc0203362:	00003517          	auipc	a0,0x3
ffffffffc0203366:	82650513          	addi	a0,a0,-2010 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020336a:	ff7fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020336e:	00003697          	auipc	a3,0x3
ffffffffc0203372:	83268693          	addi	a3,a3,-1998 # ffffffffc0205ba0 <etext+0x168c>
ffffffffc0203376:	00002617          	auipc	a2,0x2
ffffffffc020337a:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020337e:	0a800593          	li	a1,168
ffffffffc0203382:	00003517          	auipc	a0,0x3
ffffffffc0203386:	80650513          	addi	a0,a0,-2042 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020338a:	fd7fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020338e:	00003697          	auipc	a3,0x3
ffffffffc0203392:	81268693          	addi	a3,a3,-2030 # ffffffffc0205ba0 <etext+0x168c>
ffffffffc0203396:	00002617          	auipc	a2,0x2
ffffffffc020339a:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020339e:	0a600593          	li	a1,166
ffffffffc02033a2:	00002517          	auipc	a0,0x2
ffffffffc02033a6:	7e650513          	addi	a0,a0,2022 # ffffffffc0205b88 <etext+0x1674>
ffffffffc02033aa:	fb7fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc02033ae:	00002697          	auipc	a3,0x2
ffffffffc02033b2:	7f268693          	addi	a3,a3,2034 # ffffffffc0205ba0 <etext+0x168c>
ffffffffc02033b6:	00002617          	auipc	a2,0x2
ffffffffc02033ba:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02033be:	0a400593          	li	a1,164
ffffffffc02033c2:	00002517          	auipc	a0,0x2
ffffffffc02033c6:	7c650513          	addi	a0,a0,1990 # ffffffffc0205b88 <etext+0x1674>
ffffffffc02033ca:	f97fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc02033ce:	00002697          	auipc	a3,0x2
ffffffffc02033d2:	7d268693          	addi	a3,a3,2002 # ffffffffc0205ba0 <etext+0x168c>
ffffffffc02033d6:	00002617          	auipc	a2,0x2
ffffffffc02033da:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02033de:	0a200593          	li	a1,162
ffffffffc02033e2:	00002517          	auipc	a0,0x2
ffffffffc02033e6:	7a650513          	addi	a0,a0,1958 # ffffffffc0205b88 <etext+0x1674>
ffffffffc02033ea:	f77fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==4);
ffffffffc02033ee:	00002697          	auipc	a3,0x2
ffffffffc02033f2:	5ea68693          	addi	a3,a3,1514 # ffffffffc02059d8 <etext+0x14c4>
ffffffffc02033f6:	00002617          	auipc	a2,0x2
ffffffffc02033fa:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02033fe:	0a000593          	li	a1,160
ffffffffc0203402:	00002517          	auipc	a0,0x2
ffffffffc0203406:	78650513          	addi	a0,a0,1926 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020340a:	f57fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==4);
ffffffffc020340e:	00002697          	auipc	a3,0x2
ffffffffc0203412:	5ca68693          	addi	a3,a3,1482 # ffffffffc02059d8 <etext+0x14c4>
ffffffffc0203416:	00002617          	auipc	a2,0x2
ffffffffc020341a:	9da60613          	addi	a2,a2,-1574 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020341e:	09e00593          	li	a1,158
ffffffffc0203422:	00002517          	auipc	a0,0x2
ffffffffc0203426:	76650513          	addi	a0,a0,1894 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020342a:	f37fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==4);
ffffffffc020342e:	00002697          	auipc	a3,0x2
ffffffffc0203432:	5aa68693          	addi	a3,a3,1450 # ffffffffc02059d8 <etext+0x14c4>
ffffffffc0203436:	00002617          	auipc	a2,0x2
ffffffffc020343a:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020343e:	09c00593          	li	a1,156
ffffffffc0203442:	00002517          	auipc	a0,0x2
ffffffffc0203446:	74650513          	addi	a0,a0,1862 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020344a:	f17fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020344e <_clock_swap_out_victim>:
        assert(head != NULL);
ffffffffc020344e:	751c                	ld	a5,40(a0)
{
ffffffffc0203450:	1141                	addi	sp,sp,-16
ffffffffc0203452:	e406                	sd	ra,8(sp)
        assert(head != NULL);
ffffffffc0203454:	cb9d                	beqz	a5,ffffffffc020348a <_clock_swap_out_victim+0x3c>
    assert(in_tick==0);
ffffffffc0203456:	ea31                	bnez	a2,ffffffffc02034aa <_clock_swap_out_victim+0x5c>
    return listelm->prev;
ffffffffc0203458:	0000e697          	auipc	a3,0xe
ffffffffc020345c:	c9068693          	addi	a3,a3,-880 # ffffffffc02110e8 <pra_list_head>
ffffffffc0203460:	629c                	ld	a5,0(a3)
        if(entry!=&pra_list_head){
ffffffffc0203462:	00d78763          	beq	a5,a3,ffffffffc0203470 <_clock_swap_out_victim+0x22>
                if(!page->visited){
ffffffffc0203466:	fe07b703          	ld	a4,-32(a5)
ffffffffc020346a:	c709                	beqz	a4,ffffffffc0203474 <_clock_swap_out_victim+0x26>
                    page->visited=0;
ffffffffc020346c:	fe07b023          	sd	zero,-32(a5)
ffffffffc0203470:	639c                	ld	a5,0(a5)
        if(entry!=&pra_list_head){
ffffffffc0203472:	bfc5                	j	ffffffffc0203462 <_clock_swap_out_victim+0x14>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203474:	6394                	ld	a3,0(a5)
ffffffffc0203476:	6798                	ld	a4,8(a5)
}
ffffffffc0203478:	60a2                	ld	ra,8(sp)
                page=le2page(entry,pra_page_link);
ffffffffc020347a:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc020347e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203480:	e314                	sd	a3,0(a4)
                    *ptr_page = page;
ffffffffc0203482:	e19c                	sd	a5,0(a1)
}
ffffffffc0203484:	4501                	li	a0,0
ffffffffc0203486:	0141                	addi	sp,sp,16
ffffffffc0203488:	8082                	ret
        assert(head != NULL);
ffffffffc020348a:	00002697          	auipc	a3,0x2
ffffffffc020348e:	75e68693          	addi	a3,a3,1886 # ffffffffc0205be8 <etext+0x16d4>
ffffffffc0203492:	00002617          	auipc	a2,0x2
ffffffffc0203496:	95e60613          	addi	a2,a2,-1698 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020349a:	05700593          	li	a1,87
ffffffffc020349e:	00002517          	auipc	a0,0x2
ffffffffc02034a2:	6ea50513          	addi	a0,a0,1770 # ffffffffc0205b88 <etext+0x1674>
ffffffffc02034a6:	ebbfc0ef          	jal	ffffffffc0200360 <__panic>
    assert(in_tick==0);
ffffffffc02034aa:	00002697          	auipc	a3,0x2
ffffffffc02034ae:	74e68693          	addi	a3,a3,1870 # ffffffffc0205bf8 <etext+0x16e4>
ffffffffc02034b2:	00002617          	auipc	a2,0x2
ffffffffc02034b6:	93e60613          	addi	a2,a2,-1730 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02034ba:	05800593          	li	a1,88
ffffffffc02034be:	00002517          	auipc	a0,0x2
ffffffffc02034c2:	6ca50513          	addi	a0,a0,1738 # ffffffffc0205b88 <etext+0x1674>
ffffffffc02034c6:	e9bfc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02034ca <_clock_init_mm>:
{     
ffffffffc02034ca:	1141                	addi	sp,sp,-16
ffffffffc02034cc:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02034ce:	0000e797          	auipc	a5,0xe
ffffffffc02034d2:	c1a78793          	addi	a5,a5,-998 # ffffffffc02110e8 <pra_list_head>
    mm->sm_priv = &pra_list_head;
ffffffffc02034d6:	f51c                	sd	a5,40(a0)
    cprintf(" mm->sm_priv %x in clock_init_mm\n",mm->sm_priv);
ffffffffc02034d8:	85be                	mv	a1,a5
ffffffffc02034da:	00002517          	auipc	a0,0x2
ffffffffc02034de:	72e50513          	addi	a0,a0,1838 # ffffffffc0205c08 <etext+0x16f4>
ffffffffc02034e2:	e79c                	sd	a5,8(a5)
ffffffffc02034e4:	e39c                	sd	a5,0(a5)
    curr_ptr = &pra_list_head; 
ffffffffc02034e6:	0000e717          	auipc	a4,0xe
ffffffffc02034ea:	06f73923          	sd	a5,114(a4) # ffffffffc0211558 <curr_ptr>
    cprintf(" mm->sm_priv %x in clock_init_mm\n",mm->sm_priv);
ffffffffc02034ee:	bcdfc0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc02034f2:	60a2                	ld	ra,8(sp)
ffffffffc02034f4:	4501                	li	a0,0
ffffffffc02034f6:	0141                	addi	sp,sp,16
ffffffffc02034f8:	8082                	ret

ffffffffc02034fa <_clock_map_swappable>:
{
ffffffffc02034fa:	7179                	addi	sp,sp,-48
ffffffffc02034fc:	e44e                	sd	s3,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02034fe:	0000e997          	auipc	s3,0xe
ffffffffc0203502:	05a98993          	addi	s3,s3,90 # ffffffffc0211558 <curr_ptr>
ffffffffc0203506:	0009b783          	ld	a5,0(s3)
{
ffffffffc020350a:	f406                	sd	ra,40(sp)
ffffffffc020350c:	f022                	sd	s0,32(sp)
ffffffffc020350e:	ec26                	sd	s1,24(sp)
ffffffffc0203510:	e84a                	sd	s2,16(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203512:	cfb9                	beqz	a5,ffffffffc0203570 <_clock_map_swappable+0x76>
    list_entry_t * head=(list_entry_t*) mm->sm_priv;
ffffffffc0203514:	03060493          	addi	s1,a2,48
    curr_ptr = entry;
ffffffffc0203518:	0099b023          	sd	s1,0(s3)
    if(check_over_flag){
ffffffffc020351c:	0000e797          	auipc	a5,0xe
ffffffffc0203520:	0247a783          	lw	a5,36(a5) # ffffffffc0211540 <check_over_flag>
    list_entry_t * head=(list_entry_t*) mm->sm_priv;
ffffffffc0203524:	02853903          	ld	s2,40(a0)
    if(check_over_flag){
ffffffffc0203528:	8432                	mv	s0,a2
ffffffffc020352a:	e39d                	bnez	a5,ffffffffc0203550 <_clock_map_swappable+0x56>
    __list_add(elm, listelm, listelm->next);
ffffffffc020352c:	00893783          	ld	a5,8(s2)
}
ffffffffc0203530:	70a2                	ld	ra,40(sp)
ffffffffc0203532:	69a2                	ld	s3,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203534:	e384                	sd	s1,0(a5)
ffffffffc0203536:	00993423          	sd	s1,8(s2)
    elm->next = next;
ffffffffc020353a:	fc1c                	sd	a5,56(s0)
    page->visited = 1;
ffffffffc020353c:	4785                	li	a5,1
    elm->prev = prev;
ffffffffc020353e:	03243823          	sd	s2,48(s0)
ffffffffc0203542:	e81c                	sd	a5,16(s0)
}
ffffffffc0203544:	7402                	ld	s0,32(sp)
ffffffffc0203546:	64e2                	ld	s1,24(sp)
ffffffffc0203548:	6942                	ld	s2,16(sp)
ffffffffc020354a:	4501                	li	a0,0
ffffffffc020354c:	6145                	addi	sp,sp,48
ffffffffc020354e:	8082                	ret
    cprintf("curr_ptr 0x%016lx\n",curr_ptr);
ffffffffc0203550:	85a6                	mv	a1,s1
ffffffffc0203552:	00002517          	auipc	a0,0x2
ffffffffc0203556:	70650513          	addi	a0,a0,1798 # ffffffffc0205c58 <etext+0x1744>
ffffffffc020355a:	b61fc0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("curr_ptr 0x%016lx\n",curr_ptr);
ffffffffc020355e:	0009b583          	ld	a1,0(s3)
ffffffffc0203562:	00002517          	auipc	a0,0x2
ffffffffc0203566:	6f650513          	addi	a0,a0,1782 # ffffffffc0205c58 <etext+0x1744>
ffffffffc020356a:	b51fc0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc020356e:	bf7d                	j	ffffffffc020352c <_clock_map_swappable+0x32>
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203570:	00002697          	auipc	a3,0x2
ffffffffc0203574:	6c068693          	addi	a3,a3,1728 # ffffffffc0205c30 <etext+0x171c>
ffffffffc0203578:	00002617          	auipc	a2,0x2
ffffffffc020357c:	87860613          	addi	a2,a2,-1928 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203580:	03b00593          	li	a1,59
ffffffffc0203584:	00002517          	auipc	a0,0x2
ffffffffc0203588:	60450513          	addi	a0,a0,1540 # ffffffffc0205b88 <etext+0x1674>
ffffffffc020358c:	dd5fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203590 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203590:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203592:	00002697          	auipc	a3,0x2
ffffffffc0203596:	6f668693          	addi	a3,a3,1782 # ffffffffc0205c88 <etext+0x1774>
ffffffffc020359a:	00002617          	auipc	a2,0x2
ffffffffc020359e:	85660613          	addi	a2,a2,-1962 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02035a2:	07d00593          	li	a1,125
ffffffffc02035a6:	00002517          	auipc	a0,0x2
ffffffffc02035aa:	70250513          	addi	a0,a0,1794 # ffffffffc0205ca8 <etext+0x1794>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035ae:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02035b0:	db1fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02035b4 <mm_create>:
mm_create(void) {
ffffffffc02035b4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035b6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02035ba:	e022                	sd	s0,0(sp)
ffffffffc02035bc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035be:	a2aff0ef          	jal	ffffffffc02027e8 <kmalloc>
ffffffffc02035c2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02035c4:	c105                	beqz	a0,ffffffffc02035e4 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02035c6:	e408                	sd	a0,8(s0)
ffffffffc02035c8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02035ca:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02035ce:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02035d2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02035d6:	0000e797          	auipc	a5,0xe
ffffffffc02035da:	f6e7a783          	lw	a5,-146(a5) # ffffffffc0211544 <swap_init_ok>
ffffffffc02035de:	eb81                	bnez	a5,ffffffffc02035ee <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02035e0:	02053423          	sd	zero,40(a0)
}
ffffffffc02035e4:	60a2                	ld	ra,8(sp)
ffffffffc02035e6:	8522                	mv	a0,s0
ffffffffc02035e8:	6402                	ld	s0,0(sp)
ffffffffc02035ea:	0141                	addi	sp,sp,16
ffffffffc02035ec:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02035ee:	a4bff0ef          	jal	ffffffffc0203038 <swap_init_mm>
}
ffffffffc02035f2:	60a2                	ld	ra,8(sp)
ffffffffc02035f4:	8522                	mv	a0,s0
ffffffffc02035f6:	6402                	ld	s0,0(sp)
ffffffffc02035f8:	0141                	addi	sp,sp,16
ffffffffc02035fa:	8082                	ret

ffffffffc02035fc <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02035fc:	1101                	addi	sp,sp,-32
ffffffffc02035fe:	e04a                	sd	s2,0(sp)
ffffffffc0203600:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203602:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203606:	e822                	sd	s0,16(sp)
ffffffffc0203608:	e426                	sd	s1,8(sp)
ffffffffc020360a:	ec06                	sd	ra,24(sp)
ffffffffc020360c:	84ae                	mv	s1,a1
ffffffffc020360e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203610:	9d8ff0ef          	jal	ffffffffc02027e8 <kmalloc>
    if (vma != NULL) {
ffffffffc0203614:	c509                	beqz	a0,ffffffffc020361e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203616:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020361a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020361c:	ed00                	sd	s0,24(a0)
}
ffffffffc020361e:	60e2                	ld	ra,24(sp)
ffffffffc0203620:	6442                	ld	s0,16(sp)
ffffffffc0203622:	64a2                	ld	s1,8(sp)
ffffffffc0203624:	6902                	ld	s2,0(sp)
ffffffffc0203626:	6105                	addi	sp,sp,32
ffffffffc0203628:	8082                	ret

ffffffffc020362a <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc020362a:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc020362c:	c505                	beqz	a0,ffffffffc0203654 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020362e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203630:	c501                	beqz	a0,ffffffffc0203638 <find_vma+0xe>
ffffffffc0203632:	651c                	ld	a5,8(a0)
ffffffffc0203634:	02f5f663          	bgeu	a1,a5,ffffffffc0203660 <find_vma+0x36>
    return listelm->next;
ffffffffc0203638:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020363a:	00f68d63          	beq	a3,a5,ffffffffc0203654 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020363e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203642:	00e5e663          	bltu	a1,a4,ffffffffc020364e <find_vma+0x24>
ffffffffc0203646:	ff07b703          	ld	a4,-16(a5)
ffffffffc020364a:	00e5e763          	bltu	a1,a4,ffffffffc0203658 <find_vma+0x2e>
ffffffffc020364e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203650:	fef697e3          	bne	a3,a5,ffffffffc020363e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203654:	4501                	li	a0,0
}
ffffffffc0203656:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203658:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020365c:	ea88                	sd	a0,16(a3)
ffffffffc020365e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203660:	691c                	ld	a5,16(a0)
ffffffffc0203662:	fcf5fbe3          	bgeu	a1,a5,ffffffffc0203638 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203666:	ea88                	sd	a0,16(a3)
ffffffffc0203668:	8082                	ret

ffffffffc020366a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020366a:	6590                	ld	a2,8(a1)
ffffffffc020366c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203670:	1141                	addi	sp,sp,-16
ffffffffc0203672:	e406                	sd	ra,8(sp)
ffffffffc0203674:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203676:	01066763          	bltu	a2,a6,ffffffffc0203684 <insert_vma_struct+0x1a>
ffffffffc020367a:	a085                	j	ffffffffc02036da <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020367c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203680:	04e66863          	bltu	a2,a4,ffffffffc02036d0 <insert_vma_struct+0x66>
ffffffffc0203684:	86be                	mv	a3,a5
ffffffffc0203686:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203688:	fef51ae3          	bne	a0,a5,ffffffffc020367c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020368c:	02a68463          	beq	a3,a0,ffffffffc02036b4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203690:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203694:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203698:	08e8f163          	bgeu	a7,a4,ffffffffc020371a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020369c:	04e66f63          	bltu	a2,a4,ffffffffc02036fa <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02036a0:	00f50a63          	beq	a0,a5,ffffffffc02036b4 <insert_vma_struct+0x4a>
ffffffffc02036a4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036a8:	05076963          	bltu	a4,a6,ffffffffc02036fa <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036ac:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036b0:	02c77363          	bgeu	a4,a2,ffffffffc02036d6 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02036b4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036b6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036b8:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036bc:	e390                	sd	a2,0(a5)
ffffffffc02036be:	e690                	sd	a2,8(a3)
}
ffffffffc02036c0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036c2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02036c4:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02036c6:	0017079b          	addiw	a5,a4,1
ffffffffc02036ca:	d11c                	sw	a5,32(a0)
}
ffffffffc02036cc:	0141                	addi	sp,sp,16
ffffffffc02036ce:	8082                	ret
    if (le_prev != list) {
ffffffffc02036d0:	fca690e3          	bne	a3,a0,ffffffffc0203690 <insert_vma_struct+0x26>
ffffffffc02036d4:	bfd1                	j	ffffffffc02036a8 <insert_vma_struct+0x3e>
ffffffffc02036d6:	ebbff0ef          	jal	ffffffffc0203590 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036da:	00002697          	auipc	a3,0x2
ffffffffc02036de:	5de68693          	addi	a3,a3,1502 # ffffffffc0205cb8 <etext+0x17a4>
ffffffffc02036e2:	00001617          	auipc	a2,0x1
ffffffffc02036e6:	70e60613          	addi	a2,a2,1806 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc02036ea:	08400593          	li	a1,132
ffffffffc02036ee:	00002517          	auipc	a0,0x2
ffffffffc02036f2:	5ba50513          	addi	a0,a0,1466 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc02036f6:	c6bfc0ef          	jal	ffffffffc0200360 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036fa:	00002697          	auipc	a3,0x2
ffffffffc02036fe:	5fe68693          	addi	a3,a3,1534 # ffffffffc0205cf8 <etext+0x17e4>
ffffffffc0203702:	00001617          	auipc	a2,0x1
ffffffffc0203706:	6ee60613          	addi	a2,a2,1774 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020370a:	07c00593          	li	a1,124
ffffffffc020370e:	00002517          	auipc	a0,0x2
ffffffffc0203712:	59a50513          	addi	a0,a0,1434 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203716:	c4bfc0ef          	jal	ffffffffc0200360 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020371a:	00002697          	auipc	a3,0x2
ffffffffc020371e:	5be68693          	addi	a3,a3,1470 # ffffffffc0205cd8 <etext+0x17c4>
ffffffffc0203722:	00001617          	auipc	a2,0x1
ffffffffc0203726:	6ce60613          	addi	a2,a2,1742 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc020372a:	07b00593          	li	a1,123
ffffffffc020372e:	00002517          	auipc	a0,0x2
ffffffffc0203732:	57a50513          	addi	a0,a0,1402 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203736:	c2bfc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020373a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc020373a:	1141                	addi	sp,sp,-16
ffffffffc020373c:	e022                	sd	s0,0(sp)
ffffffffc020373e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203740:	6508                	ld	a0,8(a0)
ffffffffc0203742:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203744:	00a40e63          	beq	s0,a0,ffffffffc0203760 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203748:	6118                	ld	a4,0(a0)
ffffffffc020374a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020374c:	03000593          	li	a1,48
ffffffffc0203750:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203752:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203754:	e398                	sd	a4,0(a5)
ffffffffc0203756:	95eff0ef          	jal	ffffffffc02028b4 <kfree>
    return listelm->next;
ffffffffc020375a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020375c:	fea416e3          	bne	s0,a0,ffffffffc0203748 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203760:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203762:	6402                	ld	s0,0(sp)
ffffffffc0203764:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203766:	03000593          	li	a1,48
}
ffffffffc020376a:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020376c:	948ff06f          	j	ffffffffc02028b4 <kfree>

ffffffffc0203770 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203770:	715d                	addi	sp,sp,-80
ffffffffc0203772:	e486                	sd	ra,72(sp)
ffffffffc0203774:	f44e                	sd	s3,40(sp)
ffffffffc0203776:	f052                	sd	s4,32(sp)
ffffffffc0203778:	e0a2                	sd	s0,64(sp)
ffffffffc020377a:	fc26                	sd	s1,56(sp)
ffffffffc020377c:	f84a                	sd	s2,48(sp)
ffffffffc020377e:	ec56                	sd	s5,24(sp)
ffffffffc0203780:	e85a                	sd	s6,16(sp)
ffffffffc0203782:	e45e                	sd	s7,8(sp)
ffffffffc0203784:	e062                	sd	s8,0(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203786:	f0dfd0ef          	jal	ffffffffc0201692 <nr_free_pages>
ffffffffc020378a:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020378c:	f07fd0ef          	jal	ffffffffc0201692 <nr_free_pages>
ffffffffc0203790:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203792:	03000513          	li	a0,48
ffffffffc0203796:	852ff0ef          	jal	ffffffffc02027e8 <kmalloc>
    if (mm != NULL) {
ffffffffc020379a:	30050563          	beqz	a0,ffffffffc0203aa4 <vmm_init+0x334>
    elm->prev = elm->next = elm;
ffffffffc020379e:	e508                	sd	a0,8(a0)
ffffffffc02037a0:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02037a2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037a6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037aa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037ae:	0000e797          	auipc	a5,0xe
ffffffffc02037b2:	d967a783          	lw	a5,-618(a5) # ffffffffc0211544 <swap_init_ok>
ffffffffc02037b6:	842a                	mv	s0,a0
ffffffffc02037b8:	2c079363          	bnez	a5,ffffffffc0203a7e <vmm_init+0x30e>
        else mm->sm_priv = NULL;
ffffffffc02037bc:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02037c0:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037c4:	03000513          	li	a0,48
ffffffffc02037c8:	820ff0ef          	jal	ffffffffc02027e8 <kmalloc>
ffffffffc02037cc:	00248913          	addi	s2,s1,2
ffffffffc02037d0:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02037d2:	2a050963          	beqz	a0,ffffffffc0203a84 <vmm_init+0x314>
        vma->vm_start = vm_start;
ffffffffc02037d6:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02037d8:	01253823          	sd	s2,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02037dc:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02037e0:	14ed                	addi	s1,s1,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02037e2:	8522                	mv	a0,s0
ffffffffc02037e4:	e87ff0ef          	jal	ffffffffc020366a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02037e8:	fcf1                	bnez	s1,ffffffffc02037c4 <vmm_init+0x54>
ffffffffc02037ea:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02037ee:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037f2:	03000513          	li	a0,48
ffffffffc02037f6:	ff3fe0ef          	jal	ffffffffc02027e8 <kmalloc>
ffffffffc02037fa:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02037fc:	2c050463          	beqz	a0,ffffffffc0203ac4 <vmm_init+0x354>
        vma->vm_end = vm_end;
ffffffffc0203800:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203804:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203806:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203808:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020380c:	0495                	addi	s1,s1,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020380e:	8522                	mv	a0,s0
ffffffffc0203810:	e5bff0ef          	jal	ffffffffc020366a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203814:	fd249fe3          	bne	s1,s2,ffffffffc02037f2 <vmm_init+0x82>
    return listelm->next;
ffffffffc0203818:	00843b03          	ld	s6,8(s0)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc020381c:	3c8b0b63          	beq	s6,s0,ffffffffc0203bf2 <vmm_init+0x482>
    list_entry_t *le = list_next(&(mm->mmap_list));
ffffffffc0203820:	87da                	mv	a5,s6
        assert(le != &(mm->mmap_list));
ffffffffc0203822:	4715                	li	a4,5
    for (i = 1; i <= step2; i ++) {
ffffffffc0203824:	1f400593          	li	a1,500
ffffffffc0203828:	a021                	j	ffffffffc0203830 <vmm_init+0xc0>
        assert(le != &(mm->mmap_list));
ffffffffc020382a:	0715                	addi	a4,a4,5
ffffffffc020382c:	3c878363          	beq	a5,s0,ffffffffc0203bf2 <vmm_init+0x482>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203830:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203834:	32e69f63          	bne	a3,a4,ffffffffc0203b72 <vmm_init+0x402>
ffffffffc0203838:	ff07b603          	ld	a2,-16(a5)
ffffffffc020383c:	00270693          	addi	a3,a4,2
ffffffffc0203840:	32d61963          	bne	a2,a3,ffffffffc0203b72 <vmm_init+0x402>
ffffffffc0203844:	679c                	ld	a5,8(a5)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203846:	feb712e3          	bne	a4,a1,ffffffffc020382a <vmm_init+0xba>
ffffffffc020384a:	4b9d                	li	s7,7
ffffffffc020384c:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020384e:	1f900c13          	li	s8,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203852:	85a6                	mv	a1,s1
ffffffffc0203854:	8522                	mv	a0,s0
ffffffffc0203856:	dd5ff0ef          	jal	ffffffffc020362a <find_vma>
ffffffffc020385a:	8aaa                	mv	s5,a0
        assert(vma1 != NULL);
ffffffffc020385c:	3c050b63          	beqz	a0,ffffffffc0203c32 <vmm_init+0x4c2>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203860:	00148593          	addi	a1,s1,1
ffffffffc0203864:	8522                	mv	a0,s0
ffffffffc0203866:	dc5ff0ef          	jal	ffffffffc020362a <find_vma>
ffffffffc020386a:	892a                	mv	s2,a0
        assert(vma2 != NULL);
ffffffffc020386c:	3a050363          	beqz	a0,ffffffffc0203c12 <vmm_init+0x4a2>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203870:	85de                	mv	a1,s7
ffffffffc0203872:	8522                	mv	a0,s0
ffffffffc0203874:	db7ff0ef          	jal	ffffffffc020362a <find_vma>
        assert(vma3 == NULL);
ffffffffc0203878:	32051d63          	bnez	a0,ffffffffc0203bb2 <vmm_init+0x442>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020387c:	00348593          	addi	a1,s1,3
ffffffffc0203880:	8522                	mv	a0,s0
ffffffffc0203882:	da9ff0ef          	jal	ffffffffc020362a <find_vma>
        assert(vma4 == NULL);
ffffffffc0203886:	30051663          	bnez	a0,ffffffffc0203b92 <vmm_init+0x422>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020388a:	00448593          	addi	a1,s1,4
ffffffffc020388e:	8522                	mv	a0,s0
ffffffffc0203890:	d9bff0ef          	jal	ffffffffc020362a <find_vma>
        assert(vma5 == NULL);
ffffffffc0203894:	32051f63          	bnez	a0,ffffffffc0203bd2 <vmm_init+0x462>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203898:	008ab783          	ld	a5,8(s5) # 1008 <kern_entry-0xffffffffc01feff8>
ffffffffc020389c:	2a979b63          	bne	a5,s1,ffffffffc0203b52 <vmm_init+0x3e2>
ffffffffc02038a0:	010ab783          	ld	a5,16(s5)
ffffffffc02038a4:	2afb9763          	bne	s7,a5,ffffffffc0203b52 <vmm_init+0x3e2>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02038a8:	00893783          	ld	a5,8(s2)
ffffffffc02038ac:	28979363          	bne	a5,s1,ffffffffc0203b32 <vmm_init+0x3c2>
ffffffffc02038b0:	01093783          	ld	a5,16(s2)
ffffffffc02038b4:	26fb9f63          	bne	s7,a5,ffffffffc0203b32 <vmm_init+0x3c2>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02038b8:	0495                	addi	s1,s1,5
ffffffffc02038ba:	0b95                	addi	s7,s7,5
ffffffffc02038bc:	f9849be3          	bne	s1,s8,ffffffffc0203852 <vmm_init+0xe2>
ffffffffc02038c0:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02038c2:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02038c4:	85a6                	mv	a1,s1
ffffffffc02038c6:	8522                	mv	a0,s0
ffffffffc02038c8:	d63ff0ef          	jal	ffffffffc020362a <find_vma>
        if (vma_below_5 != NULL ) {
ffffffffc02038cc:	3a051363          	bnez	a0,ffffffffc0203c72 <vmm_init+0x502>
    for (i =4; i>=0; i--) {
ffffffffc02038d0:	14fd                	addi	s1,s1,-1
ffffffffc02038d2:	ff2499e3          	bne	s1,s2,ffffffffc02038c4 <vmm_init+0x154>
    __list_del(listelm->prev, listelm->next);
ffffffffc02038d6:	000b3703          	ld	a4,0(s6)
ffffffffc02038da:	008b3783          	ld	a5,8(s6)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02038de:	fe0b0513          	addi	a0,s6,-32
ffffffffc02038e2:	03000593          	li	a1,48
    prev->next = next;
ffffffffc02038e6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02038e8:	e398                	sd	a4,0(a5)
ffffffffc02038ea:	fcbfe0ef          	jal	ffffffffc02028b4 <kfree>
    return listelm->next;
ffffffffc02038ee:	00843b03          	ld	s6,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02038f2:	ff6412e3          	bne	s0,s6,ffffffffc02038d6 <vmm_init+0x166>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02038f6:	03000593          	li	a1,48
ffffffffc02038fa:	8522                	mv	a0,s0
ffffffffc02038fc:	fb9fe0ef          	jal	ffffffffc02028b4 <kfree>
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203900:	d93fd0ef          	jal	ffffffffc0201692 <nr_free_pages>
ffffffffc0203904:	3caa1163          	bne	s4,a0,ffffffffc0203cc6 <vmm_init+0x556>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203908:	00002517          	auipc	a0,0x2
ffffffffc020390c:	57850513          	addi	a0,a0,1400 # ffffffffc0205e80 <etext+0x196c>
ffffffffc0203910:	faafc0ef          	jal	ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203914:	d7ffd0ef          	jal	ffffffffc0201692 <nr_free_pages>
ffffffffc0203918:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020391a:	03000513          	li	a0,48
ffffffffc020391e:	ecbfe0ef          	jal	ffffffffc02027e8 <kmalloc>
ffffffffc0203922:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203924:	1e050063          	beqz	a0,ffffffffc0203b04 <vmm_init+0x394>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203928:	0000e797          	auipc	a5,0xe
ffffffffc020392c:	c1c7a783          	lw	a5,-996(a5) # ffffffffc0211544 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203930:	e508                	sd	a0,8(a0)
ffffffffc0203932:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203934:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203938:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020393c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203940:	1e079663          	bnez	a5,ffffffffc0203b2c <vmm_init+0x3bc>
        else mm->sm_priv = NULL;
ffffffffc0203944:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203948:	0000ea17          	auipc	s4,0xe
ffffffffc020394c:	bd8a3a03          	ld	s4,-1064(s4) # ffffffffc0211520 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203950:	000a3783          	ld	a5,0(s4)
    check_mm_struct = mm_create();
ffffffffc0203954:	0000e717          	auipc	a4,0xe
ffffffffc0203958:	c0873a23          	sd	s0,-1004(a4) # ffffffffc0211568 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020395c:	01443c23          	sd	s4,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203960:	2e079963          	bnez	a5,ffffffffc0203c52 <vmm_init+0x4e2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203964:	03000513          	li	a0,48
ffffffffc0203968:	e81fe0ef          	jal	ffffffffc02027e8 <kmalloc>
ffffffffc020396c:	892a                	mv	s2,a0
    if (vma != NULL) {
ffffffffc020396e:	16050b63          	beqz	a0,ffffffffc0203ae4 <vmm_init+0x374>
        vma->vm_end = vm_end;
ffffffffc0203972:	002007b7          	lui	a5,0x200
ffffffffc0203976:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203978:	4789                	li	a5,2
ffffffffc020397a:	ed1c                	sd	a5,24(a0)

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020397c:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020397e:	00053423          	sd	zero,8(a0)
    insert_vma_struct(mm, vma);
ffffffffc0203982:	8522                	mv	a0,s0
ffffffffc0203984:	ce7ff0ef          	jal	ffffffffc020366a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203988:	10000593          	li	a1,256
ffffffffc020398c:	8522                	mv	a0,s0
ffffffffc020398e:	c9dff0ef          	jal	ffffffffc020362a <find_vma>
ffffffffc0203992:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203996:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020399a:	30a91663          	bne	s2,a0,ffffffffc0203ca6 <vmm_init+0x536>
        *(char *)(addr + i) = i;
ffffffffc020399e:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc02039a2:	0785                	addi	a5,a5,1
ffffffffc02039a4:	fee79de3          	bne	a5,a4,ffffffffc020399e <vmm_init+0x22e>
ffffffffc02039a8:	6705                	lui	a4,0x1
ffffffffc02039aa:	10000793          	li	a5,256
ffffffffc02039ae:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02039b2:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02039b6:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02039ba:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02039bc:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02039be:	fec79ce3          	bne	a5,a2,ffffffffc02039b6 <vmm_init+0x246>
    }
    assert(sum == 0);
ffffffffc02039c2:	32071e63          	bnez	a4,ffffffffc0203cfe <vmm_init+0x58e>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02039c6:	4581                	li	a1,0
ffffffffc02039c8:	8552                	mv	a0,s4
ffffffffc02039ca:	f8bfd0ef          	jal	ffffffffc0201954 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039ce:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02039d2:	0000e717          	auipc	a4,0xe
ffffffffc02039d6:	b5e73703          	ld	a4,-1186(a4) # ffffffffc0211530 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039da:	078a                	slli	a5,a5,0x2
ffffffffc02039dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039de:	30e7f463          	bgeu	a5,a4,ffffffffc0203ce6 <vmm_init+0x576>
    return &pages[PPN(pa) - nbase];
ffffffffc02039e2:	00003717          	auipc	a4,0x3
ffffffffc02039e6:	94e73703          	ld	a4,-1714(a4) # ffffffffc0206330 <nbase>
ffffffffc02039ea:	8f99                	sub	a5,a5,a4
ffffffffc02039ec:	00379713          	slli	a4,a5,0x3
ffffffffc02039f0:	97ba                	add	a5,a5,a4
ffffffffc02039f2:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02039f4:	0000e517          	auipc	a0,0xe
ffffffffc02039f8:	b4453503          	ld	a0,-1212(a0) # ffffffffc0211538 <pages>
ffffffffc02039fc:	953e                	add	a0,a0,a5
ffffffffc02039fe:	4585                	li	a1,1
ffffffffc0203a00:	c53fd0ef          	jal	ffffffffc0201652 <free_pages>
    return listelm->next;
ffffffffc0203a04:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203a06:	000a3023          	sd	zero,0(s4)

    mm->pgdir = NULL;
ffffffffc0203a0a:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a0e:	00850e63          	beq	a0,s0,ffffffffc0203a2a <vmm_init+0x2ba>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a12:	6118                	ld	a4,0(a0)
ffffffffc0203a14:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203a16:	03000593          	li	a1,48
ffffffffc0203a1a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a1c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a1e:	e398                	sd	a4,0(a5)
ffffffffc0203a20:	e95fe0ef          	jal	ffffffffc02028b4 <kfree>
    return listelm->next;
ffffffffc0203a24:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a26:	fea416e3          	bne	s0,a0,ffffffffc0203a12 <vmm_init+0x2a2>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203a2a:	03000593          	li	a1,48
ffffffffc0203a2e:	8522                	mv	a0,s0
ffffffffc0203a30:	e85fe0ef          	jal	ffffffffc02028b4 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203a34:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203a36:	0000e797          	auipc	a5,0xe
ffffffffc0203a3a:	b207b923          	sd	zero,-1230(a5) # ffffffffc0211568 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a3e:	c55fd0ef          	jal	ffffffffc0201692 <nr_free_pages>
ffffffffc0203a42:	2ea49e63          	bne	s1,a0,ffffffffc0203d3e <vmm_init+0x5ce>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203a46:	00002517          	auipc	a0,0x2
ffffffffc0203a4a:	4a250513          	addi	a0,a0,1186 # ffffffffc0205ee8 <etext+0x19d4>
ffffffffc0203a4e:	e6cfc0ef          	jal	ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a52:	c41fd0ef          	jal	ffffffffc0201692 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203a56:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a58:	2ca99363          	bne	s3,a0,ffffffffc0203d1e <vmm_init+0x5ae>
}
ffffffffc0203a5c:	6406                	ld	s0,64(sp)
ffffffffc0203a5e:	60a6                	ld	ra,72(sp)
ffffffffc0203a60:	74e2                	ld	s1,56(sp)
ffffffffc0203a62:	7942                	ld	s2,48(sp)
ffffffffc0203a64:	79a2                	ld	s3,40(sp)
ffffffffc0203a66:	7a02                	ld	s4,32(sp)
ffffffffc0203a68:	6ae2                	ld	s5,24(sp)
ffffffffc0203a6a:	6b42                	ld	s6,16(sp)
ffffffffc0203a6c:	6ba2                	ld	s7,8(sp)
ffffffffc0203a6e:	6c02                	ld	s8,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a70:	00002517          	auipc	a0,0x2
ffffffffc0203a74:	49850513          	addi	a0,a0,1176 # ffffffffc0205f08 <etext+0x19f4>
}
ffffffffc0203a78:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a7a:	e40fc06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a7e:	dbaff0ef          	jal	ffffffffc0203038 <swap_init_mm>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a82:	bb3d                	j	ffffffffc02037c0 <vmm_init+0x50>
        assert(vma != NULL);
ffffffffc0203a84:	00002697          	auipc	a3,0x2
ffffffffc0203a88:	e1468693          	addi	a3,a3,-492 # ffffffffc0205898 <etext+0x1384>
ffffffffc0203a8c:	00001617          	auipc	a2,0x1
ffffffffc0203a90:	36460613          	addi	a2,a2,868 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203a94:	0ce00593          	li	a1,206
ffffffffc0203a98:	00002517          	auipc	a0,0x2
ffffffffc0203a9c:	21050513          	addi	a0,a0,528 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203aa0:	8c1fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(mm != NULL);
ffffffffc0203aa4:	00002697          	auipc	a3,0x2
ffffffffc0203aa8:	dbc68693          	addi	a3,a3,-580 # ffffffffc0205860 <etext+0x134c>
ffffffffc0203aac:	00001617          	auipc	a2,0x1
ffffffffc0203ab0:	34460613          	addi	a2,a2,836 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203ab4:	0c700593          	li	a1,199
ffffffffc0203ab8:	00002517          	auipc	a0,0x2
ffffffffc0203abc:	1f050513          	addi	a0,a0,496 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203ac0:	8a1fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma != NULL);
ffffffffc0203ac4:	00002697          	auipc	a3,0x2
ffffffffc0203ac8:	dd468693          	addi	a3,a3,-556 # ffffffffc0205898 <etext+0x1384>
ffffffffc0203acc:	00001617          	auipc	a2,0x1
ffffffffc0203ad0:	32460613          	addi	a2,a2,804 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203ad4:	0d400593          	li	a1,212
ffffffffc0203ad8:	00002517          	auipc	a0,0x2
ffffffffc0203adc:	1d050513          	addi	a0,a0,464 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203ae0:	881fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(vma != NULL);
ffffffffc0203ae4:	00002697          	auipc	a3,0x2
ffffffffc0203ae8:	db468693          	addi	a3,a3,-588 # ffffffffc0205898 <etext+0x1384>
ffffffffc0203aec:	00001617          	auipc	a2,0x1
ffffffffc0203af0:	30460613          	addi	a2,a2,772 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203af4:	11100593          	li	a1,273
ffffffffc0203af8:	00002517          	auipc	a0,0x2
ffffffffc0203afc:	1b050513          	addi	a0,a0,432 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203b00:	861fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203b04:	00002697          	auipc	a3,0x2
ffffffffc0203b08:	39c68693          	addi	a3,a3,924 # ffffffffc0205ea0 <etext+0x198c>
ffffffffc0203b0c:	00001617          	auipc	a2,0x1
ffffffffc0203b10:	2e460613          	addi	a2,a2,740 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203b14:	10a00593          	li	a1,266
ffffffffc0203b18:	00002517          	auipc	a0,0x2
ffffffffc0203b1c:	19050513          	addi	a0,a0,400 # ffffffffc0205ca8 <etext+0x1794>
    check_mm_struct = mm_create();
ffffffffc0203b20:	0000e797          	auipc	a5,0xe
ffffffffc0203b24:	a407b423          	sd	zero,-1464(a5) # ffffffffc0211568 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203b28:	839fc0ef          	jal	ffffffffc0200360 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203b2c:	d0cff0ef          	jal	ffffffffc0203038 <swap_init_mm>
    assert(check_mm_struct != NULL);
ffffffffc0203b30:	bd21                	j	ffffffffc0203948 <vmm_init+0x1d8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b32:	00002697          	auipc	a3,0x2
ffffffffc0203b36:	2b668693          	addi	a3,a3,694 # ffffffffc0205de8 <etext+0x18d4>
ffffffffc0203b3a:	00001617          	auipc	a2,0x1
ffffffffc0203b3e:	2b660613          	addi	a2,a2,694 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203b42:	0ee00593          	li	a1,238
ffffffffc0203b46:	00002517          	auipc	a0,0x2
ffffffffc0203b4a:	16250513          	addi	a0,a0,354 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203b4e:	813fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b52:	00002697          	auipc	a3,0x2
ffffffffc0203b56:	26668693          	addi	a3,a3,614 # ffffffffc0205db8 <etext+0x18a4>
ffffffffc0203b5a:	00001617          	auipc	a2,0x1
ffffffffc0203b5e:	29660613          	addi	a2,a2,662 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203b62:	0ed00593          	li	a1,237
ffffffffc0203b66:	00002517          	auipc	a0,0x2
ffffffffc0203b6a:	14250513          	addi	a0,a0,322 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203b6e:	ff2fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b72:	00002697          	auipc	a3,0x2
ffffffffc0203b76:	1be68693          	addi	a3,a3,446 # ffffffffc0205d30 <etext+0x181c>
ffffffffc0203b7a:	00001617          	auipc	a2,0x1
ffffffffc0203b7e:	27660613          	addi	a2,a2,630 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203b82:	0dd00593          	li	a1,221
ffffffffc0203b86:	00002517          	auipc	a0,0x2
ffffffffc0203b8a:	12250513          	addi	a0,a0,290 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203b8e:	fd2fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma4 == NULL);
ffffffffc0203b92:	00002697          	auipc	a3,0x2
ffffffffc0203b96:	20668693          	addi	a3,a3,518 # ffffffffc0205d98 <etext+0x1884>
ffffffffc0203b9a:	00001617          	auipc	a2,0x1
ffffffffc0203b9e:	25660613          	addi	a2,a2,598 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203ba2:	0e900593          	li	a1,233
ffffffffc0203ba6:	00002517          	auipc	a0,0x2
ffffffffc0203baa:	10250513          	addi	a0,a0,258 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203bae:	fb2fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma3 == NULL);
ffffffffc0203bb2:	00002697          	auipc	a3,0x2
ffffffffc0203bb6:	1d668693          	addi	a3,a3,470 # ffffffffc0205d88 <etext+0x1874>
ffffffffc0203bba:	00001617          	auipc	a2,0x1
ffffffffc0203bbe:	23660613          	addi	a2,a2,566 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203bc2:	0e700593          	li	a1,231
ffffffffc0203bc6:	00002517          	auipc	a0,0x2
ffffffffc0203bca:	0e250513          	addi	a0,a0,226 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203bce:	f92fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma5 == NULL);
ffffffffc0203bd2:	00002697          	auipc	a3,0x2
ffffffffc0203bd6:	1d668693          	addi	a3,a3,470 # ffffffffc0205da8 <etext+0x1894>
ffffffffc0203bda:	00001617          	auipc	a2,0x1
ffffffffc0203bde:	21660613          	addi	a2,a2,534 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203be2:	0eb00593          	li	a1,235
ffffffffc0203be6:	00002517          	auipc	a0,0x2
ffffffffc0203bea:	0c250513          	addi	a0,a0,194 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203bee:	f72fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203bf2:	00002697          	auipc	a3,0x2
ffffffffc0203bf6:	12668693          	addi	a3,a3,294 # ffffffffc0205d18 <etext+0x1804>
ffffffffc0203bfa:	00001617          	auipc	a2,0x1
ffffffffc0203bfe:	1f660613          	addi	a2,a2,502 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203c02:	0db00593          	li	a1,219
ffffffffc0203c06:	00002517          	auipc	a0,0x2
ffffffffc0203c0a:	0a250513          	addi	a0,a0,162 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203c0e:	f52fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma2 != NULL);
ffffffffc0203c12:	00002697          	auipc	a3,0x2
ffffffffc0203c16:	16668693          	addi	a3,a3,358 # ffffffffc0205d78 <etext+0x1864>
ffffffffc0203c1a:	00001617          	auipc	a2,0x1
ffffffffc0203c1e:	1d660613          	addi	a2,a2,470 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203c22:	0e500593          	li	a1,229
ffffffffc0203c26:	00002517          	auipc	a0,0x2
ffffffffc0203c2a:	08250513          	addi	a0,a0,130 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203c2e:	f32fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma1 != NULL);
ffffffffc0203c32:	00002697          	auipc	a3,0x2
ffffffffc0203c36:	13668693          	addi	a3,a3,310 # ffffffffc0205d68 <etext+0x1854>
ffffffffc0203c3a:	00001617          	auipc	a2,0x1
ffffffffc0203c3e:	1b660613          	addi	a2,a2,438 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203c42:	0e300593          	li	a1,227
ffffffffc0203c46:	00002517          	auipc	a0,0x2
ffffffffc0203c4a:	06250513          	addi	a0,a0,98 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203c4e:	f12fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203c52:	00002697          	auipc	a3,0x2
ffffffffc0203c56:	c3668693          	addi	a3,a3,-970 # ffffffffc0205888 <etext+0x1374>
ffffffffc0203c5a:	00001617          	auipc	a2,0x1
ffffffffc0203c5e:	19660613          	addi	a2,a2,406 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203c62:	10d00593          	li	a1,269
ffffffffc0203c66:	00002517          	auipc	a0,0x2
ffffffffc0203c6a:	04250513          	addi	a0,a0,66 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203c6e:	ef2fc0ef          	jal	ffffffffc0200360 <__panic>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203c72:	6914                	ld	a3,16(a0)
ffffffffc0203c74:	6510                	ld	a2,8(a0)
ffffffffc0203c76:	0004859b          	sext.w	a1,s1
ffffffffc0203c7a:	00002517          	auipc	a0,0x2
ffffffffc0203c7e:	19e50513          	addi	a0,a0,414 # ffffffffc0205e18 <etext+0x1904>
ffffffffc0203c82:	c38fc0ef          	jal	ffffffffc02000ba <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203c86:	00002697          	auipc	a3,0x2
ffffffffc0203c8a:	1ba68693          	addi	a3,a3,442 # ffffffffc0205e40 <etext+0x192c>
ffffffffc0203c8e:	00001617          	auipc	a2,0x1
ffffffffc0203c92:	16260613          	addi	a2,a2,354 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203c96:	0f600593          	li	a1,246
ffffffffc0203c9a:	00002517          	auipc	a0,0x2
ffffffffc0203c9e:	00e50513          	addi	a0,a0,14 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203ca2:	ebefc0ef          	jal	ffffffffc0200360 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203ca6:	00002697          	auipc	a3,0x2
ffffffffc0203caa:	21268693          	addi	a3,a3,530 # ffffffffc0205eb8 <etext+0x19a4>
ffffffffc0203cae:	00001617          	auipc	a2,0x1
ffffffffc0203cb2:	14260613          	addi	a2,a2,322 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203cb6:	11600593          	li	a1,278
ffffffffc0203cba:	00002517          	auipc	a0,0x2
ffffffffc0203cbe:	fee50513          	addi	a0,a0,-18 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203cc2:	e9efc0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cc6:	00002697          	auipc	a3,0x2
ffffffffc0203cca:	19268693          	addi	a3,a3,402 # ffffffffc0205e58 <etext+0x1944>
ffffffffc0203cce:	00001617          	auipc	a2,0x1
ffffffffc0203cd2:	12260613          	addi	a2,a2,290 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203cd6:	0fb00593          	li	a1,251
ffffffffc0203cda:	00002517          	auipc	a0,0x2
ffffffffc0203cde:	fce50513          	addi	a0,a0,-50 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203ce2:	e7efc0ef          	jal	ffffffffc0200360 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203ce6:	00001617          	auipc	a2,0x1
ffffffffc0203cea:	4ba60613          	addi	a2,a2,1210 # ffffffffc02051a0 <etext+0xc8c>
ffffffffc0203cee:	06500593          	li	a1,101
ffffffffc0203cf2:	00001517          	auipc	a0,0x1
ffffffffc0203cf6:	4ce50513          	addi	a0,a0,1230 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0203cfa:	e66fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(sum == 0);
ffffffffc0203cfe:	00002697          	auipc	a3,0x2
ffffffffc0203d02:	1da68693          	addi	a3,a3,474 # ffffffffc0205ed8 <etext+0x19c4>
ffffffffc0203d06:	00001617          	auipc	a2,0x1
ffffffffc0203d0a:	0ea60613          	addi	a2,a2,234 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203d0e:	12000593          	li	a1,288
ffffffffc0203d12:	00002517          	auipc	a0,0x2
ffffffffc0203d16:	f9650513          	addi	a0,a0,-106 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203d1a:	e46fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d1e:	00002697          	auipc	a3,0x2
ffffffffc0203d22:	13a68693          	addi	a3,a3,314 # ffffffffc0205e58 <etext+0x1944>
ffffffffc0203d26:	00001617          	auipc	a2,0x1
ffffffffc0203d2a:	0ca60613          	addi	a2,a2,202 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203d2e:	0bd00593          	li	a1,189
ffffffffc0203d32:	00002517          	auipc	a0,0x2
ffffffffc0203d36:	f7650513          	addi	a0,a0,-138 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203d3a:	e26fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d3e:	00002697          	auipc	a3,0x2
ffffffffc0203d42:	11a68693          	addi	a3,a3,282 # ffffffffc0205e58 <etext+0x1944>
ffffffffc0203d46:	00001617          	auipc	a2,0x1
ffffffffc0203d4a:	0aa60613          	addi	a2,a2,170 # ffffffffc0204df0 <etext+0x8dc>
ffffffffc0203d4e:	12e00593          	li	a1,302
ffffffffc0203d52:	00002517          	auipc	a0,0x2
ffffffffc0203d56:	f5650513          	addi	a0,a0,-170 # ffffffffc0205ca8 <etext+0x1794>
ffffffffc0203d5a:	e06fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203d5e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d5e:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d60:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d62:	f022                	sd	s0,32(sp)
ffffffffc0203d64:	ec26                	sd	s1,24(sp)
ffffffffc0203d66:	f406                	sd	ra,40(sp)
ffffffffc0203d68:	8432                	mv	s0,a2
ffffffffc0203d6a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d6c:	8bfff0ef          	jal	ffffffffc020362a <find_vma>

    pgfault_num++;
ffffffffc0203d70:	0000d797          	auipc	a5,0xd
ffffffffc0203d74:	7f07a783          	lw	a5,2032(a5) # ffffffffc0211560 <pgfault_num>
ffffffffc0203d78:	2785                	addiw	a5,a5,1
ffffffffc0203d7a:	0000d717          	auipc	a4,0xd
ffffffffc0203d7e:	7ef72323          	sw	a5,2022(a4) # ffffffffc0211560 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203d82:	c159                	beqz	a0,ffffffffc0203e08 <do_pgfault+0xaa>
ffffffffc0203d84:	651c                	ld	a5,8(a0)
ffffffffc0203d86:	08f46163          	bltu	s0,a5,ffffffffc0203e08 <do_pgfault+0xaa>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203d8a:	6d1c                	ld	a5,24(a0)
ffffffffc0203d8c:	e84a                	sd	s2,16(sp)
        perm |= (PTE_R | PTE_W);
ffffffffc0203d8e:	4959                	li	s2,22
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203d90:	8b89                	andi	a5,a5,2
ffffffffc0203d92:	cbb1                	beqz	a5,ffffffffc0203de6 <do_pgfault+0x88>
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d94:	77fd                	lui	a5,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203d96:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d98:	8c7d                	and	s0,s0,a5
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203d9a:	85a2                	mv	a1,s0
ffffffffc0203d9c:	4605                	li	a2,1
ffffffffc0203d9e:	92ffd0ef          	jal	ffffffffc02016cc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203da2:	610c                	ld	a1,0(a0)
ffffffffc0203da4:	c1b9                	beqz	a1,ffffffffc0203dea <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203da6:	0000d797          	auipc	a5,0xd
ffffffffc0203daa:	79e7a783          	lw	a5,1950(a5) # ffffffffc0211544 <swap_init_ok>
ffffffffc0203dae:	c7b5                	beqz	a5,ffffffffc0203e1a <do_pgfault+0xbc>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc0203db0:	0030                	addi	a2,sp,8
ffffffffc0203db2:	85a2                	mv	a1,s0
ffffffffc0203db4:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203db6:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203db8:	baeff0ef          	jal	ffffffffc0203166 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203dbc:	65a2                	ld	a1,8(sp)
ffffffffc0203dbe:	6c88                	ld	a0,24(s1)
ffffffffc0203dc0:	86ca                	mv	a3,s2
ffffffffc0203dc2:	8622                	mv	a2,s0
ffffffffc0203dc4:	c2bfd0ef          	jal	ffffffffc02019ee <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203dc8:	6622                	ld	a2,8(sp)
ffffffffc0203dca:	4685                	li	a3,1
ffffffffc0203dcc:	85a2                	mv	a1,s0
ffffffffc0203dce:	8526                	mv	a0,s1
ffffffffc0203dd0:	a74ff0ef          	jal	ffffffffc0203044 <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc0203dd4:	67a2                	ld	a5,8(sp)
ffffffffc0203dd6:	e3a0                	sd	s0,64(a5)
ffffffffc0203dd8:	6942                	ld	s2,16(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203dda:	4501                	li	a0,0
failed:
    return ret;
}
ffffffffc0203ddc:	70a2                	ld	ra,40(sp)
ffffffffc0203dde:	7402                	ld	s0,32(sp)
ffffffffc0203de0:	64e2                	ld	s1,24(sp)
ffffffffc0203de2:	6145                	addi	sp,sp,48
ffffffffc0203de4:	8082                	ret
    uint32_t perm = PTE_U;
ffffffffc0203de6:	4941                	li	s2,16
ffffffffc0203de8:	b775                	j	ffffffffc0203d94 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203dea:	6c88                	ld	a0,24(s1)
ffffffffc0203dec:	864a                	mv	a2,s2
ffffffffc0203dee:	85a2                	mv	a1,s0
ffffffffc0203df0:	941fe0ef          	jal	ffffffffc0202730 <pgdir_alloc_page>
ffffffffc0203df4:	f175                	bnez	a0,ffffffffc0203dd8 <do_pgfault+0x7a>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203df6:	00002517          	auipc	a0,0x2
ffffffffc0203dfa:	15a50513          	addi	a0,a0,346 # ffffffffc0205f50 <etext+0x1a3c>
ffffffffc0203dfe:	abcfc0ef          	jal	ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e02:	6942                	ld	s2,16(sp)
ffffffffc0203e04:	5571                	li	a0,-4
ffffffffc0203e06:	bfd9                	j	ffffffffc0203ddc <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203e08:	85a2                	mv	a1,s0
ffffffffc0203e0a:	00002517          	auipc	a0,0x2
ffffffffc0203e0e:	11650513          	addi	a0,a0,278 # ffffffffc0205f20 <etext+0x1a0c>
ffffffffc0203e12:	aa8fc0ef          	jal	ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203e16:	5575                	li	a0,-3
        goto failed;
ffffffffc0203e18:	b7d1                	j	ffffffffc0203ddc <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203e1a:	00002517          	auipc	a0,0x2
ffffffffc0203e1e:	15e50513          	addi	a0,a0,350 # ffffffffc0205f78 <etext+0x1a64>
ffffffffc0203e22:	a98fc0ef          	jal	ffffffffc02000ba <cprintf>
            goto failed;
ffffffffc0203e26:	bff1                	j	ffffffffc0203e02 <do_pgfault+0xa4>

ffffffffc0203e28 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203e28:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e2a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203e2c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e2e:	e54fc0ef          	jal	ffffffffc0200482 <ide_device_valid>
ffffffffc0203e32:	cd01                	beqz	a0,ffffffffc0203e4a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e34:	4505                	li	a0,1
ffffffffc0203e36:	e52fc0ef          	jal	ffffffffc0200488 <ide_device_size>
}
ffffffffc0203e3a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e3c:	810d                	srli	a0,a0,0x3
ffffffffc0203e3e:	0000d797          	auipc	a5,0xd
ffffffffc0203e42:	70a7b523          	sd	a0,1802(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203e46:	0141                	addi	sp,sp,16
ffffffffc0203e48:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e4a:	00002617          	auipc	a2,0x2
ffffffffc0203e4e:	15660613          	addi	a2,a2,342 # ffffffffc0205fa0 <etext+0x1a8c>
ffffffffc0203e52:	45b5                	li	a1,13
ffffffffc0203e54:	00002517          	auipc	a0,0x2
ffffffffc0203e58:	16c50513          	addi	a0,a0,364 # ffffffffc0205fc0 <etext+0x1aac>
ffffffffc0203e5c:	d04fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203e60 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e60:	1141                	addi	sp,sp,-16
ffffffffc0203e62:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e64:	00855713          	srli	a4,a0,0x8
ffffffffc0203e68:	cb2d                	beqz	a4,ffffffffc0203eda <swapfs_read+0x7a>
ffffffffc0203e6a:	0000d797          	auipc	a5,0xd
ffffffffc0203e6e:	6de7b783          	ld	a5,1758(a5) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203e72:	06f77463          	bgeu	a4,a5,ffffffffc0203eda <swapfs_read+0x7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e76:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0203e7a:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc0203e7e:	07b2                	slli	a5,a5,0xc
ffffffffc0203e80:	e3978793          	addi	a5,a5,-455
ffffffffc0203e84:	07b2                	slli	a5,a5,0xc
ffffffffc0203e86:	0000d697          	auipc	a3,0xd
ffffffffc0203e8a:	6b26b683          	ld	a3,1714(a3) # ffffffffc0211538 <pages>
ffffffffc0203e8e:	e3978793          	addi	a5,a5,-455
ffffffffc0203e92:	8d95                	sub	a1,a1,a3
ffffffffc0203e94:	07b2                	slli	a5,a5,0xc
ffffffffc0203e96:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e9a:	e3978793          	addi	a5,a5,-455
ffffffffc0203e9e:	02f60633          	mul	a2,a2,a5
ffffffffc0203ea2:	00002797          	auipc	a5,0x2
ffffffffc0203ea6:	48e7b783          	ld	a5,1166(a5) # ffffffffc0206330 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eaa:	0000d697          	auipc	a3,0xd
ffffffffc0203eae:	6866b683          	ld	a3,1670(a3) # ffffffffc0211530 <npage>
ffffffffc0203eb2:	0037159b          	slliw	a1,a4,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203eb6:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eb8:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ebc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ebe:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ec0:	02d7f963          	bgeu	a5,a3,ffffffffc0203ef2 <swapfs_read+0x92>
}
ffffffffc0203ec4:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ec6:	0000d797          	auipc	a5,0xd
ffffffffc0203eca:	6627b783          	ld	a5,1634(a5) # ffffffffc0211528 <va_pa_offset>
ffffffffc0203ece:	46a1                	li	a3,8
ffffffffc0203ed0:	963e                	add	a2,a2,a5
ffffffffc0203ed2:	4505                	li	a0,1
}
ffffffffc0203ed4:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ed6:	db8fc06f          	j	ffffffffc020048e <ide_read_secs>
ffffffffc0203eda:	86aa                	mv	a3,a0
ffffffffc0203edc:	00002617          	auipc	a2,0x2
ffffffffc0203ee0:	0fc60613          	addi	a2,a2,252 # ffffffffc0205fd8 <etext+0x1ac4>
ffffffffc0203ee4:	45d1                	li	a1,20
ffffffffc0203ee6:	00002517          	auipc	a0,0x2
ffffffffc0203eea:	0da50513          	addi	a0,a0,218 # ffffffffc0205fc0 <etext+0x1aac>
ffffffffc0203eee:	c72fc0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0203ef2:	86b2                	mv	a3,a2
ffffffffc0203ef4:	06a00593          	li	a1,106
ffffffffc0203ef8:	00001617          	auipc	a2,0x1
ffffffffc0203efc:	30060613          	addi	a2,a2,768 # ffffffffc02051f8 <etext+0xce4>
ffffffffc0203f00:	00001517          	auipc	a0,0x1
ffffffffc0203f04:	2c050513          	addi	a0,a0,704 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0203f08:	c58fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203f0c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f0c:	1141                	addi	sp,sp,-16
ffffffffc0203f0e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f10:	00855713          	srli	a4,a0,0x8
ffffffffc0203f14:	cb2d                	beqz	a4,ffffffffc0203f86 <swapfs_write+0x7a>
ffffffffc0203f16:	0000d797          	auipc	a5,0xd
ffffffffc0203f1a:	6327b783          	ld	a5,1586(a5) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203f1e:	06f77463          	bgeu	a4,a5,ffffffffc0203f86 <swapfs_write+0x7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f22:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0203f26:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c9>
ffffffffc0203f2a:	07b2                	slli	a5,a5,0xc
ffffffffc0203f2c:	e3978793          	addi	a5,a5,-455
ffffffffc0203f30:	07b2                	slli	a5,a5,0xc
ffffffffc0203f32:	0000d697          	auipc	a3,0xd
ffffffffc0203f36:	6066b683          	ld	a3,1542(a3) # ffffffffc0211538 <pages>
ffffffffc0203f3a:	e3978793          	addi	a5,a5,-455
ffffffffc0203f3e:	8d95                	sub	a1,a1,a3
ffffffffc0203f40:	07b2                	slli	a5,a5,0xc
ffffffffc0203f42:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f46:	e3978793          	addi	a5,a5,-455
ffffffffc0203f4a:	02f60633          	mul	a2,a2,a5
ffffffffc0203f4e:	00002797          	auipc	a5,0x2
ffffffffc0203f52:	3e27b783          	ld	a5,994(a5) # ffffffffc0206330 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f56:	0000d697          	auipc	a3,0xd
ffffffffc0203f5a:	5da6b683          	ld	a3,1498(a3) # ffffffffc0211530 <npage>
ffffffffc0203f5e:	0037159b          	slliw	a1,a4,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f62:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f64:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f68:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f6a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f6c:	02d7f963          	bgeu	a5,a3,ffffffffc0203f9e <swapfs_write+0x92>
}
ffffffffc0203f70:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f72:	0000d797          	auipc	a5,0xd
ffffffffc0203f76:	5b67b783          	ld	a5,1462(a5) # ffffffffc0211528 <va_pa_offset>
ffffffffc0203f7a:	46a1                	li	a3,8
ffffffffc0203f7c:	963e                	add	a2,a2,a5
ffffffffc0203f7e:	4505                	li	a0,1
}
ffffffffc0203f80:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f82:	d30fc06f          	j	ffffffffc02004b2 <ide_write_secs>
ffffffffc0203f86:	86aa                	mv	a3,a0
ffffffffc0203f88:	00002617          	auipc	a2,0x2
ffffffffc0203f8c:	05060613          	addi	a2,a2,80 # ffffffffc0205fd8 <etext+0x1ac4>
ffffffffc0203f90:	45e5                	li	a1,25
ffffffffc0203f92:	00002517          	auipc	a0,0x2
ffffffffc0203f96:	02e50513          	addi	a0,a0,46 # ffffffffc0205fc0 <etext+0x1aac>
ffffffffc0203f9a:	bc6fc0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0203f9e:	86b2                	mv	a3,a2
ffffffffc0203fa0:	06a00593          	li	a1,106
ffffffffc0203fa4:	00001617          	auipc	a2,0x1
ffffffffc0203fa8:	25460613          	addi	a2,a2,596 # ffffffffc02051f8 <etext+0xce4>
ffffffffc0203fac:	00001517          	auipc	a0,0x1
ffffffffc0203fb0:	21450513          	addi	a0,a0,532 # ffffffffc02051c0 <etext+0xcac>
ffffffffc0203fb4:	bacfc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203fb8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203fb8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fbc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203fbe:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fc2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203fc4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fc8:	f022                	sd	s0,32(sp)
ffffffffc0203fca:	ec26                	sd	s1,24(sp)
ffffffffc0203fcc:	e84a                	sd	s2,16(sp)
ffffffffc0203fce:	f406                	sd	ra,40(sp)
ffffffffc0203fd0:	84aa                	mv	s1,a0
ffffffffc0203fd2:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203fd4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203fd8:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203fda:	05067063          	bgeu	a2,a6,ffffffffc020401a <printnum+0x62>
ffffffffc0203fde:	e44e                	sd	s3,8(sp)
ffffffffc0203fe0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203fe2:	4785                	li	a5,1
ffffffffc0203fe4:	00e7d763          	bge	a5,a4,ffffffffc0203ff2 <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0203fe8:	85ca                	mv	a1,s2
ffffffffc0203fea:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0203fec:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203fee:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203ff0:	fc65                	bnez	s0,ffffffffc0203fe8 <printnum+0x30>
ffffffffc0203ff2:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ff4:	1a02                	slli	s4,s4,0x20
ffffffffc0203ff6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203ffa:	00002797          	auipc	a5,0x2
ffffffffc0203ffe:	ffe78793          	addi	a5,a5,-2 # ffffffffc0205ff8 <etext+0x1ae4>
ffffffffc0204002:	97d2                	add	a5,a5,s4
}
ffffffffc0204004:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204006:	0007c503          	lbu	a0,0(a5)
}
ffffffffc020400a:	70a2                	ld	ra,40(sp)
ffffffffc020400c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020400e:	85ca                	mv	a1,s2
ffffffffc0204010:	87a6                	mv	a5,s1
}
ffffffffc0204012:	6942                	ld	s2,16(sp)
ffffffffc0204014:	64e2                	ld	s1,24(sp)
ffffffffc0204016:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204018:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020401a:	03065633          	divu	a2,a2,a6
ffffffffc020401e:	8722                	mv	a4,s0
ffffffffc0204020:	f99ff0ef          	jal	ffffffffc0203fb8 <printnum>
ffffffffc0204024:	bfc1                	j	ffffffffc0203ff4 <printnum+0x3c>

ffffffffc0204026 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204026:	7119                	addi	sp,sp,-128
ffffffffc0204028:	f4a6                	sd	s1,104(sp)
ffffffffc020402a:	f0ca                	sd	s2,96(sp)
ffffffffc020402c:	ecce                	sd	s3,88(sp)
ffffffffc020402e:	e8d2                	sd	s4,80(sp)
ffffffffc0204030:	e4d6                	sd	s5,72(sp)
ffffffffc0204032:	e0da                	sd	s6,64(sp)
ffffffffc0204034:	f862                	sd	s8,48(sp)
ffffffffc0204036:	fc86                	sd	ra,120(sp)
ffffffffc0204038:	f8a2                	sd	s0,112(sp)
ffffffffc020403a:	fc5e                	sd	s7,56(sp)
ffffffffc020403c:	f466                	sd	s9,40(sp)
ffffffffc020403e:	f06a                	sd	s10,32(sp)
ffffffffc0204040:	ec6e                	sd	s11,24(sp)
ffffffffc0204042:	892a                	mv	s2,a0
ffffffffc0204044:	84ae                	mv	s1,a1
ffffffffc0204046:	8c32                	mv	s8,a2
ffffffffc0204048:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020404a:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020404e:	05500b13          	li	s6,85
ffffffffc0204052:	00002a97          	auipc	s5,0x2
ffffffffc0204056:	14ea8a93          	addi	s5,s5,334 # ffffffffc02061a0 <default_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020405a:	000c4503          	lbu	a0,0(s8)
ffffffffc020405e:	001c0413          	addi	s0,s8,1
ffffffffc0204062:	01350a63          	beq	a0,s3,ffffffffc0204076 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0204066:	cd0d                	beqz	a0,ffffffffc02040a0 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0204068:	85a6                	mv	a1,s1
ffffffffc020406a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020406c:	00044503          	lbu	a0,0(s0)
ffffffffc0204070:	0405                	addi	s0,s0,1
ffffffffc0204072:	ff351ae3          	bne	a0,s3,ffffffffc0204066 <vprintfmt+0x40>
        char padc = ' ';
ffffffffc0204076:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc020407a:	4b81                	li	s7,0
ffffffffc020407c:	4601                	li	a2,0
        width = precision = -1;
ffffffffc020407e:	5d7d                	li	s10,-1
ffffffffc0204080:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204082:	00044683          	lbu	a3,0(s0)
ffffffffc0204086:	00140c13          	addi	s8,s0,1
ffffffffc020408a:	fdd6859b          	addiw	a1,a3,-35
ffffffffc020408e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204092:	02bb6663          	bltu	s6,a1,ffffffffc02040be <vprintfmt+0x98>
ffffffffc0204096:	058a                	slli	a1,a1,0x2
ffffffffc0204098:	95d6                	add	a1,a1,s5
ffffffffc020409a:	4198                	lw	a4,0(a1)
ffffffffc020409c:	9756                	add	a4,a4,s5
ffffffffc020409e:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02040a0:	70e6                	ld	ra,120(sp)
ffffffffc02040a2:	7446                	ld	s0,112(sp)
ffffffffc02040a4:	74a6                	ld	s1,104(sp)
ffffffffc02040a6:	7906                	ld	s2,96(sp)
ffffffffc02040a8:	69e6                	ld	s3,88(sp)
ffffffffc02040aa:	6a46                	ld	s4,80(sp)
ffffffffc02040ac:	6aa6                	ld	s5,72(sp)
ffffffffc02040ae:	6b06                	ld	s6,64(sp)
ffffffffc02040b0:	7be2                	ld	s7,56(sp)
ffffffffc02040b2:	7c42                	ld	s8,48(sp)
ffffffffc02040b4:	7ca2                	ld	s9,40(sp)
ffffffffc02040b6:	7d02                	ld	s10,32(sp)
ffffffffc02040b8:	6de2                	ld	s11,24(sp)
ffffffffc02040ba:	6109                	addi	sp,sp,128
ffffffffc02040bc:	8082                	ret
            putch('%', putdat);
ffffffffc02040be:	85a6                	mv	a1,s1
ffffffffc02040c0:	02500513          	li	a0,37
ffffffffc02040c4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040c6:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040ca:	02500793          	li	a5,37
ffffffffc02040ce:	8c22                	mv	s8,s0
ffffffffc02040d0:	f8f705e3          	beq	a4,a5,ffffffffc020405a <vprintfmt+0x34>
ffffffffc02040d4:	02500713          	li	a4,37
ffffffffc02040d8:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02040dc:	1c7d                	addi	s8,s8,-1
ffffffffc02040de:	fee79de3          	bne	a5,a4,ffffffffc02040d8 <vprintfmt+0xb2>
ffffffffc02040e2:	bfa5                	j	ffffffffc020405a <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02040e4:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02040e8:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc02040ea:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02040ee:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc02040f2:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f6:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc02040f8:	02b76563          	bltu	a4,a1,ffffffffc0204122 <vprintfmt+0xfc>
ffffffffc02040fc:	4525                	li	a0,9
                ch = *fmt;
ffffffffc02040fe:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204102:	002d171b          	slliw	a4,s10,0x2
ffffffffc0204106:	01a7073b          	addw	a4,a4,s10
ffffffffc020410a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020410e:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc0204110:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204114:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204116:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc020411a:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc020411e:	feb570e3          	bgeu	a0,a1,ffffffffc02040fe <vprintfmt+0xd8>
            if (width < 0)
ffffffffc0204122:	f60cd0e3          	bgez	s9,ffffffffc0204082 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0204126:	8cea                	mv	s9,s10
ffffffffc0204128:	5d7d                	li	s10,-1
ffffffffc020412a:	bfa1                	j	ffffffffc0204082 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020412c:	8db6                	mv	s11,a3
ffffffffc020412e:	8462                	mv	s0,s8
ffffffffc0204130:	bf89                	j	ffffffffc0204082 <vprintfmt+0x5c>
ffffffffc0204132:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0204134:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0204136:	b7b1                	j	ffffffffc0204082 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0204138:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020413a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020413e:	00c7c463          	blt	a5,a2,ffffffffc0204146 <vprintfmt+0x120>
    else if (lflag) {
ffffffffc0204142:	1a060163          	beqz	a2,ffffffffc02042e4 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc0204146:	000a3603          	ld	a2,0(s4)
ffffffffc020414a:	46c1                	li	a3,16
ffffffffc020414c:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020414e:	000d879b          	sext.w	a5,s11
ffffffffc0204152:	8766                	mv	a4,s9
ffffffffc0204154:	85a6                	mv	a1,s1
ffffffffc0204156:	854a                	mv	a0,s2
ffffffffc0204158:	e61ff0ef          	jal	ffffffffc0203fb8 <printnum>
            break;
ffffffffc020415c:	bdfd                	j	ffffffffc020405a <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020415e:	000a2503          	lw	a0,0(s4)
ffffffffc0204162:	85a6                	mv	a1,s1
ffffffffc0204164:	0a21                	addi	s4,s4,8
ffffffffc0204166:	9902                	jalr	s2
            break;
ffffffffc0204168:	bdcd                	j	ffffffffc020405a <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020416a:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020416c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0204170:	00c7c463          	blt	a5,a2,ffffffffc0204178 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc0204174:	16060363          	beqz	a2,ffffffffc02042da <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc0204178:	000a3603          	ld	a2,0(s4)
ffffffffc020417c:	46a9                	li	a3,10
ffffffffc020417e:	8a3a                	mv	s4,a4
ffffffffc0204180:	b7f9                	j	ffffffffc020414e <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc0204182:	85a6                	mv	a1,s1
ffffffffc0204184:	03000513          	li	a0,48
ffffffffc0204188:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020418a:	85a6                	mv	a1,s1
ffffffffc020418c:	07800513          	li	a0,120
ffffffffc0204190:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204192:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0204196:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204198:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020419a:	bf55                	j	ffffffffc020414e <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc020419c:	85a6                	mv	a1,s1
ffffffffc020419e:	02500513          	li	a0,37
ffffffffc02041a2:	9902                	jalr	s2
            break;
ffffffffc02041a4:	bd5d                	j	ffffffffc020405a <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc02041a6:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041aa:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc02041ac:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc02041ae:	bf95                	j	ffffffffc0204122 <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc02041b0:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02041b2:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02041b6:	00c7c463          	blt	a5,a2,ffffffffc02041be <vprintfmt+0x198>
    else if (lflag) {
ffffffffc02041ba:	10060b63          	beqz	a2,ffffffffc02042d0 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc02041be:	000a3603          	ld	a2,0(s4)
ffffffffc02041c2:	46a1                	li	a3,8
ffffffffc02041c4:	8a3a                	mv	s4,a4
ffffffffc02041c6:	b761                	j	ffffffffc020414e <vprintfmt+0x128>
            if (width < 0)
ffffffffc02041c8:	fffcc793          	not	a5,s9
ffffffffc02041cc:	97fd                	srai	a5,a5,0x3f
ffffffffc02041ce:	00fcf7b3          	and	a5,s9,a5
ffffffffc02041d2:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d6:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02041d8:	b56d                	j	ffffffffc0204082 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02041da:	000a3403          	ld	s0,0(s4)
ffffffffc02041de:	008a0793          	addi	a5,s4,8
ffffffffc02041e2:	e43e                	sd	a5,8(sp)
ffffffffc02041e4:	12040063          	beqz	s0,ffffffffc0204304 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02041e8:	0d905963          	blez	s9,ffffffffc02042ba <vprintfmt+0x294>
ffffffffc02041ec:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041f0:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc02041f4:	12fd9763          	bne	s11,a5,ffffffffc0204322 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041f8:	00044783          	lbu	a5,0(s0)
ffffffffc02041fc:	0007851b          	sext.w	a0,a5
ffffffffc0204200:	cb9d                	beqz	a5,ffffffffc0204236 <vprintfmt+0x210>
ffffffffc0204202:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204204:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204208:	000d4563          	bltz	s10,ffffffffc0204212 <vprintfmt+0x1ec>
ffffffffc020420c:	3d7d                	addiw	s10,s10,-1
ffffffffc020420e:	028d0263          	beq	s10,s0,ffffffffc0204232 <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc0204212:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204214:	0c0b8d63          	beqz	s7,ffffffffc02042ee <vprintfmt+0x2c8>
ffffffffc0204218:	3781                	addiw	a5,a5,-32
ffffffffc020421a:	0cfdfa63          	bgeu	s11,a5,ffffffffc02042ee <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc020421e:	03f00513          	li	a0,63
ffffffffc0204222:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204224:	000a4783          	lbu	a5,0(s4)
ffffffffc0204228:	3cfd                	addiw	s9,s9,-1
ffffffffc020422a:	0a05                	addi	s4,s4,1
ffffffffc020422c:	0007851b          	sext.w	a0,a5
ffffffffc0204230:	ffe1                	bnez	a5,ffffffffc0204208 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc0204232:	01905963          	blez	s9,ffffffffc0204244 <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc0204236:	85a6                	mv	a1,s1
ffffffffc0204238:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc020423c:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc020423e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204240:	fe0c9be3          	bnez	s9,ffffffffc0204236 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204244:	6a22                	ld	s4,8(sp)
ffffffffc0204246:	bd11                	j	ffffffffc020405a <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0204248:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020424a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc020424e:	00c7c363          	blt	a5,a2,ffffffffc0204254 <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc0204252:	ce25                	beqz	a2,ffffffffc02042ca <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc0204254:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204258:	08044d63          	bltz	s0,ffffffffc02042f2 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc020425c:	8622                	mv	a2,s0
ffffffffc020425e:	8a5e                	mv	s4,s7
ffffffffc0204260:	46a9                	li	a3,10
ffffffffc0204262:	b5f5                	j	ffffffffc020414e <vprintfmt+0x128>
            if (err < 0) {
ffffffffc0204264:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204268:	4619                	li	a2,6
            if (err < 0) {
ffffffffc020426a:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020426e:	8fb9                	xor	a5,a5,a4
ffffffffc0204270:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204274:	02d64663          	blt	a2,a3,ffffffffc02042a0 <vprintfmt+0x27a>
ffffffffc0204278:	00369713          	slli	a4,a3,0x3
ffffffffc020427c:	00002797          	auipc	a5,0x2
ffffffffc0204280:	07c78793          	addi	a5,a5,124 # ffffffffc02062f8 <error_string>
ffffffffc0204284:	97ba                	add	a5,a5,a4
ffffffffc0204286:	639c                	ld	a5,0(a5)
ffffffffc0204288:	cf81                	beqz	a5,ffffffffc02042a0 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020428a:	86be                	mv	a3,a5
ffffffffc020428c:	00002617          	auipc	a2,0x2
ffffffffc0204290:	d9c60613          	addi	a2,a2,-612 # ffffffffc0206028 <etext+0x1b14>
ffffffffc0204294:	85a6                	mv	a1,s1
ffffffffc0204296:	854a                	mv	a0,s2
ffffffffc0204298:	0e8000ef          	jal	ffffffffc0204380 <printfmt>
            err = va_arg(ap, int);
ffffffffc020429c:	0a21                	addi	s4,s4,8
ffffffffc020429e:	bb75                	j	ffffffffc020405a <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02042a0:	00002617          	auipc	a2,0x2
ffffffffc02042a4:	d7860613          	addi	a2,a2,-648 # ffffffffc0206018 <etext+0x1b04>
ffffffffc02042a8:	85a6                	mv	a1,s1
ffffffffc02042aa:	854a                	mv	a0,s2
ffffffffc02042ac:	0d4000ef          	jal	ffffffffc0204380 <printfmt>
            err = va_arg(ap, int);
ffffffffc02042b0:	0a21                	addi	s4,s4,8
ffffffffc02042b2:	b365                	j	ffffffffc020405a <vprintfmt+0x34>
            lflag ++;
ffffffffc02042b4:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042b6:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02042b8:	b3e9                	j	ffffffffc0204082 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042ba:	00044783          	lbu	a5,0(s0)
ffffffffc02042be:	0007851b          	sext.w	a0,a5
ffffffffc02042c2:	d3c9                	beqz	a5,ffffffffc0204244 <vprintfmt+0x21e>
ffffffffc02042c4:	00140a13          	addi	s4,s0,1
ffffffffc02042c8:	bf2d                	j	ffffffffc0204202 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc02042ca:	000a2403          	lw	s0,0(s4)
ffffffffc02042ce:	b769                	j	ffffffffc0204258 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc02042d0:	000a6603          	lwu	a2,0(s4)
ffffffffc02042d4:	46a1                	li	a3,8
ffffffffc02042d6:	8a3a                	mv	s4,a4
ffffffffc02042d8:	bd9d                	j	ffffffffc020414e <vprintfmt+0x128>
ffffffffc02042da:	000a6603          	lwu	a2,0(s4)
ffffffffc02042de:	46a9                	li	a3,10
ffffffffc02042e0:	8a3a                	mv	s4,a4
ffffffffc02042e2:	b5b5                	j	ffffffffc020414e <vprintfmt+0x128>
ffffffffc02042e4:	000a6603          	lwu	a2,0(s4)
ffffffffc02042e8:	46c1                	li	a3,16
ffffffffc02042ea:	8a3a                	mv	s4,a4
ffffffffc02042ec:	b58d                	j	ffffffffc020414e <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc02042ee:	9902                	jalr	s2
ffffffffc02042f0:	bf15                	j	ffffffffc0204224 <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc02042f2:	85a6                	mv	a1,s1
ffffffffc02042f4:	02d00513          	li	a0,45
ffffffffc02042f8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02042fa:	40800633          	neg	a2,s0
ffffffffc02042fe:	8a5e                	mv	s4,s7
ffffffffc0204300:	46a9                	li	a3,10
ffffffffc0204302:	b5b1                	j	ffffffffc020414e <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc0204304:	01905663          	blez	s9,ffffffffc0204310 <vprintfmt+0x2ea>
ffffffffc0204308:	02d00793          	li	a5,45
ffffffffc020430c:	04fd9263          	bne	s11,a5,ffffffffc0204350 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204310:	02800793          	li	a5,40
ffffffffc0204314:	00002a17          	auipc	s4,0x2
ffffffffc0204318:	cfda0a13          	addi	s4,s4,-771 # ffffffffc0206011 <etext+0x1afd>
ffffffffc020431c:	02800513          	li	a0,40
ffffffffc0204320:	b5cd                	j	ffffffffc0204202 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204322:	85ea                	mv	a1,s10
ffffffffc0204324:	8522                	mv	a0,s0
ffffffffc0204326:	148000ef          	jal	ffffffffc020446e <strnlen>
ffffffffc020432a:	40ac8cbb          	subw	s9,s9,a0
ffffffffc020432e:	01905963          	blez	s9,ffffffffc0204340 <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc0204332:	2d81                	sext.w	s11,s11
ffffffffc0204334:	85a6                	mv	a1,s1
ffffffffc0204336:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204338:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc020433a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020433c:	fe0c9ce3          	bnez	s9,ffffffffc0204334 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204340:	00044783          	lbu	a5,0(s0)
ffffffffc0204344:	0007851b          	sext.w	a0,a5
ffffffffc0204348:	ea079de3          	bnez	a5,ffffffffc0204202 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020434c:	6a22                	ld	s4,8(sp)
ffffffffc020434e:	b331                	j	ffffffffc020405a <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204350:	85ea                	mv	a1,s10
ffffffffc0204352:	00002517          	auipc	a0,0x2
ffffffffc0204356:	cbe50513          	addi	a0,a0,-834 # ffffffffc0206010 <etext+0x1afc>
ffffffffc020435a:	114000ef          	jal	ffffffffc020446e <strnlen>
ffffffffc020435e:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc0204362:	00002417          	auipc	s0,0x2
ffffffffc0204366:	cae40413          	addi	s0,s0,-850 # ffffffffc0206010 <etext+0x1afc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020436a:	00002a17          	auipc	s4,0x2
ffffffffc020436e:	ca7a0a13          	addi	s4,s4,-857 # ffffffffc0206011 <etext+0x1afd>
ffffffffc0204372:	02800793          	li	a5,40
ffffffffc0204376:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020437a:	fb904ce3          	bgtz	s9,ffffffffc0204332 <vprintfmt+0x30c>
ffffffffc020437e:	b551                	j	ffffffffc0204202 <vprintfmt+0x1dc>

ffffffffc0204380 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204380:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204382:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204386:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204388:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020438a:	ec06                	sd	ra,24(sp)
ffffffffc020438c:	f83a                	sd	a4,48(sp)
ffffffffc020438e:	fc3e                	sd	a5,56(sp)
ffffffffc0204390:	e0c2                	sd	a6,64(sp)
ffffffffc0204392:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204394:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204396:	c91ff0ef          	jal	ffffffffc0204026 <vprintfmt>
}
ffffffffc020439a:	60e2                	ld	ra,24(sp)
ffffffffc020439c:	6161                	addi	sp,sp,80
ffffffffc020439e:	8082                	ret

ffffffffc02043a0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02043a0:	715d                	addi	sp,sp,-80
ffffffffc02043a2:	e486                	sd	ra,72(sp)
ffffffffc02043a4:	e0a2                	sd	s0,64(sp)
ffffffffc02043a6:	fc26                	sd	s1,56(sp)
ffffffffc02043a8:	f84a                	sd	s2,48(sp)
ffffffffc02043aa:	f44e                	sd	s3,40(sp)
ffffffffc02043ac:	f052                	sd	s4,32(sp)
ffffffffc02043ae:	ec56                	sd	s5,24(sp)
ffffffffc02043b0:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc02043b2:	c901                	beqz	a0,ffffffffc02043c2 <readline+0x22>
ffffffffc02043b4:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02043b6:	00002517          	auipc	a0,0x2
ffffffffc02043ba:	c7250513          	addi	a0,a0,-910 # ffffffffc0206028 <etext+0x1b14>
ffffffffc02043be:	cfdfb0ef          	jal	ffffffffc02000ba <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02043c2:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043c4:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc02043c6:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02043c8:	4a29                	li	s4,10
ffffffffc02043ca:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc02043cc:	0000db17          	auipc	s6,0xd
ffffffffc02043d0:	d2cb0b13          	addi	s6,s6,-724 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043d4:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc02043d8:	d19fb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc02043dc:	00054a63          	bltz	a0,ffffffffc02043f0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043e0:	00a4da63          	bge	s1,a0,ffffffffc02043f4 <readline+0x54>
ffffffffc02043e4:	0289d263          	bge	s3,s0,ffffffffc0204408 <readline+0x68>
        c = getchar();
ffffffffc02043e8:	d09fb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc02043ec:	fe055ae3          	bgez	a0,ffffffffc02043e0 <readline+0x40>
            return NULL;
ffffffffc02043f0:	4501                	li	a0,0
ffffffffc02043f2:	a091                	j	ffffffffc0204436 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02043f4:	03251463          	bne	a0,s2,ffffffffc020441c <readline+0x7c>
ffffffffc02043f8:	04804963          	bgtz	s0,ffffffffc020444a <readline+0xaa>
        c = getchar();
ffffffffc02043fc:	cf5fb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc0204400:	fe0548e3          	bltz	a0,ffffffffc02043f0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204404:	fea4d8e3          	bge	s1,a0,ffffffffc02043f4 <readline+0x54>
            cputchar(c);
ffffffffc0204408:	e42a                	sd	a0,8(sp)
ffffffffc020440a:	ce5fb0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i ++] = c;
ffffffffc020440e:	6522                	ld	a0,8(sp)
ffffffffc0204410:	008b07b3          	add	a5,s6,s0
ffffffffc0204414:	2405                	addiw	s0,s0,1
ffffffffc0204416:	00a78023          	sb	a0,0(a5)
ffffffffc020441a:	bf7d                	j	ffffffffc02043d8 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020441c:	01450463          	beq	a0,s4,ffffffffc0204424 <readline+0x84>
ffffffffc0204420:	fb551ce3          	bne	a0,s5,ffffffffc02043d8 <readline+0x38>
            cputchar(c);
ffffffffc0204424:	ccbfb0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i] = '\0';
ffffffffc0204428:	0000d517          	auipc	a0,0xd
ffffffffc020442c:	cd050513          	addi	a0,a0,-816 # ffffffffc02110f8 <buf>
ffffffffc0204430:	942a                	add	s0,s0,a0
ffffffffc0204432:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0204436:	60a6                	ld	ra,72(sp)
ffffffffc0204438:	6406                	ld	s0,64(sp)
ffffffffc020443a:	74e2                	ld	s1,56(sp)
ffffffffc020443c:	7942                	ld	s2,48(sp)
ffffffffc020443e:	79a2                	ld	s3,40(sp)
ffffffffc0204440:	7a02                	ld	s4,32(sp)
ffffffffc0204442:	6ae2                	ld	s5,24(sp)
ffffffffc0204444:	6b42                	ld	s6,16(sp)
ffffffffc0204446:	6161                	addi	sp,sp,80
ffffffffc0204448:	8082                	ret
            cputchar(c);
ffffffffc020444a:	4521                	li	a0,8
ffffffffc020444c:	ca3fb0ef          	jal	ffffffffc02000ee <cputchar>
            i --;
ffffffffc0204450:	347d                	addiw	s0,s0,-1
ffffffffc0204452:	b759                	j	ffffffffc02043d8 <readline+0x38>

ffffffffc0204454 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204454:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204458:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020445a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020445c:	cb81                	beqz	a5,ffffffffc020446c <strlen+0x18>
        cnt ++;
ffffffffc020445e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204460:	00a707b3          	add	a5,a4,a0
ffffffffc0204464:	0007c783          	lbu	a5,0(a5)
ffffffffc0204468:	fbfd                	bnez	a5,ffffffffc020445e <strlen+0xa>
ffffffffc020446a:	8082                	ret
    }
    return cnt;
}
ffffffffc020446c:	8082                	ret

ffffffffc020446e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020446e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204470:	e589                	bnez	a1,ffffffffc020447a <strnlen+0xc>
ffffffffc0204472:	a811                	j	ffffffffc0204486 <strnlen+0x18>
        cnt ++;
ffffffffc0204474:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204476:	00f58863          	beq	a1,a5,ffffffffc0204486 <strnlen+0x18>
ffffffffc020447a:	00f50733          	add	a4,a0,a5
ffffffffc020447e:	00074703          	lbu	a4,0(a4)
ffffffffc0204482:	fb6d                	bnez	a4,ffffffffc0204474 <strnlen+0x6>
ffffffffc0204484:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204486:	852e                	mv	a0,a1
ffffffffc0204488:	8082                	ret

ffffffffc020448a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020448a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020448c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204490:	0785                	addi	a5,a5,1
ffffffffc0204492:	0585                	addi	a1,a1,1
ffffffffc0204494:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204498:	fb75                	bnez	a4,ffffffffc020448c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020449a:	8082                	ret

ffffffffc020449c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020449c:	00054783          	lbu	a5,0(a0)
ffffffffc02044a0:	e791                	bnez	a5,ffffffffc02044ac <strcmp+0x10>
ffffffffc02044a2:	a02d                	j	ffffffffc02044cc <strcmp+0x30>
ffffffffc02044a4:	00054783          	lbu	a5,0(a0)
ffffffffc02044a8:	cf89                	beqz	a5,ffffffffc02044c2 <strcmp+0x26>
ffffffffc02044aa:	85b6                	mv	a1,a3
ffffffffc02044ac:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02044b0:	0505                	addi	a0,a0,1
ffffffffc02044b2:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044b6:	fef707e3          	beq	a4,a5,ffffffffc02044a4 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044ba:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02044be:	9d19                	subw	a0,a0,a4
ffffffffc02044c0:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044c2:	0015c703          	lbu	a4,1(a1)
ffffffffc02044c6:	4501                	li	a0,0
}
ffffffffc02044c8:	9d19                	subw	a0,a0,a4
ffffffffc02044ca:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044cc:	0005c703          	lbu	a4,0(a1)
ffffffffc02044d0:	4501                	li	a0,0
ffffffffc02044d2:	b7f5                	j	ffffffffc02044be <strcmp+0x22>

ffffffffc02044d4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02044d4:	00054783          	lbu	a5,0(a0)
ffffffffc02044d8:	c799                	beqz	a5,ffffffffc02044e6 <strchr+0x12>
        if (*s == c) {
ffffffffc02044da:	00f58763          	beq	a1,a5,ffffffffc02044e8 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02044de:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02044e2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02044e4:	fbfd                	bnez	a5,ffffffffc02044da <strchr+0x6>
    }
    return NULL;
ffffffffc02044e6:	4501                	li	a0,0
}
ffffffffc02044e8:	8082                	ret

ffffffffc02044ea <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02044ea:	ca01                	beqz	a2,ffffffffc02044fa <memset+0x10>
ffffffffc02044ec:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02044ee:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02044f0:	0785                	addi	a5,a5,1
ffffffffc02044f2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02044f6:	fef61de3          	bne	a2,a5,ffffffffc02044f0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02044fa:	8082                	ret

ffffffffc02044fc <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02044fc:	ca19                	beqz	a2,ffffffffc0204512 <memcpy+0x16>
ffffffffc02044fe:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204500:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204502:	0005c703          	lbu	a4,0(a1)
ffffffffc0204506:	0585                	addi	a1,a1,1
ffffffffc0204508:	0785                	addi	a5,a5,1
ffffffffc020450a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020450e:	feb61ae3          	bne	a2,a1,ffffffffc0204502 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204512:	8082                	ret
