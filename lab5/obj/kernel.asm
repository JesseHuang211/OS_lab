
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00092517          	auipc	a0,0x92
ffffffffc0200036:	6ee50513          	addi	a0,a0,1774 # ffffffffc0292720 <buf>
ffffffffc020003a:	0009e617          	auipc	a2,0x9e
ffffffffc020003e:	c4660613          	addi	a2,a2,-954 # ffffffffc029dc80 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc020aff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	698060ef          	jal	ffffffffc02066e2 <memset>
    cons_init();                // init the console
ffffffffc020004e:	524000ef          	jal	ffffffffc0200572 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	6be58593          	addi	a1,a1,1726 # ffffffffc0206710 <etext+0x4>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	6d650513          	addi	a0,a0,1750 # ffffffffc0206730 <etext+0x24>
ffffffffc0200062:	11e000ef          	jal	ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1ae000ef          	jal	ffffffffc0200214 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	500020ef          	jal	ffffffffc020256a <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d8000ef          	jal	ffffffffc0200646 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5d6000ef          	jal	ffffffffc0200648 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	46a040ef          	jal	ffffffffc02044e0 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	5b1050ef          	jal	ffffffffc0205e2a <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	566000ef          	jal	ffffffffc02005e4 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	38c030ef          	jal	ffffffffc020340e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	49a000ef          	jal	ffffffffc0200520 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b0000ef          	jal	ffffffffc020063a <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	737050ef          	jal	ffffffffc0205fc4 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a2                	sd	s0,64(sp)
ffffffffc0200098:	fc26                	sd	s1,56(sp)
ffffffffc020009a:	f84a                	sd	s2,48(sp)
ffffffffc020009c:	f44e                	sd	s3,40(sp)
ffffffffc020009e:	f052                	sd	s4,32(sp)
ffffffffc02000a0:	ec56                	sd	s5,24(sp)
ffffffffc02000a2:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	69050513          	addi	a0,a0,1680 # ffffffffc0206738 <etext+0x2c>
ffffffffc02000b0:	0d0000ef          	jal	ffffffffc0200180 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02000b4:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4a29                	li	s4,10
ffffffffc02000bc:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc02000be:	00092b17          	auipc	s6,0x92
ffffffffc02000c2:	662b0b13          	addi	s6,s6,1634 # ffffffffc0292720 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc02000ca:	13a000ef          	jal	ffffffffc0200204 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a4da63          	bge	s1,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	0289d263          	bge	s3,s0,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	12a000ef          	jal	ffffffffc0200204 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03251463          	bne	a0,s2,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	04804963          	bgtz	s0,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ee:	116000ef          	jal	ffffffffc0200204 <getchar>
        if (c < 0) {
ffffffffc02000f2:	fe0548e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f6:	fea4d8e3          	bge	s1,a0,ffffffffc02000e6 <readline+0x54>
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0b8000ef          	jal	ffffffffc02001b4 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	008b07b3          	add	a5,s6,s0
ffffffffc0200106:	2405                	addiw	s0,s0,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01450463          	beq	a0,s4,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb551ce3          	bne	a0,s5,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	09e000ef          	jal	ffffffffc02001b4 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	00092517          	auipc	a0,0x92
ffffffffc020011e:	60650513          	addi	a0,a0,1542 # ffffffffc0292720 <buf>
ffffffffc0200122:	942a                	add	s0,s0,a0
ffffffffc0200124:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6406                	ld	s0,64(sp)
ffffffffc020012c:	74e2                	ld	s1,56(sp)
ffffffffc020012e:	7942                	ld	s2,48(sp)
ffffffffc0200130:	79a2                	ld	s3,40(sp)
ffffffffc0200132:	7a02                	ld	s4,32(sp)
ffffffffc0200134:	6ae2                	ld	s5,24(sp)
ffffffffc0200136:	6b42                	ld	s6,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	076000ef          	jal	ffffffffc02001b4 <cputchar>
            i --;
ffffffffc0200142:	347d                	addiw	s0,s0,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	426000ef          	jal	ffffffffc0200574 <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	15e060ef          	jal	ffffffffc02062d2 <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc0200186:	f42e                	sd	a1,40(sp)
ffffffffc0200188:	f832                	sd	a2,48(sp)
ffffffffc020018a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018c:	862a                	mv	a2,a0
ffffffffc020018e:	004c                	addi	a1,sp,4
ffffffffc0200190:	00000517          	auipc	a0,0x0
ffffffffc0200194:	fb650513          	addi	a0,a0,-74 # ffffffffc0200146 <cputch>
ffffffffc0200198:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc020019a:	ec06                	sd	ra,24(sp)
ffffffffc020019c:	e0ba                	sd	a4,64(sp)
ffffffffc020019e:	e4be                	sd	a5,72(sp)
ffffffffc02001a0:	e8c2                	sd	a6,80(sp)
ffffffffc02001a2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001a8:	12a060ef          	jal	ffffffffc02062d2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ac:	60e2                	ld	ra,24(sp)
ffffffffc02001ae:	4512                	lw	a0,4(sp)
ffffffffc02001b0:	6125                	addi	sp,sp,96
ffffffffc02001b2:	8082                	ret

ffffffffc02001b4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b4:	a6c1                	j	ffffffffc0200574 <cons_putc>

ffffffffc02001b6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b6:	1101                	addi	sp,sp,-32
ffffffffc02001b8:	ec06                	sd	ra,24(sp)
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	87aa                	mv	a5,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	00054503          	lbu	a0,0(a0)
ffffffffc02001c2:	c905                	beqz	a0,ffffffffc02001f2 <cputs+0x3c>
ffffffffc02001c4:	e426                	sd	s1,8(sp)
ffffffffc02001c6:	00178493          	addi	s1,a5,1
ffffffffc02001ca:	8426                	mv	s0,s1
    cons_putc(c);
ffffffffc02001cc:	3a8000ef          	jal	ffffffffc0200574 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00044503          	lbu	a0,0(s0)
ffffffffc02001d4:	87a2                	mv	a5,s0
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	f975                	bnez	a0,ffffffffc02001cc <cputs+0x16>
    (*cnt) ++;
ffffffffc02001da:	9f85                	subw	a5,a5,s1
    cons_putc(c);
ffffffffc02001dc:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc02001de:	0027841b          	addiw	s0,a5,2
ffffffffc02001e2:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001e4:	390000ef          	jal	ffffffffc0200574 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	6105                	addi	sp,sp,32
ffffffffc02001f0:	8082                	ret
    cons_putc(c);
ffffffffc02001f2:	4529                	li	a0,10
ffffffffc02001f4:	380000ef          	jal	ffffffffc0200574 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001f8:	4405                	li	s0,1
}
ffffffffc02001fa:	60e2                	ld	ra,24(sp)
ffffffffc02001fc:	8522                	mv	a0,s0
ffffffffc02001fe:	6442                	ld	s0,16(sp)
ffffffffc0200200:	6105                	addi	sp,sp,32
ffffffffc0200202:	8082                	ret

ffffffffc0200204 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200204:	1141                	addi	sp,sp,-16
ffffffffc0200206:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200208:	3a0000ef          	jal	ffffffffc02005a8 <cons_getc>
ffffffffc020020c:	dd75                	beqz	a0,ffffffffc0200208 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
ffffffffc0200210:	0141                	addi	sp,sp,16
ffffffffc0200212:	8082                	ret

ffffffffc0200214 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200214:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200216:	00006517          	auipc	a0,0x6
ffffffffc020021a:	52a50513          	addi	a0,a0,1322 # ffffffffc0206740 <etext+0x34>
void print_kerninfo(void) {
ffffffffc020021e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200220:	f61ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200224:	00000597          	auipc	a1,0x0
ffffffffc0200228:	e0e58593          	addi	a1,a1,-498 # ffffffffc0200032 <kern_init>
ffffffffc020022c:	00006517          	auipc	a0,0x6
ffffffffc0200230:	53450513          	addi	a0,a0,1332 # ffffffffc0206760 <etext+0x54>
ffffffffc0200234:	f4dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200238:	00006597          	auipc	a1,0x6
ffffffffc020023c:	4d458593          	addi	a1,a1,1236 # ffffffffc020670c <etext>
ffffffffc0200240:	00006517          	auipc	a0,0x6
ffffffffc0200244:	54050513          	addi	a0,a0,1344 # ffffffffc0206780 <etext+0x74>
ffffffffc0200248:	f39ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024c:	00092597          	auipc	a1,0x92
ffffffffc0200250:	4d458593          	addi	a1,a1,1236 # ffffffffc0292720 <buf>
ffffffffc0200254:	00006517          	auipc	a0,0x6
ffffffffc0200258:	54c50513          	addi	a0,a0,1356 # ffffffffc02067a0 <etext+0x94>
ffffffffc020025c:	f25ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200260:	0009e597          	auipc	a1,0x9e
ffffffffc0200264:	a2058593          	addi	a1,a1,-1504 # ffffffffc029dc80 <end>
ffffffffc0200268:	00006517          	auipc	a0,0x6
ffffffffc020026c:	55850513          	addi	a0,a0,1368 # ffffffffc02067c0 <etext+0xb4>
ffffffffc0200270:	f11ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200274:	0009e797          	auipc	a5,0x9e
ffffffffc0200278:	e0b78793          	addi	a5,a5,-501 # ffffffffc029e07f <end+0x3ff>
ffffffffc020027c:	00000717          	auipc	a4,0x0
ffffffffc0200280:	db670713          	addi	a4,a4,-586 # ffffffffc0200032 <kern_init>
ffffffffc0200284:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200286:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200290:	95be                	add	a1,a1,a5
ffffffffc0200292:	85a9                	srai	a1,a1,0xa
ffffffffc0200294:	00006517          	auipc	a0,0x6
ffffffffc0200298:	54c50513          	addi	a0,a0,1356 # ffffffffc02067e0 <etext+0xd4>
}
ffffffffc020029c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	b5cd                	j	ffffffffc0200180 <cprintf>

ffffffffc02002a0 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a0:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a2:	00006617          	auipc	a2,0x6
ffffffffc02002a6:	56e60613          	addi	a2,a2,1390 # ffffffffc0206810 <etext+0x104>
ffffffffc02002aa:	04d00593          	li	a1,77
ffffffffc02002ae:	00006517          	auipc	a0,0x6
ffffffffc02002b2:	57a50513          	addi	a0,a0,1402 # ffffffffc0206828 <etext+0x11c>
void print_stackframe(void) {
ffffffffc02002b6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002b8:	1bc000ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02002bc <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002bc:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002be:	00006617          	auipc	a2,0x6
ffffffffc02002c2:	58260613          	addi	a2,a2,1410 # ffffffffc0206840 <etext+0x134>
ffffffffc02002c6:	00006597          	auipc	a1,0x6
ffffffffc02002ca:	59a58593          	addi	a1,a1,1434 # ffffffffc0206860 <etext+0x154>
ffffffffc02002ce:	00006517          	auipc	a0,0x6
ffffffffc02002d2:	59a50513          	addi	a0,a0,1434 # ffffffffc0206868 <etext+0x15c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d8:	ea9ff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02002dc:	00006617          	auipc	a2,0x6
ffffffffc02002e0:	59c60613          	addi	a2,a2,1436 # ffffffffc0206878 <etext+0x16c>
ffffffffc02002e4:	00006597          	auipc	a1,0x6
ffffffffc02002e8:	5bc58593          	addi	a1,a1,1468 # ffffffffc02068a0 <etext+0x194>
ffffffffc02002ec:	00006517          	auipc	a0,0x6
ffffffffc02002f0:	57c50513          	addi	a0,a0,1404 # ffffffffc0206868 <etext+0x15c>
ffffffffc02002f4:	e8dff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02002f8:	00006617          	auipc	a2,0x6
ffffffffc02002fc:	5b860613          	addi	a2,a2,1464 # ffffffffc02068b0 <etext+0x1a4>
ffffffffc0200300:	00006597          	auipc	a1,0x6
ffffffffc0200304:	5d058593          	addi	a1,a1,1488 # ffffffffc02068d0 <etext+0x1c4>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	56050513          	addi	a0,a0,1376 # ffffffffc0206868 <etext+0x15c>
ffffffffc0200310:	e71ff0ef          	jal	ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc0200314:	60a2                	ld	ra,8(sp)
ffffffffc0200316:	4501                	li	a0,0
ffffffffc0200318:	0141                	addi	sp,sp,16
ffffffffc020031a:	8082                	ret

ffffffffc020031c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020031c:	1141                	addi	sp,sp,-16
ffffffffc020031e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200320:	ef5ff0ef          	jal	ffffffffc0200214 <print_kerninfo>
    return 0;
}
ffffffffc0200324:	60a2                	ld	ra,8(sp)
ffffffffc0200326:	4501                	li	a0,0
ffffffffc0200328:	0141                	addi	sp,sp,16
ffffffffc020032a:	8082                	ret

ffffffffc020032c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032c:	1141                	addi	sp,sp,-16
ffffffffc020032e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200330:	f71ff0ef          	jal	ffffffffc02002a0 <print_stackframe>
    return 0;
}
ffffffffc0200334:	60a2                	ld	ra,8(sp)
ffffffffc0200336:	4501                	li	a0,0
ffffffffc0200338:	0141                	addi	sp,sp,16
ffffffffc020033a:	8082                	ret

ffffffffc020033c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020033c:	7115                	addi	sp,sp,-224
ffffffffc020033e:	f15a                	sd	s6,160(sp)
ffffffffc0200340:	8b2a                	mv	s6,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200342:	00006517          	auipc	a0,0x6
ffffffffc0200346:	59e50513          	addi	a0,a0,1438 # ffffffffc02068e0 <etext+0x1d4>
kmonitor(struct trapframe *tf) {
ffffffffc020034a:	ed86                	sd	ra,216(sp)
ffffffffc020034c:	e9a2                	sd	s0,208(sp)
ffffffffc020034e:	e5a6                	sd	s1,200(sp)
ffffffffc0200350:	e1ca                	sd	s2,192(sp)
ffffffffc0200352:	fd4e                	sd	s3,184(sp)
ffffffffc0200354:	f952                	sd	s4,176(sp)
ffffffffc0200356:	f556                	sd	s5,168(sp)
ffffffffc0200358:	ed5e                	sd	s7,152(sp)
ffffffffc020035a:	e962                	sd	s8,144(sp)
ffffffffc020035c:	e566                	sd	s9,136(sp)
ffffffffc020035e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200360:	e21ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200364:	00006517          	auipc	a0,0x6
ffffffffc0200368:	5a450513          	addi	a0,a0,1444 # ffffffffc0206908 <etext+0x1fc>
ffffffffc020036c:	e15ff0ef          	jal	ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200370:	000b0563          	beqz	s6,ffffffffc020037a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200374:	855a                	mv	a0,s6
ffffffffc0200376:	4ba000ef          	jal	ffffffffc0200830 <print_trapframe>
ffffffffc020037a:	00008c17          	auipc	s8,0x8
ffffffffc020037e:	67ec0c13          	addi	s8,s8,1662 # ffffffffc02089f8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200382:	00006917          	auipc	s2,0x6
ffffffffc0200386:	5ae90913          	addi	s2,s2,1454 # ffffffffc0206930 <etext+0x224>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00006497          	auipc	s1,0x6
ffffffffc020038e:	5ae48493          	addi	s1,s1,1454 # ffffffffc0206938 <etext+0x22c>
        if (argc == MAXARGS - 1) {
ffffffffc0200392:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200394:	00006a97          	auipc	s5,0x6
ffffffffc0200398:	5aca8a93          	addi	s5,s5,1452 # ffffffffc0206940 <etext+0x234>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039c:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039e:	00006b97          	auipc	s7,0x6
ffffffffc02003a2:	5c2b8b93          	addi	s7,s7,1474 # ffffffffc0206960 <etext+0x254>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a6:	854a                	mv	a0,s2
ffffffffc02003a8:	cebff0ef          	jal	ffffffffc0200092 <readline>
ffffffffc02003ac:	842a                	mv	s0,a0
ffffffffc02003ae:	dd65                	beqz	a0,ffffffffc02003a6 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003b4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b6:	e59d                	bnez	a1,ffffffffc02003e4 <kmonitor+0xa8>
    if (argc == 0) {
ffffffffc02003b8:	fe0c87e3          	beqz	s9,ffffffffc02003a6 <kmonitor+0x6a>
ffffffffc02003bc:	00008d17          	auipc	s10,0x8
ffffffffc02003c0:	63cd0d13          	addi	s10,s10,1596 # ffffffffc02089f8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c6:	6582                	ld	a1,0(sp)
ffffffffc02003c8:	000d3503          	ld	a0,0(s10)
ffffffffc02003cc:	2c8060ef          	jal	ffffffffc0206694 <strcmp>
ffffffffc02003d0:	c53d                	beqz	a0,ffffffffc020043e <kmonitor+0x102>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d2:	2405                	addiw	s0,s0,1
ffffffffc02003d4:	0d61                	addi	s10,s10,24
ffffffffc02003d6:	ff4418e3          	bne	s0,s4,ffffffffc02003c6 <kmonitor+0x8a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003da:	6582                	ld	a1,0(sp)
ffffffffc02003dc:	855e                	mv	a0,s7
ffffffffc02003de:	da3ff0ef          	jal	ffffffffc0200180 <cprintf>
    return 0;
ffffffffc02003e2:	b7d1                	j	ffffffffc02003a6 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e4:	8526                	mv	a0,s1
ffffffffc02003e6:	2e6060ef          	jal	ffffffffc02066cc <strchr>
ffffffffc02003ea:	c901                	beqz	a0,ffffffffc02003fa <kmonitor+0xbe>
ffffffffc02003ec:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003f0:	00040023          	sb	zero,0(s0)
ffffffffc02003f4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f6:	d1e9                	beqz	a1,ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc02003f8:	b7f5                	j	ffffffffc02003e4 <kmonitor+0xa8>
        if (*buf == '\0') {
ffffffffc02003fa:	00044783          	lbu	a5,0(s0)
ffffffffc02003fe:	dfcd                	beqz	a5,ffffffffc02003b8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200400:	033c8a63          	beq	s9,s3,ffffffffc0200434 <kmonitor+0xf8>
        argv[argc ++] = buf;
ffffffffc0200404:	003c9793          	slli	a5,s9,0x3
ffffffffc0200408:	08078793          	addi	a5,a5,128
ffffffffc020040c:	978a                	add	a5,a5,sp
ffffffffc020040e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200412:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200416:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200418:	e591                	bnez	a1,ffffffffc0200424 <kmonitor+0xe8>
ffffffffc020041a:	bf79                	j	ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc020041c:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	d9d9                	beqz	a1,ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc0200424:	8526                	mv	a0,s1
ffffffffc0200426:	2a6060ef          	jal	ffffffffc02066cc <strchr>
ffffffffc020042a:	d96d                	beqz	a0,ffffffffc020041c <kmonitor+0xe0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00044583          	lbu	a1,0(s0)
ffffffffc0200430:	d5c1                	beqz	a1,ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc0200432:	bf4d                	j	ffffffffc02003e4 <kmonitor+0xa8>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200434:	45c1                	li	a1,16
ffffffffc0200436:	8556                	mv	a0,s5
ffffffffc0200438:	d49ff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc020043c:	b7e1                	j	ffffffffc0200404 <kmonitor+0xc8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020043e:	00141793          	slli	a5,s0,0x1
ffffffffc0200442:	97a2                	add	a5,a5,s0
ffffffffc0200444:	078e                	slli	a5,a5,0x3
ffffffffc0200446:	97e2                	add	a5,a5,s8
ffffffffc0200448:	6b9c                	ld	a5,16(a5)
ffffffffc020044a:	865a                	mv	a2,s6
ffffffffc020044c:	002c                	addi	a1,sp,8
ffffffffc020044e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200452:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200454:	f40559e3          	bgez	a0,ffffffffc02003a6 <kmonitor+0x6a>
}
ffffffffc0200458:	60ee                	ld	ra,216(sp)
ffffffffc020045a:	644e                	ld	s0,208(sp)
ffffffffc020045c:	64ae                	ld	s1,200(sp)
ffffffffc020045e:	690e                	ld	s2,192(sp)
ffffffffc0200460:	79ea                	ld	s3,184(sp)
ffffffffc0200462:	7a4a                	ld	s4,176(sp)
ffffffffc0200464:	7aaa                	ld	s5,168(sp)
ffffffffc0200466:	7b0a                	ld	s6,160(sp)
ffffffffc0200468:	6bea                	ld	s7,152(sp)
ffffffffc020046a:	6c4a                	ld	s8,144(sp)
ffffffffc020046c:	6caa                	ld	s9,136(sp)
ffffffffc020046e:	6d0a                	ld	s10,128(sp)
ffffffffc0200470:	612d                	addi	sp,sp,224
ffffffffc0200472:	8082                	ret

ffffffffc0200474 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200474:	0009d317          	auipc	t1,0x9d
ffffffffc0200478:	77430313          	addi	t1,t1,1908 # ffffffffc029dbe8 <is_panic>
ffffffffc020047c:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200480:	715d                	addi	sp,sp,-80
ffffffffc0200482:	ec06                	sd	ra,24(sp)
ffffffffc0200484:	f436                	sd	a3,40(sp)
ffffffffc0200486:	f83a                	sd	a4,48(sp)
ffffffffc0200488:	fc3e                	sd	a5,56(sp)
ffffffffc020048a:	e0c2                	sd	a6,64(sp)
ffffffffc020048c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020048e:	020e1c63          	bnez	t3,ffffffffc02004c6 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200492:	4785                	li	a5,1
ffffffffc0200494:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200498:	e822                	sd	s0,16(sp)
ffffffffc020049a:	103c                	addi	a5,sp,40
ffffffffc020049c:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020049e:	862e                	mv	a2,a1
ffffffffc02004a0:	85aa                	mv	a1,a0
ffffffffc02004a2:	00006517          	auipc	a0,0x6
ffffffffc02004a6:	4d650513          	addi	a0,a0,1238 # ffffffffc0206978 <etext+0x26c>
    va_start(ap, fmt);
ffffffffc02004aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004ac:	cd5ff0ef          	jal	ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b0:	65a2                	ld	a1,8(sp)
ffffffffc02004b2:	8522                	mv	a0,s0
ffffffffc02004b4:	cadff0ef          	jal	ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004b8:	00006517          	auipc	a0,0x6
ffffffffc02004bc:	4e050513          	addi	a0,a0,1248 # ffffffffc0206998 <etext+0x28c>
ffffffffc02004c0:	cc1ff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02004c4:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004c6:	4501                	li	a0,0
ffffffffc02004c8:	4581                	li	a1,0
ffffffffc02004ca:	4601                	li	a2,0
ffffffffc02004cc:	48a1                	li	a7,8
ffffffffc02004ce:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d2:	16e000ef          	jal	ffffffffc0200640 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004d6:	4501                	li	a0,0
ffffffffc02004d8:	e65ff0ef          	jal	ffffffffc020033c <kmonitor>
    while (1) {
ffffffffc02004dc:	bfed                	j	ffffffffc02004d6 <__panic+0x62>

ffffffffc02004de <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004de:	715d                	addi	sp,sp,-80
ffffffffc02004e0:	e822                	sd	s0,16(sp)
ffffffffc02004e2:	fc3e                	sd	a5,56(sp)
ffffffffc02004e4:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004e6:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	862e                	mv	a2,a1
ffffffffc02004ea:	85aa                	mv	a1,a0
ffffffffc02004ec:	00006517          	auipc	a0,0x6
ffffffffc02004f0:	4b450513          	addi	a0,a0,1204 # ffffffffc02069a0 <etext+0x294>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f4:	ec06                	sd	ra,24(sp)
ffffffffc02004f6:	f436                	sd	a3,40(sp)
ffffffffc02004f8:	f83a                	sd	a4,48(sp)
ffffffffc02004fa:	e0c2                	sd	a6,64(sp)
ffffffffc02004fc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004fe:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200500:	c81ff0ef          	jal	ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200504:	65a2                	ld	a1,8(sp)
ffffffffc0200506:	8522                	mv	a0,s0
ffffffffc0200508:	c59ff0ef          	jal	ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc020050c:	00006517          	auipc	a0,0x6
ffffffffc0200510:	48c50513          	addi	a0,a0,1164 # ffffffffc0206998 <etext+0x28c>
ffffffffc0200514:	c6dff0ef          	jal	ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc0200518:	60e2                	ld	ra,24(sp)
ffffffffc020051a:	6442                	ld	s0,16(sp)
ffffffffc020051c:	6161                	addi	sp,sp,80
ffffffffc020051e:	8082                	ret

ffffffffc0200520 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200520:	67e1                	lui	a5,0x18
ffffffffc0200522:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xeb40>
ffffffffc0200526:	0009d717          	auipc	a4,0x9d
ffffffffc020052a:	6cf73523          	sd	a5,1738(a4) # ffffffffc029dbf0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020052e:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200532:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200534:	953e                	add	a0,a0,a5
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4881                	li	a7,0
ffffffffc020053a:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020053e:	02000793          	li	a5,32
ffffffffc0200542:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200546:	00006517          	auipc	a0,0x6
ffffffffc020054a:	47a50513          	addi	a0,a0,1146 # ffffffffc02069c0 <etext+0x2b4>
    ticks = 0;
ffffffffc020054e:	0009d797          	auipc	a5,0x9d
ffffffffc0200552:	6a07b523          	sd	zero,1706(a5) # ffffffffc029dbf8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200556:	b12d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200558 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200558:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020055c:	0009d797          	auipc	a5,0x9d
ffffffffc0200560:	6947b783          	ld	a5,1684(a5) # ffffffffc029dbf0 <timebase>
ffffffffc0200564:	953e                	add	a0,a0,a5
ffffffffc0200566:	4581                	li	a1,0
ffffffffc0200568:	4601                	li	a2,0
ffffffffc020056a:	4881                	li	a7,0
ffffffffc020056c:	00000073          	ecall
ffffffffc0200570:	8082                	ret

ffffffffc0200572 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200574:	100027f3          	csrr	a5,sstatus
ffffffffc0200578:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020057a:	0ff57513          	zext.b	a0,a0
ffffffffc020057e:	e799                	bnez	a5,ffffffffc020058c <cons_putc+0x18>
ffffffffc0200580:	4581                	li	a1,0
ffffffffc0200582:	4601                	li	a2,0
ffffffffc0200584:	4885                	li	a7,1
ffffffffc0200586:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020058a:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020058c:	1101                	addi	sp,sp,-32
ffffffffc020058e:	ec06                	sd	ra,24(sp)
ffffffffc0200590:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200592:	0ae000ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0200596:	6522                	ld	a0,8(sp)
ffffffffc0200598:	4581                	li	a1,0
ffffffffc020059a:	4601                	li	a2,0
ffffffffc020059c:	4885                	li	a7,1
ffffffffc020059e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a2:	60e2                	ld	ra,24(sp)
ffffffffc02005a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005a6:	a851                	j	ffffffffc020063a <intr_enable>

ffffffffc02005a8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005a8:	100027f3          	csrr	a5,sstatus
ffffffffc02005ac:	8b89                	andi	a5,a5,2
ffffffffc02005ae:	eb89                	bnez	a5,ffffffffc02005c0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b0:	4501                	li	a0,0
ffffffffc02005b2:	4581                	li	a1,0
ffffffffc02005b4:	4601                	li	a2,0
ffffffffc02005b6:	4889                	li	a7,2
ffffffffc02005b8:	00000073          	ecall
ffffffffc02005bc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005be:	8082                	ret
int cons_getc(void) {
ffffffffc02005c0:	1101                	addi	sp,sp,-32
ffffffffc02005c2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005c4:	07c000ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
ffffffffc02005d6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005d8:	062000ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc02005dc:	60e2                	ld	ra,24(sp)
ffffffffc02005de:	6522                	ld	a0,8(sp)
ffffffffc02005e0:	6105                	addi	sp,sp,32
ffffffffc02005e2:	8082                	ret

ffffffffc02005e4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005e4:	8082                	ret

ffffffffc02005e6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005e6:	00253513          	sltiu	a0,a0,2
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005ec:	03800513          	li	a0,56
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f2:	00092797          	auipc	a5,0x92
ffffffffc02005f6:	52e78793          	addi	a5,a5,1326 # ffffffffc0292b20 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02005fa:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02005fe:	1141                	addi	sp,sp,-16
ffffffffc0200600:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	95be                	add	a1,a1,a5
ffffffffc0200604:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200608:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	0ea060ef          	jal	ffffffffc02066f4 <memcpy>
    return 0;
}
ffffffffc020060e:	60a2                	ld	ra,8(sp)
ffffffffc0200610:	4501                	li	a0,0
ffffffffc0200612:	0141                	addi	sp,sp,16
ffffffffc0200614:	8082                	ret

ffffffffc0200616 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200616:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020061a:	00092517          	auipc	a0,0x92
ffffffffc020061e:	50650513          	addi	a0,a0,1286 # ffffffffc0292b20 <ide>
                   size_t nsecs) {
ffffffffc0200622:	1141                	addi	sp,sp,-16
ffffffffc0200624:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200626:	953e                	add	a0,a0,a5
ffffffffc0200628:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020062c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062e:	0c6060ef          	jal	ffffffffc02066f4 <memcpy>
    return 0;
}
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	4501                	li	a0,0
ffffffffc0200636:	0141                	addi	sp,sp,16
ffffffffc0200638:	8082                	ret

ffffffffc020063a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020063a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200648:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020064c:	00000797          	auipc	a5,0x0
ffffffffc0200650:	64478793          	addi	a5,a5,1604 # ffffffffc0200c90 <__alltraps>
ffffffffc0200654:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200658:	000407b7          	lui	a5,0x40
ffffffffc020065c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200662:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200664:	1141                	addi	sp,sp,-16
ffffffffc0200666:	e022                	sd	s0,0(sp)
ffffffffc0200668:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	37650513          	addi	a0,a0,886 # ffffffffc02069e0 <etext+0x2d4>
void print_regs(struct pushregs* gpr) {
ffffffffc0200672:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	b0dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200678:	640c                	ld	a1,8(s0)
ffffffffc020067a:	00006517          	auipc	a0,0x6
ffffffffc020067e:	37e50513          	addi	a0,a0,894 # ffffffffc02069f8 <etext+0x2ec>
ffffffffc0200682:	affff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200686:	680c                	ld	a1,16(s0)
ffffffffc0200688:	00006517          	auipc	a0,0x6
ffffffffc020068c:	38850513          	addi	a0,a0,904 # ffffffffc0206a10 <etext+0x304>
ffffffffc0200690:	af1ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200694:	6c0c                	ld	a1,24(s0)
ffffffffc0200696:	00006517          	auipc	a0,0x6
ffffffffc020069a:	39250513          	addi	a0,a0,914 # ffffffffc0206a28 <etext+0x31c>
ffffffffc020069e:	ae3ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a2:	700c                	ld	a1,32(s0)
ffffffffc02006a4:	00006517          	auipc	a0,0x6
ffffffffc02006a8:	39c50513          	addi	a0,a0,924 # ffffffffc0206a40 <etext+0x334>
ffffffffc02006ac:	ad5ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b0:	740c                	ld	a1,40(s0)
ffffffffc02006b2:	00006517          	auipc	a0,0x6
ffffffffc02006b6:	3a650513          	addi	a0,a0,934 # ffffffffc0206a58 <etext+0x34c>
ffffffffc02006ba:	ac7ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006be:	780c                	ld	a1,48(s0)
ffffffffc02006c0:	00006517          	auipc	a0,0x6
ffffffffc02006c4:	3b050513          	addi	a0,a0,944 # ffffffffc0206a70 <etext+0x364>
ffffffffc02006c8:	ab9ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006cc:	7c0c                	ld	a1,56(s0)
ffffffffc02006ce:	00006517          	auipc	a0,0x6
ffffffffc02006d2:	3ba50513          	addi	a0,a0,954 # ffffffffc0206a88 <etext+0x37c>
ffffffffc02006d6:	aabff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006da:	602c                	ld	a1,64(s0)
ffffffffc02006dc:	00006517          	auipc	a0,0x6
ffffffffc02006e0:	3c450513          	addi	a0,a0,964 # ffffffffc0206aa0 <etext+0x394>
ffffffffc02006e4:	a9dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006e8:	642c                	ld	a1,72(s0)
ffffffffc02006ea:	00006517          	auipc	a0,0x6
ffffffffc02006ee:	3ce50513          	addi	a0,a0,974 # ffffffffc0206ab8 <etext+0x3ac>
ffffffffc02006f2:	a8fff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f6:	682c                	ld	a1,80(s0)
ffffffffc02006f8:	00006517          	auipc	a0,0x6
ffffffffc02006fc:	3d850513          	addi	a0,a0,984 # ffffffffc0206ad0 <etext+0x3c4>
ffffffffc0200700:	a81ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200704:	6c2c                	ld	a1,88(s0)
ffffffffc0200706:	00006517          	auipc	a0,0x6
ffffffffc020070a:	3e250513          	addi	a0,a0,994 # ffffffffc0206ae8 <etext+0x3dc>
ffffffffc020070e:	a73ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200712:	702c                	ld	a1,96(s0)
ffffffffc0200714:	00006517          	auipc	a0,0x6
ffffffffc0200718:	3ec50513          	addi	a0,a0,1004 # ffffffffc0206b00 <etext+0x3f4>
ffffffffc020071c:	a65ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200720:	742c                	ld	a1,104(s0)
ffffffffc0200722:	00006517          	auipc	a0,0x6
ffffffffc0200726:	3f650513          	addi	a0,a0,1014 # ffffffffc0206b18 <etext+0x40c>
ffffffffc020072a:	a57ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020072e:	782c                	ld	a1,112(s0)
ffffffffc0200730:	00006517          	auipc	a0,0x6
ffffffffc0200734:	40050513          	addi	a0,a0,1024 # ffffffffc0206b30 <etext+0x424>
ffffffffc0200738:	a49ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073c:	7c2c                	ld	a1,120(s0)
ffffffffc020073e:	00006517          	auipc	a0,0x6
ffffffffc0200742:	40a50513          	addi	a0,a0,1034 # ffffffffc0206b48 <etext+0x43c>
ffffffffc0200746:	a3bff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074a:	604c                	ld	a1,128(s0)
ffffffffc020074c:	00006517          	auipc	a0,0x6
ffffffffc0200750:	41450513          	addi	a0,a0,1044 # ffffffffc0206b60 <etext+0x454>
ffffffffc0200754:	a2dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200758:	644c                	ld	a1,136(s0)
ffffffffc020075a:	00006517          	auipc	a0,0x6
ffffffffc020075e:	41e50513          	addi	a0,a0,1054 # ffffffffc0206b78 <etext+0x46c>
ffffffffc0200762:	a1fff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200766:	684c                	ld	a1,144(s0)
ffffffffc0200768:	00006517          	auipc	a0,0x6
ffffffffc020076c:	42850513          	addi	a0,a0,1064 # ffffffffc0206b90 <etext+0x484>
ffffffffc0200770:	a11ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200774:	6c4c                	ld	a1,152(s0)
ffffffffc0200776:	00006517          	auipc	a0,0x6
ffffffffc020077a:	43250513          	addi	a0,a0,1074 # ffffffffc0206ba8 <etext+0x49c>
ffffffffc020077e:	a03ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200782:	704c                	ld	a1,160(s0)
ffffffffc0200784:	00006517          	auipc	a0,0x6
ffffffffc0200788:	43c50513          	addi	a0,a0,1084 # ffffffffc0206bc0 <etext+0x4b4>
ffffffffc020078c:	9f5ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200790:	744c                	ld	a1,168(s0)
ffffffffc0200792:	00006517          	auipc	a0,0x6
ffffffffc0200796:	44650513          	addi	a0,a0,1094 # ffffffffc0206bd8 <etext+0x4cc>
ffffffffc020079a:	9e7ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020079e:	784c                	ld	a1,176(s0)
ffffffffc02007a0:	00006517          	auipc	a0,0x6
ffffffffc02007a4:	45050513          	addi	a0,a0,1104 # ffffffffc0206bf0 <etext+0x4e4>
ffffffffc02007a8:	9d9ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ac:	7c4c                	ld	a1,184(s0)
ffffffffc02007ae:	00006517          	auipc	a0,0x6
ffffffffc02007b2:	45a50513          	addi	a0,a0,1114 # ffffffffc0206c08 <etext+0x4fc>
ffffffffc02007b6:	9cbff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ba:	606c                	ld	a1,192(s0)
ffffffffc02007bc:	00006517          	auipc	a0,0x6
ffffffffc02007c0:	46450513          	addi	a0,a0,1124 # ffffffffc0206c20 <etext+0x514>
ffffffffc02007c4:	9bdff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007c8:	646c                	ld	a1,200(s0)
ffffffffc02007ca:	00006517          	auipc	a0,0x6
ffffffffc02007ce:	46e50513          	addi	a0,a0,1134 # ffffffffc0206c38 <etext+0x52c>
ffffffffc02007d2:	9afff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d6:	686c                	ld	a1,208(s0)
ffffffffc02007d8:	00006517          	auipc	a0,0x6
ffffffffc02007dc:	47850513          	addi	a0,a0,1144 # ffffffffc0206c50 <etext+0x544>
ffffffffc02007e0:	9a1ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e4:	6c6c                	ld	a1,216(s0)
ffffffffc02007e6:	00006517          	auipc	a0,0x6
ffffffffc02007ea:	48250513          	addi	a0,a0,1154 # ffffffffc0206c68 <etext+0x55c>
ffffffffc02007ee:	993ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f2:	706c                	ld	a1,224(s0)
ffffffffc02007f4:	00006517          	auipc	a0,0x6
ffffffffc02007f8:	48c50513          	addi	a0,a0,1164 # ffffffffc0206c80 <etext+0x574>
ffffffffc02007fc:	985ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200800:	746c                	ld	a1,232(s0)
ffffffffc0200802:	00006517          	auipc	a0,0x6
ffffffffc0200806:	49650513          	addi	a0,a0,1174 # ffffffffc0206c98 <etext+0x58c>
ffffffffc020080a:	977ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020080e:	786c                	ld	a1,240(s0)
ffffffffc0200810:	00006517          	auipc	a0,0x6
ffffffffc0200814:	4a050513          	addi	a0,a0,1184 # ffffffffc0206cb0 <etext+0x5a4>
ffffffffc0200818:	969ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020081e:	6402                	ld	s0,0(sp)
ffffffffc0200820:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	4a650513          	addi	a0,a0,1190 # ffffffffc0206cc8 <etext+0x5bc>
}
ffffffffc020082a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	955ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200830 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	1141                	addi	sp,sp,-16
ffffffffc0200832:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	00006517          	auipc	a0,0x6
ffffffffc020083c:	4a850513          	addi	a0,a0,1192 # ffffffffc0206ce0 <etext+0x5d4>
print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	93fff0ef          	jal	ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200846:	8522                	mv	a0,s0
ffffffffc0200848:	e1bff0ef          	jal	ffffffffc0200662 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084c:	10043583          	ld	a1,256(s0)
ffffffffc0200850:	00006517          	auipc	a0,0x6
ffffffffc0200854:	4a850513          	addi	a0,a0,1192 # ffffffffc0206cf8 <etext+0x5ec>
ffffffffc0200858:	929ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085c:	10843583          	ld	a1,264(s0)
ffffffffc0200860:	00006517          	auipc	a0,0x6
ffffffffc0200864:	4b050513          	addi	a0,a0,1200 # ffffffffc0206d10 <etext+0x604>
ffffffffc0200868:	919ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020086c:	11043583          	ld	a1,272(s0)
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	4b850513          	addi	a0,a0,1208 # ffffffffc0206d28 <etext+0x61c>
ffffffffc0200878:	909ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200880:	6402                	ld	s0,0(sp)
ffffffffc0200882:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200884:	00006517          	auipc	a0,0x6
ffffffffc0200888:	4b450513          	addi	a0,a0,1204 # ffffffffc0206d38 <etext+0x62c>
}
ffffffffc020088c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	8f3ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200892 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200892:	1101                	addi	sp,sp,-32
ffffffffc0200894:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200896:	0009d497          	auipc	s1,0x9d
ffffffffc020089a:	3c248493          	addi	s1,s1,962 # ffffffffc029dc58 <check_mm_struct>
ffffffffc020089e:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a0:	e822                	sd	s0,16(sp)
ffffffffc02008a2:	ec06                	sd	ra,24(sp)
ffffffffc02008a4:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a6:	cfb9                	beqz	a5,ffffffffc0200904 <pgfault_handler+0x72>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008a8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ac:	11053583          	ld	a1,272(a0)
ffffffffc02008b0:	05500613          	li	a2,85
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b4:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b8:	c399                	beqz	a5,ffffffffc02008be <pgfault_handler+0x2c>
ffffffffc02008ba:	04b00613          	li	a2,75
ffffffffc02008be:	11843703          	ld	a4,280(s0)
ffffffffc02008c2:	47bd                	li	a5,15
ffffffffc02008c4:	05200693          	li	a3,82
ffffffffc02008c8:	04f70e63          	beq	a4,a5,ffffffffc0200924 <pgfault_handler+0x92>
ffffffffc02008cc:	00006517          	auipc	a0,0x6
ffffffffc02008d0:	48450513          	addi	a0,a0,1156 # ffffffffc0206d50 <etext+0x644>
ffffffffc02008d4:	8adff0ef          	jal	ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008d8:	6088                	ld	a0,0(s1)
ffffffffc02008da:	c50d                	beqz	a0,ffffffffc0200904 <pgfault_handler+0x72>
        assert(current == idleproc);
ffffffffc02008dc:	0009d717          	auipc	a4,0x9d
ffffffffc02008e0:	38c73703          	ld	a4,908(a4) # ffffffffc029dc68 <current>
ffffffffc02008e4:	0009d797          	auipc	a5,0x9d
ffffffffc02008e8:	3947b783          	ld	a5,916(a5) # ffffffffc029dc78 <idleproc>
ffffffffc02008ec:	02f71f63          	bne	a4,a5,ffffffffc020092a <pgfault_handler+0x98>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f0:	11043603          	ld	a2,272(s0)
ffffffffc02008f4:	11843583          	ld	a1,280(s0)
}
ffffffffc02008f8:	6442                	ld	s0,16(sp)
ffffffffc02008fa:	60e2                	ld	ra,24(sp)
ffffffffc02008fc:	64a2                	ld	s1,8(sp)
ffffffffc02008fe:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200900:	1260406f          	j	ffffffffc0204a26 <do_pgfault>
        if (current == NULL) {
ffffffffc0200904:	0009d797          	auipc	a5,0x9d
ffffffffc0200908:	3647b783          	ld	a5,868(a5) # ffffffffc029dc68 <current>
ffffffffc020090c:	cf9d                	beqz	a5,ffffffffc020094a <pgfault_handler+0xb8>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc020091c:	7788                	ld	a0,40(a5)
}
ffffffffc020091e:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200920:	1060406f          	j	ffffffffc0204a26 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	b755                	j	ffffffffc02008cc <pgfault_handler+0x3a>
        assert(current == idleproc);
ffffffffc020092a:	00006697          	auipc	a3,0x6
ffffffffc020092e:	44668693          	addi	a3,a3,1094 # ffffffffc0206d70 <etext+0x664>
ffffffffc0200932:	00006617          	auipc	a2,0x6
ffffffffc0200936:	45660613          	addi	a2,a2,1110 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020093a:	06b00593          	li	a1,107
ffffffffc020093e:	00006517          	auipc	a0,0x6
ffffffffc0200942:	46250513          	addi	a0,a0,1122 # ffffffffc0206da0 <etext+0x694>
ffffffffc0200946:	b2fff0ef          	jal	ffffffffc0200474 <__panic>
            print_trapframe(tf);
ffffffffc020094a:	8522                	mv	a0,s0
ffffffffc020094c:	ee5ff0ef          	jal	ffffffffc0200830 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200950:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200954:	11043583          	ld	a1,272(s0)
ffffffffc0200958:	05500613          	li	a2,85
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020095c:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200960:	c399                	beqz	a5,ffffffffc0200966 <pgfault_handler+0xd4>
ffffffffc0200962:	04b00613          	li	a2,75
ffffffffc0200966:	11843703          	ld	a4,280(s0)
ffffffffc020096a:	47bd                	li	a5,15
ffffffffc020096c:	05200693          	li	a3,82
ffffffffc0200970:	00f71463          	bne	a4,a5,ffffffffc0200978 <pgfault_handler+0xe6>
ffffffffc0200974:	05700693          	li	a3,87
ffffffffc0200978:	00006517          	auipc	a0,0x6
ffffffffc020097c:	3d850513          	addi	a0,a0,984 # ffffffffc0206d50 <etext+0x644>
ffffffffc0200980:	801ff0ef          	jal	ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200984:	00006617          	auipc	a2,0x6
ffffffffc0200988:	43460613          	addi	a2,a2,1076 # ffffffffc0206db8 <etext+0x6ac>
ffffffffc020098c:	07200593          	li	a1,114
ffffffffc0200990:	00006517          	auipc	a0,0x6
ffffffffc0200994:	41050513          	addi	a0,a0,1040 # ffffffffc0206da0 <etext+0x694>
ffffffffc0200998:	addff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020099c <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc020099c:	11853783          	ld	a5,280(a0)
ffffffffc02009a0:	472d                	li	a4,11
ffffffffc02009a2:	0786                	slli	a5,a5,0x1
ffffffffc02009a4:	8385                	srli	a5,a5,0x1
ffffffffc02009a6:	08f76363          	bltu	a4,a5,ffffffffc0200a2c <interrupt_handler+0x90>
ffffffffc02009aa:	00008717          	auipc	a4,0x8
ffffffffc02009ae:	09670713          	addi	a4,a4,150 # ffffffffc0208a40 <commands+0x48>
ffffffffc02009b2:	078a                	slli	a5,a5,0x2
ffffffffc02009b4:	97ba                	add	a5,a5,a4
ffffffffc02009b6:	439c                	lw	a5,0(a5)
ffffffffc02009b8:	97ba                	add	a5,a5,a4
ffffffffc02009ba:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009bc:	00006517          	auipc	a0,0x6
ffffffffc02009c0:	47450513          	addi	a0,a0,1140 # ffffffffc0206e30 <etext+0x724>
ffffffffc02009c4:	fbcff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009c8:	00006517          	auipc	a0,0x6
ffffffffc02009cc:	44850513          	addi	a0,a0,1096 # ffffffffc0206e10 <etext+0x704>
ffffffffc02009d0:	fb0ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009d4:	00006517          	auipc	a0,0x6
ffffffffc02009d8:	3fc50513          	addi	a0,a0,1020 # ffffffffc0206dd0 <etext+0x6c4>
ffffffffc02009dc:	fa4ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009e0:	00006517          	auipc	a0,0x6
ffffffffc02009e4:	41050513          	addi	a0,a0,1040 # ffffffffc0206df0 <etext+0x6e4>
ffffffffc02009e8:	f98ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009ec:	1141                	addi	sp,sp,-16
ffffffffc02009ee:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009f0:	b69ff0ef          	jal	ffffffffc0200558 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009f4:	0009d697          	auipc	a3,0x9d
ffffffffc02009f8:	20468693          	addi	a3,a3,516 # ffffffffc029dbf8 <ticks>
ffffffffc02009fc:	629c                	ld	a5,0(a3)
ffffffffc02009fe:	06400713          	li	a4,100
ffffffffc0200a02:	0785                	addi	a5,a5,1
ffffffffc0200a04:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a08:	e29c                	sd	a5,0(a3)
ffffffffc0200a0a:	eb01                	bnez	a4,ffffffffc0200a1a <interrupt_handler+0x7e>
ffffffffc0200a0c:	0009d797          	auipc	a5,0x9d
ffffffffc0200a10:	25c7b783          	ld	a5,604(a5) # ffffffffc029dc68 <current>
ffffffffc0200a14:	c399                	beqz	a5,ffffffffc0200a1a <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a16:	4705                	li	a4,1
ffffffffc0200a18:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a1a:	60a2                	ld	ra,8(sp)
ffffffffc0200a1c:	0141                	addi	sp,sp,16
ffffffffc0200a1e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a20:	00006517          	auipc	a0,0x6
ffffffffc0200a24:	43050513          	addi	a0,a0,1072 # ffffffffc0206e50 <etext+0x744>
ffffffffc0200a28:	f58ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a2c:	b511                	j	ffffffffc0200830 <print_trapframe>

ffffffffc0200a2e <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a2e:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a32:	1101                	addi	sp,sp,-32
ffffffffc0200a34:	e822                	sd	s0,16(sp)
ffffffffc0200a36:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200a38:	473d                	li	a4,15
void exception_handler(struct trapframe *tf) {
ffffffffc0200a3a:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200a3c:	18f76663          	bltu	a4,a5,ffffffffc0200bc8 <exception_handler+0x19a>
ffffffffc0200a40:	00008717          	auipc	a4,0x8
ffffffffc0200a44:	03070713          	addi	a4,a4,48 # ffffffffc0208a70 <commands+0x78>
ffffffffc0200a48:	078a                	slli	a5,a5,0x2
ffffffffc0200a4a:	97ba                	add	a5,a5,a4
ffffffffc0200a4c:	439c                	lw	a5,0(a5)
ffffffffc0200a4e:	97ba                	add	a5,a5,a4
ffffffffc0200a50:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a52:	00006517          	auipc	a0,0x6
ffffffffc0200a56:	50e50513          	addi	a0,a0,1294 # ffffffffc0206f60 <etext+0x854>
ffffffffc0200a5a:	f26ff0ef          	jal	ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a5e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a62:	60e2                	ld	ra,24(sp)
            tf->epc += 4;
ffffffffc0200a64:	0791                	addi	a5,a5,4
ffffffffc0200a66:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a6a:	6442                	ld	s0,16(sp)
ffffffffc0200a6c:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a6e:	7600506f          	j	ffffffffc02061ce <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a72:	00006517          	auipc	a0,0x6
ffffffffc0200a76:	50e50513          	addi	a0,a0,1294 # ffffffffc0206f80 <etext+0x874>
}
ffffffffc0200a7a:	6442                	ld	s0,16(sp)
ffffffffc0200a7c:	60e2                	ld	ra,24(sp)
ffffffffc0200a7e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a80:	f00ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a84:	00006517          	auipc	a0,0x6
ffffffffc0200a88:	51c50513          	addi	a0,a0,1308 # ffffffffc0206fa0 <etext+0x894>
ffffffffc0200a8c:	b7fd                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Instruction page fault\n");
ffffffffc0200a8e:	00006517          	auipc	a0,0x6
ffffffffc0200a92:	53250513          	addi	a0,a0,1330 # ffffffffc0206fc0 <etext+0x8b4>
ffffffffc0200a96:	b7d5                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Load page fault\n");
ffffffffc0200a98:	00006517          	auipc	a0,0x6
ffffffffc0200a9c:	54050513          	addi	a0,a0,1344 # ffffffffc0206fd8 <etext+0x8cc>
ffffffffc0200aa0:	e426                	sd	s1,8(sp)
ffffffffc0200aa2:	edeff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200aa6:	8522                	mv	a0,s0
ffffffffc0200aa8:	debff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200aac:	84aa                	mv	s1,a0
ffffffffc0200aae:	12051f63          	bnez	a0,ffffffffc0200bec <exception_handler+0x1be>
ffffffffc0200ab2:	64a2                	ld	s1,8(sp)
}
ffffffffc0200ab4:	60e2                	ld	ra,24(sp)
ffffffffc0200ab6:	6442                	ld	s0,16(sp)
ffffffffc0200ab8:	6105                	addi	sp,sp,32
ffffffffc0200aba:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200abc:	00006517          	auipc	a0,0x6
ffffffffc0200ac0:	53450513          	addi	a0,a0,1332 # ffffffffc0206ff0 <etext+0x8e4>
ffffffffc0200ac4:	e426                	sd	s1,8(sp)
ffffffffc0200ac6:	ebaff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200aca:	8522                	mv	a0,s0
ffffffffc0200acc:	dc7ff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200ad0:	84aa                	mv	s1,a0
ffffffffc0200ad2:	d165                	beqz	a0,ffffffffc0200ab2 <exception_handler+0x84>
                print_trapframe(tf);
ffffffffc0200ad4:	8522                	mv	a0,s0
ffffffffc0200ad6:	d5bff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ada:	86a6                	mv	a3,s1
ffffffffc0200adc:	00006617          	auipc	a2,0x6
ffffffffc0200ae0:	43460613          	addi	a2,a2,1076 # ffffffffc0206f10 <etext+0x804>
ffffffffc0200ae4:	0f800593          	li	a1,248
ffffffffc0200ae8:	00006517          	auipc	a0,0x6
ffffffffc0200aec:	2b850513          	addi	a0,a0,696 # ffffffffc0206da0 <etext+0x694>
ffffffffc0200af0:	985ff0ef          	jal	ffffffffc0200474 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200af4:	00006517          	auipc	a0,0x6
ffffffffc0200af8:	37c50513          	addi	a0,a0,892 # ffffffffc0206e70 <etext+0x764>
ffffffffc0200afc:	bfbd                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Instruction access fault\n");
ffffffffc0200afe:	00006517          	auipc	a0,0x6
ffffffffc0200b02:	39250513          	addi	a0,a0,914 # ffffffffc0206e90 <etext+0x784>
ffffffffc0200b06:	bf95                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Illegal instruction\n");
ffffffffc0200b08:	00006517          	auipc	a0,0x6
ffffffffc0200b0c:	3a850513          	addi	a0,a0,936 # ffffffffc0206eb0 <etext+0x7a4>
ffffffffc0200b10:	b7ad                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Breakpoint\n");
ffffffffc0200b12:	00006517          	auipc	a0,0x6
ffffffffc0200b16:	3b650513          	addi	a0,a0,950 # ffffffffc0206ec8 <etext+0x7bc>
ffffffffc0200b1a:	e66ff0ef          	jal	ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b1e:	6458                	ld	a4,136(s0)
ffffffffc0200b20:	47a9                	li	a5,10
ffffffffc0200b22:	f8f719e3          	bne	a4,a5,ffffffffc0200ab4 <exception_handler+0x86>
                tf->epc += 4;
ffffffffc0200b26:	10843783          	ld	a5,264(s0)
ffffffffc0200b2a:	0791                	addi	a5,a5,4
ffffffffc0200b2c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b30:	69e050ef          	jal	ffffffffc02061ce <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b34:	0009d797          	auipc	a5,0x9d
ffffffffc0200b38:	1347b783          	ld	a5,308(a5) # ffffffffc029dc68 <current>
ffffffffc0200b3c:	6b9c                	ld	a5,16(a5)
ffffffffc0200b3e:	8522                	mv	a0,s0
}
ffffffffc0200b40:	6442                	ld	s0,16(sp)
ffffffffc0200b42:	60e2                	ld	ra,24(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b44:	6589                	lui	a1,0x2
ffffffffc0200b46:	95be                	add	a1,a1,a5
}
ffffffffc0200b48:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4a:	ac11                	j	ffffffffc0200d5e <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b4c:	00006517          	auipc	a0,0x6
ffffffffc0200b50:	38c50513          	addi	a0,a0,908 # ffffffffc0206ed8 <etext+0x7cc>
ffffffffc0200b54:	b71d                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Load access fault\n");
ffffffffc0200b56:	00006517          	auipc	a0,0x6
ffffffffc0200b5a:	3a250513          	addi	a0,a0,930 # ffffffffc0206ef8 <etext+0x7ec>
ffffffffc0200b5e:	e426                	sd	s1,8(sp)
ffffffffc0200b60:	e20ff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b64:	8522                	mv	a0,s0
ffffffffc0200b66:	d2dff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200b6a:	84aa                	mv	s1,a0
ffffffffc0200b6c:	d139                	beqz	a0,ffffffffc0200ab2 <exception_handler+0x84>
                print_trapframe(tf);
ffffffffc0200b6e:	8522                	mv	a0,s0
ffffffffc0200b70:	cc1ff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b74:	86a6                	mv	a3,s1
ffffffffc0200b76:	00006617          	auipc	a2,0x6
ffffffffc0200b7a:	39a60613          	addi	a2,a2,922 # ffffffffc0206f10 <etext+0x804>
ffffffffc0200b7e:	0cd00593          	li	a1,205
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	21e50513          	addi	a0,a0,542 # ffffffffc0206da0 <etext+0x694>
ffffffffc0200b8a:	8ebff0ef          	jal	ffffffffc0200474 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b8e:	00006517          	auipc	a0,0x6
ffffffffc0200b92:	3ba50513          	addi	a0,a0,954 # ffffffffc0206f48 <etext+0x83c>
ffffffffc0200b96:	e426                	sd	s1,8(sp)
ffffffffc0200b98:	de8ff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b9c:	8522                	mv	a0,s0
ffffffffc0200b9e:	cf5ff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200ba2:	84aa                	mv	s1,a0
ffffffffc0200ba4:	f00507e3          	beqz	a0,ffffffffc0200ab2 <exception_handler+0x84>
                print_trapframe(tf);
ffffffffc0200ba8:	8522                	mv	a0,s0
ffffffffc0200baa:	c87ff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bae:	86a6                	mv	a3,s1
ffffffffc0200bb0:	00006617          	auipc	a2,0x6
ffffffffc0200bb4:	36060613          	addi	a2,a2,864 # ffffffffc0206f10 <etext+0x804>
ffffffffc0200bb8:	0d700593          	li	a1,215
ffffffffc0200bbc:	00006517          	auipc	a0,0x6
ffffffffc0200bc0:	1e450513          	addi	a0,a0,484 # ffffffffc0206da0 <etext+0x694>
ffffffffc0200bc4:	8b1ff0ef          	jal	ffffffffc0200474 <__panic>
            print_trapframe(tf);
ffffffffc0200bc8:	8522                	mv	a0,s0
}
ffffffffc0200bca:	6442                	ld	s0,16(sp)
ffffffffc0200bcc:	60e2                	ld	ra,24(sp)
ffffffffc0200bce:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bd0:	b185                	j	ffffffffc0200830 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bd2:	00006617          	auipc	a2,0x6
ffffffffc0200bd6:	35e60613          	addi	a2,a2,862 # ffffffffc0206f30 <etext+0x824>
ffffffffc0200bda:	0d100593          	li	a1,209
ffffffffc0200bde:	00006517          	auipc	a0,0x6
ffffffffc0200be2:	1c250513          	addi	a0,a0,450 # ffffffffc0206da0 <etext+0x694>
ffffffffc0200be6:	e426                	sd	s1,8(sp)
ffffffffc0200be8:	88dff0ef          	jal	ffffffffc0200474 <__panic>
                print_trapframe(tf);
ffffffffc0200bec:	8522                	mv	a0,s0
ffffffffc0200bee:	c43ff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bf2:	86a6                	mv	a3,s1
ffffffffc0200bf4:	00006617          	auipc	a2,0x6
ffffffffc0200bf8:	31c60613          	addi	a2,a2,796 # ffffffffc0206f10 <etext+0x804>
ffffffffc0200bfc:	0f100593          	li	a1,241
ffffffffc0200c00:	00006517          	auipc	a0,0x6
ffffffffc0200c04:	1a050513          	addi	a0,a0,416 # ffffffffc0206da0 <etext+0x694>
ffffffffc0200c08:	86dff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0200c0c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c0c:	1101                	addi	sp,sp,-32
ffffffffc0200c0e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c10:	0009d417          	auipc	s0,0x9d
ffffffffc0200c14:	05840413          	addi	s0,s0,88 # ffffffffc029dc68 <current>
ffffffffc0200c18:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c1a:	ec06                	sd	ra,24(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c1c:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c20:	c329                	beqz	a4,ffffffffc0200c62 <trap+0x56>
ffffffffc0200c22:	e426                	sd	s1,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c24:	10053483          	ld	s1,256(a0)
ffffffffc0200c28:	e04a                	sd	s2,0(sp)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c2a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c2e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c30:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c34:	0206c463          	bltz	a3,ffffffffc0200c5c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c38:	df7ff0ef          	jal	ffffffffc0200a2e <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c3c:	601c                	ld	a5,0(s0)
ffffffffc0200c3e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c42:	e499                	bnez	s1,ffffffffc0200c50 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c44:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c48:	8b05                	andi	a4,a4,1
ffffffffc0200c4a:	ef0d                	bnez	a4,ffffffffc0200c84 <trap+0x78>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c4c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c4e:	e785                	bnez	a5,ffffffffc0200c76 <trap+0x6a>
                schedule();
            }
        }
    }
}
ffffffffc0200c50:	60e2                	ld	ra,24(sp)
ffffffffc0200c52:	6442                	ld	s0,16(sp)
ffffffffc0200c54:	64a2                	ld	s1,8(sp)
ffffffffc0200c56:	6902                	ld	s2,0(sp)
ffffffffc0200c58:	6105                	addi	sp,sp,32
ffffffffc0200c5a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c5c:	d41ff0ef          	jal	ffffffffc020099c <interrupt_handler>
ffffffffc0200c60:	bff1                	j	ffffffffc0200c3c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c62:	0006c663          	bltz	a3,ffffffffc0200c6e <trap+0x62>
}
ffffffffc0200c66:	6442                	ld	s0,16(sp)
ffffffffc0200c68:	60e2                	ld	ra,24(sp)
ffffffffc0200c6a:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c6c:	b3c9                	j	ffffffffc0200a2e <exception_handler>
}
ffffffffc0200c6e:	6442                	ld	s0,16(sp)
ffffffffc0200c70:	60e2                	ld	ra,24(sp)
ffffffffc0200c72:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c74:	b325                	j	ffffffffc020099c <interrupt_handler>
}
ffffffffc0200c76:	6442                	ld	s0,16(sp)
                schedule();
ffffffffc0200c78:	64a2                	ld	s1,8(sp)
ffffffffc0200c7a:	6902                	ld	s2,0(sp)
}
ffffffffc0200c7c:	60e2                	ld	ra,24(sp)
ffffffffc0200c7e:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c80:	4620506f          	j	ffffffffc02060e2 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c84:	555d                	li	a0,-9
ffffffffc0200c86:	700040ef          	jal	ffffffffc0205386 <do_exit>
            if (current->need_resched) {
ffffffffc0200c8a:	601c                	ld	a5,0(s0)
ffffffffc0200c8c:	b7c1                	j	ffffffffc0200c4c <trap+0x40>
	...

ffffffffc0200c90 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c90:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c94:	00011463          	bnez	sp,ffffffffc0200c9c <__alltraps+0xc>
ffffffffc0200c98:	14002173          	csrr	sp,sscratch
ffffffffc0200c9c:	712d                	addi	sp,sp,-288
ffffffffc0200c9e:	e002                	sd	zero,0(sp)
ffffffffc0200ca0:	e406                	sd	ra,8(sp)
ffffffffc0200ca2:	ec0e                	sd	gp,24(sp)
ffffffffc0200ca4:	f012                	sd	tp,32(sp)
ffffffffc0200ca6:	f416                	sd	t0,40(sp)
ffffffffc0200ca8:	f81a                	sd	t1,48(sp)
ffffffffc0200caa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cac:	e0a2                	sd	s0,64(sp)
ffffffffc0200cae:	e4a6                	sd	s1,72(sp)
ffffffffc0200cb0:	e8aa                	sd	a0,80(sp)
ffffffffc0200cb2:	ecae                	sd	a1,88(sp)
ffffffffc0200cb4:	f0b2                	sd	a2,96(sp)
ffffffffc0200cb6:	f4b6                	sd	a3,104(sp)
ffffffffc0200cb8:	f8ba                	sd	a4,112(sp)
ffffffffc0200cba:	fcbe                	sd	a5,120(sp)
ffffffffc0200cbc:	e142                	sd	a6,128(sp)
ffffffffc0200cbe:	e546                	sd	a7,136(sp)
ffffffffc0200cc0:	e94a                	sd	s2,144(sp)
ffffffffc0200cc2:	ed4e                	sd	s3,152(sp)
ffffffffc0200cc4:	f152                	sd	s4,160(sp)
ffffffffc0200cc6:	f556                	sd	s5,168(sp)
ffffffffc0200cc8:	f95a                	sd	s6,176(sp)
ffffffffc0200cca:	fd5e                	sd	s7,184(sp)
ffffffffc0200ccc:	e1e2                	sd	s8,192(sp)
ffffffffc0200cce:	e5e6                	sd	s9,200(sp)
ffffffffc0200cd0:	e9ea                	sd	s10,208(sp)
ffffffffc0200cd2:	edee                	sd	s11,216(sp)
ffffffffc0200cd4:	f1f2                	sd	t3,224(sp)
ffffffffc0200cd6:	f5f6                	sd	t4,232(sp)
ffffffffc0200cd8:	f9fa                	sd	t5,240(sp)
ffffffffc0200cda:	fdfe                	sd	t6,248(sp)
ffffffffc0200cdc:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ce0:	100024f3          	csrr	s1,sstatus
ffffffffc0200ce4:	14102973          	csrr	s2,sepc
ffffffffc0200ce8:	143029f3          	csrr	s3,stval
ffffffffc0200cec:	14202a73          	csrr	s4,scause
ffffffffc0200cf0:	e822                	sd	s0,16(sp)
ffffffffc0200cf2:	e226                	sd	s1,256(sp)
ffffffffc0200cf4:	e64a                	sd	s2,264(sp)
ffffffffc0200cf6:	ea4e                	sd	s3,272(sp)
ffffffffc0200cf8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cfa:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cfc:	f11ff0ef          	jal	ffffffffc0200c0c <trap>

ffffffffc0200d00 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d00:	6492                	ld	s1,256(sp)
ffffffffc0200d02:	6932                	ld	s2,264(sp)
ffffffffc0200d04:	1004f413          	andi	s0,s1,256
ffffffffc0200d08:	e401                	bnez	s0,ffffffffc0200d10 <__trapret+0x10>
ffffffffc0200d0a:	1200                	addi	s0,sp,288
ffffffffc0200d0c:	14041073          	csrw	sscratch,s0
ffffffffc0200d10:	10049073          	csrw	sstatus,s1
ffffffffc0200d14:	14191073          	csrw	sepc,s2
ffffffffc0200d18:	60a2                	ld	ra,8(sp)
ffffffffc0200d1a:	61e2                	ld	gp,24(sp)
ffffffffc0200d1c:	7202                	ld	tp,32(sp)
ffffffffc0200d1e:	72a2                	ld	t0,40(sp)
ffffffffc0200d20:	7342                	ld	t1,48(sp)
ffffffffc0200d22:	73e2                	ld	t2,56(sp)
ffffffffc0200d24:	6406                	ld	s0,64(sp)
ffffffffc0200d26:	64a6                	ld	s1,72(sp)
ffffffffc0200d28:	6546                	ld	a0,80(sp)
ffffffffc0200d2a:	65e6                	ld	a1,88(sp)
ffffffffc0200d2c:	7606                	ld	a2,96(sp)
ffffffffc0200d2e:	76a6                	ld	a3,104(sp)
ffffffffc0200d30:	7746                	ld	a4,112(sp)
ffffffffc0200d32:	77e6                	ld	a5,120(sp)
ffffffffc0200d34:	680a                	ld	a6,128(sp)
ffffffffc0200d36:	68aa                	ld	a7,136(sp)
ffffffffc0200d38:	694a                	ld	s2,144(sp)
ffffffffc0200d3a:	69ea                	ld	s3,152(sp)
ffffffffc0200d3c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d3e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d40:	7b4a                	ld	s6,176(sp)
ffffffffc0200d42:	7bea                	ld	s7,184(sp)
ffffffffc0200d44:	6c0e                	ld	s8,192(sp)
ffffffffc0200d46:	6cae                	ld	s9,200(sp)
ffffffffc0200d48:	6d4e                	ld	s10,208(sp)
ffffffffc0200d4a:	6dee                	ld	s11,216(sp)
ffffffffc0200d4c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d4e:	7eae                	ld	t4,232(sp)
ffffffffc0200d50:	7f4e                	ld	t5,240(sp)
ffffffffc0200d52:	7fee                	ld	t6,248(sp)
ffffffffc0200d54:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d56:	10200073          	sret

ffffffffc0200d5a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d5a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d5c:	b755                	j	ffffffffc0200d00 <__trapret>

ffffffffc0200d5e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d5e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6718>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d62:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d66:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d6a:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d6e:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d72:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d76:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d7a:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d7e:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d82:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d84:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d86:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d88:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d8a:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d8c:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d8e:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d90:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d92:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d94:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d96:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d98:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d9a:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d9c:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d9e:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200da0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200da2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200da4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200da6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200da8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200daa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dac:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dae:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200db0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200db2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200db4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200db6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200db8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dba:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dbc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dbe:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dc0:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dc2:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dc4:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dc6:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dc8:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dca:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dcc:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dce:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dd0:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dd2:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dd4:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dd6:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dd8:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dda:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200ddc:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dde:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200de0:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200de2:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200de4:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200de6:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200de8:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200dea:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200dec:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200dee:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200df0:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200df2:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200df4:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200df6:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200df8:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200dfa:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200dfc:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200dfe:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e00:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e02:	812e                	mv	sp,a1
ffffffffc0200e04:	bdf5                	j	ffffffffc0200d00 <__trapret>

ffffffffc0200e06 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e06:	00099797          	auipc	a5,0x99
ffffffffc0200e0a:	d1a78793          	addi	a5,a5,-742 # ffffffffc0299b20 <free_area>
ffffffffc0200e0e:	e79c                	sd	a5,8(a5)
ffffffffc0200e10:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e12:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e16:	8082                	ret

ffffffffc0200e18 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e18:	00099517          	auipc	a0,0x99
ffffffffc0200e1c:	d1856503          	lwu	a0,-744(a0) # ffffffffc0299b30 <free_area+0x10>
ffffffffc0200e20:	8082                	ret

ffffffffc0200e22 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e22:	715d                	addi	sp,sp,-80
ffffffffc0200e24:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e26:	00099417          	auipc	s0,0x99
ffffffffc0200e2a:	cfa40413          	addi	s0,s0,-774 # ffffffffc0299b20 <free_area>
ffffffffc0200e2e:	641c                	ld	a5,8(s0)
ffffffffc0200e30:	e486                	sd	ra,72(sp)
ffffffffc0200e32:	fc26                	sd	s1,56(sp)
ffffffffc0200e34:	f84a                	sd	s2,48(sp)
ffffffffc0200e36:	f44e                	sd	s3,40(sp)
ffffffffc0200e38:	f052                	sd	s4,32(sp)
ffffffffc0200e3a:	ec56                	sd	s5,24(sp)
ffffffffc0200e3c:	e85a                	sd	s6,16(sp)
ffffffffc0200e3e:	e45e                	sd	s7,8(sp)
ffffffffc0200e40:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e42:	2a878963          	beq	a5,s0,ffffffffc02010f4 <default_check+0x2d2>
    int count = 0, total = 0;
ffffffffc0200e46:	4481                	li	s1,0
ffffffffc0200e48:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e4a:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e4e:	8b09                	andi	a4,a4,2
ffffffffc0200e50:	2a070663          	beqz	a4,ffffffffc02010fc <default_check+0x2da>
        count ++, total += p->property;
ffffffffc0200e54:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e58:	679c                	ld	a5,8(a5)
ffffffffc0200e5a:	2905                	addiw	s2,s2,1
ffffffffc0200e5c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e5e:	fe8796e3          	bne	a5,s0,ffffffffc0200e4a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e62:	89a6                	mv	s3,s1
ffffffffc0200e64:	70d000ef          	jal	ffffffffc0201d70 <nr_free_pages>
ffffffffc0200e68:	6f351a63          	bne	a0,s3,ffffffffc020155c <default_check+0x73a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e6c:	4505                	li	a0,1
ffffffffc0200e6e:	633000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200e72:	8aaa                	mv	s5,a0
ffffffffc0200e74:	42050463          	beqz	a0,ffffffffc020129c <default_check+0x47a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e78:	4505                	li	a0,1
ffffffffc0200e7a:	627000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200e7e:	89aa                	mv	s3,a0
ffffffffc0200e80:	6e050e63          	beqz	a0,ffffffffc020157c <default_check+0x75a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e84:	4505                	li	a0,1
ffffffffc0200e86:	61b000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200e8a:	8a2a                	mv	s4,a0
ffffffffc0200e8c:	48050863          	beqz	a0,ffffffffc020131c <default_check+0x4fa>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e90:	293a8663          	beq	s5,s3,ffffffffc020111c <default_check+0x2fa>
ffffffffc0200e94:	28aa8463          	beq	s5,a0,ffffffffc020111c <default_check+0x2fa>
ffffffffc0200e98:	28a98263          	beq	s3,a0,ffffffffc020111c <default_check+0x2fa>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e9c:	000aa783          	lw	a5,0(s5)
ffffffffc0200ea0:	28079e63          	bnez	a5,ffffffffc020113c <default_check+0x31a>
ffffffffc0200ea4:	0009a783          	lw	a5,0(s3)
ffffffffc0200ea8:	28079a63          	bnez	a5,ffffffffc020113c <default_check+0x31a>
ffffffffc0200eac:	411c                	lw	a5,0(a0)
ffffffffc0200eae:	28079763          	bnez	a5,ffffffffc020113c <default_check+0x31a>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200eb2:	0009d797          	auipc	a5,0x9d
ffffffffc0200eb6:	d7e7b783          	ld	a5,-642(a5) # ffffffffc029dc30 <pages>
ffffffffc0200eba:	40fa8733          	sub	a4,s5,a5
ffffffffc0200ebe:	00008617          	auipc	a2,0x8
ffffffffc0200ec2:	f4a63603          	ld	a2,-182(a2) # ffffffffc0208e08 <nbase>
ffffffffc0200ec6:	8719                	srai	a4,a4,0x6
ffffffffc0200ec8:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eca:	0009d697          	auipc	a3,0x9d
ffffffffc0200ece:	d5e6b683          	ld	a3,-674(a3) # ffffffffc029dc28 <npage>
ffffffffc0200ed2:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ed4:	0732                	slli	a4,a4,0xc
ffffffffc0200ed6:	28d77363          	bgeu	a4,a3,ffffffffc020115c <default_check+0x33a>
    return page - pages + nbase;
ffffffffc0200eda:	40f98733          	sub	a4,s3,a5
ffffffffc0200ede:	8719                	srai	a4,a4,0x6
ffffffffc0200ee0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ee2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ee4:	4ad77c63          	bgeu	a4,a3,ffffffffc020139c <default_check+0x57a>
    return page - pages + nbase;
ffffffffc0200ee8:	40f507b3          	sub	a5,a0,a5
ffffffffc0200eec:	8799                	srai	a5,a5,0x6
ffffffffc0200eee:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ef0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ef2:	30d7f563          	bgeu	a5,a3,ffffffffc02011fc <default_check+0x3da>
    assert(alloc_page() == NULL);
ffffffffc0200ef6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ef8:	00043c03          	ld	s8,0(s0)
ffffffffc0200efc:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f00:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200f04:	e400                	sd	s0,8(s0)
ffffffffc0200f06:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200f08:	00099797          	auipc	a5,0x99
ffffffffc0200f0c:	c207a423          	sw	zero,-984(a5) # ffffffffc0299b30 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f10:	591000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200f14:	2c051463          	bnez	a0,ffffffffc02011dc <default_check+0x3ba>
    free_page(p0);
ffffffffc0200f18:	4585                	li	a1,1
ffffffffc0200f1a:	8556                	mv	a0,s5
ffffffffc0200f1c:	615000ef          	jal	ffffffffc0201d30 <free_pages>
    free_page(p1);
ffffffffc0200f20:	4585                	li	a1,1
ffffffffc0200f22:	854e                	mv	a0,s3
ffffffffc0200f24:	60d000ef          	jal	ffffffffc0201d30 <free_pages>
    free_page(p2);
ffffffffc0200f28:	4585                	li	a1,1
ffffffffc0200f2a:	8552                	mv	a0,s4
ffffffffc0200f2c:	605000ef          	jal	ffffffffc0201d30 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f30:	4818                	lw	a4,16(s0)
ffffffffc0200f32:	478d                	li	a5,3
ffffffffc0200f34:	28f71463          	bne	a4,a5,ffffffffc02011bc <default_check+0x39a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f38:	4505                	li	a0,1
ffffffffc0200f3a:	567000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200f3e:	89aa                	mv	s3,a0
ffffffffc0200f40:	24050e63          	beqz	a0,ffffffffc020119c <default_check+0x37a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f44:	4505                	li	a0,1
ffffffffc0200f46:	55b000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200f4a:	8aaa                	mv	s5,a0
ffffffffc0200f4c:	3a050863          	beqz	a0,ffffffffc02012fc <default_check+0x4da>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f50:	4505                	li	a0,1
ffffffffc0200f52:	54f000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200f56:	8a2a                	mv	s4,a0
ffffffffc0200f58:	38050263          	beqz	a0,ffffffffc02012dc <default_check+0x4ba>
    assert(alloc_page() == NULL);
ffffffffc0200f5c:	4505                	li	a0,1
ffffffffc0200f5e:	543000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200f62:	34051d63          	bnez	a0,ffffffffc02012bc <default_check+0x49a>
    free_page(p0);
ffffffffc0200f66:	4585                	li	a1,1
ffffffffc0200f68:	854e                	mv	a0,s3
ffffffffc0200f6a:	5c7000ef          	jal	ffffffffc0201d30 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f6e:	641c                	ld	a5,8(s0)
ffffffffc0200f70:	20878663          	beq	a5,s0,ffffffffc020117c <default_check+0x35a>
    assert((p = alloc_page()) == p0);
ffffffffc0200f74:	4505                	li	a0,1
ffffffffc0200f76:	52b000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200f7a:	30a99163          	bne	s3,a0,ffffffffc020127c <default_check+0x45a>
    assert(alloc_page() == NULL);
ffffffffc0200f7e:	4505                	li	a0,1
ffffffffc0200f80:	521000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200f84:	2c051c63          	bnez	a0,ffffffffc020125c <default_check+0x43a>
    assert(nr_free == 0);
ffffffffc0200f88:	481c                	lw	a5,16(s0)
ffffffffc0200f8a:	2a079963          	bnez	a5,ffffffffc020123c <default_check+0x41a>
    free_page(p);
ffffffffc0200f8e:	854e                	mv	a0,s3
ffffffffc0200f90:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f92:	01843023          	sd	s8,0(s0)
ffffffffc0200f96:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f9a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f9e:	593000ef          	jal	ffffffffc0201d30 <free_pages>
    free_page(p1);
ffffffffc0200fa2:	4585                	li	a1,1
ffffffffc0200fa4:	8556                	mv	a0,s5
ffffffffc0200fa6:	58b000ef          	jal	ffffffffc0201d30 <free_pages>
    free_page(p2);
ffffffffc0200faa:	4585                	li	a1,1
ffffffffc0200fac:	8552                	mv	a0,s4
ffffffffc0200fae:	583000ef          	jal	ffffffffc0201d30 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200fb2:	4515                	li	a0,5
ffffffffc0200fb4:	4ed000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200fb8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fba:	26050163          	beqz	a0,ffffffffc020121c <default_check+0x3fa>
ffffffffc0200fbe:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc0200fc0:	8b89                	andi	a5,a5,2
ffffffffc0200fc2:	52079d63          	bnez	a5,ffffffffc02014fc <default_check+0x6da>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fc6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fc8:	00043b83          	ld	s7,0(s0)
ffffffffc0200fcc:	00843b03          	ld	s6,8(s0)
ffffffffc0200fd0:	e000                	sd	s0,0(s0)
ffffffffc0200fd2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200fd4:	4cd000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200fd8:	50051263          	bnez	a0,ffffffffc02014dc <default_check+0x6ba>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200fdc:	08098a13          	addi	s4,s3,128
ffffffffc0200fe0:	8552                	mv	a0,s4
ffffffffc0200fe2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200fe4:	01042c03          	lw	s8,16(s0)
    nr_free = 0;
ffffffffc0200fe8:	00099797          	auipc	a5,0x99
ffffffffc0200fec:	b407a423          	sw	zero,-1208(a5) # ffffffffc0299b30 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200ff0:	541000ef          	jal	ffffffffc0201d30 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ff4:	4511                	li	a0,4
ffffffffc0200ff6:	4ab000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0200ffa:	4c051163          	bnez	a0,ffffffffc02014bc <default_check+0x69a>
ffffffffc0200ffe:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201002:	8b89                	andi	a5,a5,2
ffffffffc0201004:	48078c63          	beqz	a5,ffffffffc020149c <default_check+0x67a>
ffffffffc0201008:	0909a703          	lw	a4,144(s3)
ffffffffc020100c:	478d                	li	a5,3
ffffffffc020100e:	48f71763          	bne	a4,a5,ffffffffc020149c <default_check+0x67a>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201012:	450d                	li	a0,3
ffffffffc0201014:	48d000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0201018:	8aaa                	mv	s5,a0
ffffffffc020101a:	46050163          	beqz	a0,ffffffffc020147c <default_check+0x65a>
    assert(alloc_page() == NULL);
ffffffffc020101e:	4505                	li	a0,1
ffffffffc0201020:	481000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0201024:	42051c63          	bnez	a0,ffffffffc020145c <default_check+0x63a>
    assert(p0 + 2 == p1);
ffffffffc0201028:	415a1a63          	bne	s4,s5,ffffffffc020143c <default_check+0x61a>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020102c:	4585                	li	a1,1
ffffffffc020102e:	854e                	mv	a0,s3
ffffffffc0201030:	501000ef          	jal	ffffffffc0201d30 <free_pages>
    free_pages(p1, 3);
ffffffffc0201034:	458d                	li	a1,3
ffffffffc0201036:	8552                	mv	a0,s4
ffffffffc0201038:	4f9000ef          	jal	ffffffffc0201d30 <free_pages>
ffffffffc020103c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201040:	04098a93          	addi	s5,s3,64
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201044:	8b89                	andi	a5,a5,2
ffffffffc0201046:	3c078b63          	beqz	a5,ffffffffc020141c <default_check+0x5fa>
ffffffffc020104a:	0109a703          	lw	a4,16(s3)
ffffffffc020104e:	4785                	li	a5,1
ffffffffc0201050:	3cf71663          	bne	a4,a5,ffffffffc020141c <default_check+0x5fa>
ffffffffc0201054:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201058:	8b89                	andi	a5,a5,2
ffffffffc020105a:	3a078163          	beqz	a5,ffffffffc02013fc <default_check+0x5da>
ffffffffc020105e:	010a2703          	lw	a4,16(s4)
ffffffffc0201062:	478d                	li	a5,3
ffffffffc0201064:	38f71c63          	bne	a4,a5,ffffffffc02013fc <default_check+0x5da>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201068:	4505                	li	a0,1
ffffffffc020106a:	437000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc020106e:	36a99763          	bne	s3,a0,ffffffffc02013dc <default_check+0x5ba>
    free_page(p0);
ffffffffc0201072:	4585                	li	a1,1
ffffffffc0201074:	4bd000ef          	jal	ffffffffc0201d30 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201078:	4509                	li	a0,2
ffffffffc020107a:	427000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc020107e:	32aa1f63          	bne	s4,a0,ffffffffc02013bc <default_check+0x59a>

    free_pages(p0, 2);
ffffffffc0201082:	4589                	li	a1,2
ffffffffc0201084:	4ad000ef          	jal	ffffffffc0201d30 <free_pages>
    free_page(p2);
ffffffffc0201088:	4585                	li	a1,1
ffffffffc020108a:	8556                	mv	a0,s5
ffffffffc020108c:	4a5000ef          	jal	ffffffffc0201d30 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201090:	4515                	li	a0,5
ffffffffc0201092:	40f000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0201096:	89aa                	mv	s3,a0
ffffffffc0201098:	48050263          	beqz	a0,ffffffffc020151c <default_check+0x6fa>
    assert(alloc_page() == NULL);
ffffffffc020109c:	4505                	li	a0,1
ffffffffc020109e:	403000ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc02010a2:	2c051d63          	bnez	a0,ffffffffc020137c <default_check+0x55a>

    assert(nr_free == 0);
ffffffffc02010a6:	481c                	lw	a5,16(s0)
ffffffffc02010a8:	2a079a63          	bnez	a5,ffffffffc020135c <default_check+0x53a>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010ac:	4595                	li	a1,5
ffffffffc02010ae:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02010b0:	01842823          	sw	s8,16(s0)
    free_list = free_list_store;
ffffffffc02010b4:	01743023          	sd	s7,0(s0)
ffffffffc02010b8:	01643423          	sd	s6,8(s0)
    free_pages(p0, 5);
ffffffffc02010bc:	475000ef          	jal	ffffffffc0201d30 <free_pages>
    return listelm->next;
ffffffffc02010c0:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010c2:	00878963          	beq	a5,s0,ffffffffc02010d4 <default_check+0x2b2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010c6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ca:	679c                	ld	a5,8(a5)
ffffffffc02010cc:	397d                	addiw	s2,s2,-1
ffffffffc02010ce:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010d0:	fe879be3          	bne	a5,s0,ffffffffc02010c6 <default_check+0x2a4>
    }
    assert(count == 0);
ffffffffc02010d4:	26091463          	bnez	s2,ffffffffc020133c <default_check+0x51a>
    assert(total == 0);
ffffffffc02010d8:	46049263          	bnez	s1,ffffffffc020153c <default_check+0x71a>
}
ffffffffc02010dc:	60a6                	ld	ra,72(sp)
ffffffffc02010de:	6406                	ld	s0,64(sp)
ffffffffc02010e0:	74e2                	ld	s1,56(sp)
ffffffffc02010e2:	7942                	ld	s2,48(sp)
ffffffffc02010e4:	79a2                	ld	s3,40(sp)
ffffffffc02010e6:	7a02                	ld	s4,32(sp)
ffffffffc02010e8:	6ae2                	ld	s5,24(sp)
ffffffffc02010ea:	6b42                	ld	s6,16(sp)
ffffffffc02010ec:	6ba2                	ld	s7,8(sp)
ffffffffc02010ee:	6c02                	ld	s8,0(sp)
ffffffffc02010f0:	6161                	addi	sp,sp,80
ffffffffc02010f2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010f4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02010f6:	4481                	li	s1,0
ffffffffc02010f8:	4901                	li	s2,0
ffffffffc02010fa:	b3ad                	j	ffffffffc0200e64 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02010fc:	00006697          	auipc	a3,0x6
ffffffffc0201100:	f0c68693          	addi	a3,a3,-244 # ffffffffc0207008 <etext+0x8fc>
ffffffffc0201104:	00006617          	auipc	a2,0x6
ffffffffc0201108:	c8460613          	addi	a2,a2,-892 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020110c:	0f000593          	li	a1,240
ffffffffc0201110:	00006517          	auipc	a0,0x6
ffffffffc0201114:	f0850513          	addi	a0,a0,-248 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201118:	b5cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020111c:	00006697          	auipc	a3,0x6
ffffffffc0201120:	f9468693          	addi	a3,a3,-108 # ffffffffc02070b0 <etext+0x9a4>
ffffffffc0201124:	00006617          	auipc	a2,0x6
ffffffffc0201128:	c6460613          	addi	a2,a2,-924 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020112c:	0bd00593          	li	a1,189
ffffffffc0201130:	00006517          	auipc	a0,0x6
ffffffffc0201134:	ee850513          	addi	a0,a0,-280 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201138:	b3cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020113c:	00006697          	auipc	a3,0x6
ffffffffc0201140:	f9c68693          	addi	a3,a3,-100 # ffffffffc02070d8 <etext+0x9cc>
ffffffffc0201144:	00006617          	auipc	a2,0x6
ffffffffc0201148:	c4460613          	addi	a2,a2,-956 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020114c:	0be00593          	li	a1,190
ffffffffc0201150:	00006517          	auipc	a0,0x6
ffffffffc0201154:	ec850513          	addi	a0,a0,-312 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201158:	b1cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020115c:	00006697          	auipc	a3,0x6
ffffffffc0201160:	fbc68693          	addi	a3,a3,-68 # ffffffffc0207118 <etext+0xa0c>
ffffffffc0201164:	00006617          	auipc	a2,0x6
ffffffffc0201168:	c2460613          	addi	a2,a2,-988 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020116c:	0c000593          	li	a1,192
ffffffffc0201170:	00006517          	auipc	a0,0x6
ffffffffc0201174:	ea850513          	addi	a0,a0,-344 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201178:	afcff0ef          	jal	ffffffffc0200474 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020117c:	00006697          	auipc	a3,0x6
ffffffffc0201180:	02468693          	addi	a3,a3,36 # ffffffffc02071a0 <etext+0xa94>
ffffffffc0201184:	00006617          	auipc	a2,0x6
ffffffffc0201188:	c0460613          	addi	a2,a2,-1020 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020118c:	0d900593          	li	a1,217
ffffffffc0201190:	00006517          	auipc	a0,0x6
ffffffffc0201194:	e8850513          	addi	a0,a0,-376 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201198:	adcff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020119c:	00006697          	auipc	a3,0x6
ffffffffc02011a0:	eb468693          	addi	a3,a3,-332 # ffffffffc0207050 <etext+0x944>
ffffffffc02011a4:	00006617          	auipc	a2,0x6
ffffffffc02011a8:	be460613          	addi	a2,a2,-1052 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02011ac:	0d200593          	li	a1,210
ffffffffc02011b0:	00006517          	auipc	a0,0x6
ffffffffc02011b4:	e6850513          	addi	a0,a0,-408 # ffffffffc0207018 <etext+0x90c>
ffffffffc02011b8:	abcff0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free == 3);
ffffffffc02011bc:	00006697          	auipc	a3,0x6
ffffffffc02011c0:	fd468693          	addi	a3,a3,-44 # ffffffffc0207190 <etext+0xa84>
ffffffffc02011c4:	00006617          	auipc	a2,0x6
ffffffffc02011c8:	bc460613          	addi	a2,a2,-1084 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02011cc:	0d000593          	li	a1,208
ffffffffc02011d0:	00006517          	auipc	a0,0x6
ffffffffc02011d4:	e4850513          	addi	a0,a0,-440 # ffffffffc0207018 <etext+0x90c>
ffffffffc02011d8:	a9cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011dc:	00006697          	auipc	a3,0x6
ffffffffc02011e0:	f9c68693          	addi	a3,a3,-100 # ffffffffc0207178 <etext+0xa6c>
ffffffffc02011e4:	00006617          	auipc	a2,0x6
ffffffffc02011e8:	ba460613          	addi	a2,a2,-1116 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02011ec:	0cb00593          	li	a1,203
ffffffffc02011f0:	00006517          	auipc	a0,0x6
ffffffffc02011f4:	e2850513          	addi	a0,a0,-472 # ffffffffc0207018 <etext+0x90c>
ffffffffc02011f8:	a7cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011fc:	00006697          	auipc	a3,0x6
ffffffffc0201200:	f5c68693          	addi	a3,a3,-164 # ffffffffc0207158 <etext+0xa4c>
ffffffffc0201204:	00006617          	auipc	a2,0x6
ffffffffc0201208:	b8460613          	addi	a2,a2,-1148 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020120c:	0c200593          	li	a1,194
ffffffffc0201210:	00006517          	auipc	a0,0x6
ffffffffc0201214:	e0850513          	addi	a0,a0,-504 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201218:	a5cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(p0 != NULL);
ffffffffc020121c:	00006697          	auipc	a3,0x6
ffffffffc0201220:	fcc68693          	addi	a3,a3,-52 # ffffffffc02071e8 <etext+0xadc>
ffffffffc0201224:	00006617          	auipc	a2,0x6
ffffffffc0201228:	b6460613          	addi	a2,a2,-1180 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020122c:	0f800593          	li	a1,248
ffffffffc0201230:	00006517          	auipc	a0,0x6
ffffffffc0201234:	de850513          	addi	a0,a0,-536 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201238:	a3cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free == 0);
ffffffffc020123c:	00006697          	auipc	a3,0x6
ffffffffc0201240:	f9c68693          	addi	a3,a3,-100 # ffffffffc02071d8 <etext+0xacc>
ffffffffc0201244:	00006617          	auipc	a2,0x6
ffffffffc0201248:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020124c:	0df00593          	li	a1,223
ffffffffc0201250:	00006517          	auipc	a0,0x6
ffffffffc0201254:	dc850513          	addi	a0,a0,-568 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201258:	a1cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020125c:	00006697          	auipc	a3,0x6
ffffffffc0201260:	f1c68693          	addi	a3,a3,-228 # ffffffffc0207178 <etext+0xa6c>
ffffffffc0201264:	00006617          	auipc	a2,0x6
ffffffffc0201268:	b2460613          	addi	a2,a2,-1244 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020126c:	0dd00593          	li	a1,221
ffffffffc0201270:	00006517          	auipc	a0,0x6
ffffffffc0201274:	da850513          	addi	a0,a0,-600 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201278:	9fcff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020127c:	00006697          	auipc	a3,0x6
ffffffffc0201280:	f3c68693          	addi	a3,a3,-196 # ffffffffc02071b8 <etext+0xaac>
ffffffffc0201284:	00006617          	auipc	a2,0x6
ffffffffc0201288:	b0460613          	addi	a2,a2,-1276 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020128c:	0dc00593          	li	a1,220
ffffffffc0201290:	00006517          	auipc	a0,0x6
ffffffffc0201294:	d8850513          	addi	a0,a0,-632 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201298:	9dcff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020129c:	00006697          	auipc	a3,0x6
ffffffffc02012a0:	db468693          	addi	a3,a3,-588 # ffffffffc0207050 <etext+0x944>
ffffffffc02012a4:	00006617          	auipc	a2,0x6
ffffffffc02012a8:	ae460613          	addi	a2,a2,-1308 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02012ac:	0b900593          	li	a1,185
ffffffffc02012b0:	00006517          	auipc	a0,0x6
ffffffffc02012b4:	d6850513          	addi	a0,a0,-664 # ffffffffc0207018 <etext+0x90c>
ffffffffc02012b8:	9bcff0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012bc:	00006697          	auipc	a3,0x6
ffffffffc02012c0:	ebc68693          	addi	a3,a3,-324 # ffffffffc0207178 <etext+0xa6c>
ffffffffc02012c4:	00006617          	auipc	a2,0x6
ffffffffc02012c8:	ac460613          	addi	a2,a2,-1340 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02012cc:	0d600593          	li	a1,214
ffffffffc02012d0:	00006517          	auipc	a0,0x6
ffffffffc02012d4:	d4850513          	addi	a0,a0,-696 # ffffffffc0207018 <etext+0x90c>
ffffffffc02012d8:	99cff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012dc:	00006697          	auipc	a3,0x6
ffffffffc02012e0:	db468693          	addi	a3,a3,-588 # ffffffffc0207090 <etext+0x984>
ffffffffc02012e4:	00006617          	auipc	a2,0x6
ffffffffc02012e8:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02012ec:	0d400593          	li	a1,212
ffffffffc02012f0:	00006517          	auipc	a0,0x6
ffffffffc02012f4:	d2850513          	addi	a0,a0,-728 # ffffffffc0207018 <etext+0x90c>
ffffffffc02012f8:	97cff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012fc:	00006697          	auipc	a3,0x6
ffffffffc0201300:	d7468693          	addi	a3,a3,-652 # ffffffffc0207070 <etext+0x964>
ffffffffc0201304:	00006617          	auipc	a2,0x6
ffffffffc0201308:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020130c:	0d300593          	li	a1,211
ffffffffc0201310:	00006517          	auipc	a0,0x6
ffffffffc0201314:	d0850513          	addi	a0,a0,-760 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201318:	95cff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020131c:	00006697          	auipc	a3,0x6
ffffffffc0201320:	d7468693          	addi	a3,a3,-652 # ffffffffc0207090 <etext+0x984>
ffffffffc0201324:	00006617          	auipc	a2,0x6
ffffffffc0201328:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020132c:	0bb00593          	li	a1,187
ffffffffc0201330:	00006517          	auipc	a0,0x6
ffffffffc0201334:	ce850513          	addi	a0,a0,-792 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201338:	93cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(count == 0);
ffffffffc020133c:	00006697          	auipc	a3,0x6
ffffffffc0201340:	ffc68693          	addi	a3,a3,-4 # ffffffffc0207338 <etext+0xc2c>
ffffffffc0201344:	00006617          	auipc	a2,0x6
ffffffffc0201348:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020134c:	12500593          	li	a1,293
ffffffffc0201350:	00006517          	auipc	a0,0x6
ffffffffc0201354:	cc850513          	addi	a0,a0,-824 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201358:	91cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free == 0);
ffffffffc020135c:	00006697          	auipc	a3,0x6
ffffffffc0201360:	e7c68693          	addi	a3,a3,-388 # ffffffffc02071d8 <etext+0xacc>
ffffffffc0201364:	00006617          	auipc	a2,0x6
ffffffffc0201368:	a2460613          	addi	a2,a2,-1500 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020136c:	11a00593          	li	a1,282
ffffffffc0201370:	00006517          	auipc	a0,0x6
ffffffffc0201374:	ca850513          	addi	a0,a0,-856 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201378:	8fcff0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020137c:	00006697          	auipc	a3,0x6
ffffffffc0201380:	dfc68693          	addi	a3,a3,-516 # ffffffffc0207178 <etext+0xa6c>
ffffffffc0201384:	00006617          	auipc	a2,0x6
ffffffffc0201388:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020138c:	11800593          	li	a1,280
ffffffffc0201390:	00006517          	auipc	a0,0x6
ffffffffc0201394:	c8850513          	addi	a0,a0,-888 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201398:	8dcff0ef          	jal	ffffffffc0200474 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020139c:	00006697          	auipc	a3,0x6
ffffffffc02013a0:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207138 <etext+0xa2c>
ffffffffc02013a4:	00006617          	auipc	a2,0x6
ffffffffc02013a8:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02013ac:	0c100593          	li	a1,193
ffffffffc02013b0:	00006517          	auipc	a0,0x6
ffffffffc02013b4:	c6850513          	addi	a0,a0,-920 # ffffffffc0207018 <etext+0x90c>
ffffffffc02013b8:	8bcff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013bc:	00006697          	auipc	a3,0x6
ffffffffc02013c0:	f3c68693          	addi	a3,a3,-196 # ffffffffc02072f8 <etext+0xbec>
ffffffffc02013c4:	00006617          	auipc	a2,0x6
ffffffffc02013c8:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02013cc:	11200593          	li	a1,274
ffffffffc02013d0:	00006517          	auipc	a0,0x6
ffffffffc02013d4:	c4850513          	addi	a0,a0,-952 # ffffffffc0207018 <etext+0x90c>
ffffffffc02013d8:	89cff0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013dc:	00006697          	auipc	a3,0x6
ffffffffc02013e0:	efc68693          	addi	a3,a3,-260 # ffffffffc02072d8 <etext+0xbcc>
ffffffffc02013e4:	00006617          	auipc	a2,0x6
ffffffffc02013e8:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02013ec:	11000593          	li	a1,272
ffffffffc02013f0:	00006517          	auipc	a0,0x6
ffffffffc02013f4:	c2850513          	addi	a0,a0,-984 # ffffffffc0207018 <etext+0x90c>
ffffffffc02013f8:	87cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02013fc:	00006697          	auipc	a3,0x6
ffffffffc0201400:	eb468693          	addi	a3,a3,-332 # ffffffffc02072b0 <etext+0xba4>
ffffffffc0201404:	00006617          	auipc	a2,0x6
ffffffffc0201408:	98460613          	addi	a2,a2,-1660 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020140c:	10e00593          	li	a1,270
ffffffffc0201410:	00006517          	auipc	a0,0x6
ffffffffc0201414:	c0850513          	addi	a0,a0,-1016 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201418:	85cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020141c:	00006697          	auipc	a3,0x6
ffffffffc0201420:	e6c68693          	addi	a3,a3,-404 # ffffffffc0207288 <etext+0xb7c>
ffffffffc0201424:	00006617          	auipc	a2,0x6
ffffffffc0201428:	96460613          	addi	a2,a2,-1692 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020142c:	10d00593          	li	a1,269
ffffffffc0201430:	00006517          	auipc	a0,0x6
ffffffffc0201434:	be850513          	addi	a0,a0,-1048 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201438:	83cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020143c:	00006697          	auipc	a3,0x6
ffffffffc0201440:	e3c68693          	addi	a3,a3,-452 # ffffffffc0207278 <etext+0xb6c>
ffffffffc0201444:	00006617          	auipc	a2,0x6
ffffffffc0201448:	94460613          	addi	a2,a2,-1724 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020144c:	10800593          	li	a1,264
ffffffffc0201450:	00006517          	auipc	a0,0x6
ffffffffc0201454:	bc850513          	addi	a0,a0,-1080 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201458:	81cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020145c:	00006697          	auipc	a3,0x6
ffffffffc0201460:	d1c68693          	addi	a3,a3,-740 # ffffffffc0207178 <etext+0xa6c>
ffffffffc0201464:	00006617          	auipc	a2,0x6
ffffffffc0201468:	92460613          	addi	a2,a2,-1756 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020146c:	10700593          	li	a1,263
ffffffffc0201470:	00006517          	auipc	a0,0x6
ffffffffc0201474:	ba850513          	addi	a0,a0,-1112 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201478:	ffdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020147c:	00006697          	auipc	a3,0x6
ffffffffc0201480:	ddc68693          	addi	a3,a3,-548 # ffffffffc0207258 <etext+0xb4c>
ffffffffc0201484:	00006617          	auipc	a2,0x6
ffffffffc0201488:	90460613          	addi	a2,a2,-1788 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020148c:	10600593          	li	a1,262
ffffffffc0201490:	00006517          	auipc	a0,0x6
ffffffffc0201494:	b8850513          	addi	a0,a0,-1144 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201498:	fddfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020149c:	00006697          	auipc	a3,0x6
ffffffffc02014a0:	d8c68693          	addi	a3,a3,-628 # ffffffffc0207228 <etext+0xb1c>
ffffffffc02014a4:	00006617          	auipc	a2,0x6
ffffffffc02014a8:	8e460613          	addi	a2,a2,-1820 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02014ac:	10500593          	li	a1,261
ffffffffc02014b0:	00006517          	auipc	a0,0x6
ffffffffc02014b4:	b6850513          	addi	a0,a0,-1176 # ffffffffc0207018 <etext+0x90c>
ffffffffc02014b8:	fbdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014bc:	00006697          	auipc	a3,0x6
ffffffffc02014c0:	d5468693          	addi	a3,a3,-684 # ffffffffc0207210 <etext+0xb04>
ffffffffc02014c4:	00006617          	auipc	a2,0x6
ffffffffc02014c8:	8c460613          	addi	a2,a2,-1852 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02014cc:	10400593          	li	a1,260
ffffffffc02014d0:	00006517          	auipc	a0,0x6
ffffffffc02014d4:	b4850513          	addi	a0,a0,-1208 # ffffffffc0207018 <etext+0x90c>
ffffffffc02014d8:	f9dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014dc:	00006697          	auipc	a3,0x6
ffffffffc02014e0:	c9c68693          	addi	a3,a3,-868 # ffffffffc0207178 <etext+0xa6c>
ffffffffc02014e4:	00006617          	auipc	a2,0x6
ffffffffc02014e8:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02014ec:	0fe00593          	li	a1,254
ffffffffc02014f0:	00006517          	auipc	a0,0x6
ffffffffc02014f4:	b2850513          	addi	a0,a0,-1240 # ffffffffc0207018 <etext+0x90c>
ffffffffc02014f8:	f7dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(!PageProperty(p0));
ffffffffc02014fc:	00006697          	auipc	a3,0x6
ffffffffc0201500:	cfc68693          	addi	a3,a3,-772 # ffffffffc02071f8 <etext+0xaec>
ffffffffc0201504:	00006617          	auipc	a2,0x6
ffffffffc0201508:	88460613          	addi	a2,a2,-1916 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020150c:	0f900593          	li	a1,249
ffffffffc0201510:	00006517          	auipc	a0,0x6
ffffffffc0201514:	b0850513          	addi	a0,a0,-1272 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201518:	f5dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020151c:	00006697          	auipc	a3,0x6
ffffffffc0201520:	dfc68693          	addi	a3,a3,-516 # ffffffffc0207318 <etext+0xc0c>
ffffffffc0201524:	00006617          	auipc	a2,0x6
ffffffffc0201528:	86460613          	addi	a2,a2,-1948 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020152c:	11700593          	li	a1,279
ffffffffc0201530:	00006517          	auipc	a0,0x6
ffffffffc0201534:	ae850513          	addi	a0,a0,-1304 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201538:	f3dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(total == 0);
ffffffffc020153c:	00006697          	auipc	a3,0x6
ffffffffc0201540:	e0c68693          	addi	a3,a3,-500 # ffffffffc0207348 <etext+0xc3c>
ffffffffc0201544:	00006617          	auipc	a2,0x6
ffffffffc0201548:	84460613          	addi	a2,a2,-1980 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020154c:	12600593          	li	a1,294
ffffffffc0201550:	00006517          	auipc	a0,0x6
ffffffffc0201554:	ac850513          	addi	a0,a0,-1336 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201558:	f1dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(total == nr_free_pages());
ffffffffc020155c:	00006697          	auipc	a3,0x6
ffffffffc0201560:	ad468693          	addi	a3,a3,-1324 # ffffffffc0207030 <etext+0x924>
ffffffffc0201564:	00006617          	auipc	a2,0x6
ffffffffc0201568:	82460613          	addi	a2,a2,-2012 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020156c:	0f300593          	li	a1,243
ffffffffc0201570:	00006517          	auipc	a0,0x6
ffffffffc0201574:	aa850513          	addi	a0,a0,-1368 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201578:	efdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020157c:	00006697          	auipc	a3,0x6
ffffffffc0201580:	af468693          	addi	a3,a3,-1292 # ffffffffc0207070 <etext+0x964>
ffffffffc0201584:	00006617          	auipc	a2,0x6
ffffffffc0201588:	80460613          	addi	a2,a2,-2044 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020158c:	0ba00593          	li	a1,186
ffffffffc0201590:	00006517          	auipc	a0,0x6
ffffffffc0201594:	a8850513          	addi	a0,a0,-1400 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201598:	eddfe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020159c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020159c:	1141                	addi	sp,sp,-16
ffffffffc020159e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015a0:	14058463          	beqz	a1,ffffffffc02016e8 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02015a4:	00659713          	slli	a4,a1,0x6
ffffffffc02015a8:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02015ac:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02015ae:	c30d                	beqz	a4,ffffffffc02015d0 <default_free_pages+0x34>
ffffffffc02015b0:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015b2:	8b05                	andi	a4,a4,1
ffffffffc02015b4:	10071a63          	bnez	a4,ffffffffc02016c8 <default_free_pages+0x12c>
ffffffffc02015b8:	6798                	ld	a4,8(a5)
ffffffffc02015ba:	8b09                	andi	a4,a4,2
ffffffffc02015bc:	10071663          	bnez	a4,ffffffffc02016c8 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015c0:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02015c4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015c8:	04078793          	addi	a5,a5,64
ffffffffc02015cc:	fed792e3          	bne	a5,a3,ffffffffc02015b0 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015d0:	2581                	sext.w	a1,a1
ffffffffc02015d2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015d4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015d8:	4789                	li	a5,2
ffffffffc02015da:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02015de:	00098697          	auipc	a3,0x98
ffffffffc02015e2:	54268693          	addi	a3,a3,1346 # ffffffffc0299b20 <free_area>
ffffffffc02015e6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015e8:	669c                	ld	a5,8(a3)
ffffffffc02015ea:	9f2d                	addw	a4,a4,a1
ffffffffc02015ec:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ee:	0ad78163          	beq	a5,a3,ffffffffc0201690 <default_free_pages+0xf4>
            struct Page* page = le2page(le, page_link);
ffffffffc02015f2:	fe878713          	addi	a4,a5,-24
ffffffffc02015f6:	4581                	li	a1,0
ffffffffc02015f8:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02015fc:	00e56a63          	bltu	a0,a4,ffffffffc0201610 <default_free_pages+0x74>
    return listelm->next;
ffffffffc0201600:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201602:	04d70c63          	beq	a4,a3,ffffffffc020165a <default_free_pages+0xbe>
    struct Page *p = base;
ffffffffc0201606:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201608:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020160c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201600 <default_free_pages+0x64>
ffffffffc0201610:	c199                	beqz	a1,ffffffffc0201616 <default_free_pages+0x7a>
ffffffffc0201612:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201616:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201618:	e390                	sd	a2,0(a5)
ffffffffc020161a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020161c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020161e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201620:	00d70d63          	beq	a4,a3,ffffffffc020163a <default_free_pages+0x9e>
        if (p + p->property == base) {
ffffffffc0201624:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201628:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc020162c:	02059813          	slli	a6,a1,0x20
ffffffffc0201630:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201634:	97b2                	add	a5,a5,a2
ffffffffc0201636:	02f50c63          	beq	a0,a5,ffffffffc020166e <default_free_pages+0xd2>
    return listelm->next;
ffffffffc020163a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020163c:	00d78c63          	beq	a5,a3,ffffffffc0201654 <default_free_pages+0xb8>
        if (base + base->property == p) {
ffffffffc0201640:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201642:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201646:	02061593          	slli	a1,a2,0x20
ffffffffc020164a:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020164e:	972a                	add	a4,a4,a0
ffffffffc0201650:	04e68c63          	beq	a3,a4,ffffffffc02016a8 <default_free_pages+0x10c>
}
ffffffffc0201654:	60a2                	ld	ra,8(sp)
ffffffffc0201656:	0141                	addi	sp,sp,16
ffffffffc0201658:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020165a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020165c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020165e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201660:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201662:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201664:	02d70f63          	beq	a4,a3,ffffffffc02016a2 <default_free_pages+0x106>
ffffffffc0201668:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020166a:	87ba                	mv	a5,a4
ffffffffc020166c:	bf71                	j	ffffffffc0201608 <default_free_pages+0x6c>
            p->property += base->property;
ffffffffc020166e:	491c                	lw	a5,16(a0)
ffffffffc0201670:	9fad                	addw	a5,a5,a1
ffffffffc0201672:	fef72c23          	sw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201676:	57f5                	li	a5,-3
ffffffffc0201678:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020167c:	01853803          	ld	a6,24(a0)
ffffffffc0201680:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201682:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201684:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201688:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020168a:	0105b023          	sd	a6,0(a1)
ffffffffc020168e:	b77d                	j	ffffffffc020163c <default_free_pages+0xa0>
}
ffffffffc0201690:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201692:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201696:	e398                	sd	a4,0(a5)
ffffffffc0201698:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020169a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020169c:	ed1c                	sd	a5,24(a0)
}
ffffffffc020169e:	0141                	addi	sp,sp,16
ffffffffc02016a0:	8082                	ret
ffffffffc02016a2:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02016a4:	873e                	mv	a4,a5
ffffffffc02016a6:	bfad                	j	ffffffffc0201620 <default_free_pages+0x84>
            base->property += p->property;
ffffffffc02016a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016ac:	ff078693          	addi	a3,a5,-16
ffffffffc02016b0:	9f31                	addw	a4,a4,a2
ffffffffc02016b2:	c918                	sw	a4,16(a0)
ffffffffc02016b4:	5775                	li	a4,-3
ffffffffc02016b6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016ba:	6398                	ld	a4,0(a5)
ffffffffc02016bc:	679c                	ld	a5,8(a5)
}
ffffffffc02016be:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016c0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016c2:	e398                	sd	a4,0(a5)
ffffffffc02016c4:	0141                	addi	sp,sp,16
ffffffffc02016c6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016c8:	00006697          	auipc	a3,0x6
ffffffffc02016cc:	c9868693          	addi	a3,a3,-872 # ffffffffc0207360 <etext+0xc54>
ffffffffc02016d0:	00005617          	auipc	a2,0x5
ffffffffc02016d4:	6b860613          	addi	a2,a2,1720 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02016d8:	08300593          	li	a1,131
ffffffffc02016dc:	00006517          	auipc	a0,0x6
ffffffffc02016e0:	93c50513          	addi	a0,a0,-1732 # ffffffffc0207018 <etext+0x90c>
ffffffffc02016e4:	d91fe0ef          	jal	ffffffffc0200474 <__panic>
    assert(n > 0);
ffffffffc02016e8:	00006697          	auipc	a3,0x6
ffffffffc02016ec:	c7068693          	addi	a3,a3,-912 # ffffffffc0207358 <etext+0xc4c>
ffffffffc02016f0:	00005617          	auipc	a2,0x5
ffffffffc02016f4:	69860613          	addi	a2,a2,1688 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02016f8:	08000593          	li	a1,128
ffffffffc02016fc:	00006517          	auipc	a0,0x6
ffffffffc0201700:	91c50513          	addi	a0,a0,-1764 # ffffffffc0207018 <etext+0x90c>
ffffffffc0201704:	d71fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201708 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201708:	c949                	beqz	a0,ffffffffc020179a <default_alloc_pages+0x92>
    if (n > nr_free) {
ffffffffc020170a:	00098617          	auipc	a2,0x98
ffffffffc020170e:	41660613          	addi	a2,a2,1046 # ffffffffc0299b20 <free_area>
ffffffffc0201712:	4a0c                	lw	a1,16(a2)
ffffffffc0201714:	872a                	mv	a4,a0
ffffffffc0201716:	02059793          	slli	a5,a1,0x20
ffffffffc020171a:	9381                	srli	a5,a5,0x20
ffffffffc020171c:	00a7eb63          	bltu	a5,a0,ffffffffc0201732 <default_alloc_pages+0x2a>
    list_entry_t *le = &free_list;
ffffffffc0201720:	87b2                	mv	a5,a2
ffffffffc0201722:	a029                	j	ffffffffc020172c <default_alloc_pages+0x24>
        if (p->property >= n) {
ffffffffc0201724:	ff87e683          	lwu	a3,-8(a5)
ffffffffc0201728:	00e6f763          	bgeu	a3,a4,ffffffffc0201736 <default_alloc_pages+0x2e>
    return listelm->next;
ffffffffc020172c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020172e:	fec79be3          	bne	a5,a2,ffffffffc0201724 <default_alloc_pages+0x1c>
        return NULL;
ffffffffc0201732:	4501                	li	a0,0
}
ffffffffc0201734:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0201736:	0087b883          	ld	a7,8(a5)
        if (page->property > n) {
ffffffffc020173a:	ff87a803          	lw	a6,-8(a5)
    return listelm->prev;
ffffffffc020173e:	6394                	ld	a3,0(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201740:	fe878513          	addi	a0,a5,-24
        if (page->property > n) {
ffffffffc0201744:	02081313          	slli	t1,a6,0x20
    prev->next = next;
ffffffffc0201748:	0116b423          	sd	a7,8(a3)
    next->prev = prev;
ffffffffc020174c:	00d8b023          	sd	a3,0(a7)
ffffffffc0201750:	02035313          	srli	t1,t1,0x20
            p->property = page->property - n;
ffffffffc0201754:	0007089b          	sext.w	a7,a4
        if (page->property > n) {
ffffffffc0201758:	02677963          	bgeu	a4,t1,ffffffffc020178a <default_alloc_pages+0x82>
            struct Page *p = page + n;
ffffffffc020175c:	071a                	slli	a4,a4,0x6
ffffffffc020175e:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201760:	4118083b          	subw	a6,a6,a7
ffffffffc0201764:	01072823          	sw	a6,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201768:	4589                	li	a1,2
ffffffffc020176a:	00870813          	addi	a6,a4,8
ffffffffc020176e:	40b8302f          	amoor.d	zero,a1,(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201772:	0086b803          	ld	a6,8(a3)
            list_add(prev, &(p->page_link));
ffffffffc0201776:	01870313          	addi	t1,a4,24
        nr_free -= n;
ffffffffc020177a:	4a0c                	lw	a1,16(a2)
    prev->next = next->prev = elm;
ffffffffc020177c:	00683023          	sd	t1,0(a6)
ffffffffc0201780:	0066b423          	sd	t1,8(a3)
    elm->next = next;
ffffffffc0201784:	03073023          	sd	a6,32(a4)
    elm->prev = prev;
ffffffffc0201788:	ef14                	sd	a3,24(a4)
ffffffffc020178a:	411585bb          	subw	a1,a1,a7
ffffffffc020178e:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201790:	5775                	li	a4,-3
ffffffffc0201792:	17c1                	addi	a5,a5,-16
ffffffffc0201794:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201798:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020179a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020179c:	00006697          	auipc	a3,0x6
ffffffffc02017a0:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0207358 <etext+0xc4c>
ffffffffc02017a4:	00005617          	auipc	a2,0x5
ffffffffc02017a8:	5e460613          	addi	a2,a2,1508 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02017ac:	06200593          	li	a1,98
ffffffffc02017b0:	00006517          	auipc	a0,0x6
ffffffffc02017b4:	86850513          	addi	a0,a0,-1944 # ffffffffc0207018 <etext+0x90c>
default_alloc_pages(size_t n) {
ffffffffc02017b8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017ba:	cbbfe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02017be <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017be:	1141                	addi	sp,sp,-16
ffffffffc02017c0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017c2:	c5f1                	beqz	a1,ffffffffc020188e <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017c4:	00659713          	slli	a4,a1,0x6
ffffffffc02017c8:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02017cc:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02017ce:	cf11                	beqz	a4,ffffffffc02017ea <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017d0:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02017d2:	8b05                	andi	a4,a4,1
ffffffffc02017d4:	cf49                	beqz	a4,ffffffffc020186e <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017d6:	0007a823          	sw	zero,16(a5)
ffffffffc02017da:	0007b423          	sd	zero,8(a5)
ffffffffc02017de:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02017e2:	04078793          	addi	a5,a5,64
ffffffffc02017e6:	fed795e3          	bne	a5,a3,ffffffffc02017d0 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02017ea:	2581                	sext.w	a1,a1
ffffffffc02017ec:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017ee:	4789                	li	a5,2
ffffffffc02017f0:	00850713          	addi	a4,a0,8
ffffffffc02017f4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02017f8:	00098697          	auipc	a3,0x98
ffffffffc02017fc:	32868693          	addi	a3,a3,808 # ffffffffc0299b20 <free_area>
ffffffffc0201800:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201802:	669c                	ld	a5,8(a3)
ffffffffc0201804:	9f2d                	addw	a4,a4,a1
ffffffffc0201806:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201808:	04d78663          	beq	a5,a3,ffffffffc0201854 <default_init_memmap+0x96>
            struct Page* page = le2page(le, page_link);
ffffffffc020180c:	fe878713          	addi	a4,a5,-24
ffffffffc0201810:	4581                	li	a1,0
ffffffffc0201812:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201816:	00e56a63          	bltu	a0,a4,ffffffffc020182a <default_init_memmap+0x6c>
    return listelm->next;
ffffffffc020181a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020181c:	02d70263          	beq	a4,a3,ffffffffc0201840 <default_init_memmap+0x82>
    struct Page *p = base;
ffffffffc0201820:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201822:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201826:	fee57ae3          	bgeu	a0,a4,ffffffffc020181a <default_init_memmap+0x5c>
ffffffffc020182a:	c199                	beqz	a1,ffffffffc0201830 <default_init_memmap+0x72>
ffffffffc020182c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201830:	6398                	ld	a4,0(a5)
}
ffffffffc0201832:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201834:	e390                	sd	a2,0(a5)
ffffffffc0201836:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201838:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020183a:	ed18                	sd	a4,24(a0)
ffffffffc020183c:	0141                	addi	sp,sp,16
ffffffffc020183e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201840:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201842:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201844:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201846:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201848:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020184a:	00d70e63          	beq	a4,a3,ffffffffc0201866 <default_init_memmap+0xa8>
ffffffffc020184e:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201850:	87ba                	mv	a5,a4
ffffffffc0201852:	bfc1                	j	ffffffffc0201822 <default_init_memmap+0x64>
}
ffffffffc0201854:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201856:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020185a:	e398                	sd	a4,0(a5)
ffffffffc020185c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020185e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201860:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201862:	0141                	addi	sp,sp,16
ffffffffc0201864:	8082                	ret
ffffffffc0201866:	60a2                	ld	ra,8(sp)
ffffffffc0201868:	e290                	sd	a2,0(a3)
ffffffffc020186a:	0141                	addi	sp,sp,16
ffffffffc020186c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020186e:	00006697          	auipc	a3,0x6
ffffffffc0201872:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0207388 <etext+0xc7c>
ffffffffc0201876:	00005617          	auipc	a2,0x5
ffffffffc020187a:	51260613          	addi	a2,a2,1298 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020187e:	04900593          	li	a1,73
ffffffffc0201882:	00005517          	auipc	a0,0x5
ffffffffc0201886:	79650513          	addi	a0,a0,1942 # ffffffffc0207018 <etext+0x90c>
ffffffffc020188a:	bebfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(n > 0);
ffffffffc020188e:	00006697          	auipc	a3,0x6
ffffffffc0201892:	aca68693          	addi	a3,a3,-1334 # ffffffffc0207358 <etext+0xc4c>
ffffffffc0201896:	00005617          	auipc	a2,0x5
ffffffffc020189a:	4f260613          	addi	a2,a2,1266 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020189e:	04600593          	li	a1,70
ffffffffc02018a2:	00005517          	auipc	a0,0x5
ffffffffc02018a6:	77650513          	addi	a0,a0,1910 # ffffffffc0207018 <etext+0x90c>
ffffffffc02018aa:	bcbfe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02018ae <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02018ae:	cd49                	beqz	a0,ffffffffc0201948 <slob_free+0x9a>
{
ffffffffc02018b0:	1141                	addi	sp,sp,-16
ffffffffc02018b2:	e022                	sd	s0,0(sp)
ffffffffc02018b4:	e406                	sd	ra,8(sp)
ffffffffc02018b6:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018b8:	eda1                	bnez	a1,ffffffffc0201910 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018ba:	100027f3          	csrr	a5,sstatus
ffffffffc02018be:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018c0:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018c2:	efb9                	bnez	a5,ffffffffc0201920 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018c4:	00091617          	auipc	a2,0x91
ffffffffc02018c8:	e4c60613          	addi	a2,a2,-436 # ffffffffc0292710 <slobfree>
ffffffffc02018cc:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018ce:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018d0:	0287fa63          	bgeu	a5,s0,ffffffffc0201904 <slob_free+0x56>
ffffffffc02018d4:	00e46463          	bltu	s0,a4,ffffffffc02018dc <slob_free+0x2e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018d8:	02e7ea63          	bltu	a5,a4,ffffffffc020190c <slob_free+0x5e>
			break;

	if (b + b->units == cur->next) {
ffffffffc02018dc:	400c                	lw	a1,0(s0)
ffffffffc02018de:	00459693          	slli	a3,a1,0x4
ffffffffc02018e2:	96a2                	add	a3,a3,s0
ffffffffc02018e4:	04d70d63          	beq	a4,a3,ffffffffc020193e <slob_free+0x90>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02018e8:	438c                	lw	a1,0(a5)
ffffffffc02018ea:	e418                	sd	a4,8(s0)
ffffffffc02018ec:	00459693          	slli	a3,a1,0x4
ffffffffc02018f0:	96be                	add	a3,a3,a5
ffffffffc02018f2:	04d40063          	beq	s0,a3,ffffffffc0201932 <slob_free+0x84>
ffffffffc02018f6:	e780                	sd	s0,8(a5)
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur;
ffffffffc02018f8:	e21c                	sd	a5,0(a2)
    if (flag) {
ffffffffc02018fa:	e51d                	bnez	a0,ffffffffc0201928 <slob_free+0x7a>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02018fc:	60a2                	ld	ra,8(sp)
ffffffffc02018fe:	6402                	ld	s0,0(sp)
ffffffffc0201900:	0141                	addi	sp,sp,16
ffffffffc0201902:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201904:	00e7e463          	bltu	a5,a4,ffffffffc020190c <slob_free+0x5e>
ffffffffc0201908:	fce46ae3          	bltu	s0,a4,ffffffffc02018dc <slob_free+0x2e>
        return 1;
ffffffffc020190c:	87ba                	mv	a5,a4
ffffffffc020190e:	b7c1                	j	ffffffffc02018ce <slob_free+0x20>
		b->units = SLOB_UNITS(size);
ffffffffc0201910:	25bd                	addiw	a1,a1,15
ffffffffc0201912:	8191                	srli	a1,a1,0x4
ffffffffc0201914:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201916:	100027f3          	csrr	a5,sstatus
ffffffffc020191a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020191c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020191e:	d3dd                	beqz	a5,ffffffffc02018c4 <slob_free+0x16>
        intr_disable();
ffffffffc0201920:	d21fe0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0201924:	4505                	li	a0,1
ffffffffc0201926:	bf79                	j	ffffffffc02018c4 <slob_free+0x16>
}
ffffffffc0201928:	6402                	ld	s0,0(sp)
ffffffffc020192a:	60a2                	ld	ra,8(sp)
ffffffffc020192c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020192e:	d0dfe06f          	j	ffffffffc020063a <intr_enable>
		cur->units += b->units;
ffffffffc0201932:	4014                	lw	a3,0(s0)
		cur->next = b->next;
ffffffffc0201934:	843a                	mv	s0,a4
		cur->units += b->units;
ffffffffc0201936:	00b6873b          	addw	a4,a3,a1
ffffffffc020193a:	c398                	sw	a4,0(a5)
		cur->next = b->next;
ffffffffc020193c:	bf6d                	j	ffffffffc02018f6 <slob_free+0x48>
		b->units += cur->next->units;
ffffffffc020193e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201940:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201942:	9ead                	addw	a3,a3,a1
ffffffffc0201944:	c014                	sw	a3,0(s0)
		b->next = cur->next->next;
ffffffffc0201946:	b74d                	j	ffffffffc02018e8 <slob_free+0x3a>
ffffffffc0201948:	8082                	ret

ffffffffc020194a <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020194a:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020194c:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020194e:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201952:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201954:	34c000ef          	jal	ffffffffc0201ca0 <alloc_pages>
  if(!page)
ffffffffc0201958:	c91d                	beqz	a0,ffffffffc020198e <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020195a:	0009c797          	auipc	a5,0x9c
ffffffffc020195e:	2d67b783          	ld	a5,726(a5) # ffffffffc029dc30 <pages>
ffffffffc0201962:	8d1d                	sub	a0,a0,a5
ffffffffc0201964:	8519                	srai	a0,a0,0x6
ffffffffc0201966:	00007797          	auipc	a5,0x7
ffffffffc020196a:	4a27b783          	ld	a5,1186(a5) # ffffffffc0208e08 <nbase>
ffffffffc020196e:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201970:	00c51793          	slli	a5,a0,0xc
ffffffffc0201974:	83b1                	srli	a5,a5,0xc
ffffffffc0201976:	0009c717          	auipc	a4,0x9c
ffffffffc020197a:	2b273703          	ld	a4,690(a4) # ffffffffc029dc28 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020197e:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201980:	00e7fa63          	bgeu	a5,a4,ffffffffc0201994 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201984:	0009c797          	auipc	a5,0x9c
ffffffffc0201988:	29c7b783          	ld	a5,668(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc020198c:	953e                	add	a0,a0,a5
}
ffffffffc020198e:	60a2                	ld	ra,8(sp)
ffffffffc0201990:	0141                	addi	sp,sp,16
ffffffffc0201992:	8082                	ret
ffffffffc0201994:	86aa                	mv	a3,a0
ffffffffc0201996:	00006617          	auipc	a2,0x6
ffffffffc020199a:	a1a60613          	addi	a2,a2,-1510 # ffffffffc02073b0 <etext+0xca4>
ffffffffc020199e:	06900593          	li	a1,105
ffffffffc02019a2:	00006517          	auipc	a0,0x6
ffffffffc02019a6:	a3650513          	addi	a0,a0,-1482 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02019aa:	acbfe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02019ae <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019ae:	1101                	addi	sp,sp,-32
ffffffffc02019b0:	ec06                	sd	ra,24(sp)
ffffffffc02019b2:	e822                	sd	s0,16(sp)
ffffffffc02019b4:	e426                	sd	s1,8(sp)
ffffffffc02019b6:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019b8:	01050713          	addi	a4,a0,16
ffffffffc02019bc:	6785                	lui	a5,0x1
ffffffffc02019be:	0cf77363          	bgeu	a4,a5,ffffffffc0201a84 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019c2:	00f50493          	addi	s1,a0,15
ffffffffc02019c6:	8091                	srli	s1,s1,0x4
ffffffffc02019c8:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019ca:	10002673          	csrr	a2,sstatus
ffffffffc02019ce:	8a09                	andi	a2,a2,2
ffffffffc02019d0:	e25d                	bnez	a2,ffffffffc0201a76 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02019d2:	00091917          	auipc	s2,0x91
ffffffffc02019d6:	d3e90913          	addi	s2,s2,-706 # ffffffffc0292710 <slobfree>
ffffffffc02019da:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02019de:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019e0:	4398                	lw	a4,0(a5)
ffffffffc02019e2:	08975e63          	bge	a4,s1,ffffffffc0201a7e <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02019e6:	00f68b63          	beq	a3,a5,ffffffffc02019fc <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02019ea:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019ec:	4018                	lw	a4,0(s0)
ffffffffc02019ee:	02975a63          	bge	a4,s1,ffffffffc0201a22 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc02019f2:	00093683          	ld	a3,0(s2)
ffffffffc02019f6:	87a2                	mv	a5,s0
ffffffffc02019f8:	fef699e3          	bne	a3,a5,ffffffffc02019ea <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc02019fc:	ee31                	bnez	a2,ffffffffc0201a58 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02019fe:	4501                	li	a0,0
ffffffffc0201a00:	f4bff0ef          	jal	ffffffffc020194a <__slob_get_free_pages.constprop.0>
ffffffffc0201a04:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a06:	cd05                	beqz	a0,ffffffffc0201a3e <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a08:	6585                	lui	a1,0x1
ffffffffc0201a0a:	ea5ff0ef          	jal	ffffffffc02018ae <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a0e:	10002673          	csrr	a2,sstatus
ffffffffc0201a12:	8a09                	andi	a2,a2,2
ffffffffc0201a14:	ee05                	bnez	a2,ffffffffc0201a4c <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a16:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a1a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a1c:	4018                	lw	a4,0(s0)
ffffffffc0201a1e:	fc974ae3          	blt	a4,s1,ffffffffc02019f2 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a22:	04e48763          	beq	s1,a4,ffffffffc0201a70 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a26:	00449693          	slli	a3,s1,0x4
ffffffffc0201a2a:	96a2                	add	a3,a3,s0
ffffffffc0201a2c:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a2e:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a30:	9f05                	subw	a4,a4,s1
ffffffffc0201a32:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a34:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a36:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a38:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a3c:	e20d                	bnez	a2,ffffffffc0201a5e <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a3e:	60e2                	ld	ra,24(sp)
ffffffffc0201a40:	8522                	mv	a0,s0
ffffffffc0201a42:	6442                	ld	s0,16(sp)
ffffffffc0201a44:	64a2                	ld	s1,8(sp)
ffffffffc0201a46:	6902                	ld	s2,0(sp)
ffffffffc0201a48:	6105                	addi	sp,sp,32
ffffffffc0201a4a:	8082                	ret
        intr_disable();
ffffffffc0201a4c:	bf5fe0ef          	jal	ffffffffc0200640 <intr_disable>
			cur = slobfree;
ffffffffc0201a50:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a54:	4605                	li	a2,1
ffffffffc0201a56:	b7d1                	j	ffffffffc0201a1a <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a58:	be3fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0201a5c:	b74d                	j	ffffffffc02019fe <slob_alloc.constprop.0+0x50>
ffffffffc0201a5e:	bddfe0ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc0201a62:	60e2                	ld	ra,24(sp)
ffffffffc0201a64:	8522                	mv	a0,s0
ffffffffc0201a66:	6442                	ld	s0,16(sp)
ffffffffc0201a68:	64a2                	ld	s1,8(sp)
ffffffffc0201a6a:	6902                	ld	s2,0(sp)
ffffffffc0201a6c:	6105                	addi	sp,sp,32
ffffffffc0201a6e:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201a70:	6418                	ld	a4,8(s0)
ffffffffc0201a72:	e798                	sd	a4,8(a5)
ffffffffc0201a74:	b7d1                	j	ffffffffc0201a38 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201a76:	bcbfe0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0201a7a:	4605                	li	a2,1
ffffffffc0201a7c:	bf99                	j	ffffffffc02019d2 <slob_alloc.constprop.0+0x24>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a7e:	843e                	mv	s0,a5
	prev = slobfree;
ffffffffc0201a80:	87b6                	mv	a5,a3
ffffffffc0201a82:	b745                	j	ffffffffc0201a22 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201a84:	00006697          	auipc	a3,0x6
ffffffffc0201a88:	96468693          	addi	a3,a3,-1692 # ffffffffc02073e8 <etext+0xcdc>
ffffffffc0201a8c:	00005617          	auipc	a2,0x5
ffffffffc0201a90:	2fc60613          	addi	a2,a2,764 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0201a94:	06400593          	li	a1,100
ffffffffc0201a98:	00006517          	auipc	a0,0x6
ffffffffc0201a9c:	97050513          	addi	a0,a0,-1680 # ffffffffc0207408 <etext+0xcfc>
ffffffffc0201aa0:	9d5fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201aa4 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201aa4:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201aa6:	00006517          	auipc	a0,0x6
ffffffffc0201aaa:	97a50513          	addi	a0,a0,-1670 # ffffffffc0207420 <etext+0xd14>
kmalloc_init(void) {
ffffffffc0201aae:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201ab0:	ed0fe0ef          	jal	ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201ab4:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ab6:	00006517          	auipc	a0,0x6
ffffffffc0201aba:	98250513          	addi	a0,a0,-1662 # ffffffffc0207438 <etext+0xd2c>
}
ffffffffc0201abe:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ac0:	ec0fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201ac4 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201ac4:	4501                	li	a0,0
ffffffffc0201ac6:	8082                	ret

ffffffffc0201ac8 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201ac8:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201aca:	6785                	lui	a5,0x1
{
ffffffffc0201acc:	e822                	sd	s0,16(sp)
ffffffffc0201ace:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ad0:	17bd                	addi	a5,a5,-17 # fef <_binary_obj___user_softint_out_size-0x7609>
{
ffffffffc0201ad2:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ad4:	04a7fa63          	bgeu	a5,a0,ffffffffc0201b28 <kmalloc+0x60>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201ad8:	4561                	li	a0,24
ffffffffc0201ada:	e426                	sd	s1,8(sp)
ffffffffc0201adc:	ed3ff0ef          	jal	ffffffffc02019ae <slob_alloc.constprop.0>
ffffffffc0201ae0:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201ae2:	c549                	beqz	a0,ffffffffc0201b6c <kmalloc+0xa4>
ffffffffc0201ae4:	e04a                	sd	s2,0(sp)
	bb->order = find_order(size);
ffffffffc0201ae6:	0004079b          	sext.w	a5,s0
ffffffffc0201aea:	6905                	lui	s2,0x1
	int order = 0;
ffffffffc0201aec:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201aee:	00f95763          	bge	s2,a5,ffffffffc0201afc <kmalloc+0x34>
ffffffffc0201af2:	6705                	lui	a4,0x1
ffffffffc0201af4:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201af6:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201af8:	fef74ee3          	blt	a4,a5,ffffffffc0201af4 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201afc:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201afe:	e4dff0ef          	jal	ffffffffc020194a <__slob_get_free_pages.constprop.0>
ffffffffc0201b02:	e488                	sd	a0,8(s1)
	if (bb->pages) {
ffffffffc0201b04:	cd21                	beqz	a0,ffffffffc0201b5c <kmalloc+0x94>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b06:	100027f3          	csrr	a5,sstatus
ffffffffc0201b0a:	8b89                	andi	a5,a5,2
ffffffffc0201b0c:	e795                	bnez	a5,ffffffffc0201b38 <kmalloc+0x70>
		bb->next = bigblocks;
ffffffffc0201b0e:	0009c797          	auipc	a5,0x9c
ffffffffc0201b12:	0f278793          	addi	a5,a5,242 # ffffffffc029dc00 <bigblocks>
ffffffffc0201b16:	6398                	ld	a4,0(a5)
ffffffffc0201b18:	6902                	ld	s2,0(sp)
		bigblocks = bb;
ffffffffc0201b1a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b1c:	e898                	sd	a4,16(s1)
    if (flag) {
ffffffffc0201b1e:	64a2                	ld	s1,8(sp)
  return __kmalloc(size, 0);
}
ffffffffc0201b20:	60e2                	ld	ra,24(sp)
ffffffffc0201b22:	6442                	ld	s0,16(sp)
ffffffffc0201b24:	6105                	addi	sp,sp,32
ffffffffc0201b26:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b28:	0541                	addi	a0,a0,16
ffffffffc0201b2a:	e85ff0ef          	jal	ffffffffc02019ae <slob_alloc.constprop.0>
ffffffffc0201b2e:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b30:	0541                	addi	a0,a0,16
ffffffffc0201b32:	f7fd                	bnez	a5,ffffffffc0201b20 <kmalloc+0x58>
		return 0;
ffffffffc0201b34:	4501                	li	a0,0
  return __kmalloc(size, 0);
ffffffffc0201b36:	b7ed                	j	ffffffffc0201b20 <kmalloc+0x58>
        intr_disable();
ffffffffc0201b38:	b09fe0ef          	jal	ffffffffc0200640 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b3c:	0009c797          	auipc	a5,0x9c
ffffffffc0201b40:	0c478793          	addi	a5,a5,196 # ffffffffc029dc00 <bigblocks>
ffffffffc0201b44:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b46:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b48:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b4a:	af1fe0ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc0201b4e:	60e2                	ld	ra,24(sp)
ffffffffc0201b50:	6442                	ld	s0,16(sp)
		return bb->pages;
ffffffffc0201b52:	6488                	ld	a0,8(s1)
ffffffffc0201b54:	6902                	ld	s2,0(sp)
ffffffffc0201b56:	64a2                	ld	s1,8(sp)
}
ffffffffc0201b58:	6105                	addi	sp,sp,32
ffffffffc0201b5a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b5c:	8526                	mv	a0,s1
ffffffffc0201b5e:	45e1                	li	a1,24
ffffffffc0201b60:	d4fff0ef          	jal	ffffffffc02018ae <slob_free>
		return 0;
ffffffffc0201b64:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b66:	64a2                	ld	s1,8(sp)
ffffffffc0201b68:	6902                	ld	s2,0(sp)
ffffffffc0201b6a:	bf5d                	j	ffffffffc0201b20 <kmalloc+0x58>
ffffffffc0201b6c:	64a2                	ld	s1,8(sp)
		return 0;
ffffffffc0201b6e:	4501                	li	a0,0
ffffffffc0201b70:	bf45                	j	ffffffffc0201b20 <kmalloc+0x58>

ffffffffc0201b72 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201b72:	c169                	beqz	a0,ffffffffc0201c34 <kfree+0xc2>
{
ffffffffc0201b74:	1101                	addi	sp,sp,-32
ffffffffc0201b76:	e822                	sd	s0,16(sp)
ffffffffc0201b78:	ec06                	sd	ra,24(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201b7a:	03451793          	slli	a5,a0,0x34
ffffffffc0201b7e:	842a                	mv	s0,a0
ffffffffc0201b80:	e7c9                	bnez	a5,ffffffffc0201c0a <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b82:	100027f3          	csrr	a5,sstatus
ffffffffc0201b86:	8b89                	andi	a5,a5,2
ffffffffc0201b88:	ebc1                	bnez	a5,ffffffffc0201c18 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b8a:	0009c797          	auipc	a5,0x9c
ffffffffc0201b8e:	0767b783          	ld	a5,118(a5) # ffffffffc029dc00 <bigblocks>
    return 0;
ffffffffc0201b92:	4601                	li	a2,0
ffffffffc0201b94:	cbbd                	beqz	a5,ffffffffc0201c0a <kfree+0x98>
ffffffffc0201b96:	e426                	sd	s1,8(sp)
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201b98:	0009c697          	auipc	a3,0x9c
ffffffffc0201b9c:	06868693          	addi	a3,a3,104 # ffffffffc029dc00 <bigblocks>
ffffffffc0201ba0:	a021                	j	ffffffffc0201ba8 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ba2:	01048693          	addi	a3,s1,16
ffffffffc0201ba6:	c3a5                	beqz	a5,ffffffffc0201c06 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201ba8:	6798                	ld	a4,8(a5)
ffffffffc0201baa:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201bac:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201bae:	fe871ae3          	bne	a4,s0,ffffffffc0201ba2 <kfree+0x30>
				*last = bb->next;
ffffffffc0201bb2:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201bb4:	ee2d                	bnez	a2,ffffffffc0201c2e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bb6:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bba:	4098                	lw	a4,0(s1)
ffffffffc0201bbc:	08f46963          	bltu	s0,a5,ffffffffc0201c4e <kfree+0xdc>
ffffffffc0201bc0:	0009c797          	auipc	a5,0x9c
ffffffffc0201bc4:	0607b783          	ld	a5,96(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc0201bc8:	8c1d                	sub	s0,s0,a5
    if (PPN(pa) >= npage) {
ffffffffc0201bca:	8031                	srli	s0,s0,0xc
ffffffffc0201bcc:	0009c797          	auipc	a5,0x9c
ffffffffc0201bd0:	05c7b783          	ld	a5,92(a5) # ffffffffc029dc28 <npage>
ffffffffc0201bd4:	06f47163          	bgeu	s0,a5,ffffffffc0201c36 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bd8:	00007797          	auipc	a5,0x7
ffffffffc0201bdc:	2307b783          	ld	a5,560(a5) # ffffffffc0208e08 <nbase>
ffffffffc0201be0:	8c1d                	sub	s0,s0,a5
ffffffffc0201be2:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201be4:	0009c517          	auipc	a0,0x9c
ffffffffc0201be8:	04c53503          	ld	a0,76(a0) # ffffffffc029dc30 <pages>
ffffffffc0201bec:	4585                	li	a1,1
ffffffffc0201bee:	9522                	add	a0,a0,s0
ffffffffc0201bf0:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201bf4:	13c000ef          	jal	ffffffffc0201d30 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201bf8:	6442                	ld	s0,16(sp)
ffffffffc0201bfa:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bfc:	8526                	mv	a0,s1
ffffffffc0201bfe:	64a2                	ld	s1,8(sp)
ffffffffc0201c00:	45e1                	li	a1,24
}
ffffffffc0201c02:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c04:	b16d                	j	ffffffffc02018ae <slob_free>
ffffffffc0201c06:	64a2                	ld	s1,8(sp)
ffffffffc0201c08:	e205                	bnez	a2,ffffffffc0201c28 <kfree+0xb6>
ffffffffc0201c0a:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c0e:	6442                	ld	s0,16(sp)
ffffffffc0201c10:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c12:	4581                	li	a1,0
}
ffffffffc0201c14:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c16:	b961                	j	ffffffffc02018ae <slob_free>
        intr_disable();
ffffffffc0201c18:	a29fe0ef          	jal	ffffffffc0200640 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c1c:	0009c797          	auipc	a5,0x9c
ffffffffc0201c20:	fe47b783          	ld	a5,-28(a5) # ffffffffc029dc00 <bigblocks>
        return 1;
ffffffffc0201c24:	4605                	li	a2,1
ffffffffc0201c26:	fba5                	bnez	a5,ffffffffc0201b96 <kfree+0x24>
        intr_enable();
ffffffffc0201c28:	a13fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0201c2c:	bff9                	j	ffffffffc0201c0a <kfree+0x98>
ffffffffc0201c2e:	a0dfe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0201c32:	b751                	j	ffffffffc0201bb6 <kfree+0x44>
ffffffffc0201c34:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c36:	00006617          	auipc	a2,0x6
ffffffffc0201c3a:	84a60613          	addi	a2,a2,-1974 # ffffffffc0207480 <etext+0xd74>
ffffffffc0201c3e:	06200593          	li	a1,98
ffffffffc0201c42:	00005517          	auipc	a0,0x5
ffffffffc0201c46:	79650513          	addi	a0,a0,1942 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0201c4a:	82bfe0ef          	jal	ffffffffc0200474 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c4e:	86a2                	mv	a3,s0
ffffffffc0201c50:	00006617          	auipc	a2,0x6
ffffffffc0201c54:	80860613          	addi	a2,a2,-2040 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0201c58:	06e00593          	li	a1,110
ffffffffc0201c5c:	00005517          	auipc	a0,0x5
ffffffffc0201c60:	77c50513          	addi	a0,a0,1916 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0201c64:	811fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201c68 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201c68:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201c6a:	00006617          	auipc	a2,0x6
ffffffffc0201c6e:	81660613          	addi	a2,a2,-2026 # ffffffffc0207480 <etext+0xd74>
ffffffffc0201c72:	06200593          	li	a1,98
ffffffffc0201c76:	00005517          	auipc	a0,0x5
ffffffffc0201c7a:	76250513          	addi	a0,a0,1890 # ffffffffc02073d8 <etext+0xccc>
pa2page(uintptr_t pa) {
ffffffffc0201c7e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c80:	ff4fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201c84 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201c84:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201c86:	00006617          	auipc	a2,0x6
ffffffffc0201c8a:	81a60613          	addi	a2,a2,-2022 # ffffffffc02074a0 <etext+0xd94>
ffffffffc0201c8e:	07400593          	li	a1,116
ffffffffc0201c92:	00005517          	auipc	a0,0x5
ffffffffc0201c96:	74650513          	addi	a0,a0,1862 # ffffffffc02073d8 <etext+0xccc>
pte2page(pte_t pte) {
ffffffffc0201c9a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201c9c:	fd8fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201ca0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201ca0:	7139                	addi	sp,sp,-64
ffffffffc0201ca2:	f426                	sd	s1,40(sp)
ffffffffc0201ca4:	f04a                	sd	s2,32(sp)
ffffffffc0201ca6:	ec4e                	sd	s3,24(sp)
ffffffffc0201ca8:	e852                	sd	s4,16(sp)
ffffffffc0201caa:	e456                	sd	s5,8(sp)
ffffffffc0201cac:	e05a                	sd	s6,0(sp)
ffffffffc0201cae:	fc06                	sd	ra,56(sp)
ffffffffc0201cb0:	f822                	sd	s0,48(sp)
ffffffffc0201cb2:	84aa                	mv	s1,a0
ffffffffc0201cb4:	0009c917          	auipc	s2,0x9c
ffffffffc0201cb8:	f5490913          	addi	s2,s2,-172 # ffffffffc029dc08 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cbc:	4a05                	li	s4,1
ffffffffc0201cbe:	0009ca97          	auipc	s5,0x9c
ffffffffc0201cc2:	f7aa8a93          	addi	s5,s5,-134 # ffffffffc029dc38 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cc6:	0005099b          	sext.w	s3,a0
ffffffffc0201cca:	0009cb17          	auipc	s6,0x9c
ffffffffc0201cce:	f8eb0b13          	addi	s6,s6,-114 # ffffffffc029dc58 <check_mm_struct>
ffffffffc0201cd2:	a015                	j	ffffffffc0201cf6 <alloc_pages+0x56>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201cd4:	00093783          	ld	a5,0(s2)
ffffffffc0201cd8:	6f9c                	ld	a5,24(a5)
ffffffffc0201cda:	9782                	jalr	a5
ffffffffc0201cdc:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cde:	4601                	li	a2,0
ffffffffc0201ce0:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ce2:	ec05                	bnez	s0,ffffffffc0201d1a <alloc_pages+0x7a>
ffffffffc0201ce4:	029a6b63          	bltu	s4,s1,ffffffffc0201d1a <alloc_pages+0x7a>
ffffffffc0201ce8:	000aa783          	lw	a5,0(s5)
ffffffffc0201cec:	c79d                	beqz	a5,ffffffffc0201d1a <alloc_pages+0x7a>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cee:	000b3503          	ld	a0,0(s6)
ffffffffc0201cf2:	6a5010ef          	jal	ffffffffc0203b96 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cf6:	100027f3          	csrr	a5,sstatus
ffffffffc0201cfa:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201cfc:	8526                	mv	a0,s1
ffffffffc0201cfe:	dbf9                	beqz	a5,ffffffffc0201cd4 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201d00:	941fe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0201d04:	00093783          	ld	a5,0(s2)
ffffffffc0201d08:	8526                	mv	a0,s1
ffffffffc0201d0a:	6f9c                	ld	a5,24(a5)
ffffffffc0201d0c:	9782                	jalr	a5
ffffffffc0201d0e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d10:	92bfe0ef          	jal	ffffffffc020063a <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d14:	4601                	li	a2,0
ffffffffc0201d16:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d18:	d471                	beqz	s0,ffffffffc0201ce4 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d1a:	70e2                	ld	ra,56(sp)
ffffffffc0201d1c:	8522                	mv	a0,s0
ffffffffc0201d1e:	7442                	ld	s0,48(sp)
ffffffffc0201d20:	74a2                	ld	s1,40(sp)
ffffffffc0201d22:	7902                	ld	s2,32(sp)
ffffffffc0201d24:	69e2                	ld	s3,24(sp)
ffffffffc0201d26:	6a42                	ld	s4,16(sp)
ffffffffc0201d28:	6aa2                	ld	s5,8(sp)
ffffffffc0201d2a:	6b02                	ld	s6,0(sp)
ffffffffc0201d2c:	6121                	addi	sp,sp,64
ffffffffc0201d2e:	8082                	ret

ffffffffc0201d30 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d30:	100027f3          	csrr	a5,sstatus
ffffffffc0201d34:	8b89                	andi	a5,a5,2
ffffffffc0201d36:	e799                	bnez	a5,ffffffffc0201d44 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d38:	0009c797          	auipc	a5,0x9c
ffffffffc0201d3c:	ed07b783          	ld	a5,-304(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0201d40:	739c                	ld	a5,32(a5)
ffffffffc0201d42:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d44:	1101                	addi	sp,sp,-32
ffffffffc0201d46:	ec06                	sd	ra,24(sp)
ffffffffc0201d48:	e822                	sd	s0,16(sp)
ffffffffc0201d4a:	e426                	sd	s1,8(sp)
ffffffffc0201d4c:	842a                	mv	s0,a0
ffffffffc0201d4e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d50:	8f1fe0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d54:	0009c797          	auipc	a5,0x9c
ffffffffc0201d58:	eb47b783          	ld	a5,-332(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0201d5c:	739c                	ld	a5,32(a5)
ffffffffc0201d5e:	85a6                	mv	a1,s1
ffffffffc0201d60:	8522                	mv	a0,s0
ffffffffc0201d62:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201d64:	6442                	ld	s0,16(sp)
ffffffffc0201d66:	60e2                	ld	ra,24(sp)
ffffffffc0201d68:	64a2                	ld	s1,8(sp)
ffffffffc0201d6a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201d6c:	8cffe06f          	j	ffffffffc020063a <intr_enable>

ffffffffc0201d70 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d70:	100027f3          	csrr	a5,sstatus
ffffffffc0201d74:	8b89                	andi	a5,a5,2
ffffffffc0201d76:	e799                	bnez	a5,ffffffffc0201d84 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d78:	0009c797          	auipc	a5,0x9c
ffffffffc0201d7c:	e907b783          	ld	a5,-368(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0201d80:	779c                	ld	a5,40(a5)
ffffffffc0201d82:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201d84:	1141                	addi	sp,sp,-16
ffffffffc0201d86:	e406                	sd	ra,8(sp)
ffffffffc0201d88:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201d8a:	8b7fe0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d8e:	0009c797          	auipc	a5,0x9c
ffffffffc0201d92:	e7a7b783          	ld	a5,-390(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0201d96:	779c                	ld	a5,40(a5)
ffffffffc0201d98:	9782                	jalr	a5
ffffffffc0201d9a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d9c:	89ffe0ef          	jal	ffffffffc020063a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201da0:	60a2                	ld	ra,8(sp)
ffffffffc0201da2:	8522                	mv	a0,s0
ffffffffc0201da4:	6402                	ld	s0,0(sp)
ffffffffc0201da6:	0141                	addi	sp,sp,16
ffffffffc0201da8:	8082                	ret

ffffffffc0201daa <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201daa:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201dae:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201db2:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201db4:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201db6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201db8:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dbc:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dbe:	f04a                	sd	s2,32(sp)
ffffffffc0201dc0:	ec4e                	sd	s3,24(sp)
ffffffffc0201dc2:	e852                	sd	s4,16(sp)
ffffffffc0201dc4:	fc06                	sd	ra,56(sp)
ffffffffc0201dc6:	f822                	sd	s0,48(sp)
ffffffffc0201dc8:	e456                	sd	s5,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dca:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dce:	892e                	mv	s2,a1
ffffffffc0201dd0:	89b2                	mv	s3,a2
ffffffffc0201dd2:	0009ca17          	auipc	s4,0x9c
ffffffffc0201dd6:	e56a0a13          	addi	s4,s4,-426 # ffffffffc029dc28 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dda:	eba5                	bnez	a5,ffffffffc0201e4a <get_pte+0xa0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201ddc:	12060e63          	beqz	a2,ffffffffc0201f18 <get_pte+0x16e>
ffffffffc0201de0:	4505                	li	a0,1
ffffffffc0201de2:	ebfff0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0201de6:	842a                	mv	s0,a0
ffffffffc0201de8:	12050863          	beqz	a0,ffffffffc0201f18 <get_pte+0x16e>
    page->ref = val;
ffffffffc0201dec:	e05a                	sd	s6,0(sp)
    return page - pages + nbase;
ffffffffc0201dee:	0009cb17          	auipc	s6,0x9c
ffffffffc0201df2:	e42b0b13          	addi	s6,s6,-446 # ffffffffc029dc30 <pages>
ffffffffc0201df6:	000b3503          	ld	a0,0(s6)
ffffffffc0201dfa:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201dfe:	0009ca17          	auipc	s4,0x9c
ffffffffc0201e02:	e2aa0a13          	addi	s4,s4,-470 # ffffffffc029dc28 <npage>
ffffffffc0201e06:	40a40533          	sub	a0,s0,a0
ffffffffc0201e0a:	8519                	srai	a0,a0,0x6
ffffffffc0201e0c:	9556                	add	a0,a0,s5
ffffffffc0201e0e:	000a3703          	ld	a4,0(s4)
ffffffffc0201e12:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e16:	4685                	li	a3,1
ffffffffc0201e18:	c014                	sw	a3,0(s0)
ffffffffc0201e1a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e1c:	0532                	slli	a0,a0,0xc
ffffffffc0201e1e:	14e7f563          	bgeu	a5,a4,ffffffffc0201f68 <get_pte+0x1be>
ffffffffc0201e22:	0009c797          	auipc	a5,0x9c
ffffffffc0201e26:	dfe7b783          	ld	a5,-514(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc0201e2a:	953e                	add	a0,a0,a5
ffffffffc0201e2c:	6605                	lui	a2,0x1
ffffffffc0201e2e:	4581                	li	a1,0
ffffffffc0201e30:	0b3040ef          	jal	ffffffffc02066e2 <memset>
    return page - pages + nbase;
ffffffffc0201e34:	000b3783          	ld	a5,0(s6)
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e38:	6b02                	ld	s6,0(sp)
ffffffffc0201e3a:	40f406b3          	sub	a3,s0,a5
ffffffffc0201e3e:	8699                	srai	a3,a3,0x6
ffffffffc0201e40:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e42:	06aa                	slli	a3,a3,0xa
ffffffffc0201e44:	0116e693          	ori	a3,a3,17
ffffffffc0201e48:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e4a:	77fd                	lui	a5,0xfffff
ffffffffc0201e4c:	068a                	slli	a3,a3,0x2
ffffffffc0201e4e:	000a3703          	ld	a4,0(s4)
ffffffffc0201e52:	8efd                	and	a3,a3,a5
ffffffffc0201e54:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e58:	0ce7f263          	bgeu	a5,a4,ffffffffc0201f1c <get_pte+0x172>
ffffffffc0201e5c:	0009ca97          	auipc	s5,0x9c
ffffffffc0201e60:	dc4a8a93          	addi	s5,s5,-572 # ffffffffc029dc20 <va_pa_offset>
ffffffffc0201e64:	000ab603          	ld	a2,0(s5)
ffffffffc0201e68:	01595793          	srli	a5,s2,0x15
ffffffffc0201e6c:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e70:	96b2                	add	a3,a3,a2
ffffffffc0201e72:	078e                	slli	a5,a5,0x3
ffffffffc0201e74:	00f68433          	add	s0,a3,a5
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201e78:	6014                	ld	a3,0(s0)
ffffffffc0201e7a:	0016f793          	andi	a5,a3,1
ffffffffc0201e7e:	e3bd                	bnez	a5,ffffffffc0201ee4 <get_pte+0x13a>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e80:	08098c63          	beqz	s3,ffffffffc0201f18 <get_pte+0x16e>
ffffffffc0201e84:	4505                	li	a0,1
ffffffffc0201e86:	e1bff0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0201e8a:	84aa                	mv	s1,a0
ffffffffc0201e8c:	c551                	beqz	a0,ffffffffc0201f18 <get_pte+0x16e>
    page->ref = val;
ffffffffc0201e8e:	e05a                	sd	s6,0(sp)
    return page - pages + nbase;
ffffffffc0201e90:	0009cb17          	auipc	s6,0x9c
ffffffffc0201e94:	da0b0b13          	addi	s6,s6,-608 # ffffffffc029dc30 <pages>
ffffffffc0201e98:	000b3683          	ld	a3,0(s6)
ffffffffc0201e9c:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ea0:	000a3703          	ld	a4,0(s4)
ffffffffc0201ea4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ea8:	8699                	srai	a3,a3,0x6
ffffffffc0201eaa:	96ce                	add	a3,a3,s3
ffffffffc0201eac:	00c69793          	slli	a5,a3,0xc
    page->ref = val;
ffffffffc0201eb0:	4605                	li	a2,1
ffffffffc0201eb2:	c110                	sw	a2,0(a0)
ffffffffc0201eb4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201eb6:	06b2                	slli	a3,a3,0xc
ffffffffc0201eb8:	08e7fc63          	bgeu	a5,a4,ffffffffc0201f50 <get_pte+0x1a6>
ffffffffc0201ebc:	000ab503          	ld	a0,0(s5)
ffffffffc0201ec0:	6605                	lui	a2,0x1
ffffffffc0201ec2:	4581                	li	a1,0
ffffffffc0201ec4:	9536                	add	a0,a0,a3
ffffffffc0201ec6:	01d040ef          	jal	ffffffffc02066e2 <memset>
    return page - pages + nbase;
ffffffffc0201eca:	000b3783          	ld	a5,0(s6)
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201ece:	6b02                	ld	s6,0(sp)
ffffffffc0201ed0:	40f486b3          	sub	a3,s1,a5
ffffffffc0201ed4:	8699                	srai	a3,a3,0x6
ffffffffc0201ed6:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ed8:	06aa                	slli	a3,a3,0xa
ffffffffc0201eda:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ede:	e014                	sd	a3,0(s0)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201ee0:	000a3703          	ld	a4,0(s4)
ffffffffc0201ee4:	77fd                	lui	a5,0xfffff
ffffffffc0201ee6:	068a                	slli	a3,a3,0x2
ffffffffc0201ee8:	8efd                	and	a3,a3,a5
ffffffffc0201eea:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201eee:	04e7f463          	bgeu	a5,a4,ffffffffc0201f36 <get_pte+0x18c>
ffffffffc0201ef2:	000ab783          	ld	a5,0(s5)
ffffffffc0201ef6:	00c95913          	srli	s2,s2,0xc
ffffffffc0201efa:	1ff97913          	andi	s2,s2,511
ffffffffc0201efe:	96be                	add	a3,a3,a5
ffffffffc0201f00:	090e                	slli	s2,s2,0x3
ffffffffc0201f02:	01268533          	add	a0,a3,s2
}
ffffffffc0201f06:	70e2                	ld	ra,56(sp)
ffffffffc0201f08:	7442                	ld	s0,48(sp)
ffffffffc0201f0a:	74a2                	ld	s1,40(sp)
ffffffffc0201f0c:	7902                	ld	s2,32(sp)
ffffffffc0201f0e:	69e2                	ld	s3,24(sp)
ffffffffc0201f10:	6a42                	ld	s4,16(sp)
ffffffffc0201f12:	6aa2                	ld	s5,8(sp)
ffffffffc0201f14:	6121                	addi	sp,sp,64
ffffffffc0201f16:	8082                	ret
            return NULL;
ffffffffc0201f18:	4501                	li	a0,0
ffffffffc0201f1a:	b7f5                	j	ffffffffc0201f06 <get_pte+0x15c>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f1c:	00005617          	auipc	a2,0x5
ffffffffc0201f20:	49460613          	addi	a2,a2,1172 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0201f24:	0e300593          	li	a1,227
ffffffffc0201f28:	00005517          	auipc	a0,0x5
ffffffffc0201f2c:	5a050513          	addi	a0,a0,1440 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0201f30:	e05a                	sd	s6,0(sp)
ffffffffc0201f32:	d42fe0ef          	jal	ffffffffc0200474 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f36:	00005617          	auipc	a2,0x5
ffffffffc0201f3a:	47a60613          	addi	a2,a2,1146 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0201f3e:	0ee00593          	li	a1,238
ffffffffc0201f42:	00005517          	auipc	a0,0x5
ffffffffc0201f46:	58650513          	addi	a0,a0,1414 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0201f4a:	e05a                	sd	s6,0(sp)
ffffffffc0201f4c:	d28fe0ef          	jal	ffffffffc0200474 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f50:	00005617          	auipc	a2,0x5
ffffffffc0201f54:	46060613          	addi	a2,a2,1120 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0201f58:	0eb00593          	li	a1,235
ffffffffc0201f5c:	00005517          	auipc	a0,0x5
ffffffffc0201f60:	56c50513          	addi	a0,a0,1388 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0201f64:	d10fe0ef          	jal	ffffffffc0200474 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f68:	86aa                	mv	a3,a0
ffffffffc0201f6a:	00005617          	auipc	a2,0x5
ffffffffc0201f6e:	44660613          	addi	a2,a2,1094 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0201f72:	0df00593          	li	a1,223
ffffffffc0201f76:	00005517          	auipc	a0,0x5
ffffffffc0201f7a:	55250513          	addi	a0,a0,1362 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0201f7e:	cf6fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201f82 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f82:	1141                	addi	sp,sp,-16
ffffffffc0201f84:	e022                	sd	s0,0(sp)
ffffffffc0201f86:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f88:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f8a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f8c:	e1fff0ef          	jal	ffffffffc0201daa <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201f90:	c011                	beqz	s0,ffffffffc0201f94 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201f92:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201f94:	c511                	beqz	a0,ffffffffc0201fa0 <get_page+0x1e>
ffffffffc0201f96:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201f98:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201f9a:	0017f713          	andi	a4,a5,1
ffffffffc0201f9e:	e709                	bnez	a4,ffffffffc0201fa8 <get_page+0x26>
}
ffffffffc0201fa0:	60a2                	ld	ra,8(sp)
ffffffffc0201fa2:	6402                	ld	s0,0(sp)
ffffffffc0201fa4:	0141                	addi	sp,sp,16
ffffffffc0201fa6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fa8:	078a                	slli	a5,a5,0x2
ffffffffc0201faa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fac:	0009c717          	auipc	a4,0x9c
ffffffffc0201fb0:	c7c73703          	ld	a4,-900(a4) # ffffffffc029dc28 <npage>
ffffffffc0201fb4:	00e7ff63          	bgeu	a5,a4,ffffffffc0201fd2 <get_page+0x50>
ffffffffc0201fb8:	60a2                	ld	ra,8(sp)
ffffffffc0201fba:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201fbc:	fff80737          	lui	a4,0xfff80
ffffffffc0201fc0:	97ba                	add	a5,a5,a4
ffffffffc0201fc2:	0009c517          	auipc	a0,0x9c
ffffffffc0201fc6:	c6e53503          	ld	a0,-914(a0) # ffffffffc029dc30 <pages>
ffffffffc0201fca:	079a                	slli	a5,a5,0x6
ffffffffc0201fcc:	953e                	add	a0,a0,a5
ffffffffc0201fce:	0141                	addi	sp,sp,16
ffffffffc0201fd0:	8082                	ret
ffffffffc0201fd2:	c97ff0ef          	jal	ffffffffc0201c68 <pa2page.part.0>

ffffffffc0201fd6 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201fd6:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201fd8:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201fdc:	e486                	sd	ra,72(sp)
ffffffffc0201fde:	e0a2                	sd	s0,64(sp)
ffffffffc0201fe0:	fc26                	sd	s1,56(sp)
ffffffffc0201fe2:	f84a                	sd	s2,48(sp)
ffffffffc0201fe4:	f44e                	sd	s3,40(sp)
ffffffffc0201fe6:	f052                	sd	s4,32(sp)
ffffffffc0201fe8:	ec56                	sd	s5,24(sp)
ffffffffc0201fea:	e85a                	sd	s6,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201fec:	17d2                	slli	a5,a5,0x34
ffffffffc0201fee:	e7f9                	bnez	a5,ffffffffc02020bc <unmap_range+0xe6>
    assert(USER_ACCESS(start, end));
ffffffffc0201ff0:	002007b7          	lui	a5,0x200
ffffffffc0201ff4:	842e                	mv	s0,a1
ffffffffc0201ff6:	0ef5e363          	bltu	a1,a5,ffffffffc02020dc <unmap_range+0x106>
ffffffffc0201ffa:	8932                	mv	s2,a2
ffffffffc0201ffc:	0ec5f063          	bgeu	a1,a2,ffffffffc02020dc <unmap_range+0x106>
ffffffffc0202000:	4785                	li	a5,1
ffffffffc0202002:	07fe                	slli	a5,a5,0x1f
ffffffffc0202004:	0cc7ec63          	bltu	a5,a2,ffffffffc02020dc <unmap_range+0x106>
ffffffffc0202008:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020200a:	6a05                	lui	s4,0x1
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020200c:	00200b37          	lui	s6,0x200
ffffffffc0202010:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202014:	4601                	li	a2,0
ffffffffc0202016:	85a2                	mv	a1,s0
ffffffffc0202018:	854e                	mv	a0,s3
ffffffffc020201a:	d91ff0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc020201e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202020:	c125                	beqz	a0,ffffffffc0202080 <unmap_range+0xaa>
        if (*ptep != 0) {
ffffffffc0202022:	611c                	ld	a5,0(a0)
ffffffffc0202024:	ef99                	bnez	a5,ffffffffc0202042 <unmap_range+0x6c>
        start += PGSIZE;
ffffffffc0202026:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202028:	c019                	beqz	s0,ffffffffc020202e <unmap_range+0x58>
ffffffffc020202a:	ff2465e3          	bltu	s0,s2,ffffffffc0202014 <unmap_range+0x3e>
}
ffffffffc020202e:	60a6                	ld	ra,72(sp)
ffffffffc0202030:	6406                	ld	s0,64(sp)
ffffffffc0202032:	74e2                	ld	s1,56(sp)
ffffffffc0202034:	7942                	ld	s2,48(sp)
ffffffffc0202036:	79a2                	ld	s3,40(sp)
ffffffffc0202038:	7a02                	ld	s4,32(sp)
ffffffffc020203a:	6ae2                	ld	s5,24(sp)
ffffffffc020203c:	6b42                	ld	s6,16(sp)
ffffffffc020203e:	6161                	addi	sp,sp,80
ffffffffc0202040:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202042:	0017f713          	andi	a4,a5,1
ffffffffc0202046:	d365                	beqz	a4,ffffffffc0202026 <unmap_range+0x50>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202048:	078a                	slli	a5,a5,0x2
ffffffffc020204a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020204c:	0009c717          	auipc	a4,0x9c
ffffffffc0202050:	bdc73703          	ld	a4,-1060(a4) # ffffffffc029dc28 <npage>
ffffffffc0202054:	0ae7f463          	bgeu	a5,a4,ffffffffc02020fc <unmap_range+0x126>
    return &pages[PPN(pa) - nbase];
ffffffffc0202058:	fff80737          	lui	a4,0xfff80
ffffffffc020205c:	97ba                	add	a5,a5,a4
ffffffffc020205e:	079a                	slli	a5,a5,0x6
ffffffffc0202060:	0009c517          	auipc	a0,0x9c
ffffffffc0202064:	bd053503          	ld	a0,-1072(a0) # ffffffffc029dc30 <pages>
ffffffffc0202068:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020206a:	411c                	lw	a5,0(a0)
ffffffffc020206c:	fff7871b          	addiw	a4,a5,-1 # 1fffff <_binary_obj___user_exit_out_size+0x1f649f>
ffffffffc0202070:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202072:	cb19                	beqz	a4,ffffffffc0202088 <unmap_range+0xb2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202074:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202078:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020207c:	9452                	add	s0,s0,s4
ffffffffc020207e:	b76d                	j	ffffffffc0202028 <unmap_range+0x52>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202080:	945a                	add	s0,s0,s6
ffffffffc0202082:	01547433          	and	s0,s0,s5
            continue;
ffffffffc0202086:	b74d                	j	ffffffffc0202028 <unmap_range+0x52>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202088:	100027f3          	csrr	a5,sstatus
ffffffffc020208c:	8b89                	andi	a5,a5,2
ffffffffc020208e:	eb89                	bnez	a5,ffffffffc02020a0 <unmap_range+0xca>
        pmm_manager->free_pages(base, n);
ffffffffc0202090:	0009c797          	auipc	a5,0x9c
ffffffffc0202094:	b787b783          	ld	a5,-1160(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0202098:	739c                	ld	a5,32(a5)
ffffffffc020209a:	4585                	li	a1,1
ffffffffc020209c:	9782                	jalr	a5
    if (flag) {
ffffffffc020209e:	bfd9                	j	ffffffffc0202074 <unmap_range+0x9e>
        intr_disable();
ffffffffc02020a0:	e42a                	sd	a0,8(sp)
ffffffffc02020a2:	d9efe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc02020a6:	0009c797          	auipc	a5,0x9c
ffffffffc02020aa:	b627b783          	ld	a5,-1182(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc02020ae:	739c                	ld	a5,32(a5)
ffffffffc02020b0:	6522                	ld	a0,8(sp)
ffffffffc02020b2:	4585                	li	a1,1
ffffffffc02020b4:	9782                	jalr	a5
        intr_enable();
ffffffffc02020b6:	d84fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02020ba:	bf6d                	j	ffffffffc0202074 <unmap_range+0x9e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020bc:	00005697          	auipc	a3,0x5
ffffffffc02020c0:	41c68693          	addi	a3,a3,1052 # ffffffffc02074d8 <etext+0xdcc>
ffffffffc02020c4:	00005617          	auipc	a2,0x5
ffffffffc02020c8:	cc460613          	addi	a2,a2,-828 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02020cc:	10f00593          	li	a1,271
ffffffffc02020d0:	00005517          	auipc	a0,0x5
ffffffffc02020d4:	3f850513          	addi	a0,a0,1016 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02020d8:	b9cfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02020dc:	00005697          	auipc	a3,0x5
ffffffffc02020e0:	42c68693          	addi	a3,a3,1068 # ffffffffc0207508 <etext+0xdfc>
ffffffffc02020e4:	00005617          	auipc	a2,0x5
ffffffffc02020e8:	ca460613          	addi	a2,a2,-860 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02020ec:	11000593          	li	a1,272
ffffffffc02020f0:	00005517          	auipc	a0,0x5
ffffffffc02020f4:	3d850513          	addi	a0,a0,984 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02020f8:	b7cfe0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc02020fc:	b6dff0ef          	jal	ffffffffc0201c68 <pa2page.part.0>

ffffffffc0202100 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202100:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202102:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202106:	fc86                	sd	ra,120(sp)
ffffffffc0202108:	f8a2                	sd	s0,112(sp)
ffffffffc020210a:	f4a6                	sd	s1,104(sp)
ffffffffc020210c:	f0ca                	sd	s2,96(sp)
ffffffffc020210e:	ecce                	sd	s3,88(sp)
ffffffffc0202110:	e8d2                	sd	s4,80(sp)
ffffffffc0202112:	e4d6                	sd	s5,72(sp)
ffffffffc0202114:	e0da                	sd	s6,64(sp)
ffffffffc0202116:	fc5e                	sd	s7,56(sp)
ffffffffc0202118:	f862                	sd	s8,48(sp)
ffffffffc020211a:	f466                	sd	s9,40(sp)
ffffffffc020211c:	f06a                	sd	s10,32(sp)
ffffffffc020211e:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202120:	17d2                	slli	a5,a5,0x34
ffffffffc0202122:	24079163          	bnez	a5,ffffffffc0202364 <exit_range+0x264>
    assert(USER_ACCESS(start, end));
ffffffffc0202126:	002007b7          	lui	a5,0x200
ffffffffc020212a:	28f5e863          	bltu	a1,a5,ffffffffc02023ba <exit_range+0x2ba>
ffffffffc020212e:	8b32                	mv	s6,a2
ffffffffc0202130:	28c5f563          	bgeu	a1,a2,ffffffffc02023ba <exit_range+0x2ba>
ffffffffc0202134:	4785                	li	a5,1
ffffffffc0202136:	07fe                	slli	a5,a5,0x1f
ffffffffc0202138:	28c7e163          	bltu	a5,a2,ffffffffc02023ba <exit_range+0x2ba>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020213c:	c0000a37          	lui	s4,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202140:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202144:	8d2a                	mv	s10,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202146:	0145fa33          	and	s4,a1,s4
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020214a:	00f5f4b3          	and	s1,a1,a5
        d1start += PDSIZE;
ffffffffc020214e:	40000db7          	lui	s11,0x40000
    if (PPN(pa) >= npage) {
ffffffffc0202152:	0009c617          	auipc	a2,0x9c
ffffffffc0202156:	ad660613          	addi	a2,a2,-1322 # ffffffffc029dc28 <npage>
    return KADDR(page2pa(page));
ffffffffc020215a:	0009c817          	auipc	a6,0x9c
ffffffffc020215e:	ac680813          	addi	a6,a6,-1338 # ffffffffc029dc20 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202162:	0009ce97          	auipc	t4,0x9c
ffffffffc0202166:	acee8e93          	addi	t4,t4,-1330 # ffffffffc029dc30 <pages>
                d0start += PTSIZE;
ffffffffc020216a:	00200c37          	lui	s8,0x200
ffffffffc020216e:	a819                	j	ffffffffc0202184 <exit_range+0x84>
        d1start += PDSIZE;
ffffffffc0202170:	01ba09b3          	add	s3,s4,s11
    } while (d1start != 0 && d1start < end);
ffffffffc0202174:	14098763          	beqz	s3,ffffffffc02022c2 <exit_range+0x1c2>
        d1start += PDSIZE;
ffffffffc0202178:	40000a37          	lui	s4,0x40000
        d0start = d1start;
ffffffffc020217c:	400004b7          	lui	s1,0x40000
    } while (d1start != 0 && d1start < end);
ffffffffc0202180:	1569f163          	bgeu	s3,s6,ffffffffc02022c2 <exit_range+0x1c2>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202184:	01ea5913          	srli	s2,s4,0x1e
ffffffffc0202188:	1ff97913          	andi	s2,s2,511
ffffffffc020218c:	090e                	slli	s2,s2,0x3
ffffffffc020218e:	996a                	add	s2,s2,s10
ffffffffc0202190:	00093a83          	ld	s5,0(s2)
        if (pde1&PTE_V){
ffffffffc0202194:	001af793          	andi	a5,s5,1
ffffffffc0202198:	dfe1                	beqz	a5,ffffffffc0202170 <exit_range+0x70>
    if (PPN(pa) >= npage) {
ffffffffc020219a:	6214                	ld	a3,0(a2)
    return pa2page(PDE_ADDR(pde));
ffffffffc020219c:	0a8a                	slli	s5,s5,0x2
ffffffffc020219e:	00cada93          	srli	s5,s5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021a2:	20dafa63          	bgeu	s5,a3,ffffffffc02023b6 <exit_range+0x2b6>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a6:	fff80737          	lui	a4,0xfff80
ffffffffc02021aa:	9756                	add	a4,a4,s5
    return page - pages + nbase;
ffffffffc02021ac:	000807b7          	lui	a5,0x80
ffffffffc02021b0:	97ba                	add	a5,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc02021b2:	00c79b93          	slli	s7,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02021b6:	071a                	slli	a4,a4,0x6
    return KADDR(page2pa(page));
ffffffffc02021b8:	1ed7f263          	bgeu	a5,a3,ffffffffc020239c <exit_range+0x29c>
ffffffffc02021bc:	00083783          	ld	a5,0(a6)
            free_pd0 = 1;
ffffffffc02021c0:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc02021c2:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02021c6:	9bbe                	add	s7,s7,a5
    return page - pages + nbase;
ffffffffc02021c8:	00080337          	lui	t1,0x80
ffffffffc02021cc:	6885                	lui	a7,0x1
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02021ce:	01ba09b3          	add	s3,s4,s11
ffffffffc02021d2:	a801                	j	ffffffffc02021e2 <exit_range+0xe2>
                    free_pd0 = 0;
ffffffffc02021d4:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02021d6:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02021d8:	ccd1                	beqz	s1,ffffffffc0202274 <exit_range+0x174>
ffffffffc02021da:	0934fd63          	bgeu	s1,s3,ffffffffc0202274 <exit_range+0x174>
ffffffffc02021de:	1164f163          	bgeu	s1,s6,ffffffffc02022e0 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02021e2:	0154d413          	srli	s0,s1,0x15
ffffffffc02021e6:	1ff47413          	andi	s0,s0,511
ffffffffc02021ea:	040e                	slli	s0,s0,0x3
ffffffffc02021ec:	945e                	add	s0,s0,s7
ffffffffc02021ee:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02021f0:	0017f693          	andi	a3,a5,1
ffffffffc02021f4:	d2e5                	beqz	a3,ffffffffc02021d4 <exit_range+0xd4>
    if (PPN(pa) >= npage) {
ffffffffc02021f6:	00063f03          	ld	t5,0(a2)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021fa:	078a                	slli	a5,a5,0x2
ffffffffc02021fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021fe:	1be7fc63          	bgeu	a5,t5,ffffffffc02023b6 <exit_range+0x2b6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202202:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202204:	00678fb3          	add	t6,a5,t1
    return &pages[PPN(pa) - nbase];
ffffffffc0202208:	000eb503          	ld	a0,0(t4)
ffffffffc020220c:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202210:	00cf9693          	slli	a3,t6,0xc
    return KADDR(page2pa(page));
ffffffffc0202214:	17eff863          	bgeu	t6,t5,ffffffffc0202384 <exit_range+0x284>
ffffffffc0202218:	00083783          	ld	a5,0(a6)
ffffffffc020221c:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020221e:	01168f33          	add	t5,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0202222:	629c                	ld	a5,0(a3)
ffffffffc0202224:	8b85                	andi	a5,a5,1
ffffffffc0202226:	fbc5                	bnez	a5,ffffffffc02021d6 <exit_range+0xd6>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202228:	06a1                	addi	a3,a3,8
ffffffffc020222a:	ffe69ce3          	bne	a3,t5,ffffffffc0202222 <exit_range+0x122>
    return &pages[PPN(pa) - nbase];
ffffffffc020222e:	952e                	add	a0,a0,a1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202230:	100027f3          	csrr	a5,sstatus
ffffffffc0202234:	8b89                	andi	a5,a5,2
ffffffffc0202236:	ebc5                	bnez	a5,ffffffffc02022e6 <exit_range+0x1e6>
        pmm_manager->free_pages(base, n);
ffffffffc0202238:	0009c797          	auipc	a5,0x9c
ffffffffc020223c:	9d07b783          	ld	a5,-1584(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0202240:	739c                	ld	a5,32(a5)
ffffffffc0202242:	4585                	li	a1,1
ffffffffc0202244:	e03a                	sd	a4,0(sp)
ffffffffc0202246:	9782                	jalr	a5
    if (flag) {
ffffffffc0202248:	6702                	ld	a4,0(sp)
ffffffffc020224a:	fff80e37          	lui	t3,0xfff80
ffffffffc020224e:	00080337          	lui	t1,0x80
ffffffffc0202252:	6885                	lui	a7,0x1
ffffffffc0202254:	0009c617          	auipc	a2,0x9c
ffffffffc0202258:	9d460613          	addi	a2,a2,-1580 # ffffffffc029dc28 <npage>
ffffffffc020225c:	0009c817          	auipc	a6,0x9c
ffffffffc0202260:	9c480813          	addi	a6,a6,-1596 # ffffffffc029dc20 <va_pa_offset>
ffffffffc0202264:	0009ce97          	auipc	t4,0x9c
ffffffffc0202268:	9cce8e93          	addi	t4,t4,-1588 # ffffffffc029dc30 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020226c:	00043023          	sd	zero,0(s0)
                d0start += PTSIZE;
ffffffffc0202270:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202272:	f4a5                	bnez	s1,ffffffffc02021da <exit_range+0xda>
            if (free_pd0) {
ffffffffc0202274:	ee0c8ee3          	beqz	s9,ffffffffc0202170 <exit_range+0x70>
    if (PPN(pa) >= npage) {
ffffffffc0202278:	621c                	ld	a5,0(a2)
ffffffffc020227a:	12fafe63          	bgeu	s5,a5,ffffffffc02023b6 <exit_range+0x2b6>
    return &pages[PPN(pa) - nbase];
ffffffffc020227e:	0009c517          	auipc	a0,0x9c
ffffffffc0202282:	9b253503          	ld	a0,-1614(a0) # ffffffffc029dc30 <pages>
ffffffffc0202286:	953a                	add	a0,a0,a4
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202288:	100027f3          	csrr	a5,sstatus
ffffffffc020228c:	8b89                	andi	a5,a5,2
ffffffffc020228e:	efd9                	bnez	a5,ffffffffc020232c <exit_range+0x22c>
        pmm_manager->free_pages(base, n);
ffffffffc0202290:	0009c797          	auipc	a5,0x9c
ffffffffc0202294:	9787b783          	ld	a5,-1672(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0202298:	739c                	ld	a5,32(a5)
ffffffffc020229a:	4585                	li	a1,1
ffffffffc020229c:	9782                	jalr	a5
ffffffffc020229e:	0009ce97          	auipc	t4,0x9c
ffffffffc02022a2:	992e8e93          	addi	t4,t4,-1646 # ffffffffc029dc30 <pages>
ffffffffc02022a6:	0009c817          	auipc	a6,0x9c
ffffffffc02022aa:	97a80813          	addi	a6,a6,-1670 # ffffffffc029dc20 <va_pa_offset>
ffffffffc02022ae:	0009c617          	auipc	a2,0x9c
ffffffffc02022b2:	97a60613          	addi	a2,a2,-1670 # ffffffffc029dc28 <npage>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02022b6:	00093023          	sd	zero,0(s2)
        d1start += PDSIZE;
ffffffffc02022ba:	01ba09b3          	add	s3,s4,s11
    } while (d1start != 0 && d1start < end);
ffffffffc02022be:	ea099de3          	bnez	s3,ffffffffc0202178 <exit_range+0x78>
}
ffffffffc02022c2:	70e6                	ld	ra,120(sp)
ffffffffc02022c4:	7446                	ld	s0,112(sp)
ffffffffc02022c6:	74a6                	ld	s1,104(sp)
ffffffffc02022c8:	7906                	ld	s2,96(sp)
ffffffffc02022ca:	69e6                	ld	s3,88(sp)
ffffffffc02022cc:	6a46                	ld	s4,80(sp)
ffffffffc02022ce:	6aa6                	ld	s5,72(sp)
ffffffffc02022d0:	6b06                	ld	s6,64(sp)
ffffffffc02022d2:	7be2                	ld	s7,56(sp)
ffffffffc02022d4:	7c42                	ld	s8,48(sp)
ffffffffc02022d6:	7ca2                	ld	s9,40(sp)
ffffffffc02022d8:	7d02                	ld	s10,32(sp)
ffffffffc02022da:	6de2                	ld	s11,24(sp)
ffffffffc02022dc:	6109                	addi	sp,sp,128
ffffffffc02022de:	8082                	ret
            if (free_pd0) {
ffffffffc02022e0:	e80c8ce3          	beqz	s9,ffffffffc0202178 <exit_range+0x78>
ffffffffc02022e4:	bf51                	j	ffffffffc0202278 <exit_range+0x178>
        intr_disable();
ffffffffc02022e6:	e03a                	sd	a4,0(sp)
ffffffffc02022e8:	e42a                	sd	a0,8(sp)
ffffffffc02022ea:	b56fe0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02022ee:	0009c797          	auipc	a5,0x9c
ffffffffc02022f2:	91a7b783          	ld	a5,-1766(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc02022f6:	739c                	ld	a5,32(a5)
ffffffffc02022f8:	6522                	ld	a0,8(sp)
ffffffffc02022fa:	4585                	li	a1,1
ffffffffc02022fc:	9782                	jalr	a5
        intr_enable();
ffffffffc02022fe:	b3cfe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202302:	6702                	ld	a4,0(sp)
ffffffffc0202304:	0009ce97          	auipc	t4,0x9c
ffffffffc0202308:	92ce8e93          	addi	t4,t4,-1748 # ffffffffc029dc30 <pages>
ffffffffc020230c:	0009c817          	auipc	a6,0x9c
ffffffffc0202310:	91480813          	addi	a6,a6,-1772 # ffffffffc029dc20 <va_pa_offset>
ffffffffc0202314:	0009c617          	auipc	a2,0x9c
ffffffffc0202318:	91460613          	addi	a2,a2,-1772 # ffffffffc029dc28 <npage>
ffffffffc020231c:	6885                	lui	a7,0x1
ffffffffc020231e:	00080337          	lui	t1,0x80
ffffffffc0202322:	fff80e37          	lui	t3,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202326:	00043023          	sd	zero,0(s0)
ffffffffc020232a:	b799                	j	ffffffffc0202270 <exit_range+0x170>
        intr_disable();
ffffffffc020232c:	e02a                	sd	a0,0(sp)
ffffffffc020232e:	b12fe0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202332:	0009c797          	auipc	a5,0x9c
ffffffffc0202336:	8d67b783          	ld	a5,-1834(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc020233a:	739c                	ld	a5,32(a5)
ffffffffc020233c:	6502                	ld	a0,0(sp)
ffffffffc020233e:	4585                	li	a1,1
ffffffffc0202340:	9782                	jalr	a5
        intr_enable();
ffffffffc0202342:	af8fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202346:	0009c617          	auipc	a2,0x9c
ffffffffc020234a:	8e260613          	addi	a2,a2,-1822 # ffffffffc029dc28 <npage>
ffffffffc020234e:	0009c817          	auipc	a6,0x9c
ffffffffc0202352:	8d280813          	addi	a6,a6,-1838 # ffffffffc029dc20 <va_pa_offset>
ffffffffc0202356:	0009ce97          	auipc	t4,0x9c
ffffffffc020235a:	8dae8e93          	addi	t4,t4,-1830 # ffffffffc029dc30 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020235e:	00093023          	sd	zero,0(s2)
ffffffffc0202362:	bfa1                	j	ffffffffc02022ba <exit_range+0x1ba>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202364:	00005697          	auipc	a3,0x5
ffffffffc0202368:	17468693          	addi	a3,a3,372 # ffffffffc02074d8 <etext+0xdcc>
ffffffffc020236c:	00005617          	auipc	a2,0x5
ffffffffc0202370:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202374:	12000593          	li	a1,288
ffffffffc0202378:	00005517          	auipc	a0,0x5
ffffffffc020237c:	15050513          	addi	a0,a0,336 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202380:	8f4fe0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202384:	00005617          	auipc	a2,0x5
ffffffffc0202388:	02c60613          	addi	a2,a2,44 # ffffffffc02073b0 <etext+0xca4>
ffffffffc020238c:	06900593          	li	a1,105
ffffffffc0202390:	00005517          	auipc	a0,0x5
ffffffffc0202394:	04850513          	addi	a0,a0,72 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0202398:	8dcfe0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc020239c:	86de                	mv	a3,s7
ffffffffc020239e:	00005617          	auipc	a2,0x5
ffffffffc02023a2:	01260613          	addi	a2,a2,18 # ffffffffc02073b0 <etext+0xca4>
ffffffffc02023a6:	06900593          	li	a1,105
ffffffffc02023aa:	00005517          	auipc	a0,0x5
ffffffffc02023ae:	02e50513          	addi	a0,a0,46 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02023b2:	8c2fe0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc02023b6:	8b3ff0ef          	jal	ffffffffc0201c68 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023ba:	00005697          	auipc	a3,0x5
ffffffffc02023be:	14e68693          	addi	a3,a3,334 # ffffffffc0207508 <etext+0xdfc>
ffffffffc02023c2:	00005617          	auipc	a2,0x5
ffffffffc02023c6:	9c660613          	addi	a2,a2,-1594 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02023ca:	12100593          	li	a1,289
ffffffffc02023ce:	00005517          	auipc	a0,0x5
ffffffffc02023d2:	0fa50513          	addi	a0,a0,250 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02023d6:	89efe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02023da <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023da:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023dc:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023de:	ec26                	sd	s1,24(sp)
ffffffffc02023e0:	f406                	sd	ra,40(sp)
ffffffffc02023e2:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023e4:	9c7ff0ef          	jal	ffffffffc0201daa <get_pte>
    if (ptep != NULL) {
ffffffffc02023e8:	c901                	beqz	a0,ffffffffc02023f8 <page_remove+0x1e>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023ea:	611c                	ld	a5,0(a0)
ffffffffc02023ec:	f022                	sd	s0,32(sp)
ffffffffc02023ee:	842a                	mv	s0,a0
ffffffffc02023f0:	0017f713          	andi	a4,a5,1
ffffffffc02023f4:	e711                	bnez	a4,ffffffffc0202400 <page_remove+0x26>
ffffffffc02023f6:	7402                	ld	s0,32(sp)
}
ffffffffc02023f8:	70a2                	ld	ra,40(sp)
ffffffffc02023fa:	64e2                	ld	s1,24(sp)
ffffffffc02023fc:	6145                	addi	sp,sp,48
ffffffffc02023fe:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202400:	078a                	slli	a5,a5,0x2
ffffffffc0202402:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202404:	0009c717          	auipc	a4,0x9c
ffffffffc0202408:	82473703          	ld	a4,-2012(a4) # ffffffffc029dc28 <npage>
ffffffffc020240c:	06e7f363          	bgeu	a5,a4,ffffffffc0202472 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202410:	fff80737          	lui	a4,0xfff80
ffffffffc0202414:	97ba                	add	a5,a5,a4
ffffffffc0202416:	079a                	slli	a5,a5,0x6
ffffffffc0202418:	0009c517          	auipc	a0,0x9c
ffffffffc020241c:	81853503          	ld	a0,-2024(a0) # ffffffffc029dc30 <pages>
ffffffffc0202420:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202422:	411c                	lw	a5,0(a0)
ffffffffc0202424:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202428:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020242a:	cb11                	beqz	a4,ffffffffc020243e <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020242c:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202430:	12048073          	sfence.vma	s1
ffffffffc0202434:	7402                	ld	s0,32(sp)
}
ffffffffc0202436:	70a2                	ld	ra,40(sp)
ffffffffc0202438:	64e2                	ld	s1,24(sp)
ffffffffc020243a:	6145                	addi	sp,sp,48
ffffffffc020243c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020243e:	100027f3          	csrr	a5,sstatus
ffffffffc0202442:	8b89                	andi	a5,a5,2
ffffffffc0202444:	eb89                	bnez	a5,ffffffffc0202456 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202446:	0009b797          	auipc	a5,0x9b
ffffffffc020244a:	7c27b783          	ld	a5,1986(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc020244e:	739c                	ld	a5,32(a5)
ffffffffc0202450:	4585                	li	a1,1
ffffffffc0202452:	9782                	jalr	a5
    if (flag) {
ffffffffc0202454:	bfe1                	j	ffffffffc020242c <page_remove+0x52>
        intr_disable();
ffffffffc0202456:	e42a                	sd	a0,8(sp)
ffffffffc0202458:	9e8fe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc020245c:	0009b797          	auipc	a5,0x9b
ffffffffc0202460:	7ac7b783          	ld	a5,1964(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0202464:	739c                	ld	a5,32(a5)
ffffffffc0202466:	6522                	ld	a0,8(sp)
ffffffffc0202468:	4585                	li	a1,1
ffffffffc020246a:	9782                	jalr	a5
        intr_enable();
ffffffffc020246c:	9cefe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202470:	bf75                	j	ffffffffc020242c <page_remove+0x52>
ffffffffc0202472:	ff6ff0ef          	jal	ffffffffc0201c68 <pa2page.part.0>

ffffffffc0202476 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202476:	7139                	addi	sp,sp,-64
ffffffffc0202478:	e852                	sd	s4,16(sp)
ffffffffc020247a:	8a32                	mv	s4,a2
ffffffffc020247c:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020247e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202480:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202482:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202484:	f426                	sd	s1,40(sp)
ffffffffc0202486:	fc06                	sd	ra,56(sp)
ffffffffc0202488:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020248a:	921ff0ef          	jal	ffffffffc0201daa <get_pte>
    if (ptep == NULL) {
ffffffffc020248e:	c971                	beqz	a0,ffffffffc0202562 <page_insert+0xec>
    page->ref += 1;
ffffffffc0202490:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202492:	611c                	ld	a5,0(a0)
ffffffffc0202494:	ec4e                	sd	s3,24(sp)
ffffffffc0202496:	0016871b          	addiw	a4,a3,1
ffffffffc020249a:	c018                	sw	a4,0(s0)
ffffffffc020249c:	0017f713          	andi	a4,a5,1
ffffffffc02024a0:	89aa                	mv	s3,a0
ffffffffc02024a2:	eb15                	bnez	a4,ffffffffc02024d6 <page_insert+0x60>
    return &pages[PPN(pa) - nbase];
ffffffffc02024a4:	0009b717          	auipc	a4,0x9b
ffffffffc02024a8:	78c73703          	ld	a4,1932(a4) # ffffffffc029dc30 <pages>
    return page - pages + nbase;
ffffffffc02024ac:	8c19                	sub	s0,s0,a4
ffffffffc02024ae:	000807b7          	lui	a5,0x80
ffffffffc02024b2:	8419                	srai	s0,s0,0x6
ffffffffc02024b4:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024b6:	042a                	slli	s0,s0,0xa
ffffffffc02024b8:	8cc1                	or	s1,s1,s0
ffffffffc02024ba:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02024be:	0099b023          	sd	s1,0(s3) # 80000 <_binary_obj___user_exit_out_size+0x764a0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024c2:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02024c6:	69e2                	ld	s3,24(sp)
ffffffffc02024c8:	4501                	li	a0,0
}
ffffffffc02024ca:	70e2                	ld	ra,56(sp)
ffffffffc02024cc:	7442                	ld	s0,48(sp)
ffffffffc02024ce:	74a2                	ld	s1,40(sp)
ffffffffc02024d0:	6a42                	ld	s4,16(sp)
ffffffffc02024d2:	6121                	addi	sp,sp,64
ffffffffc02024d4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024d6:	078a                	slli	a5,a5,0x2
ffffffffc02024d8:	f04a                	sd	s2,32(sp)
ffffffffc02024da:	e456                	sd	s5,8(sp)
ffffffffc02024dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024de:	0009b717          	auipc	a4,0x9b
ffffffffc02024e2:	74a73703          	ld	a4,1866(a4) # ffffffffc029dc28 <npage>
ffffffffc02024e6:	08e7f063          	bgeu	a5,a4,ffffffffc0202566 <page_insert+0xf0>
    return &pages[PPN(pa) - nbase];
ffffffffc02024ea:	0009ba97          	auipc	s5,0x9b
ffffffffc02024ee:	746a8a93          	addi	s5,s5,1862 # ffffffffc029dc30 <pages>
ffffffffc02024f2:	000ab703          	ld	a4,0(s5)
ffffffffc02024f6:	fff80637          	lui	a2,0xfff80
ffffffffc02024fa:	00c78933          	add	s2,a5,a2
ffffffffc02024fe:	091a                	slli	s2,s2,0x6
ffffffffc0202500:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202502:	01240e63          	beq	s0,s2,ffffffffc020251e <page_insert+0xa8>
    page->ref -= 1;
ffffffffc0202506:	00092783          	lw	a5,0(s2)
ffffffffc020250a:	fff7869b          	addiw	a3,a5,-1 # 7ffff <_binary_obj___user_exit_out_size+0x7649f>
ffffffffc020250e:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202512:	ca91                	beqz	a3,ffffffffc0202526 <page_insert+0xb0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202514:	120a0073          	sfence.vma	s4
ffffffffc0202518:	7902                	ld	s2,32(sp)
ffffffffc020251a:	6aa2                	ld	s5,8(sp)
}
ffffffffc020251c:	bf41                	j	ffffffffc02024ac <page_insert+0x36>
    return page->ref;
ffffffffc020251e:	7902                	ld	s2,32(sp)
ffffffffc0202520:	6aa2                	ld	s5,8(sp)
    page->ref -= 1;
ffffffffc0202522:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202524:	b761                	j	ffffffffc02024ac <page_insert+0x36>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202526:	100027f3          	csrr	a5,sstatus
ffffffffc020252a:	8b89                	andi	a5,a5,2
ffffffffc020252c:	ef81                	bnez	a5,ffffffffc0202544 <page_insert+0xce>
        pmm_manager->free_pages(base, n);
ffffffffc020252e:	0009b797          	auipc	a5,0x9b
ffffffffc0202532:	6da7b783          	ld	a5,1754(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0202536:	739c                	ld	a5,32(a5)
ffffffffc0202538:	4585                	li	a1,1
ffffffffc020253a:	854a                	mv	a0,s2
ffffffffc020253c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020253e:	000ab703          	ld	a4,0(s5)
ffffffffc0202542:	bfc9                	j	ffffffffc0202514 <page_insert+0x9e>
        intr_disable();
ffffffffc0202544:	8fcfe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202548:	0009b797          	auipc	a5,0x9b
ffffffffc020254c:	6c07b783          	ld	a5,1728(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc0202550:	739c                	ld	a5,32(a5)
ffffffffc0202552:	4585                	li	a1,1
ffffffffc0202554:	854a                	mv	a0,s2
ffffffffc0202556:	9782                	jalr	a5
        intr_enable();
ffffffffc0202558:	8e2fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020255c:	000ab703          	ld	a4,0(s5)
ffffffffc0202560:	bf55                	j	ffffffffc0202514 <page_insert+0x9e>
        return -E_NO_MEM;
ffffffffc0202562:	5571                	li	a0,-4
ffffffffc0202564:	b79d                	j	ffffffffc02024ca <page_insert+0x54>
ffffffffc0202566:	f02ff0ef          	jal	ffffffffc0201c68 <pa2page.part.0>

ffffffffc020256a <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020256a:	00006797          	auipc	a5,0x6
ffffffffc020256e:	54678793          	addi	a5,a5,1350 # ffffffffc0208ab0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202572:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202574:	711d                	addi	sp,sp,-96
ffffffffc0202576:	ec86                	sd	ra,88(sp)
ffffffffc0202578:	e4a6                	sd	s1,72(sp)
ffffffffc020257a:	fc4e                	sd	s3,56(sp)
ffffffffc020257c:	f05a                	sd	s6,32(sp)
ffffffffc020257e:	ec5e                	sd	s7,24(sp)
ffffffffc0202580:	e8a2                	sd	s0,80(sp)
ffffffffc0202582:	e0ca                	sd	s2,64(sp)
ffffffffc0202584:	f852                	sd	s4,48(sp)
ffffffffc0202586:	f456                	sd	s5,40(sp)
ffffffffc0202588:	e862                	sd	s8,16(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020258a:	0009bb97          	auipc	s7,0x9b
ffffffffc020258e:	67eb8b93          	addi	s7,s7,1662 # ffffffffc029dc08 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202592:	00005517          	auipc	a0,0x5
ffffffffc0202596:	f8e50513          	addi	a0,a0,-114 # ffffffffc0207520 <etext+0xe14>
    pmm_manager = &default_pmm_manager;
ffffffffc020259a:	00fbb023          	sd	a5,0(s7)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020259e:	be3fd0ef          	jal	ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc02025a2:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025a6:	0009b997          	auipc	s3,0x9b
ffffffffc02025aa:	67a98993          	addi	s3,s3,1658 # ffffffffc029dc20 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02025ae:	0009b497          	auipc	s1,0x9b
ffffffffc02025b2:	67a48493          	addi	s1,s1,1658 # ffffffffc029dc28 <npage>
    pmm_manager->init();
ffffffffc02025b6:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025b8:	0009bb17          	auipc	s6,0x9b
ffffffffc02025bc:	678b0b13          	addi	s6,s6,1656 # ffffffffc029dc30 <pages>
    pmm_manager->init();
ffffffffc02025c0:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025c2:	57f5                	li	a5,-3
ffffffffc02025c4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02025c6:	00005517          	auipc	a0,0x5
ffffffffc02025ca:	f7250513          	addi	a0,a0,-142 # ffffffffc0207538 <etext+0xe2c>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025ce:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02025d2:	baffd0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02025d6:	46c5                	li	a3,17
ffffffffc02025d8:	06ee                	slli	a3,a3,0x1b
ffffffffc02025da:	40100613          	li	a2,1025
ffffffffc02025de:	16fd                	addi	a3,a3,-1
ffffffffc02025e0:	0656                	slli	a2,a2,0x15
ffffffffc02025e2:	07e005b7          	lui	a1,0x7e00
ffffffffc02025e6:	00005517          	auipc	a0,0x5
ffffffffc02025ea:	f6a50513          	addi	a0,a0,-150 # ffffffffc0207550 <etext+0xe44>
ffffffffc02025ee:	b93fd0ef          	jal	ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025f2:	777d                	lui	a4,0xfffff
ffffffffc02025f4:	0009c797          	auipc	a5,0x9c
ffffffffc02025f8:	68b78793          	addi	a5,a5,1675 # ffffffffc029ec7f <end+0xfff>
ffffffffc02025fc:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02025fe:	00088737          	lui	a4,0x88
ffffffffc0202602:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202604:	00fb3023          	sd	a5,0(s6)
ffffffffc0202608:	4705                	li	a4,1
ffffffffc020260a:	07a1                	addi	a5,a5,8
ffffffffc020260c:	40e7b02f          	amoor.d	zero,a4,(a5)
ffffffffc0202610:	4505                	li	a0,1
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202612:	fff805b7          	lui	a1,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202616:	000b3783          	ld	a5,0(s6)
ffffffffc020261a:	00671693          	slli	a3,a4,0x6
ffffffffc020261e:	97b6                	add	a5,a5,a3
ffffffffc0202620:	07a1                	addi	a5,a5,8
ffffffffc0202622:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202626:	6090                	ld	a2,0(s1)
ffffffffc0202628:	0705                	addi	a4,a4,1 # 88001 <_binary_obj___user_exit_out_size+0x7e4a1>
ffffffffc020262a:	00b607b3          	add	a5,a2,a1
ffffffffc020262e:	fef764e3          	bltu	a4,a5,ffffffffc0202616 <pmm_init+0xac>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202632:	000b3503          	ld	a0,0(s6)
ffffffffc0202636:	079a                	slli	a5,a5,0x6
ffffffffc0202638:	c0200737          	lui	a4,0xc0200
ffffffffc020263c:	00f506b3          	add	a3,a0,a5
ffffffffc0202640:	60e6e463          	bltu	a3,a4,ffffffffc0202c48 <pmm_init+0x6de>
ffffffffc0202644:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202648:	4745                	li	a4,17
ffffffffc020264a:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020264c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020264e:	4ae6e363          	bltu	a3,a4,ffffffffc0202af4 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202652:	00005517          	auipc	a0,0x5
ffffffffc0202656:	f2650513          	addi	a0,a0,-218 # ffffffffc0207578 <etext+0xe6c>
ffffffffc020265a:	b27fd0ef          	jal	ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020265e:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202662:	0009b917          	auipc	s2,0x9b
ffffffffc0202666:	5b690913          	addi	s2,s2,1462 # ffffffffc029dc18 <boot_pgdir>
    pmm_manager->check();
ffffffffc020266a:	7b9c                	ld	a5,48(a5)
ffffffffc020266c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020266e:	00005517          	auipc	a0,0x5
ffffffffc0202672:	f2250513          	addi	a0,a0,-222 # ffffffffc0207590 <etext+0xe84>
ffffffffc0202676:	b0bfd0ef          	jal	ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020267a:	00009697          	auipc	a3,0x9
ffffffffc020267e:	98668693          	addi	a3,a3,-1658 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202682:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202686:	c02007b7          	lui	a5,0xc0200
ffffffffc020268a:	5cf6eb63          	bltu	a3,a5,ffffffffc0202c60 <pmm_init+0x6f6>
ffffffffc020268e:	0009b783          	ld	a5,0(s3)
ffffffffc0202692:	8e9d                	sub	a3,a3,a5
ffffffffc0202694:	0009b797          	auipc	a5,0x9b
ffffffffc0202698:	56d7be23          	sd	a3,1404(a5) # ffffffffc029dc10 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020269c:	100027f3          	csrr	a5,sstatus
ffffffffc02026a0:	8b89                	andi	a5,a5,2
ffffffffc02026a2:	48079163          	bnez	a5,ffffffffc0202b24 <pmm_init+0x5ba>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026a6:	000bb783          	ld	a5,0(s7)
ffffffffc02026aa:	779c                	ld	a5,40(a5)
ffffffffc02026ac:	9782                	jalr	a5
ffffffffc02026ae:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02026b0:	6098                	ld	a4,0(s1)
ffffffffc02026b2:	c80007b7          	lui	a5,0xc8000
ffffffffc02026b6:	83b1                	srli	a5,a5,0xc
ffffffffc02026b8:	5ee7e063          	bltu	a5,a4,ffffffffc0202c98 <pmm_init+0x72e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026bc:	00093503          	ld	a0,0(s2)
ffffffffc02026c0:	5a050c63          	beqz	a0,ffffffffc0202c78 <pmm_init+0x70e>
ffffffffc02026c4:	03451793          	slli	a5,a0,0x34
ffffffffc02026c8:	5a079863          	bnez	a5,ffffffffc0202c78 <pmm_init+0x70e>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026cc:	4601                	li	a2,0
ffffffffc02026ce:	4581                	li	a1,0
ffffffffc02026d0:	8b3ff0ef          	jal	ffffffffc0201f82 <get_page>
ffffffffc02026d4:	62051463          	bnez	a0,ffffffffc0202cfc <pmm_init+0x792>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02026d8:	4505                	li	a0,1
ffffffffc02026da:	dc6ff0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc02026de:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026e0:	00093503          	ld	a0,0(s2)
ffffffffc02026e4:	4681                	li	a3,0
ffffffffc02026e6:	4601                	li	a2,0
ffffffffc02026e8:	85d2                	mv	a1,s4
ffffffffc02026ea:	d8dff0ef          	jal	ffffffffc0202476 <page_insert>
ffffffffc02026ee:	5e051763          	bnez	a0,ffffffffc0202cdc <pmm_init+0x772>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02026f2:	00093503          	ld	a0,0(s2)
ffffffffc02026f6:	4601                	li	a2,0
ffffffffc02026f8:	4581                	li	a1,0
ffffffffc02026fa:	eb0ff0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc02026fe:	5a050f63          	beqz	a0,ffffffffc0202cbc <pmm_init+0x752>
    assert(pte2page(*ptep) == p1);
ffffffffc0202702:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202704:	0017f713          	andi	a4,a5,1
ffffffffc0202708:	5a070863          	beqz	a4,ffffffffc0202cb8 <pmm_init+0x74e>
    if (PPN(pa) >= npage) {
ffffffffc020270c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020270e:	078a                	slli	a5,a5,0x2
ffffffffc0202710:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202712:	52e7f963          	bgeu	a5,a4,ffffffffc0202c44 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202716:	000b3683          	ld	a3,0(s6)
ffffffffc020271a:	fff80637          	lui	a2,0xfff80
ffffffffc020271e:	97b2                	add	a5,a5,a2
ffffffffc0202720:	079a                	slli	a5,a5,0x6
ffffffffc0202722:	97b6                	add	a5,a5,a3
ffffffffc0202724:	10fa15e3          	bne	s4,a5,ffffffffc020302e <pmm_init+0xac4>
    assert(page_ref(p1) == 1);
ffffffffc0202728:	000a2683          	lw	a3,0(s4) # 40000000 <_binary_obj___user_exit_out_size+0x3fff64a0>
ffffffffc020272c:	4785                	li	a5,1
ffffffffc020272e:	12f69ce3          	bne	a3,a5,ffffffffc0203066 <pmm_init+0xafc>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202732:	00093503          	ld	a0,0(s2)
ffffffffc0202736:	77fd                	lui	a5,0xfffff
ffffffffc0202738:	6114                	ld	a3,0(a0)
ffffffffc020273a:	068a                	slli	a3,a3,0x2
ffffffffc020273c:	8efd                	and	a3,a3,a5
ffffffffc020273e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202742:	10e676e3          	bgeu	a2,a4,ffffffffc020304e <pmm_init+0xae4>
ffffffffc0202746:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020274a:	96e2                	add	a3,a3,s8
ffffffffc020274c:	0006ba83          	ld	s5,0(a3)
ffffffffc0202750:	0a8a                	slli	s5,s5,0x2
ffffffffc0202752:	00fafab3          	and	s5,s5,a5
ffffffffc0202756:	00cad793          	srli	a5,s5,0xc
ffffffffc020275a:	62e7f163          	bgeu	a5,a4,ffffffffc0202d7c <pmm_init+0x812>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020275e:	4601                	li	a2,0
ffffffffc0202760:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202762:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202764:	e46ff0ef          	jal	ffffffffc0201daa <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202768:	0c21                	addi	s8,s8,8 # 200008 <_binary_obj___user_exit_out_size+0x1f64a8>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020276a:	5f851963          	bne	a0,s8,ffffffffc0202d5c <pmm_init+0x7f2>

    p2 = alloc_page();
ffffffffc020276e:	4505                	li	a0,1
ffffffffc0202770:	d30ff0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0202774:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202776:	00093503          	ld	a0,0(s2)
ffffffffc020277a:	46d1                	li	a3,20
ffffffffc020277c:	6605                	lui	a2,0x1
ffffffffc020277e:	85d6                	mv	a1,s5
ffffffffc0202780:	cf7ff0ef          	jal	ffffffffc0202476 <page_insert>
ffffffffc0202784:	58051c63          	bnez	a0,ffffffffc0202d1c <pmm_init+0x7b2>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202788:	00093503          	ld	a0,0(s2)
ffffffffc020278c:	4601                	li	a2,0
ffffffffc020278e:	6585                	lui	a1,0x1
ffffffffc0202790:	e1aff0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc0202794:	0e0509e3          	beqz	a0,ffffffffc0203086 <pmm_init+0xb1c>
    assert(*ptep & PTE_U);
ffffffffc0202798:	611c                	ld	a5,0(a0)
ffffffffc020279a:	0107f713          	andi	a4,a5,16
ffffffffc020279e:	6e070c63          	beqz	a4,ffffffffc0202e96 <pmm_init+0x92c>
    assert(*ptep & PTE_W);
ffffffffc02027a2:	8b91                	andi	a5,a5,4
ffffffffc02027a4:	6a078963          	beqz	a5,ffffffffc0202e56 <pmm_init+0x8ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027a8:	00093503          	ld	a0,0(s2)
ffffffffc02027ac:	611c                	ld	a5,0(a0)
ffffffffc02027ae:	8bc1                	andi	a5,a5,16
ffffffffc02027b0:	68078363          	beqz	a5,ffffffffc0202e36 <pmm_init+0x8cc>
    assert(page_ref(p2) == 1);
ffffffffc02027b4:	000aa703          	lw	a4,0(s5)
ffffffffc02027b8:	4785                	li	a5,1
ffffffffc02027ba:	58f71163          	bne	a4,a5,ffffffffc0202d3c <pmm_init+0x7d2>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027be:	4681                	li	a3,0
ffffffffc02027c0:	6605                	lui	a2,0x1
ffffffffc02027c2:	85d2                	mv	a1,s4
ffffffffc02027c4:	cb3ff0ef          	jal	ffffffffc0202476 <page_insert>
ffffffffc02027c8:	62051763          	bnez	a0,ffffffffc0202df6 <pmm_init+0x88c>
    assert(page_ref(p1) == 2);
ffffffffc02027cc:	000a2703          	lw	a4,0(s4)
ffffffffc02027d0:	4789                	li	a5,2
ffffffffc02027d2:	60f71263          	bne	a4,a5,ffffffffc0202dd6 <pmm_init+0x86c>
    assert(page_ref(p2) == 0);
ffffffffc02027d6:	000aa783          	lw	a5,0(s5)
ffffffffc02027da:	5c079e63          	bnez	a5,ffffffffc0202db6 <pmm_init+0x84c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027de:	00093503          	ld	a0,0(s2)
ffffffffc02027e2:	4601                	li	a2,0
ffffffffc02027e4:	6585                	lui	a1,0x1
ffffffffc02027e6:	dc4ff0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc02027ea:	5a050663          	beqz	a0,ffffffffc0202d96 <pmm_init+0x82c>
    assert(pte2page(*ptep) == p1);
ffffffffc02027ee:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027f0:	00177793          	andi	a5,a4,1
ffffffffc02027f4:	4c078263          	beqz	a5,ffffffffc0202cb8 <pmm_init+0x74e>
    if (PPN(pa) >= npage) {
ffffffffc02027f8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027fa:	00271793          	slli	a5,a4,0x2
ffffffffc02027fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202800:	44d7f263          	bgeu	a5,a3,ffffffffc0202c44 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202804:	000b3683          	ld	a3,0(s6)
ffffffffc0202808:	fff80637          	lui	a2,0xfff80
ffffffffc020280c:	97b2                	add	a5,a5,a2
ffffffffc020280e:	079a                	slli	a5,a5,0x6
ffffffffc0202810:	97b6                	add	a5,a5,a3
ffffffffc0202812:	6efa1263          	bne	s4,a5,ffffffffc0202ef6 <pmm_init+0x98c>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202816:	8b41                	andi	a4,a4,16
ffffffffc0202818:	6a071f63          	bnez	a4,ffffffffc0202ed6 <pmm_init+0x96c>

    page_remove(boot_pgdir, 0x0);
ffffffffc020281c:	00093503          	ld	a0,0(s2)
ffffffffc0202820:	4581                	li	a1,0
ffffffffc0202822:	bb9ff0ef          	jal	ffffffffc02023da <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202826:	000a2703          	lw	a4,0(s4)
ffffffffc020282a:	4785                	li	a5,1
ffffffffc020282c:	68f71563          	bne	a4,a5,ffffffffc0202eb6 <pmm_init+0x94c>
    assert(page_ref(p2) == 0);
ffffffffc0202830:	000aa783          	lw	a5,0(s5)
ffffffffc0202834:	74079d63          	bnez	a5,ffffffffc0202f8e <pmm_init+0xa24>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202838:	00093503          	ld	a0,0(s2)
ffffffffc020283c:	6585                	lui	a1,0x1
ffffffffc020283e:	b9dff0ef          	jal	ffffffffc02023da <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202842:	000a2783          	lw	a5,0(s4)
ffffffffc0202846:	72079463          	bnez	a5,ffffffffc0202f6e <pmm_init+0xa04>
    assert(page_ref(p2) == 0);
ffffffffc020284a:	000aa783          	lw	a5,0(s5)
ffffffffc020284e:	70079063          	bnez	a5,ffffffffc0202f4e <pmm_init+0x9e4>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202852:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202856:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202858:	000a3783          	ld	a5,0(s4)
ffffffffc020285c:	078a                	slli	a5,a5,0x2
ffffffffc020285e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202860:	3ee7f263          	bgeu	a5,a4,ffffffffc0202c44 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202864:	fff806b7          	lui	a3,0xfff80
ffffffffc0202868:	000b3503          	ld	a0,0(s6)
ffffffffc020286c:	97b6                	add	a5,a5,a3
ffffffffc020286e:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202870:	00f506b3          	add	a3,a0,a5
ffffffffc0202874:	4290                	lw	a2,0(a3)
ffffffffc0202876:	4685                	li	a3,1
ffffffffc0202878:	6ad61b63          	bne	a2,a3,ffffffffc0202f2e <pmm_init+0x9c4>
    return page - pages + nbase;
ffffffffc020287c:	8799                	srai	a5,a5,0x6
ffffffffc020287e:	00080637          	lui	a2,0x80
ffffffffc0202882:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202884:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202888:	68e7f763          	bgeu	a5,a4,ffffffffc0202f16 <pmm_init+0x9ac>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020288c:	0009b783          	ld	a5,0(s3)
ffffffffc0202890:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202892:	639c                	ld	a5,0(a5)
ffffffffc0202894:	078a                	slli	a5,a5,0x2
ffffffffc0202896:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202898:	3ae7f663          	bgeu	a5,a4,ffffffffc0202c44 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc020289c:	8f91                	sub	a5,a5,a2
ffffffffc020289e:	079a                	slli	a5,a5,0x6
ffffffffc02028a0:	953e                	add	a0,a0,a5
ffffffffc02028a2:	100027f3          	csrr	a5,sstatus
ffffffffc02028a6:	8b89                	andi	a5,a5,2
ffffffffc02028a8:	2c079863          	bnez	a5,ffffffffc0202b78 <pmm_init+0x60e>
        pmm_manager->free_pages(base, n);
ffffffffc02028ac:	000bb783          	ld	a5,0(s7)
ffffffffc02028b0:	4585                	li	a1,1
ffffffffc02028b2:	739c                	ld	a5,32(a5)
ffffffffc02028b4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02028b6:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02028ba:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028bc:	078a                	slli	a5,a5,0x2
ffffffffc02028be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028c0:	38e7f263          	bgeu	a5,a4,ffffffffc0202c44 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc02028c4:	000b3503          	ld	a0,0(s6)
ffffffffc02028c8:	fff80737          	lui	a4,0xfff80
ffffffffc02028cc:	97ba                	add	a5,a5,a4
ffffffffc02028ce:	079a                	slli	a5,a5,0x6
ffffffffc02028d0:	953e                	add	a0,a0,a5
ffffffffc02028d2:	100027f3          	csrr	a5,sstatus
ffffffffc02028d6:	8b89                	andi	a5,a5,2
ffffffffc02028d8:	28079463          	bnez	a5,ffffffffc0202b60 <pmm_init+0x5f6>
ffffffffc02028dc:	000bb783          	ld	a5,0(s7)
ffffffffc02028e0:	4585                	li	a1,1
ffffffffc02028e2:	739c                	ld	a5,32(a5)
ffffffffc02028e4:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028e6:	00093783          	ld	a5,0(s2)
ffffffffc02028ea:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd61380>
  asm volatile("sfence.vma");
ffffffffc02028ee:	12000073          	sfence.vma
ffffffffc02028f2:	100027f3          	csrr	a5,sstatus
ffffffffc02028f6:	8b89                	andi	a5,a5,2
ffffffffc02028f8:	24079a63          	bnez	a5,ffffffffc0202b4c <pmm_init+0x5e2>
        ret = pmm_manager->nr_free_pages();
ffffffffc02028fc:	000bb783          	ld	a5,0(s7)
ffffffffc0202900:	779c                	ld	a5,40(a5)
ffffffffc0202902:	9782                	jalr	a5
ffffffffc0202904:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202906:	71441463          	bne	s0,s4,ffffffffc020300e <pmm_init+0xaa4>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020290a:	00005517          	auipc	a0,0x5
ffffffffc020290e:	f6e50513          	addi	a0,a0,-146 # ffffffffc0207878 <etext+0x116c>
ffffffffc0202912:	86ffd0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc0202916:	100027f3          	csrr	a5,sstatus
ffffffffc020291a:	8b89                	andi	a5,a5,2
ffffffffc020291c:	20079e63          	bnez	a5,ffffffffc0202b38 <pmm_init+0x5ce>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202920:	000bb783          	ld	a5,0(s7)
ffffffffc0202924:	779c                	ld	a5,40(a5)
ffffffffc0202926:	9782                	jalr	a5
ffffffffc0202928:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020292a:	6098                	ld	a4,0(s1)
ffffffffc020292c:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202930:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202932:	00c71793          	slli	a5,a4,0xc
ffffffffc0202936:	6a05                	lui	s4,0x1
ffffffffc0202938:	02f47c63          	bgeu	s0,a5,ffffffffc0202970 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020293c:	00c45793          	srli	a5,s0,0xc
ffffffffc0202940:	00093503          	ld	a0,0(s2)
ffffffffc0202944:	2ee7f363          	bgeu	a5,a4,ffffffffc0202c2a <pmm_init+0x6c0>
ffffffffc0202948:	0009b583          	ld	a1,0(s3)
ffffffffc020294c:	4601                	li	a2,0
ffffffffc020294e:	95a2                	add	a1,a1,s0
ffffffffc0202950:	c5aff0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc0202954:	2a050b63          	beqz	a0,ffffffffc0202c0a <pmm_init+0x6a0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202958:	611c                	ld	a5,0(a0)
ffffffffc020295a:	078a                	slli	a5,a5,0x2
ffffffffc020295c:	0157f7b3          	and	a5,a5,s5
ffffffffc0202960:	28879563          	bne	a5,s0,ffffffffc0202bea <pmm_init+0x680>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202964:	6098                	ld	a4,0(s1)
ffffffffc0202966:	9452                	add	s0,s0,s4
ffffffffc0202968:	00c71793          	slli	a5,a4,0xc
ffffffffc020296c:	fcf468e3          	bltu	s0,a5,ffffffffc020293c <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202970:	00093783          	ld	a5,0(s2)
ffffffffc0202974:	639c                	ld	a5,0(a5)
ffffffffc0202976:	66079c63          	bnez	a5,ffffffffc0202fee <pmm_init+0xa84>

    struct Page *p;
    p = alloc_page();
ffffffffc020297a:	4505                	li	a0,1
ffffffffc020297c:	b24ff0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0202980:	842a                	mv	s0,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202982:	00093503          	ld	a0,0(s2)
ffffffffc0202986:	4699                	li	a3,6
ffffffffc0202988:	10000613          	li	a2,256
ffffffffc020298c:	85a2                	mv	a1,s0
ffffffffc020298e:	ae9ff0ef          	jal	ffffffffc0202476 <page_insert>
ffffffffc0202992:	62051e63          	bnez	a0,ffffffffc0202fce <pmm_init+0xa64>
    assert(page_ref(p) == 1);
ffffffffc0202996:	4018                	lw	a4,0(s0)
ffffffffc0202998:	4785                	li	a5,1
ffffffffc020299a:	60f71a63          	bne	a4,a5,ffffffffc0202fae <pmm_init+0xa44>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020299e:	00093503          	ld	a0,0(s2)
ffffffffc02029a2:	6605                	lui	a2,0x1
ffffffffc02029a4:	4699                	li	a3,6
ffffffffc02029a6:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x74f8>
ffffffffc02029aa:	85a2                	mv	a1,s0
ffffffffc02029ac:	acbff0ef          	jal	ffffffffc0202476 <page_insert>
ffffffffc02029b0:	46051363          	bnez	a0,ffffffffc0202e16 <pmm_init+0x8ac>
    assert(page_ref(p) == 2);
ffffffffc02029b4:	4018                	lw	a4,0(s0)
ffffffffc02029b6:	4789                	li	a5,2
ffffffffc02029b8:	72f71763          	bne	a4,a5,ffffffffc02030e6 <pmm_init+0xb7c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02029bc:	00005597          	auipc	a1,0x5
ffffffffc02029c0:	ff458593          	addi	a1,a1,-12 # ffffffffc02079b0 <etext+0x12a4>
ffffffffc02029c4:	10000513          	li	a0,256
ffffffffc02029c8:	4bb030ef          	jal	ffffffffc0206682 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02029cc:	6585                	lui	a1,0x1
ffffffffc02029ce:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x74f8>
ffffffffc02029d2:	10000513          	li	a0,256
ffffffffc02029d6:	4bf030ef          	jal	ffffffffc0206694 <strcmp>
ffffffffc02029da:	6e051663          	bnez	a0,ffffffffc02030c6 <pmm_init+0xb5c>
    return page - pages + nbase;
ffffffffc02029de:	000b3683          	ld	a3,0(s6)
ffffffffc02029e2:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc02029e6:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc02029e8:	40d406b3          	sub	a3,s0,a3
ffffffffc02029ec:	8699                	srai	a3,a3,0x6
ffffffffc02029ee:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02029f0:	00c69793          	slli	a5,a3,0xc
ffffffffc02029f4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029f6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029f8:	50e7ff63          	bgeu	a5,a4,ffffffffc0202f16 <pmm_init+0x9ac>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02029fc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a00:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a04:	97b6                	add	a5,a5,a3
ffffffffc0202a06:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_exit_out_size+0x765a0>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a0a:	443030ef          	jal	ffffffffc020664c <strlen>
ffffffffc0202a0e:	68051c63          	bnez	a0,ffffffffc02030a6 <pmm_init+0xb3c>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a12:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a16:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a18:	000a3783          	ld	a5,0(s4) # 1000 <_binary_obj___user_softint_out_size-0x75f8>
ffffffffc0202a1c:	078a                	slli	a5,a5,0x2
ffffffffc0202a1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a20:	22e7f263          	bgeu	a5,a4,ffffffffc0202c44 <pmm_init+0x6da>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a24:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202a28:	4ee7f763          	bgeu	a5,a4,ffffffffc0202f16 <pmm_init+0x9ac>
ffffffffc0202a2c:	0009b783          	ld	a5,0(s3)
ffffffffc0202a30:	00f689b3          	add	s3,a3,a5
ffffffffc0202a34:	100027f3          	csrr	a5,sstatus
ffffffffc0202a38:	8b89                	andi	a5,a5,2
ffffffffc0202a3a:	18079d63          	bnez	a5,ffffffffc0202bd4 <pmm_init+0x66a>
        pmm_manager->free_pages(base, n);
ffffffffc0202a3e:	000bb783          	ld	a5,0(s7)
ffffffffc0202a42:	4585                	li	a1,1
ffffffffc0202a44:	8522                	mv	a0,s0
ffffffffc0202a46:	739c                	ld	a5,32(a5)
ffffffffc0202a48:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a4a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202a4e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a50:	078a                	slli	a5,a5,0x2
ffffffffc0202a52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a54:	1ee7f863          	bgeu	a5,a4,ffffffffc0202c44 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a58:	000b3503          	ld	a0,0(s6)
ffffffffc0202a5c:	fff80737          	lui	a4,0xfff80
ffffffffc0202a60:	97ba                	add	a5,a5,a4
ffffffffc0202a62:	079a                	slli	a5,a5,0x6
ffffffffc0202a64:	953e                	add	a0,a0,a5
ffffffffc0202a66:	100027f3          	csrr	a5,sstatus
ffffffffc0202a6a:	8b89                	andi	a5,a5,2
ffffffffc0202a6c:	14079863          	bnez	a5,ffffffffc0202bbc <pmm_init+0x652>
ffffffffc0202a70:	000bb783          	ld	a5,0(s7)
ffffffffc0202a74:	4585                	li	a1,1
ffffffffc0202a76:	739c                	ld	a5,32(a5)
ffffffffc0202a78:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a7a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a7e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a80:	078a                	slli	a5,a5,0x2
ffffffffc0202a82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a84:	1ce7f063          	bgeu	a5,a4,ffffffffc0202c44 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a88:	000b3503          	ld	a0,0(s6)
ffffffffc0202a8c:	fff80737          	lui	a4,0xfff80
ffffffffc0202a90:	97ba                	add	a5,a5,a4
ffffffffc0202a92:	079a                	slli	a5,a5,0x6
ffffffffc0202a94:	953e                	add	a0,a0,a5
ffffffffc0202a96:	100027f3          	csrr	a5,sstatus
ffffffffc0202a9a:	8b89                	andi	a5,a5,2
ffffffffc0202a9c:	10079463          	bnez	a5,ffffffffc0202ba4 <pmm_init+0x63a>
ffffffffc0202aa0:	000bb783          	ld	a5,0(s7)
ffffffffc0202aa4:	4585                	li	a1,1
ffffffffc0202aa6:	739c                	ld	a5,32(a5)
ffffffffc0202aa8:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202aaa:	00093783          	ld	a5,0(s2)
ffffffffc0202aae:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202ab2:	12000073          	sfence.vma
ffffffffc0202ab6:	100027f3          	csrr	a5,sstatus
ffffffffc0202aba:	8b89                	andi	a5,a5,2
ffffffffc0202abc:	0c079a63          	bnez	a5,ffffffffc0202b90 <pmm_init+0x626>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ac0:	000bb783          	ld	a5,0(s7)
ffffffffc0202ac4:	779c                	ld	a5,40(a5)
ffffffffc0202ac6:	9782                	jalr	a5
ffffffffc0202ac8:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202aca:	3a8c1663          	bne	s8,s0,ffffffffc0202e76 <pmm_init+0x90c>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202ace:	00005517          	auipc	a0,0x5
ffffffffc0202ad2:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207a28 <etext+0x131c>
ffffffffc0202ad6:	eaafd0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc0202ada:	6446                	ld	s0,80(sp)
ffffffffc0202adc:	60e6                	ld	ra,88(sp)
ffffffffc0202ade:	64a6                	ld	s1,72(sp)
ffffffffc0202ae0:	6906                	ld	s2,64(sp)
ffffffffc0202ae2:	79e2                	ld	s3,56(sp)
ffffffffc0202ae4:	7a42                	ld	s4,48(sp)
ffffffffc0202ae6:	7aa2                	ld	s5,40(sp)
ffffffffc0202ae8:	7b02                	ld	s6,32(sp)
ffffffffc0202aea:	6be2                	ld	s7,24(sp)
ffffffffc0202aec:	6c42                	ld	s8,16(sp)
ffffffffc0202aee:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202af0:	fb5fe06f          	j	ffffffffc0201aa4 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202af4:	6785                	lui	a5,0x1
ffffffffc0202af6:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x75f9>
ffffffffc0202af8:	96be                	add	a3,a3,a5
ffffffffc0202afa:	77fd                	lui	a5,0xfffff
ffffffffc0202afc:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202afe:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202b02:	14c6f163          	bgeu	a3,a2,ffffffffc0202c44 <pmm_init+0x6da>
    pmm_manager->init_memmap(base, n);
ffffffffc0202b06:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202b0a:	fff805b7          	lui	a1,0xfff80
ffffffffc0202b0e:	96ae                	add	a3,a3,a1
ffffffffc0202b10:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202b12:	8f1d                	sub	a4,a4,a5
ffffffffc0202b14:	069a                	slli	a3,a3,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202b16:	00c75593          	srli	a1,a4,0xc
ffffffffc0202b1a:	9536                	add	a0,a0,a3
ffffffffc0202b1c:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202b1e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202b22:	be05                	j	ffffffffc0202652 <pmm_init+0xe8>
        intr_disable();
ffffffffc0202b24:	b1dfd0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b28:	000bb783          	ld	a5,0(s7)
ffffffffc0202b2c:	779c                	ld	a5,40(a5)
ffffffffc0202b2e:	9782                	jalr	a5
ffffffffc0202b30:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b32:	b09fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b36:	bead                	j	ffffffffc02026b0 <pmm_init+0x146>
        intr_disable();
ffffffffc0202b38:	b09fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202b3c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b40:	779c                	ld	a5,40(a5)
ffffffffc0202b42:	9782                	jalr	a5
ffffffffc0202b44:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b46:	af5fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b4a:	b3c5                	j	ffffffffc020292a <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202b4c:	af5fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202b50:	000bb783          	ld	a5,0(s7)
ffffffffc0202b54:	779c                	ld	a5,40(a5)
ffffffffc0202b56:	9782                	jalr	a5
ffffffffc0202b58:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b5a:	ae1fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b5e:	b365                	j	ffffffffc0202906 <pmm_init+0x39c>
ffffffffc0202b60:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b62:	adffd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b66:	000bb783          	ld	a5,0(s7)
ffffffffc0202b6a:	6522                	ld	a0,8(sp)
ffffffffc0202b6c:	4585                	li	a1,1
ffffffffc0202b6e:	739c                	ld	a5,32(a5)
ffffffffc0202b70:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b72:	ac9fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b76:	bb85                	j	ffffffffc02028e6 <pmm_init+0x37c>
ffffffffc0202b78:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b7a:	ac7fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202b7e:	000bb783          	ld	a5,0(s7)
ffffffffc0202b82:	6522                	ld	a0,8(sp)
ffffffffc0202b84:	4585                	li	a1,1
ffffffffc0202b86:	739c                	ld	a5,32(a5)
ffffffffc0202b88:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b8a:	ab1fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b8e:	b325                	j	ffffffffc02028b6 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202b90:	ab1fd0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b94:	000bb783          	ld	a5,0(s7)
ffffffffc0202b98:	779c                	ld	a5,40(a5)
ffffffffc0202b9a:	9782                	jalr	a5
ffffffffc0202b9c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b9e:	a9dfd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202ba2:	b725                	j	ffffffffc0202aca <pmm_init+0x560>
ffffffffc0202ba4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ba6:	a9bfd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202baa:	000bb783          	ld	a5,0(s7)
ffffffffc0202bae:	6522                	ld	a0,8(sp)
ffffffffc0202bb0:	4585                	li	a1,1
ffffffffc0202bb2:	739c                	ld	a5,32(a5)
ffffffffc0202bb4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bb6:	a85fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202bba:	bdc5                	j	ffffffffc0202aaa <pmm_init+0x540>
ffffffffc0202bbc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bbe:	a83fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202bc2:	000bb783          	ld	a5,0(s7)
ffffffffc0202bc6:	6522                	ld	a0,8(sp)
ffffffffc0202bc8:	4585                	li	a1,1
ffffffffc0202bca:	739c                	ld	a5,32(a5)
ffffffffc0202bcc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bce:	a6dfd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202bd2:	b565                	j	ffffffffc0202a7a <pmm_init+0x510>
        intr_disable();
ffffffffc0202bd4:	a6dfd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202bd8:	000bb783          	ld	a5,0(s7)
ffffffffc0202bdc:	4585                	li	a1,1
ffffffffc0202bde:	8522                	mv	a0,s0
ffffffffc0202be0:	739c                	ld	a5,32(a5)
ffffffffc0202be2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202be4:	a57fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202be8:	b58d                	j	ffffffffc0202a4a <pmm_init+0x4e0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bea:	00005697          	auipc	a3,0x5
ffffffffc0202bee:	cee68693          	addi	a3,a3,-786 # ffffffffc02078d8 <etext+0x11cc>
ffffffffc0202bf2:	00004617          	auipc	a2,0x4
ffffffffc0202bf6:	19660613          	addi	a2,a2,406 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202bfa:	23b00593          	li	a1,571
ffffffffc0202bfe:	00005517          	auipc	a0,0x5
ffffffffc0202c02:	8ca50513          	addi	a0,a0,-1846 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202c06:	86ffd0ef          	jal	ffffffffc0200474 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c0a:	00005697          	auipc	a3,0x5
ffffffffc0202c0e:	c8e68693          	addi	a3,a3,-882 # ffffffffc0207898 <etext+0x118c>
ffffffffc0202c12:	00004617          	auipc	a2,0x4
ffffffffc0202c16:	17660613          	addi	a2,a2,374 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202c1a:	23a00593          	li	a1,570
ffffffffc0202c1e:	00005517          	auipc	a0,0x5
ffffffffc0202c22:	8aa50513          	addi	a0,a0,-1878 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202c26:	84ffd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0202c2a:	86a2                	mv	a3,s0
ffffffffc0202c2c:	00004617          	auipc	a2,0x4
ffffffffc0202c30:	78460613          	addi	a2,a2,1924 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0202c34:	23a00593          	li	a1,570
ffffffffc0202c38:	00005517          	auipc	a0,0x5
ffffffffc0202c3c:	89050513          	addi	a0,a0,-1904 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202c40:	835fd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0202c44:	824ff0ef          	jal	ffffffffc0201c68 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c48:	00005617          	auipc	a2,0x5
ffffffffc0202c4c:	81060613          	addi	a2,a2,-2032 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0202c50:	07f00593          	li	a1,127
ffffffffc0202c54:	00005517          	auipc	a0,0x5
ffffffffc0202c58:	87450513          	addi	a0,a0,-1932 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202c5c:	819fd0ef          	jal	ffffffffc0200474 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c60:	00004617          	auipc	a2,0x4
ffffffffc0202c64:	7f860613          	addi	a2,a2,2040 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0202c68:	0c100593          	li	a1,193
ffffffffc0202c6c:	00005517          	auipc	a0,0x5
ffffffffc0202c70:	85c50513          	addi	a0,a0,-1956 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202c74:	801fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c78:	00005697          	auipc	a3,0x5
ffffffffc0202c7c:	95868693          	addi	a3,a3,-1704 # ffffffffc02075d0 <etext+0xec4>
ffffffffc0202c80:	00004617          	auipc	a2,0x4
ffffffffc0202c84:	10860613          	addi	a2,a2,264 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202c88:	1fe00593          	li	a1,510
ffffffffc0202c8c:	00005517          	auipc	a0,0x5
ffffffffc0202c90:	83c50513          	addi	a0,a0,-1988 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202c94:	fe0fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202c98:	00005697          	auipc	a3,0x5
ffffffffc0202c9c:	91868693          	addi	a3,a3,-1768 # ffffffffc02075b0 <etext+0xea4>
ffffffffc0202ca0:	00004617          	auipc	a2,0x4
ffffffffc0202ca4:	0e860613          	addi	a2,a2,232 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202ca8:	1fd00593          	li	a1,509
ffffffffc0202cac:	00005517          	auipc	a0,0x5
ffffffffc0202cb0:	81c50513          	addi	a0,a0,-2020 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202cb4:	fc0fd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0202cb8:	fcdfe0ef          	jal	ffffffffc0201c84 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202cbc:	00005697          	auipc	a3,0x5
ffffffffc0202cc0:	9a468693          	addi	a3,a3,-1628 # ffffffffc0207660 <etext+0xf54>
ffffffffc0202cc4:	00004617          	auipc	a2,0x4
ffffffffc0202cc8:	0c460613          	addi	a2,a2,196 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202ccc:	20600593          	li	a1,518
ffffffffc0202cd0:	00004517          	auipc	a0,0x4
ffffffffc0202cd4:	7f850513          	addi	a0,a0,2040 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202cd8:	f9cfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202cdc:	00005697          	auipc	a3,0x5
ffffffffc0202ce0:	95468693          	addi	a3,a3,-1708 # ffffffffc0207630 <etext+0xf24>
ffffffffc0202ce4:	00004617          	auipc	a2,0x4
ffffffffc0202ce8:	0a460613          	addi	a2,a2,164 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202cec:	20300593          	li	a1,515
ffffffffc0202cf0:	00004517          	auipc	a0,0x4
ffffffffc0202cf4:	7d850513          	addi	a0,a0,2008 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202cf8:	f7cfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202cfc:	00005697          	auipc	a3,0x5
ffffffffc0202d00:	90c68693          	addi	a3,a3,-1780 # ffffffffc0207608 <etext+0xefc>
ffffffffc0202d04:	00004617          	auipc	a2,0x4
ffffffffc0202d08:	08460613          	addi	a2,a2,132 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202d0c:	1ff00593          	li	a1,511
ffffffffc0202d10:	00004517          	auipc	a0,0x4
ffffffffc0202d14:	7b850513          	addi	a0,a0,1976 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202d18:	f5cfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d1c:	00005697          	auipc	a3,0x5
ffffffffc0202d20:	9cc68693          	addi	a3,a3,-1588 # ffffffffc02076e8 <etext+0xfdc>
ffffffffc0202d24:	00004617          	auipc	a2,0x4
ffffffffc0202d28:	06460613          	addi	a2,a2,100 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202d2c:	20f00593          	li	a1,527
ffffffffc0202d30:	00004517          	auipc	a0,0x4
ffffffffc0202d34:	79850513          	addi	a0,a0,1944 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202d38:	f3cfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d3c:	00005697          	auipc	a3,0x5
ffffffffc0202d40:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0207788 <etext+0x107c>
ffffffffc0202d44:	00004617          	auipc	a2,0x4
ffffffffc0202d48:	04460613          	addi	a2,a2,68 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202d4c:	21400593          	li	a1,532
ffffffffc0202d50:	00004517          	auipc	a0,0x4
ffffffffc0202d54:	77850513          	addi	a0,a0,1912 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202d58:	f1cfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d5c:	00005697          	auipc	a3,0x5
ffffffffc0202d60:	96468693          	addi	a3,a3,-1692 # ffffffffc02076c0 <etext+0xfb4>
ffffffffc0202d64:	00004617          	auipc	a2,0x4
ffffffffc0202d68:	02460613          	addi	a2,a2,36 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202d6c:	20c00593          	li	a1,524
ffffffffc0202d70:	00004517          	auipc	a0,0x4
ffffffffc0202d74:	75850513          	addi	a0,a0,1880 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202d78:	efcfd0ef          	jal	ffffffffc0200474 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d7c:	86d6                	mv	a3,s5
ffffffffc0202d7e:	00004617          	auipc	a2,0x4
ffffffffc0202d82:	63260613          	addi	a2,a2,1586 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0202d86:	20b00593          	li	a1,523
ffffffffc0202d8a:	00004517          	auipc	a0,0x4
ffffffffc0202d8e:	73e50513          	addi	a0,a0,1854 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202d92:	ee2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d96:	00005697          	auipc	a3,0x5
ffffffffc0202d9a:	98a68693          	addi	a3,a3,-1654 # ffffffffc0207720 <etext+0x1014>
ffffffffc0202d9e:	00004617          	auipc	a2,0x4
ffffffffc0202da2:	fea60613          	addi	a2,a2,-22 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202da6:	21900593          	li	a1,537
ffffffffc0202daa:	00004517          	auipc	a0,0x4
ffffffffc0202dae:	71e50513          	addi	a0,a0,1822 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202db2:	ec2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202db6:	00005697          	auipc	a3,0x5
ffffffffc0202dba:	a3268693          	addi	a3,a3,-1486 # ffffffffc02077e8 <etext+0x10dc>
ffffffffc0202dbe:	00004617          	auipc	a2,0x4
ffffffffc0202dc2:	fca60613          	addi	a2,a2,-54 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202dc6:	21800593          	li	a1,536
ffffffffc0202dca:	00004517          	auipc	a0,0x4
ffffffffc0202dce:	6fe50513          	addi	a0,a0,1790 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202dd2:	ea2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202dd6:	00005697          	auipc	a3,0x5
ffffffffc0202dda:	9fa68693          	addi	a3,a3,-1542 # ffffffffc02077d0 <etext+0x10c4>
ffffffffc0202dde:	00004617          	auipc	a2,0x4
ffffffffc0202de2:	faa60613          	addi	a2,a2,-86 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202de6:	21700593          	li	a1,535
ffffffffc0202dea:	00004517          	auipc	a0,0x4
ffffffffc0202dee:	6de50513          	addi	a0,a0,1758 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202df2:	e82fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202df6:	00005697          	auipc	a3,0x5
ffffffffc0202dfa:	9aa68693          	addi	a3,a3,-1622 # ffffffffc02077a0 <etext+0x1094>
ffffffffc0202dfe:	00004617          	auipc	a2,0x4
ffffffffc0202e02:	f8a60613          	addi	a2,a2,-118 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202e06:	21600593          	li	a1,534
ffffffffc0202e0a:	00004517          	auipc	a0,0x4
ffffffffc0202e0e:	6be50513          	addi	a0,a0,1726 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202e12:	e62fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e16:	00005697          	auipc	a3,0x5
ffffffffc0202e1a:	b4268693          	addi	a3,a3,-1214 # ffffffffc0207958 <etext+0x124c>
ffffffffc0202e1e:	00004617          	auipc	a2,0x4
ffffffffc0202e22:	f6a60613          	addi	a2,a2,-150 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202e26:	24500593          	li	a1,581
ffffffffc0202e2a:	00004517          	auipc	a0,0x4
ffffffffc0202e2e:	69e50513          	addi	a0,a0,1694 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202e32:	e42fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e36:	00005697          	auipc	a3,0x5
ffffffffc0202e3a:	93a68693          	addi	a3,a3,-1734 # ffffffffc0207770 <etext+0x1064>
ffffffffc0202e3e:	00004617          	auipc	a2,0x4
ffffffffc0202e42:	f4a60613          	addi	a2,a2,-182 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202e46:	21300593          	li	a1,531
ffffffffc0202e4a:	00004517          	auipc	a0,0x4
ffffffffc0202e4e:	67e50513          	addi	a0,a0,1662 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202e52:	e22fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e56:	00005697          	auipc	a3,0x5
ffffffffc0202e5a:	90a68693          	addi	a3,a3,-1782 # ffffffffc0207760 <etext+0x1054>
ffffffffc0202e5e:	00004617          	auipc	a2,0x4
ffffffffc0202e62:	f2a60613          	addi	a2,a2,-214 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202e66:	21200593          	li	a1,530
ffffffffc0202e6a:	00004517          	auipc	a0,0x4
ffffffffc0202e6e:	65e50513          	addi	a0,a0,1630 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202e72:	e02fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202e76:	00005697          	auipc	a3,0x5
ffffffffc0202e7a:	9e268693          	addi	a3,a3,-1566 # ffffffffc0207858 <etext+0x114c>
ffffffffc0202e7e:	00004617          	auipc	a2,0x4
ffffffffc0202e82:	f0a60613          	addi	a2,a2,-246 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202e86:	25600593          	li	a1,598
ffffffffc0202e8a:	00004517          	auipc	a0,0x4
ffffffffc0202e8e:	63e50513          	addi	a0,a0,1598 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202e92:	de2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202e96:	00005697          	auipc	a3,0x5
ffffffffc0202e9a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0207750 <etext+0x1044>
ffffffffc0202e9e:	00004617          	auipc	a2,0x4
ffffffffc0202ea2:	eea60613          	addi	a2,a2,-278 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202ea6:	21100593          	li	a1,529
ffffffffc0202eaa:	00004517          	auipc	a0,0x4
ffffffffc0202eae:	61e50513          	addi	a0,a0,1566 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202eb2:	dc2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202eb6:	00004697          	auipc	a3,0x4
ffffffffc0202eba:	7f268693          	addi	a3,a3,2034 # ffffffffc02076a8 <etext+0xf9c>
ffffffffc0202ebe:	00004617          	auipc	a2,0x4
ffffffffc0202ec2:	eca60613          	addi	a2,a2,-310 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202ec6:	21e00593          	li	a1,542
ffffffffc0202eca:	00004517          	auipc	a0,0x4
ffffffffc0202ece:	5fe50513          	addi	a0,a0,1534 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202ed2:	da2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ed6:	00005697          	auipc	a3,0x5
ffffffffc0202eda:	92a68693          	addi	a3,a3,-1750 # ffffffffc0207800 <etext+0x10f4>
ffffffffc0202ede:	00004617          	auipc	a2,0x4
ffffffffc0202ee2:	eaa60613          	addi	a2,a2,-342 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202ee6:	21b00593          	li	a1,539
ffffffffc0202eea:	00004517          	auipc	a0,0x4
ffffffffc0202eee:	5de50513          	addi	a0,a0,1502 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202ef2:	d82fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202ef6:	00004697          	auipc	a3,0x4
ffffffffc0202efa:	79a68693          	addi	a3,a3,1946 # ffffffffc0207690 <etext+0xf84>
ffffffffc0202efe:	00004617          	auipc	a2,0x4
ffffffffc0202f02:	e8a60613          	addi	a2,a2,-374 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202f06:	21a00593          	li	a1,538
ffffffffc0202f0a:	00004517          	auipc	a0,0x4
ffffffffc0202f0e:	5be50513          	addi	a0,a0,1470 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202f12:	d62fd0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f16:	00004617          	auipc	a2,0x4
ffffffffc0202f1a:	49a60613          	addi	a2,a2,1178 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0202f1e:	06900593          	li	a1,105
ffffffffc0202f22:	00004517          	auipc	a0,0x4
ffffffffc0202f26:	4b650513          	addi	a0,a0,1206 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0202f2a:	d4afd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f2e:	00005697          	auipc	a3,0x5
ffffffffc0202f32:	90268693          	addi	a3,a3,-1790 # ffffffffc0207830 <etext+0x1124>
ffffffffc0202f36:	00004617          	auipc	a2,0x4
ffffffffc0202f3a:	e5260613          	addi	a2,a2,-430 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202f3e:	22500593          	li	a1,549
ffffffffc0202f42:	00004517          	auipc	a0,0x4
ffffffffc0202f46:	58650513          	addi	a0,a0,1414 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202f4a:	d2afd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f4e:	00005697          	auipc	a3,0x5
ffffffffc0202f52:	89a68693          	addi	a3,a3,-1894 # ffffffffc02077e8 <etext+0x10dc>
ffffffffc0202f56:	00004617          	auipc	a2,0x4
ffffffffc0202f5a:	e3260613          	addi	a2,a2,-462 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202f5e:	22300593          	li	a1,547
ffffffffc0202f62:	00004517          	auipc	a0,0x4
ffffffffc0202f66:	56650513          	addi	a0,a0,1382 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202f6a:	d0afd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f6e:	00005697          	auipc	a3,0x5
ffffffffc0202f72:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0207818 <etext+0x110c>
ffffffffc0202f76:	00004617          	auipc	a2,0x4
ffffffffc0202f7a:	e1260613          	addi	a2,a2,-494 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202f7e:	22200593          	li	a1,546
ffffffffc0202f82:	00004517          	auipc	a0,0x4
ffffffffc0202f86:	54650513          	addi	a0,a0,1350 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202f8a:	ceafd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f8e:	00005697          	auipc	a3,0x5
ffffffffc0202f92:	85a68693          	addi	a3,a3,-1958 # ffffffffc02077e8 <etext+0x10dc>
ffffffffc0202f96:	00004617          	auipc	a2,0x4
ffffffffc0202f9a:	df260613          	addi	a2,a2,-526 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202f9e:	21f00593          	li	a1,543
ffffffffc0202fa2:	00004517          	auipc	a0,0x4
ffffffffc0202fa6:	52650513          	addi	a0,a0,1318 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202faa:	ccafd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202fae:	00005697          	auipc	a3,0x5
ffffffffc0202fb2:	99268693          	addi	a3,a3,-1646 # ffffffffc0207940 <etext+0x1234>
ffffffffc0202fb6:	00004617          	auipc	a2,0x4
ffffffffc0202fba:	dd260613          	addi	a2,a2,-558 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202fbe:	24400593          	li	a1,580
ffffffffc0202fc2:	00004517          	auipc	a0,0x4
ffffffffc0202fc6:	50650513          	addi	a0,a0,1286 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202fca:	caafd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202fce:	00005697          	auipc	a3,0x5
ffffffffc0202fd2:	93a68693          	addi	a3,a3,-1734 # ffffffffc0207908 <etext+0x11fc>
ffffffffc0202fd6:	00004617          	auipc	a2,0x4
ffffffffc0202fda:	db260613          	addi	a2,a2,-590 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202fde:	24300593          	li	a1,579
ffffffffc0202fe2:	00004517          	auipc	a0,0x4
ffffffffc0202fe6:	4e650513          	addi	a0,a0,1254 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0202fea:	c8afd0ef          	jal	ffffffffc0200474 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202fee:	00005697          	auipc	a3,0x5
ffffffffc0202ff2:	90268693          	addi	a3,a3,-1790 # ffffffffc02078f0 <etext+0x11e4>
ffffffffc0202ff6:	00004617          	auipc	a2,0x4
ffffffffc0202ffa:	d9260613          	addi	a2,a2,-622 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0202ffe:	23f00593          	li	a1,575
ffffffffc0203002:	00004517          	auipc	a0,0x4
ffffffffc0203006:	4c650513          	addi	a0,a0,1222 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc020300a:	c6afd0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020300e:	00005697          	auipc	a3,0x5
ffffffffc0203012:	84a68693          	addi	a3,a3,-1974 # ffffffffc0207858 <etext+0x114c>
ffffffffc0203016:	00004617          	auipc	a2,0x4
ffffffffc020301a:	d7260613          	addi	a2,a2,-654 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020301e:	22d00593          	li	a1,557
ffffffffc0203022:	00004517          	auipc	a0,0x4
ffffffffc0203026:	4a650513          	addi	a0,a0,1190 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc020302a:	c4afd0ef          	jal	ffffffffc0200474 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020302e:	00004697          	auipc	a3,0x4
ffffffffc0203032:	66268693          	addi	a3,a3,1634 # ffffffffc0207690 <etext+0xf84>
ffffffffc0203036:	00004617          	auipc	a2,0x4
ffffffffc020303a:	d5260613          	addi	a2,a2,-686 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020303e:	20700593          	li	a1,519
ffffffffc0203042:	00004517          	auipc	a0,0x4
ffffffffc0203046:	48650513          	addi	a0,a0,1158 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc020304a:	c2afd0ef          	jal	ffffffffc0200474 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020304e:	00004617          	auipc	a2,0x4
ffffffffc0203052:	36260613          	addi	a2,a2,866 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0203056:	20a00593          	li	a1,522
ffffffffc020305a:	00004517          	auipc	a0,0x4
ffffffffc020305e:	46e50513          	addi	a0,a0,1134 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0203062:	c12fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203066:	00004697          	auipc	a3,0x4
ffffffffc020306a:	64268693          	addi	a3,a3,1602 # ffffffffc02076a8 <etext+0xf9c>
ffffffffc020306e:	00004617          	auipc	a2,0x4
ffffffffc0203072:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203076:	20800593          	li	a1,520
ffffffffc020307a:	00004517          	auipc	a0,0x4
ffffffffc020307e:	44e50513          	addi	a0,a0,1102 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0203082:	bf2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203086:	00004697          	auipc	a3,0x4
ffffffffc020308a:	69a68693          	addi	a3,a3,1690 # ffffffffc0207720 <etext+0x1014>
ffffffffc020308e:	00004617          	auipc	a2,0x4
ffffffffc0203092:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203096:	21000593          	li	a1,528
ffffffffc020309a:	00004517          	auipc	a0,0x4
ffffffffc020309e:	42e50513          	addi	a0,a0,1070 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02030a2:	bd2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02030a6:	00005697          	auipc	a3,0x5
ffffffffc02030aa:	95a68693          	addi	a3,a3,-1702 # ffffffffc0207a00 <etext+0x12f4>
ffffffffc02030ae:	00004617          	auipc	a2,0x4
ffffffffc02030b2:	cda60613          	addi	a2,a2,-806 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02030b6:	24d00593          	li	a1,589
ffffffffc02030ba:	00004517          	auipc	a0,0x4
ffffffffc02030be:	40e50513          	addi	a0,a0,1038 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02030c2:	bb2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02030c6:	00005697          	auipc	a3,0x5
ffffffffc02030ca:	90268693          	addi	a3,a3,-1790 # ffffffffc02079c8 <etext+0x12bc>
ffffffffc02030ce:	00004617          	auipc	a2,0x4
ffffffffc02030d2:	cba60613          	addi	a2,a2,-838 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02030d6:	24a00593          	li	a1,586
ffffffffc02030da:	00004517          	auipc	a0,0x4
ffffffffc02030de:	3ee50513          	addi	a0,a0,1006 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02030e2:	b92fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02030e6:	00005697          	auipc	a3,0x5
ffffffffc02030ea:	8b268693          	addi	a3,a3,-1870 # ffffffffc0207998 <etext+0x128c>
ffffffffc02030ee:	00004617          	auipc	a2,0x4
ffffffffc02030f2:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02030f6:	24600593          	li	a1,582
ffffffffc02030fa:	00004517          	auipc	a0,0x4
ffffffffc02030fe:	3ce50513          	addi	a0,a0,974 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0203102:	b72fd0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203106 <copy_range>:
               bool share) {
ffffffffc0203106:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203108:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc020310c:	f486                	sd	ra,104(sp)
ffffffffc020310e:	f0a2                	sd	s0,96(sp)
ffffffffc0203110:	eca6                	sd	s1,88(sp)
ffffffffc0203112:	e8ca                	sd	s2,80(sp)
ffffffffc0203114:	e4ce                	sd	s3,72(sp)
ffffffffc0203116:	e0d2                	sd	s4,64(sp)
ffffffffc0203118:	fc56                	sd	s5,56(sp)
ffffffffc020311a:	f85a                	sd	s6,48(sp)
ffffffffc020311c:	f45e                	sd	s7,40(sp)
ffffffffc020311e:	f062                	sd	s8,32(sp)
ffffffffc0203120:	ec66                	sd	s9,24(sp)
ffffffffc0203122:	e86a                	sd	s10,16(sp)
ffffffffc0203124:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203126:	17d2                	slli	a5,a5,0x34
ffffffffc0203128:	1e079563          	bnez	a5,ffffffffc0203312 <copy_range+0x20c>
    assert(USER_ACCESS(start, end));
ffffffffc020312c:	002007b7          	lui	a5,0x200
ffffffffc0203130:	8432                	mv	s0,a2
ffffffffc0203132:	16f66863          	bltu	a2,a5,ffffffffc02032a2 <copy_range+0x19c>
ffffffffc0203136:	8936                	mv	s2,a3
ffffffffc0203138:	16d67563          	bgeu	a2,a3,ffffffffc02032a2 <copy_range+0x19c>
ffffffffc020313c:	4785                	li	a5,1
ffffffffc020313e:	07fe                	slli	a5,a5,0x1f
ffffffffc0203140:	16d7e163          	bltu	a5,a3,ffffffffc02032a2 <copy_range+0x19c>
ffffffffc0203144:	5b7d                	li	s6,-1
ffffffffc0203146:	8aaa                	mv	s5,a0
ffffffffc0203148:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc020314a:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020314c:	0009bc97          	auipc	s9,0x9b
ffffffffc0203150:	adcc8c93          	addi	s9,s9,-1316 # ffffffffc029dc28 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203154:	0009bc17          	auipc	s8,0x9b
ffffffffc0203158:	adcc0c13          	addi	s8,s8,-1316 # ffffffffc029dc30 <pages>
    return page - pages + nbase;
ffffffffc020315c:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc0203160:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203164:	4601                	li	a2,0
ffffffffc0203166:	85a2                	mv	a1,s0
ffffffffc0203168:	854e                	mv	a0,s3
ffffffffc020316a:	c41fe0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc020316e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0203170:	c17d                	beqz	a0,ffffffffc0203256 <copy_range+0x150>
        if (*ptep & PTE_V) {
ffffffffc0203172:	611c                	ld	a5,0(a0)
ffffffffc0203174:	8b85                	andi	a5,a5,1
ffffffffc0203176:	e78d                	bnez	a5,ffffffffc02031a0 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0203178:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020317a:	c019                	beqz	s0,ffffffffc0203180 <copy_range+0x7a>
ffffffffc020317c:	ff2464e3          	bltu	s0,s2,ffffffffc0203164 <copy_range+0x5e>
    return 0;
ffffffffc0203180:	4501                	li	a0,0
}
ffffffffc0203182:	70a6                	ld	ra,104(sp)
ffffffffc0203184:	7406                	ld	s0,96(sp)
ffffffffc0203186:	64e6                	ld	s1,88(sp)
ffffffffc0203188:	6946                	ld	s2,80(sp)
ffffffffc020318a:	69a6                	ld	s3,72(sp)
ffffffffc020318c:	6a06                	ld	s4,64(sp)
ffffffffc020318e:	7ae2                	ld	s5,56(sp)
ffffffffc0203190:	7b42                	ld	s6,48(sp)
ffffffffc0203192:	7ba2                	ld	s7,40(sp)
ffffffffc0203194:	7c02                	ld	s8,32(sp)
ffffffffc0203196:	6ce2                	ld	s9,24(sp)
ffffffffc0203198:	6d42                	ld	s10,16(sp)
ffffffffc020319a:	6da2                	ld	s11,8(sp)
ffffffffc020319c:	6165                	addi	sp,sp,112
ffffffffc020319e:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02031a0:	4605                	li	a2,1
ffffffffc02031a2:	85a2                	mv	a1,s0
ffffffffc02031a4:	8556                	mv	a0,s5
ffffffffc02031a6:	c05fe0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc02031aa:	cd4d                	beqz	a0,ffffffffc0203264 <copy_range+0x15e>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02031ac:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc02031ae:	0017f713          	andi	a4,a5,1
ffffffffc02031b2:	01f7f493          	andi	s1,a5,31
ffffffffc02031b6:	14070263          	beqz	a4,ffffffffc02032fa <copy_range+0x1f4>
    if (PPN(pa) >= npage) {
ffffffffc02031ba:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031be:	078a                	slli	a5,a5,0x2
ffffffffc02031c0:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031c4:	10d77f63          	bgeu	a4,a3,ffffffffc02032e2 <copy_range+0x1dc>
    return &pages[PPN(pa) - nbase];
ffffffffc02031c8:	000c3783          	ld	a5,0(s8)
ffffffffc02031cc:	fff806b7          	lui	a3,0xfff80
ffffffffc02031d0:	9736                	add	a4,a4,a3
ffffffffc02031d2:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc02031d4:	4505                	li	a0,1
ffffffffc02031d6:	00e78db3          	add	s11,a5,a4
ffffffffc02031da:	ac7fe0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc02031de:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02031e0:	0a0d8163          	beqz	s11,ffffffffc0203282 <copy_range+0x17c>
            assert(npage != NULL);
ffffffffc02031e4:	cd79                	beqz	a0,ffffffffc02032c2 <copy_range+0x1bc>
    return page - pages + nbase;
ffffffffc02031e6:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc02031ea:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02031ee:	40ed86b3          	sub	a3,s11,a4
ffffffffc02031f2:	8699                	srai	a3,a3,0x6
ffffffffc02031f4:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02031f6:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02031fa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031fc:	06c7f763          	bgeu	a5,a2,ffffffffc020326a <copy_range+0x164>
    return page - pages + nbase;
ffffffffc0203200:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc0203204:	0009b717          	auipc	a4,0x9b
ffffffffc0203208:	a1c70713          	addi	a4,a4,-1508 # ffffffffc029dc20 <va_pa_offset>
ffffffffc020320c:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc020320e:	8799                	srai	a5,a5,0x6
ffffffffc0203210:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc0203212:	0167f733          	and	a4,a5,s6
ffffffffc0203216:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020321a:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020321c:	04c77663          	bgeu	a4,a2,ffffffffc0203268 <copy_range+0x162>
                memcpy(dst_kva, src_kva, PGSIZE);
ffffffffc0203220:	6605                	lui	a2,0x1
ffffffffc0203222:	953e                	add	a0,a0,a5
ffffffffc0203224:	4d0030ef          	jal	ffffffffc02066f4 <memcpy>
                ret=page_insert(to, npage, start, perm);
ffffffffc0203228:	86a6                	mv	a3,s1
ffffffffc020322a:	8622                	mv	a2,s0
ffffffffc020322c:	85ea                	mv	a1,s10
ffffffffc020322e:	8556                	mv	a0,s5
ffffffffc0203230:	a46ff0ef          	jal	ffffffffc0202476 <page_insert>
                assert(ret == 0);
ffffffffc0203234:	d131                	beqz	a0,ffffffffc0203178 <copy_range+0x72>
ffffffffc0203236:	00005697          	auipc	a3,0x5
ffffffffc020323a:	83268693          	addi	a3,a3,-1998 # ffffffffc0207a68 <etext+0x135c>
ffffffffc020323e:	00004617          	auipc	a2,0x4
ffffffffc0203242:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203246:	19a00593          	li	a1,410
ffffffffc020324a:	00004517          	auipc	a0,0x4
ffffffffc020324e:	27e50513          	addi	a0,a0,638 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc0203252:	a22fd0ef          	jal	ffffffffc0200474 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203256:	002007b7          	lui	a5,0x200
ffffffffc020325a:	97a2                	add	a5,a5,s0
ffffffffc020325c:	ffe00437          	lui	s0,0xffe00
ffffffffc0203260:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc0203262:	bf21                	j	ffffffffc020317a <copy_range+0x74>
                return -E_NO_MEM;
ffffffffc0203264:	5571                	li	a0,-4
ffffffffc0203266:	bf31                	j	ffffffffc0203182 <copy_range+0x7c>
ffffffffc0203268:	86be                	mv	a3,a5
ffffffffc020326a:	00004617          	auipc	a2,0x4
ffffffffc020326e:	14660613          	addi	a2,a2,326 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0203272:	06900593          	li	a1,105
ffffffffc0203276:	00004517          	auipc	a0,0x4
ffffffffc020327a:	16250513          	addi	a0,a0,354 # ffffffffc02073d8 <etext+0xccc>
ffffffffc020327e:	9f6fd0ef          	jal	ffffffffc0200474 <__panic>
            assert(page != NULL);
ffffffffc0203282:	00004697          	auipc	a3,0x4
ffffffffc0203286:	7c668693          	addi	a3,a3,1990 # ffffffffc0207a48 <etext+0x133c>
ffffffffc020328a:	00004617          	auipc	a2,0x4
ffffffffc020328e:	afe60613          	addi	a2,a2,-1282 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203292:	17200593          	li	a1,370
ffffffffc0203296:	00004517          	auipc	a0,0x4
ffffffffc020329a:	23250513          	addi	a0,a0,562 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc020329e:	9d6fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02032a2:	00004697          	auipc	a3,0x4
ffffffffc02032a6:	26668693          	addi	a3,a3,614 # ffffffffc0207508 <etext+0xdfc>
ffffffffc02032aa:	00004617          	auipc	a2,0x4
ffffffffc02032ae:	ade60613          	addi	a2,a2,-1314 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02032b2:	15e00593          	li	a1,350
ffffffffc02032b6:	00004517          	auipc	a0,0x4
ffffffffc02032ba:	21250513          	addi	a0,a0,530 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02032be:	9b6fd0ef          	jal	ffffffffc0200474 <__panic>
            assert(npage != NULL);
ffffffffc02032c2:	00004697          	auipc	a3,0x4
ffffffffc02032c6:	79668693          	addi	a3,a3,1942 # ffffffffc0207a58 <etext+0x134c>
ffffffffc02032ca:	00004617          	auipc	a2,0x4
ffffffffc02032ce:	abe60613          	addi	a2,a2,-1346 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02032d2:	17300593          	li	a1,371
ffffffffc02032d6:	00004517          	auipc	a0,0x4
ffffffffc02032da:	1f250513          	addi	a0,a0,498 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02032de:	996fd0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02032e2:	00004617          	auipc	a2,0x4
ffffffffc02032e6:	19e60613          	addi	a2,a2,414 # ffffffffc0207480 <etext+0xd74>
ffffffffc02032ea:	06200593          	li	a1,98
ffffffffc02032ee:	00004517          	auipc	a0,0x4
ffffffffc02032f2:	0ea50513          	addi	a0,a0,234 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02032f6:	97efd0ef          	jal	ffffffffc0200474 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032fa:	00004617          	auipc	a2,0x4
ffffffffc02032fe:	1a660613          	addi	a2,a2,422 # ffffffffc02074a0 <etext+0xd94>
ffffffffc0203302:	07400593          	li	a1,116
ffffffffc0203306:	00004517          	auipc	a0,0x4
ffffffffc020330a:	0d250513          	addi	a0,a0,210 # ffffffffc02073d8 <etext+0xccc>
ffffffffc020330e:	966fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203312:	00004697          	auipc	a3,0x4
ffffffffc0203316:	1c668693          	addi	a3,a3,454 # ffffffffc02074d8 <etext+0xdcc>
ffffffffc020331a:	00004617          	auipc	a2,0x4
ffffffffc020331e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203322:	15d00593          	li	a1,349
ffffffffc0203326:	00004517          	auipc	a0,0x4
ffffffffc020332a:	1a250513          	addi	a0,a0,418 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc020332e:	946fd0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203332 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203332:	12058073          	sfence.vma	a1
}
ffffffffc0203336:	8082                	ret

ffffffffc0203338 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203338:	7179                	addi	sp,sp,-48
ffffffffc020333a:	e84a                	sd	s2,16(sp)
ffffffffc020333c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020333e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203340:	ec26                	sd	s1,24(sp)
ffffffffc0203342:	e44e                	sd	s3,8(sp)
ffffffffc0203344:	f406                	sd	ra,40(sp)
ffffffffc0203346:	f022                	sd	s0,32(sp)
ffffffffc0203348:	84ae                	mv	s1,a1
ffffffffc020334a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020334c:	955fe0ef          	jal	ffffffffc0201ca0 <alloc_pages>
    if (page != NULL) {
ffffffffc0203350:	c12d                	beqz	a0,ffffffffc02033b2 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203352:	842a                	mv	s0,a0
ffffffffc0203354:	85aa                	mv	a1,a0
ffffffffc0203356:	86ce                	mv	a3,s3
ffffffffc0203358:	8626                	mv	a2,s1
ffffffffc020335a:	854a                	mv	a0,s2
ffffffffc020335c:	91aff0ef          	jal	ffffffffc0202476 <page_insert>
ffffffffc0203360:	ed0d                	bnez	a0,ffffffffc020339a <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0203362:	0009b797          	auipc	a5,0x9b
ffffffffc0203366:	8d67a783          	lw	a5,-1834(a5) # ffffffffc029dc38 <swap_init_ok>
ffffffffc020336a:	c385                	beqz	a5,ffffffffc020338a <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc020336c:	0009b517          	auipc	a0,0x9b
ffffffffc0203370:	8ec53503          	ld	a0,-1812(a0) # ffffffffc029dc58 <check_mm_struct>
ffffffffc0203374:	c919                	beqz	a0,ffffffffc020338a <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203376:	4681                	li	a3,0
ffffffffc0203378:	8622                	mv	a2,s0
ffffffffc020337a:	85a6                	mv	a1,s1
ffffffffc020337c:	00f000ef          	jal	ffffffffc0203b8a <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203380:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203382:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203384:	4785                	li	a5,1
ffffffffc0203386:	04f71663          	bne	a4,a5,ffffffffc02033d2 <pgdir_alloc_page+0x9a>
}
ffffffffc020338a:	70a2                	ld	ra,40(sp)
ffffffffc020338c:	8522                	mv	a0,s0
ffffffffc020338e:	7402                	ld	s0,32(sp)
ffffffffc0203390:	64e2                	ld	s1,24(sp)
ffffffffc0203392:	6942                	ld	s2,16(sp)
ffffffffc0203394:	69a2                	ld	s3,8(sp)
ffffffffc0203396:	6145                	addi	sp,sp,48
ffffffffc0203398:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020339a:	100027f3          	csrr	a5,sstatus
ffffffffc020339e:	8b89                	andi	a5,a5,2
ffffffffc02033a0:	eb99                	bnez	a5,ffffffffc02033b6 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc02033a2:	0009b797          	auipc	a5,0x9b
ffffffffc02033a6:	8667b783          	ld	a5,-1946(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc02033aa:	739c                	ld	a5,32(a5)
ffffffffc02033ac:	4585                	li	a1,1
ffffffffc02033ae:	8522                	mv	a0,s0
ffffffffc02033b0:	9782                	jalr	a5
            return NULL;
ffffffffc02033b2:	4401                	li	s0,0
ffffffffc02033b4:	bfd9                	j	ffffffffc020338a <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc02033b6:	a8afd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02033ba:	0009b797          	auipc	a5,0x9b
ffffffffc02033be:	84e7b783          	ld	a5,-1970(a5) # ffffffffc029dc08 <pmm_manager>
ffffffffc02033c2:	739c                	ld	a5,32(a5)
ffffffffc02033c4:	8522                	mv	a0,s0
ffffffffc02033c6:	4585                	li	a1,1
ffffffffc02033c8:	9782                	jalr	a5
            return NULL;
ffffffffc02033ca:	4401                	li	s0,0
        intr_enable();
ffffffffc02033cc:	a6efd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02033d0:	bf6d                	j	ffffffffc020338a <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc02033d2:	00004697          	auipc	a3,0x4
ffffffffc02033d6:	6a668693          	addi	a3,a3,1702 # ffffffffc0207a78 <etext+0x136c>
ffffffffc02033da:	00004617          	auipc	a2,0x4
ffffffffc02033de:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02033e2:	1de00593          	li	a1,478
ffffffffc02033e6:	00004517          	auipc	a0,0x4
ffffffffc02033ea:	0e250513          	addi	a0,a0,226 # ffffffffc02074c8 <etext+0xdbc>
ffffffffc02033ee:	886fd0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02033f2 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02033f2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02033f4:	00004617          	auipc	a2,0x4
ffffffffc02033f8:	08c60613          	addi	a2,a2,140 # ffffffffc0207480 <etext+0xd74>
ffffffffc02033fc:	06200593          	li	a1,98
ffffffffc0203400:	00004517          	auipc	a0,0x4
ffffffffc0203404:	fd850513          	addi	a0,a0,-40 # ffffffffc02073d8 <etext+0xccc>
pa2page(uintptr_t pa) {
ffffffffc0203408:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020340a:	86afd0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020340e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020340e:	7135                	addi	sp,sp,-160
ffffffffc0203410:	ed06                	sd	ra,152(sp)
     swapfs_init();
ffffffffc0203412:	7b4010ef          	jal	ffffffffc0204bc6 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0203416:	0009b697          	auipc	a3,0x9b
ffffffffc020341a:	82a6b683          	ld	a3,-2006(a3) # ffffffffc029dc40 <max_swap_offset>
ffffffffc020341e:	010007b7          	lui	a5,0x1000
ffffffffc0203422:	ff968713          	addi	a4,a3,-7
ffffffffc0203426:	17e1                	addi	a5,a5,-8 # fffff8 <_binary_obj___user_exit_out_size+0xff6498>
ffffffffc0203428:	44e7eb63          	bltu	a5,a4,ffffffffc020387e <swap_init+0x470>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc020342c:	0008f797          	auipc	a5,0x8f
ffffffffc0203430:	2a478793          	addi	a5,a5,676 # ffffffffc02926d0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203434:	6798                	ld	a4,8(a5)
ffffffffc0203436:	e14a                	sd	s2,128(sp)
ffffffffc0203438:	f0da                	sd	s6,96(sp)
     sm = &swap_manager_fifo;
ffffffffc020343a:	0009bb17          	auipc	s6,0x9b
ffffffffc020343e:	80eb0b13          	addi	s6,s6,-2034 # ffffffffc029dc48 <sm>
ffffffffc0203442:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0203446:	9702                	jalr	a4
ffffffffc0203448:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020344a:	c519                	beqz	a0,ffffffffc0203458 <swap_init+0x4a>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020344c:	60ea                	ld	ra,152(sp)
ffffffffc020344e:	7b06                	ld	s6,96(sp)
ffffffffc0203450:	854a                	mv	a0,s2
ffffffffc0203452:	690a                	ld	s2,128(sp)
ffffffffc0203454:	610d                	addi	sp,sp,160
ffffffffc0203456:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203458:	000b3783          	ld	a5,0(s6)
ffffffffc020345c:	00004517          	auipc	a0,0x4
ffffffffc0203460:	66450513          	addi	a0,a0,1636 # ffffffffc0207ac0 <etext+0x13b4>
ffffffffc0203464:	e922                	sd	s0,144(sp)
ffffffffc0203466:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203468:	4785                	li	a5,1
ffffffffc020346a:	e0ea                	sd	s10,64(sp)
ffffffffc020346c:	fc6e                	sd	s11,56(sp)
ffffffffc020346e:	0009a717          	auipc	a4,0x9a
ffffffffc0203472:	7cf72523          	sw	a5,1994(a4) # ffffffffc029dc38 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203476:	e526                	sd	s1,136(sp)
ffffffffc0203478:	fcce                	sd	s3,120(sp)
ffffffffc020347a:	f8d2                	sd	s4,112(sp)
ffffffffc020347c:	f4d6                	sd	s5,104(sp)
ffffffffc020347e:	ecde                	sd	s7,88(sp)
ffffffffc0203480:	e8e2                	sd	s8,80(sp)
ffffffffc0203482:	e4e6                	sd	s9,72(sp)
    return listelm->next;
ffffffffc0203484:	00096417          	auipc	s0,0x96
ffffffffc0203488:	69c40413          	addi	s0,s0,1692 # ffffffffc0299b20 <free_area>
ffffffffc020348c:	cf5fc0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc0203490:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203492:	4d81                	li	s11,0
ffffffffc0203494:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203496:	36878463          	beq	a5,s0,ffffffffc02037fe <swap_init+0x3f0>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020349a:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020349e:	8b09                	andi	a4,a4,2
ffffffffc02034a0:	36070163          	beqz	a4,ffffffffc0203802 <swap_init+0x3f4>
        count ++, total += p->property;
ffffffffc02034a4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02034a8:	679c                	ld	a5,8(a5)
ffffffffc02034aa:	2d05                	addiw	s10,s10,1
ffffffffc02034ac:	01b70dbb          	addw	s11,a4,s11
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034b0:	fe8795e3          	bne	a5,s0,ffffffffc020349a <swap_init+0x8c>
     }
     assert(total == nr_free_pages());
ffffffffc02034b4:	84ee                	mv	s1,s11
ffffffffc02034b6:	8bbfe0ef          	jal	ffffffffc0201d70 <nr_free_pages>
ffffffffc02034ba:	46951663          	bne	a0,s1,ffffffffc0203926 <swap_init+0x518>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02034be:	866e                	mv	a2,s11
ffffffffc02034c0:	85ea                	mv	a1,s10
ffffffffc02034c2:	00004517          	auipc	a0,0x4
ffffffffc02034c6:	61650513          	addi	a0,a0,1558 # ffffffffc0207ad8 <etext+0x13cc>
ffffffffc02034ca:	cb7fc0ef          	jal	ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02034ce:	45f000ef          	jal	ffffffffc020412c <mm_create>
ffffffffc02034d2:	e82a                	sd	a0,16(sp)
     assert(mm != NULL);
ffffffffc02034d4:	4a050963          	beqz	a0,ffffffffc0203986 <swap_init+0x578>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02034d8:	0009a797          	auipc	a5,0x9a
ffffffffc02034dc:	78078793          	addi	a5,a5,1920 # ffffffffc029dc58 <check_mm_struct>
ffffffffc02034e0:	6398                	ld	a4,0(a5)
ffffffffc02034e2:	42071263          	bnez	a4,ffffffffc0203906 <swap_init+0x4f8>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034e6:	0009a717          	auipc	a4,0x9a
ffffffffc02034ea:	73270713          	addi	a4,a4,1842 # ffffffffc029dc18 <boot_pgdir>
ffffffffc02034ee:	00073a83          	ld	s5,0(a4)
     check_mm_struct = mm;
ffffffffc02034f2:	6742                	ld	a4,16(sp)
ffffffffc02034f4:	e398                	sd	a4,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02034f6:	000ab783          	ld	a5,0(s5) # fffffffffffff000 <end+0x3fd61380>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034fa:	01573c23          	sd	s5,24(a4)
     assert(pgdir[0] == 0);
ffffffffc02034fe:	46079463          	bnez	a5,ffffffffc0203966 <swap_init+0x558>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203502:	6599                	lui	a1,0x6
ffffffffc0203504:	460d                	li	a2,3
ffffffffc0203506:	6505                	lui	a0,0x1
ffffffffc0203508:	46d000ef          	jal	ffffffffc0204174 <vma_create>
ffffffffc020350c:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020350e:	56050863          	beqz	a0,ffffffffc0203a7e <swap_init+0x670>

     insert_vma_struct(mm, vma);
ffffffffc0203512:	64c2                	ld	s1,16(sp)
ffffffffc0203514:	8526                	mv	a0,s1
ffffffffc0203516:	4cd000ef          	jal	ffffffffc02041e2 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020351a:	00004517          	auipc	a0,0x4
ffffffffc020351e:	62e50513          	addi	a0,a0,1582 # ffffffffc0207b48 <etext+0x143c>
ffffffffc0203522:	c5ffc0ef          	jal	ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203526:	6c88                	ld	a0,24(s1)
ffffffffc0203528:	4605                	li	a2,1
ffffffffc020352a:	6585                	lui	a1,0x1
ffffffffc020352c:	87ffe0ef          	jal	ffffffffc0201daa <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203530:	50050763          	beqz	a0,ffffffffc0203a3e <swap_init+0x630>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203534:	00004517          	auipc	a0,0x4
ffffffffc0203538:	66450513          	addi	a0,a0,1636 # ffffffffc0207b98 <etext+0x148c>
ffffffffc020353c:	00096497          	auipc	s1,0x96
ffffffffc0203540:	61c48493          	addi	s1,s1,1564 # ffffffffc0299b58 <check_rp>
ffffffffc0203544:	c3dfc0ef          	jal	ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203548:	00096997          	auipc	s3,0x96
ffffffffc020354c:	63098993          	addi	s3,s3,1584 # ffffffffc0299b78 <swap_out_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203550:	8ba6                	mv	s7,s1
          check_rp[i] = alloc_page();
ffffffffc0203552:	4505                	li	a0,1
ffffffffc0203554:	f4cfe0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0203558:	00abb023          	sd	a0,0(s7) # 80000 <_binary_obj___user_exit_out_size+0x764a0>
          assert(check_rp[i] != NULL );
ffffffffc020355c:	30050163          	beqz	a0,ffffffffc020385e <swap_init+0x450>
ffffffffc0203560:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203562:	8b89                	andi	a5,a5,2
ffffffffc0203564:	38079163          	bnez	a5,ffffffffc02038e6 <swap_init+0x4d8>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203568:	0ba1                	addi	s7,s7,8
ffffffffc020356a:	ff3b94e3          	bne	s7,s3,ffffffffc0203552 <swap_init+0x144>
     }
     list_entry_t free_list_store = free_list;
ffffffffc020356e:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203570:	00096b97          	auipc	s7,0x96
ffffffffc0203574:	5e8b8b93          	addi	s7,s7,1512 # ffffffffc0299b58 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0203578:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020357a:	f43e                	sd	a5,40(sp)
ffffffffc020357c:	641c                	ld	a5,8(s0)
ffffffffc020357e:	e400                	sd	s0,8(s0)
ffffffffc0203580:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203582:	481c                	lw	a5,16(s0)
ffffffffc0203584:	ec3e                	sd	a5,24(sp)
     nr_free = 0;
ffffffffc0203586:	00096797          	auipc	a5,0x96
ffffffffc020358a:	5a07a523          	sw	zero,1450(a5) # ffffffffc0299b30 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020358e:	000bb503          	ld	a0,0(s7)
ffffffffc0203592:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203594:	0ba1                	addi	s7,s7,8
        free_pages(check_rp[i],1);
ffffffffc0203596:	f9afe0ef          	jal	ffffffffc0201d30 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020359a:	ff3b9ae3          	bne	s7,s3,ffffffffc020358e <swap_init+0x180>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020359e:	01042b83          	lw	s7,16(s0)
ffffffffc02035a2:	4791                	li	a5,4
ffffffffc02035a4:	46fb9d63          	bne	s7,a5,ffffffffc0203a1e <swap_init+0x610>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02035a8:	00004517          	auipc	a0,0x4
ffffffffc02035ac:	67850513          	addi	a0,a0,1656 # ffffffffc0207c20 <etext+0x1514>
ffffffffc02035b0:	bd1fc0ef          	jal	ffffffffc0200180 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02035b4:	0009a797          	auipc	a5,0x9a
ffffffffc02035b8:	6807ae23          	sw	zero,1692(a5) # ffffffffc029dc50 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035bc:	6785                	lui	a5,0x1
ffffffffc02035be:	4629                	li	a2,10
ffffffffc02035c0:	00c78023          	sb	a2,0(a5) # 1000 <_binary_obj___user_softint_out_size-0x75f8>
     assert(pgfault_num==1);
ffffffffc02035c4:	0009a697          	auipc	a3,0x9a
ffffffffc02035c8:	68c6a683          	lw	a3,1676(a3) # ffffffffc029dc50 <pgfault_num>
ffffffffc02035cc:	4705                	li	a4,1
ffffffffc02035ce:	0009a797          	auipc	a5,0x9a
ffffffffc02035d2:	68278793          	addi	a5,a5,1666 # ffffffffc029dc50 <pgfault_num>
ffffffffc02035d6:	58e69463          	bne	a3,a4,ffffffffc0203b5e <swap_init+0x750>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02035da:	6705                	lui	a4,0x1
ffffffffc02035dc:	00c70823          	sb	a2,16(a4) # 1010 <_binary_obj___user_softint_out_size-0x75e8>
     assert(pgfault_num==1);
ffffffffc02035e0:	4390                	lw	a2,0(a5)
ffffffffc02035e2:	40d61e63          	bne	a2,a3,ffffffffc02039fe <swap_init+0x5f0>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035e6:	6709                	lui	a4,0x2
ffffffffc02035e8:	46ad                	li	a3,11
ffffffffc02035ea:	00d70023          	sb	a3,0(a4) # 2000 <_binary_obj___user_softint_out_size-0x65f8>
     assert(pgfault_num==2);
ffffffffc02035ee:	4398                	lw	a4,0(a5)
ffffffffc02035f0:	4589                	li	a1,2
ffffffffc02035f2:	0007061b          	sext.w	a2,a4
ffffffffc02035f6:	4eb71463          	bne	a4,a1,ffffffffc0203ade <swap_init+0x6d0>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02035fa:	6709                	lui	a4,0x2
ffffffffc02035fc:	00d70823          	sb	a3,16(a4) # 2010 <_binary_obj___user_softint_out_size-0x65e8>
     assert(pgfault_num==2);
ffffffffc0203600:	4394                	lw	a3,0(a5)
ffffffffc0203602:	4ec69e63          	bne	a3,a2,ffffffffc0203afe <swap_init+0x6f0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203606:	670d                	lui	a4,0x3
ffffffffc0203608:	46b1                	li	a3,12
ffffffffc020360a:	00d70023          	sb	a3,0(a4) # 3000 <_binary_obj___user_softint_out_size-0x55f8>
     assert(pgfault_num==3);
ffffffffc020360e:	4398                	lw	a4,0(a5)
ffffffffc0203610:	458d                	li	a1,3
ffffffffc0203612:	0007061b          	sext.w	a2,a4
ffffffffc0203616:	50b71463          	bne	a4,a1,ffffffffc0203b1e <swap_init+0x710>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020361a:	670d                	lui	a4,0x3
ffffffffc020361c:	00d70823          	sb	a3,16(a4) # 3010 <_binary_obj___user_softint_out_size-0x55e8>
     assert(pgfault_num==3);
ffffffffc0203620:	4394                	lw	a3,0(a5)
ffffffffc0203622:	50c69e63          	bne	a3,a2,ffffffffc0203b3e <swap_init+0x730>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203626:	6711                	lui	a4,0x4
ffffffffc0203628:	46b5                	li	a3,13
ffffffffc020362a:	00d70023          	sb	a3,0(a4) # 4000 <_binary_obj___user_softint_out_size-0x45f8>
     assert(pgfault_num==4);
ffffffffc020362e:	4398                	lw	a4,0(a5)
ffffffffc0203630:	0007061b          	sext.w	a2,a4
ffffffffc0203634:	47771563          	bne	a4,s7,ffffffffc0203a9e <swap_init+0x690>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203638:	6711                	lui	a4,0x4
ffffffffc020363a:	00d70823          	sb	a3,16(a4) # 4010 <_binary_obj___user_softint_out_size-0x45e8>
     assert(pgfault_num==4);
ffffffffc020363e:	439c                	lw	a5,0(a5)
ffffffffc0203640:	46c79f63          	bne	a5,a2,ffffffffc0203abe <swap_init+0x6b0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203644:	481c                	lw	a5,16(s0)
ffffffffc0203646:	30079063          	bnez	a5,ffffffffc0203946 <swap_init+0x538>
ffffffffc020364a:	00096797          	auipc	a5,0x96
ffffffffc020364e:	55678793          	addi	a5,a5,1366 # ffffffffc0299ba0 <swap_in_seq_no>
ffffffffc0203652:	00096717          	auipc	a4,0x96
ffffffffc0203656:	52670713          	addi	a4,a4,1318 # ffffffffc0299b78 <swap_out_seq_no>
ffffffffc020365a:	00096617          	auipc	a2,0x96
ffffffffc020365e:	56e60613          	addi	a2,a2,1390 # ffffffffc0299bc8 <pra_list_head>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203662:	56fd                	li	a3,-1
ffffffffc0203664:	c394                	sw	a3,0(a5)
ffffffffc0203666:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203668:	0791                	addi	a5,a5,4
ffffffffc020366a:	0711                	addi	a4,a4,4
ffffffffc020366c:	fec79ce3          	bne	a5,a2,ffffffffc0203664 <swap_init+0x256>
ffffffffc0203670:	00096717          	auipc	a4,0x96
ffffffffc0203674:	4c870713          	addi	a4,a4,1224 # ffffffffc0299b38 <check_ptep>
ffffffffc0203678:	00096a17          	auipc	s4,0x96
ffffffffc020367c:	4e0a0a13          	addi	s4,s4,1248 # ffffffffc0299b58 <check_rp>
ffffffffc0203680:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203682:	0009ab97          	auipc	s7,0x9a
ffffffffc0203686:	5a6b8b93          	addi	s7,s7,1446 # ffffffffc029dc28 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020368a:	0009ac17          	auipc	s8,0x9a
ffffffffc020368e:	5a6c0c13          	addi	s8,s8,1446 # ffffffffc029dc30 <pages>
ffffffffc0203692:	00005c97          	auipc	s9,0x5
ffffffffc0203696:	776c8c93          	addi	s9,s9,1910 # ffffffffc0208e08 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020369a:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020369e:	4601                	li	a2,0
ffffffffc02036a0:	8556                	mv	a0,s5
ffffffffc02036a2:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc02036a4:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036a6:	f04fe0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc02036aa:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02036ac:	65a2                	ld	a1,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036ae:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc02036b0:	1e050f63          	beqz	a0,ffffffffc02038ae <swap_init+0x4a0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02036b4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02036b6:	0017f613          	andi	a2,a5,1
ffffffffc02036ba:	20060a63          	beqz	a2,ffffffffc02038ce <swap_init+0x4c0>
    if (PPN(pa) >= npage) {
ffffffffc02036be:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc02036c2:	078a                	slli	a5,a5,0x2
ffffffffc02036c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036c6:	16c7f063          	bgeu	a5,a2,ffffffffc0203826 <swap_init+0x418>
    return &pages[PPN(pa) - nbase];
ffffffffc02036ca:	000cb303          	ld	t1,0(s9)
ffffffffc02036ce:	000c3603          	ld	a2,0(s8)
ffffffffc02036d2:	000a3503          	ld	a0,0(s4)
ffffffffc02036d6:	406787b3          	sub	a5,a5,t1
ffffffffc02036da:	079a                	slli	a5,a5,0x6
ffffffffc02036dc:	6685                	lui	a3,0x1
ffffffffc02036de:	97b2                	add	a5,a5,a2
ffffffffc02036e0:	0a21                	addi	s4,s4,8
ffffffffc02036e2:	0721                	addi	a4,a4,8
ffffffffc02036e4:	95b6                	add	a1,a1,a3
ffffffffc02036e6:	14f51c63          	bne	a0,a5,ffffffffc020383e <swap_init+0x430>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036ea:	6795                	lui	a5,0x5
ffffffffc02036ec:	faf597e3          	bne	a1,a5,ffffffffc020369a <swap_init+0x28c>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02036f0:	00004517          	auipc	a0,0x4
ffffffffc02036f4:	5d850513          	addi	a0,a0,1496 # ffffffffc0207cc8 <etext+0x15bc>
ffffffffc02036f8:	a89fc0ef          	jal	ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc02036fc:	000b3783          	ld	a5,0(s6)
ffffffffc0203700:	7f9c                	ld	a5,56(a5)
ffffffffc0203702:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203704:	34051d63          	bnez	a0,ffffffffc0203a5e <swap_init+0x650>

     nr_free = nr_free_store;
ffffffffc0203708:	67e2                	ld	a5,24(sp)
ffffffffc020370a:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc020370c:	77a2                	ld	a5,40(sp)
ffffffffc020370e:	e01c                	sd	a5,0(s0)
ffffffffc0203710:	7782                	ld	a5,32(sp)
ffffffffc0203712:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203714:	6088                	ld	a0,0(s1)
ffffffffc0203716:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203718:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc020371a:	e16fe0ef          	jal	ffffffffc0201d30 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020371e:	ff349be3          	bne	s1,s3,ffffffffc0203714 <swap_init+0x306>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203722:	67c2                	ld	a5,16(sp)
ffffffffc0203724:	0007bc23          	sd	zero,24(a5) # 5018 <_binary_obj___user_softint_out_size-0x35e0>
     mm_destroy(mm);
ffffffffc0203728:	853e                	mv	a0,a5
ffffffffc020372a:	389000ef          	jal	ffffffffc02042b2 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020372e:	0009a797          	auipc	a5,0x9a
ffffffffc0203732:	4ea78793          	addi	a5,a5,1258 # ffffffffc029dc18 <boot_pgdir>
ffffffffc0203736:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203738:	000bb703          	ld	a4,0(s7)
     check_mm_struct = NULL;
ffffffffc020373c:	0009a697          	auipc	a3,0x9a
ffffffffc0203740:	5006be23          	sd	zero,1308(a3) # ffffffffc029dc58 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203744:	639c                	ld	a5,0(a5)
ffffffffc0203746:	078a                	slli	a5,a5,0x2
ffffffffc0203748:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374a:	0ce7fc63          	bgeu	a5,a4,ffffffffc0203822 <swap_init+0x414>
    return &pages[PPN(pa) - nbase];
ffffffffc020374e:	000cb483          	ld	s1,0(s9)
ffffffffc0203752:	000c3503          	ld	a0,0(s8)
ffffffffc0203756:	409786b3          	sub	a3,a5,s1
ffffffffc020375a:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020375c:	8699                	srai	a3,a3,0x6
ffffffffc020375e:	96a6                	add	a3,a3,s1
    return KADDR(page2pa(page));
ffffffffc0203760:	00c69793          	slli	a5,a3,0xc
ffffffffc0203764:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203766:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203768:	24e7ff63          	bgeu	a5,a4,ffffffffc02039c6 <swap_init+0x5b8>
     free_page(pde2page(pd0[0]));
ffffffffc020376c:	0009a797          	auipc	a5,0x9a
ffffffffc0203770:	4b47b783          	ld	a5,1204(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc0203774:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0203776:	639c                	ld	a5,0(a5)
ffffffffc0203778:	078a                	slli	a5,a5,0x2
ffffffffc020377a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020377c:	0ae7f363          	bgeu	a5,a4,ffffffffc0203822 <swap_init+0x414>
    return &pages[PPN(pa) - nbase];
ffffffffc0203780:	8f85                	sub	a5,a5,s1
ffffffffc0203782:	079a                	slli	a5,a5,0x6
ffffffffc0203784:	953e                	add	a0,a0,a5
ffffffffc0203786:	4585                	li	a1,1
ffffffffc0203788:	da8fe0ef          	jal	ffffffffc0201d30 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020378c:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0203790:	000bb703          	ld	a4,0(s7)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203794:	078a                	slli	a5,a5,0x2
ffffffffc0203796:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203798:	08e7f563          	bgeu	a5,a4,ffffffffc0203822 <swap_init+0x414>
    return &pages[PPN(pa) - nbase];
ffffffffc020379c:	000c3503          	ld	a0,0(s8)
ffffffffc02037a0:	8f85                	sub	a5,a5,s1
ffffffffc02037a2:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02037a4:	4585                	li	a1,1
ffffffffc02037a6:	953e                	add	a0,a0,a5
ffffffffc02037a8:	d88fe0ef          	jal	ffffffffc0201d30 <free_pages>
     pgdir[0] = 0;
ffffffffc02037ac:	000ab023          	sd	zero,0(s5)
  asm volatile("sfence.vma");
ffffffffc02037b0:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02037b4:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037b6:	00878a63          	beq	a5,s0,ffffffffc02037ca <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02037ba:	ff87a703          	lw	a4,-8(a5)
ffffffffc02037be:	679c                	ld	a5,8(a5)
ffffffffc02037c0:	3d7d                	addiw	s10,s10,-1
ffffffffc02037c2:	40ed8dbb          	subw	s11,s11,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037c6:	fe879ae3          	bne	a5,s0,ffffffffc02037ba <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc02037ca:	200d1a63          	bnez	s10,ffffffffc02039de <swap_init+0x5d0>
     assert(total==0);
ffffffffc02037ce:	1c0d9c63          	bnez	s11,ffffffffc02039a6 <swap_init+0x598>

     cprintf("check_swap() succeeded!\n");
ffffffffc02037d2:	00004517          	auipc	a0,0x4
ffffffffc02037d6:	54650513          	addi	a0,a0,1350 # ffffffffc0207d18 <etext+0x160c>
ffffffffc02037da:	9a7fc0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc02037de:	60ea                	ld	ra,152(sp)
     cprintf("check_swap() succeeded!\n");
ffffffffc02037e0:	644a                	ld	s0,144(sp)
ffffffffc02037e2:	64aa                	ld	s1,136(sp)
ffffffffc02037e4:	79e6                	ld	s3,120(sp)
ffffffffc02037e6:	7a46                	ld	s4,112(sp)
ffffffffc02037e8:	7aa6                	ld	s5,104(sp)
ffffffffc02037ea:	6be6                	ld	s7,88(sp)
ffffffffc02037ec:	6c46                	ld	s8,80(sp)
ffffffffc02037ee:	6ca6                	ld	s9,72(sp)
ffffffffc02037f0:	6d06                	ld	s10,64(sp)
ffffffffc02037f2:	7de2                	ld	s11,56(sp)
}
ffffffffc02037f4:	7b06                	ld	s6,96(sp)
ffffffffc02037f6:	854a                	mv	a0,s2
ffffffffc02037f8:	690a                	ld	s2,128(sp)
ffffffffc02037fa:	610d                	addi	sp,sp,160
ffffffffc02037fc:	8082                	ret
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037fe:	4481                	li	s1,0
ffffffffc0203800:	b95d                	j	ffffffffc02034b6 <swap_init+0xa8>
        assert(PageProperty(p));
ffffffffc0203802:	00004697          	auipc	a3,0x4
ffffffffc0203806:	80668693          	addi	a3,a3,-2042 # ffffffffc0207008 <etext+0x8fc>
ffffffffc020380a:	00003617          	auipc	a2,0x3
ffffffffc020380e:	57e60613          	addi	a2,a2,1406 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203812:	0bc00593          	li	a1,188
ffffffffc0203816:	00004517          	auipc	a0,0x4
ffffffffc020381a:	29a50513          	addi	a0,a0,666 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc020381e:	c57fc0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0203822:	bd1ff0ef          	jal	ffffffffc02033f2 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203826:	00004617          	auipc	a2,0x4
ffffffffc020382a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0207480 <etext+0xd74>
ffffffffc020382e:	06200593          	li	a1,98
ffffffffc0203832:	00004517          	auipc	a0,0x4
ffffffffc0203836:	ba650513          	addi	a0,a0,-1114 # ffffffffc02073d8 <etext+0xccc>
ffffffffc020383a:	c3bfc0ef          	jal	ffffffffc0200474 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020383e:	00004697          	auipc	a3,0x4
ffffffffc0203842:	46268693          	addi	a3,a3,1122 # ffffffffc0207ca0 <etext+0x1594>
ffffffffc0203846:	00003617          	auipc	a2,0x3
ffffffffc020384a:	54260613          	addi	a2,a2,1346 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020384e:	0fc00593          	li	a1,252
ffffffffc0203852:	00004517          	auipc	a0,0x4
ffffffffc0203856:	25e50513          	addi	a0,a0,606 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc020385a:	c1bfc0ef          	jal	ffffffffc0200474 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020385e:	00004697          	auipc	a3,0x4
ffffffffc0203862:	36268693          	addi	a3,a3,866 # ffffffffc0207bc0 <etext+0x14b4>
ffffffffc0203866:	00003617          	auipc	a2,0x3
ffffffffc020386a:	52260613          	addi	a2,a2,1314 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020386e:	0dc00593          	li	a1,220
ffffffffc0203872:	00004517          	auipc	a0,0x4
ffffffffc0203876:	23e50513          	addi	a0,a0,574 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc020387a:	bfbfc0ef          	jal	ffffffffc0200474 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020387e:	00004617          	auipc	a2,0x4
ffffffffc0203882:	21260613          	addi	a2,a2,530 # ffffffffc0207a90 <etext+0x1384>
ffffffffc0203886:	02800593          	li	a1,40
ffffffffc020388a:	00004517          	auipc	a0,0x4
ffffffffc020388e:	22650513          	addi	a0,a0,550 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203892:	e922                	sd	s0,144(sp)
ffffffffc0203894:	e526                	sd	s1,136(sp)
ffffffffc0203896:	e14a                	sd	s2,128(sp)
ffffffffc0203898:	fcce                	sd	s3,120(sp)
ffffffffc020389a:	f8d2                	sd	s4,112(sp)
ffffffffc020389c:	f4d6                	sd	s5,104(sp)
ffffffffc020389e:	f0da                	sd	s6,96(sp)
ffffffffc02038a0:	ecde                	sd	s7,88(sp)
ffffffffc02038a2:	e8e2                	sd	s8,80(sp)
ffffffffc02038a4:	e4e6                	sd	s9,72(sp)
ffffffffc02038a6:	e0ea                	sd	s10,64(sp)
ffffffffc02038a8:	fc6e                	sd	s11,56(sp)
ffffffffc02038aa:	bcbfc0ef          	jal	ffffffffc0200474 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02038ae:	00004697          	auipc	a3,0x4
ffffffffc02038b2:	3da68693          	addi	a3,a3,986 # ffffffffc0207c88 <etext+0x157c>
ffffffffc02038b6:	00003617          	auipc	a2,0x3
ffffffffc02038ba:	4d260613          	addi	a2,a2,1234 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02038be:	0fb00593          	li	a1,251
ffffffffc02038c2:	00004517          	auipc	a0,0x4
ffffffffc02038c6:	1ee50513          	addi	a0,a0,494 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc02038ca:	babfc0ef          	jal	ffffffffc0200474 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02038ce:	00004617          	auipc	a2,0x4
ffffffffc02038d2:	bd260613          	addi	a2,a2,-1070 # ffffffffc02074a0 <etext+0xd94>
ffffffffc02038d6:	07400593          	li	a1,116
ffffffffc02038da:	00004517          	auipc	a0,0x4
ffffffffc02038de:	afe50513          	addi	a0,a0,-1282 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02038e2:	b93fc0ef          	jal	ffffffffc0200474 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02038e6:	00004697          	auipc	a3,0x4
ffffffffc02038ea:	2f268693          	addi	a3,a3,754 # ffffffffc0207bd8 <etext+0x14cc>
ffffffffc02038ee:	00003617          	auipc	a2,0x3
ffffffffc02038f2:	49a60613          	addi	a2,a2,1178 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02038f6:	0dd00593          	li	a1,221
ffffffffc02038fa:	00004517          	auipc	a0,0x4
ffffffffc02038fe:	1b650513          	addi	a0,a0,438 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203902:	b73fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203906:	00004697          	auipc	a3,0x4
ffffffffc020390a:	20a68693          	addi	a3,a3,522 # ffffffffc0207b10 <etext+0x1404>
ffffffffc020390e:	00003617          	auipc	a2,0x3
ffffffffc0203912:	47a60613          	addi	a2,a2,1146 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203916:	0c700593          	li	a1,199
ffffffffc020391a:	00004517          	auipc	a0,0x4
ffffffffc020391e:	19650513          	addi	a0,a0,406 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203922:	b53fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203926:	00003697          	auipc	a3,0x3
ffffffffc020392a:	70a68693          	addi	a3,a3,1802 # ffffffffc0207030 <etext+0x924>
ffffffffc020392e:	00003617          	auipc	a2,0x3
ffffffffc0203932:	45a60613          	addi	a2,a2,1114 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203936:	0bf00593          	li	a1,191
ffffffffc020393a:	00004517          	auipc	a0,0x4
ffffffffc020393e:	17650513          	addi	a0,a0,374 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203942:	b33fc0ef          	jal	ffffffffc0200474 <__panic>
     assert( nr_free == 0);         
ffffffffc0203946:	00004697          	auipc	a3,0x4
ffffffffc020394a:	89268693          	addi	a3,a3,-1902 # ffffffffc02071d8 <etext+0xacc>
ffffffffc020394e:	00003617          	auipc	a2,0x3
ffffffffc0203952:	43a60613          	addi	a2,a2,1082 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203956:	0f300593          	li	a1,243
ffffffffc020395a:	00004517          	auipc	a0,0x4
ffffffffc020395e:	15650513          	addi	a0,a0,342 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203962:	b13fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203966:	00004697          	auipc	a3,0x4
ffffffffc020396a:	1c268693          	addi	a3,a3,450 # ffffffffc0207b28 <etext+0x141c>
ffffffffc020396e:	00003617          	auipc	a2,0x3
ffffffffc0203972:	41a60613          	addi	a2,a2,1050 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203976:	0cc00593          	li	a1,204
ffffffffc020397a:	00004517          	auipc	a0,0x4
ffffffffc020397e:	13650513          	addi	a0,a0,310 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203982:	af3fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(mm != NULL);
ffffffffc0203986:	00004697          	auipc	a3,0x4
ffffffffc020398a:	17a68693          	addi	a3,a3,378 # ffffffffc0207b00 <etext+0x13f4>
ffffffffc020398e:	00003617          	auipc	a2,0x3
ffffffffc0203992:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203996:	0c400593          	li	a1,196
ffffffffc020399a:	00004517          	auipc	a0,0x4
ffffffffc020399e:	11650513          	addi	a0,a0,278 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc02039a2:	ad3fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(total==0);
ffffffffc02039a6:	00004697          	auipc	a3,0x4
ffffffffc02039aa:	36268693          	addi	a3,a3,866 # ffffffffc0207d08 <etext+0x15fc>
ffffffffc02039ae:	00003617          	auipc	a2,0x3
ffffffffc02039b2:	3da60613          	addi	a2,a2,986 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02039b6:	11e00593          	li	a1,286
ffffffffc02039ba:	00004517          	auipc	a0,0x4
ffffffffc02039be:	0f650513          	addi	a0,a0,246 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc02039c2:	ab3fc0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc02039c6:	00004617          	auipc	a2,0x4
ffffffffc02039ca:	9ea60613          	addi	a2,a2,-1558 # ffffffffc02073b0 <etext+0xca4>
ffffffffc02039ce:	06900593          	li	a1,105
ffffffffc02039d2:	00004517          	auipc	a0,0x4
ffffffffc02039d6:	a0650513          	addi	a0,a0,-1530 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02039da:	a9bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(count==0);
ffffffffc02039de:	00004697          	auipc	a3,0x4
ffffffffc02039e2:	31a68693          	addi	a3,a3,794 # ffffffffc0207cf8 <etext+0x15ec>
ffffffffc02039e6:	00003617          	auipc	a2,0x3
ffffffffc02039ea:	3a260613          	addi	a2,a2,930 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02039ee:	11d00593          	li	a1,285
ffffffffc02039f2:	00004517          	auipc	a0,0x4
ffffffffc02039f6:	0be50513          	addi	a0,a0,190 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc02039fa:	a7bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==1);
ffffffffc02039fe:	00004697          	auipc	a3,0x4
ffffffffc0203a02:	24a68693          	addi	a3,a3,586 # ffffffffc0207c48 <etext+0x153c>
ffffffffc0203a06:	00003617          	auipc	a2,0x3
ffffffffc0203a0a:	38260613          	addi	a2,a2,898 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203a0e:	09500593          	li	a1,149
ffffffffc0203a12:	00004517          	auipc	a0,0x4
ffffffffc0203a16:	09e50513          	addi	a0,a0,158 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203a1a:	a5bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a1e:	00004697          	auipc	a3,0x4
ffffffffc0203a22:	1da68693          	addi	a3,a3,474 # ffffffffc0207bf8 <etext+0x14ec>
ffffffffc0203a26:	00003617          	auipc	a2,0x3
ffffffffc0203a2a:	36260613          	addi	a2,a2,866 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203a2e:	0ea00593          	li	a1,234
ffffffffc0203a32:	00004517          	auipc	a0,0x4
ffffffffc0203a36:	07e50513          	addi	a0,a0,126 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203a3a:	a3bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203a3e:	00004697          	auipc	a3,0x4
ffffffffc0203a42:	14268693          	addi	a3,a3,322 # ffffffffc0207b80 <etext+0x1474>
ffffffffc0203a46:	00003617          	auipc	a2,0x3
ffffffffc0203a4a:	34260613          	addi	a2,a2,834 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203a4e:	0d700593          	li	a1,215
ffffffffc0203a52:	00004517          	auipc	a0,0x4
ffffffffc0203a56:	05e50513          	addi	a0,a0,94 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203a5a:	a1bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(ret==0);
ffffffffc0203a5e:	00004697          	auipc	a3,0x4
ffffffffc0203a62:	29268693          	addi	a3,a3,658 # ffffffffc0207cf0 <etext+0x15e4>
ffffffffc0203a66:	00003617          	auipc	a2,0x3
ffffffffc0203a6a:	32260613          	addi	a2,a2,802 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203a6e:	10200593          	li	a1,258
ffffffffc0203a72:	00004517          	auipc	a0,0x4
ffffffffc0203a76:	03e50513          	addi	a0,a0,62 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203a7a:	9fbfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(vma != NULL);
ffffffffc0203a7e:	00004697          	auipc	a3,0x4
ffffffffc0203a82:	0ba68693          	addi	a3,a3,186 # ffffffffc0207b38 <etext+0x142c>
ffffffffc0203a86:	00003617          	auipc	a2,0x3
ffffffffc0203a8a:	30260613          	addi	a2,a2,770 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203a8e:	0cf00593          	li	a1,207
ffffffffc0203a92:	00004517          	auipc	a0,0x4
ffffffffc0203a96:	01e50513          	addi	a0,a0,30 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203a9a:	9dbfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==4);
ffffffffc0203a9e:	00004697          	auipc	a3,0x4
ffffffffc0203aa2:	1da68693          	addi	a3,a3,474 # ffffffffc0207c78 <etext+0x156c>
ffffffffc0203aa6:	00003617          	auipc	a2,0x3
ffffffffc0203aaa:	2e260613          	addi	a2,a2,738 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203aae:	09f00593          	li	a1,159
ffffffffc0203ab2:	00004517          	auipc	a0,0x4
ffffffffc0203ab6:	ffe50513          	addi	a0,a0,-2 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203aba:	9bbfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==4);
ffffffffc0203abe:	00004697          	auipc	a3,0x4
ffffffffc0203ac2:	1ba68693          	addi	a3,a3,442 # ffffffffc0207c78 <etext+0x156c>
ffffffffc0203ac6:	00003617          	auipc	a2,0x3
ffffffffc0203aca:	2c260613          	addi	a2,a2,706 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203ace:	0a100593          	li	a1,161
ffffffffc0203ad2:	00004517          	auipc	a0,0x4
ffffffffc0203ad6:	fde50513          	addi	a0,a0,-34 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203ada:	99bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==2);
ffffffffc0203ade:	00004697          	auipc	a3,0x4
ffffffffc0203ae2:	17a68693          	addi	a3,a3,378 # ffffffffc0207c58 <etext+0x154c>
ffffffffc0203ae6:	00003617          	auipc	a2,0x3
ffffffffc0203aea:	2a260613          	addi	a2,a2,674 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203aee:	09700593          	li	a1,151
ffffffffc0203af2:	00004517          	auipc	a0,0x4
ffffffffc0203af6:	fbe50513          	addi	a0,a0,-66 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203afa:	97bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==2);
ffffffffc0203afe:	00004697          	auipc	a3,0x4
ffffffffc0203b02:	15a68693          	addi	a3,a3,346 # ffffffffc0207c58 <etext+0x154c>
ffffffffc0203b06:	00003617          	auipc	a2,0x3
ffffffffc0203b0a:	28260613          	addi	a2,a2,642 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203b0e:	09900593          	li	a1,153
ffffffffc0203b12:	00004517          	auipc	a0,0x4
ffffffffc0203b16:	f9e50513          	addi	a0,a0,-98 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203b1a:	95bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==3);
ffffffffc0203b1e:	00004697          	auipc	a3,0x4
ffffffffc0203b22:	14a68693          	addi	a3,a3,330 # ffffffffc0207c68 <etext+0x155c>
ffffffffc0203b26:	00003617          	auipc	a2,0x3
ffffffffc0203b2a:	26260613          	addi	a2,a2,610 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203b2e:	09b00593          	li	a1,155
ffffffffc0203b32:	00004517          	auipc	a0,0x4
ffffffffc0203b36:	f7e50513          	addi	a0,a0,-130 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203b3a:	93bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==3);
ffffffffc0203b3e:	00004697          	auipc	a3,0x4
ffffffffc0203b42:	12a68693          	addi	a3,a3,298 # ffffffffc0207c68 <etext+0x155c>
ffffffffc0203b46:	00003617          	auipc	a2,0x3
ffffffffc0203b4a:	24260613          	addi	a2,a2,578 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203b4e:	09d00593          	li	a1,157
ffffffffc0203b52:	00004517          	auipc	a0,0x4
ffffffffc0203b56:	f5e50513          	addi	a0,a0,-162 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203b5a:	91bfc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==1);
ffffffffc0203b5e:	00004697          	auipc	a3,0x4
ffffffffc0203b62:	0ea68693          	addi	a3,a3,234 # ffffffffc0207c48 <etext+0x153c>
ffffffffc0203b66:	00003617          	auipc	a2,0x3
ffffffffc0203b6a:	22260613          	addi	a2,a2,546 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203b6e:	09300593          	li	a1,147
ffffffffc0203b72:	00004517          	auipc	a0,0x4
ffffffffc0203b76:	f3e50513          	addi	a0,a0,-194 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203b7a:	8fbfc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203b7e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b7e:	0009a797          	auipc	a5,0x9a
ffffffffc0203b82:	0ca7b783          	ld	a5,202(a5) # ffffffffc029dc48 <sm>
ffffffffc0203b86:	6b9c                	ld	a5,16(a5)
ffffffffc0203b88:	8782                	jr	a5

ffffffffc0203b8a <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b8a:	0009a797          	auipc	a5,0x9a
ffffffffc0203b8e:	0be7b783          	ld	a5,190(a5) # ffffffffc029dc48 <sm>
ffffffffc0203b92:	739c                	ld	a5,32(a5)
ffffffffc0203b94:	8782                	jr	a5

ffffffffc0203b96 <swap_out>:
{
ffffffffc0203b96:	711d                	addi	sp,sp,-96
ffffffffc0203b98:	ec86                	sd	ra,88(sp)
ffffffffc0203b9a:	e8a2                	sd	s0,80(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b9c:	0e058663          	beqz	a1,ffffffffc0203c88 <swap_out+0xf2>
ffffffffc0203ba0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ba2:	fc4e                	sd	s3,56(sp)
ffffffffc0203ba4:	f852                	sd	s4,48(sp)
ffffffffc0203ba6:	f456                	sd	s5,40(sp)
ffffffffc0203ba8:	f05a                	sd	s6,32(sp)
ffffffffc0203baa:	ec5e                	sd	s7,24(sp)
ffffffffc0203bac:	e4a6                	sd	s1,72(sp)
ffffffffc0203bae:	e862                	sd	s8,16(sp)
ffffffffc0203bb0:	8a2e                	mv	s4,a1
ffffffffc0203bb2:	892a                	mv	s2,a0
ffffffffc0203bb4:	8ab2                	mv	s5,a2
ffffffffc0203bb6:	4401                	li	s0,0
ffffffffc0203bb8:	0009a997          	auipc	s3,0x9a
ffffffffc0203bbc:	09098993          	addi	s3,s3,144 # ffffffffc029dc48 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bc0:	00004b17          	auipc	s6,0x4
ffffffffc0203bc4:	1d8b0b13          	addi	s6,s6,472 # ffffffffc0207d98 <etext+0x168c>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bc8:	00004b97          	auipc	s7,0x4
ffffffffc0203bcc:	1b8b8b93          	addi	s7,s7,440 # ffffffffc0207d80 <etext+0x1674>
ffffffffc0203bd0:	a825                	j	ffffffffc0203c08 <swap_out+0x72>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bd2:	67a2                	ld	a5,8(sp)
ffffffffc0203bd4:	8626                	mv	a2,s1
ffffffffc0203bd6:	85a2                	mv	a1,s0
ffffffffc0203bd8:	7f94                	ld	a3,56(a5)
ffffffffc0203bda:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203bdc:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bde:	82b1                	srli	a3,a3,0xc
ffffffffc0203be0:	0685                	addi	a3,a3,1
ffffffffc0203be2:	d9efc0ef          	jal	ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203be6:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203be8:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203bea:	7d1c                	ld	a5,56(a0)
ffffffffc0203bec:	83b1                	srli	a5,a5,0xc
ffffffffc0203bee:	0785                	addi	a5,a5,1
ffffffffc0203bf0:	07a2                	slli	a5,a5,0x8
ffffffffc0203bf2:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203bf6:	93afe0ef          	jal	ffffffffc0201d30 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203bfa:	01893503          	ld	a0,24(s2)
ffffffffc0203bfe:	85a6                	mv	a1,s1
ffffffffc0203c00:	f32ff0ef          	jal	ffffffffc0203332 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203c04:	048a0d63          	beq	s4,s0,ffffffffc0203c5e <swap_out+0xc8>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203c08:	0009b783          	ld	a5,0(s3)
ffffffffc0203c0c:	8656                	mv	a2,s5
ffffffffc0203c0e:	002c                	addi	a1,sp,8
ffffffffc0203c10:	7b9c                	ld	a5,48(a5)
ffffffffc0203c12:	854a                	mv	a0,s2
ffffffffc0203c14:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203c16:	e12d                	bnez	a0,ffffffffc0203c78 <swap_out+0xe2>
          v=page->pra_vaddr; 
ffffffffc0203c18:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c1a:	01893503          	ld	a0,24(s2)
ffffffffc0203c1e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203c20:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c22:	85a6                	mv	a1,s1
ffffffffc0203c24:	986fe0ef          	jal	ffffffffc0201daa <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c28:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c2a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c2c:	8b85                	andi	a5,a5,1
ffffffffc0203c2e:	cfb9                	beqz	a5,ffffffffc0203c8c <swap_out+0xf6>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203c30:	65a2                	ld	a1,8(sp)
ffffffffc0203c32:	7d9c                	ld	a5,56(a1)
ffffffffc0203c34:	83b1                	srli	a5,a5,0xc
ffffffffc0203c36:	0785                	addi	a5,a5,1
ffffffffc0203c38:	00879513          	slli	a0,a5,0x8
ffffffffc0203c3c:	050010ef          	jal	ffffffffc0204c8c <swapfs_write>
ffffffffc0203c40:	d949                	beqz	a0,ffffffffc0203bd2 <swap_out+0x3c>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c42:	855e                	mv	a0,s7
ffffffffc0203c44:	d3cfc0ef          	jal	ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c48:	0009b783          	ld	a5,0(s3)
ffffffffc0203c4c:	6622                	ld	a2,8(sp)
ffffffffc0203c4e:	4681                	li	a3,0
ffffffffc0203c50:	739c                	ld	a5,32(a5)
ffffffffc0203c52:	85a6                	mv	a1,s1
ffffffffc0203c54:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203c56:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c58:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203c5a:	fa8a17e3          	bne	s4,s0,ffffffffc0203c08 <swap_out+0x72>
ffffffffc0203c5e:	64a6                	ld	s1,72(sp)
ffffffffc0203c60:	6906                	ld	s2,64(sp)
ffffffffc0203c62:	79e2                	ld	s3,56(sp)
ffffffffc0203c64:	7a42                	ld	s4,48(sp)
ffffffffc0203c66:	7aa2                	ld	s5,40(sp)
ffffffffc0203c68:	7b02                	ld	s6,32(sp)
ffffffffc0203c6a:	6be2                	ld	s7,24(sp)
ffffffffc0203c6c:	6c42                	ld	s8,16(sp)
}
ffffffffc0203c6e:	60e6                	ld	ra,88(sp)
ffffffffc0203c70:	8522                	mv	a0,s0
ffffffffc0203c72:	6446                	ld	s0,80(sp)
ffffffffc0203c74:	6125                	addi	sp,sp,96
ffffffffc0203c76:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c78:	85a2                	mv	a1,s0
ffffffffc0203c7a:	00004517          	auipc	a0,0x4
ffffffffc0203c7e:	0be50513          	addi	a0,a0,190 # ffffffffc0207d38 <etext+0x162c>
ffffffffc0203c82:	cfefc0ef          	jal	ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203c86:	bfe1                	j	ffffffffc0203c5e <swap_out+0xc8>
     for (i = 0; i != n; ++ i)
ffffffffc0203c88:	4401                	li	s0,0
ffffffffc0203c8a:	b7d5                	j	ffffffffc0203c6e <swap_out+0xd8>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c8c:	00004697          	auipc	a3,0x4
ffffffffc0203c90:	0dc68693          	addi	a3,a3,220 # ffffffffc0207d68 <etext+0x165c>
ffffffffc0203c94:	00003617          	auipc	a2,0x3
ffffffffc0203c98:	0f460613          	addi	a2,a2,244 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203c9c:	06800593          	li	a1,104
ffffffffc0203ca0:	00004517          	auipc	a0,0x4
ffffffffc0203ca4:	e1050513          	addi	a0,a0,-496 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203ca8:	fccfc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203cac <swap_in>:
{
ffffffffc0203cac:	7179                	addi	sp,sp,-48
ffffffffc0203cae:	e84a                	sd	s2,16(sp)
ffffffffc0203cb0:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203cb2:	4505                	li	a0,1
{
ffffffffc0203cb4:	ec26                	sd	s1,24(sp)
ffffffffc0203cb6:	e44e                	sd	s3,8(sp)
ffffffffc0203cb8:	f406                	sd	ra,40(sp)
ffffffffc0203cba:	f022                	sd	s0,32(sp)
ffffffffc0203cbc:	84ae                	mv	s1,a1
ffffffffc0203cbe:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203cc0:	fe1fd0ef          	jal	ffffffffc0201ca0 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203cc4:	c129                	beqz	a0,ffffffffc0203d06 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203cc6:	842a                	mv	s0,a0
ffffffffc0203cc8:	01893503          	ld	a0,24(s2)
ffffffffc0203ccc:	4601                	li	a2,0
ffffffffc0203cce:	85a6                	mv	a1,s1
ffffffffc0203cd0:	8dafe0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc0203cd4:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203cd6:	6108                	ld	a0,0(a0)
ffffffffc0203cd8:	85a2                	mv	a1,s0
ffffffffc0203cda:	725000ef          	jal	ffffffffc0204bfe <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203cde:	00093583          	ld	a1,0(s2)
ffffffffc0203ce2:	8626                	mv	a2,s1
ffffffffc0203ce4:	00004517          	auipc	a0,0x4
ffffffffc0203ce8:	10450513          	addi	a0,a0,260 # ffffffffc0207de8 <etext+0x16dc>
ffffffffc0203cec:	81a1                	srli	a1,a1,0x8
ffffffffc0203cee:	c92fc0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc0203cf2:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203cf4:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203cf8:	7402                	ld	s0,32(sp)
ffffffffc0203cfa:	64e2                	ld	s1,24(sp)
ffffffffc0203cfc:	6942                	ld	s2,16(sp)
ffffffffc0203cfe:	69a2                	ld	s3,8(sp)
ffffffffc0203d00:	4501                	li	a0,0
ffffffffc0203d02:	6145                	addi	sp,sp,48
ffffffffc0203d04:	8082                	ret
     assert(result!=NULL);
ffffffffc0203d06:	00004697          	auipc	a3,0x4
ffffffffc0203d0a:	0d268693          	addi	a3,a3,210 # ffffffffc0207dd8 <etext+0x16cc>
ffffffffc0203d0e:	00003617          	auipc	a2,0x3
ffffffffc0203d12:	07a60613          	addi	a2,a2,122 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203d16:	07e00593          	li	a1,126
ffffffffc0203d1a:	00004517          	auipc	a0,0x4
ffffffffc0203d1e:	d9650513          	addi	a0,a0,-618 # ffffffffc0207ab0 <etext+0x13a4>
ffffffffc0203d22:	f52fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203d26 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203d26:	00096797          	auipc	a5,0x96
ffffffffc0203d2a:	ea278793          	addi	a5,a5,-350 # ffffffffc0299bc8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203d2e:	f51c                	sd	a5,40(a0)
ffffffffc0203d30:	e79c                	sd	a5,8(a5)
ffffffffc0203d32:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203d34:	4501                	li	a0,0
ffffffffc0203d36:	8082                	ret

ffffffffc0203d38 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203d38:	4501                	li	a0,0
ffffffffc0203d3a:	8082                	ret

ffffffffc0203d3c <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203d3c:	4501                	li	a0,0
ffffffffc0203d3e:	8082                	ret

ffffffffc0203d40 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203d40:	4501                	li	a0,0
ffffffffc0203d42:	8082                	ret

ffffffffc0203d44 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203d44:	711d                	addi	sp,sp,-96
ffffffffc0203d46:	fc4e                	sd	s3,56(sp)
ffffffffc0203d48:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d4a:	00004517          	auipc	a0,0x4
ffffffffc0203d4e:	0de50513          	addi	a0,a0,222 # ffffffffc0207e28 <etext+0x171c>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d52:	698d                	lui	s3,0x3
ffffffffc0203d54:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203d56:	e4a6                	sd	s1,72(sp)
ffffffffc0203d58:	ec86                	sd	ra,88(sp)
ffffffffc0203d5a:	e8a2                	sd	s0,80(sp)
ffffffffc0203d5c:	e0ca                	sd	s2,64(sp)
ffffffffc0203d5e:	f456                	sd	s5,40(sp)
ffffffffc0203d60:	f05a                	sd	s6,32(sp)
ffffffffc0203d62:	ec5e                	sd	s7,24(sp)
ffffffffc0203d64:	e862                	sd	s8,16(sp)
ffffffffc0203d66:	e466                	sd	s9,8(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d68:	c18fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d6c:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_softint_out_size-0x55f8>
    assert(pgfault_num==4);
ffffffffc0203d70:	0009a497          	auipc	s1,0x9a
ffffffffc0203d74:	ee04a483          	lw	s1,-288(s1) # ffffffffc029dc50 <pgfault_num>
ffffffffc0203d78:	4791                	li	a5,4
ffffffffc0203d7a:	14f49963          	bne	s1,a5,ffffffffc0203ecc <_fifo_check_swap+0x188>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d7e:	00004517          	auipc	a0,0x4
ffffffffc0203d82:	0ea50513          	addi	a0,a0,234 # ffffffffc0207e68 <etext+0x175c>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d86:	6a85                	lui	s5,0x1
ffffffffc0203d88:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d8a:	bf6fc0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc0203d8e:	0009a417          	auipc	s0,0x9a
ffffffffc0203d92:	ec240413          	addi	s0,s0,-318 # ffffffffc029dc50 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d96:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_softint_out_size-0x75f8>
    assert(pgfault_num==4);
ffffffffc0203d9a:	401c                	lw	a5,0(s0)
ffffffffc0203d9c:	0007891b          	sext.w	s2,a5
ffffffffc0203da0:	2a979663          	bne	a5,s1,ffffffffc020404c <_fifo_check_swap+0x308>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203da4:	00004517          	auipc	a0,0x4
ffffffffc0203da8:	0ec50513          	addi	a0,a0,236 # ffffffffc0207e90 <etext+0x1784>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dac:	6b91                	lui	s7,0x4
ffffffffc0203dae:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203db0:	bd0fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203db4:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_softint_out_size-0x45f8>
    assert(pgfault_num==4);
ffffffffc0203db8:	401c                	lw	a5,0(s0)
ffffffffc0203dba:	00078c9b          	sext.w	s9,a5
ffffffffc0203dbe:	27279763          	bne	a5,s2,ffffffffc020402c <_fifo_check_swap+0x2e8>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dc2:	00004517          	auipc	a0,0x4
ffffffffc0203dc6:	0f650513          	addi	a0,a0,246 # ffffffffc0207eb8 <etext+0x17ac>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dca:	6489                	lui	s1,0x2
ffffffffc0203dcc:	492d                	li	s2,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dce:	bb2fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dd2:	01248023          	sb	s2,0(s1) # 2000 <_binary_obj___user_softint_out_size-0x65f8>
    assert(pgfault_num==4);
ffffffffc0203dd6:	401c                	lw	a5,0(s0)
ffffffffc0203dd8:	23979a63          	bne	a5,s9,ffffffffc020400c <_fifo_check_swap+0x2c8>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203ddc:	00004517          	auipc	a0,0x4
ffffffffc0203de0:	10450513          	addi	a0,a0,260 # ffffffffc0207ee0 <etext+0x17d4>
ffffffffc0203de4:	b9cfc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203de8:	6795                	lui	a5,0x5
ffffffffc0203dea:	4739                	li	a4,14
ffffffffc0203dec:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_softint_out_size-0x35f8>
    assert(pgfault_num==5);
ffffffffc0203df0:	401c                	lw	a5,0(s0)
ffffffffc0203df2:	4715                	li	a4,5
ffffffffc0203df4:	00078c9b          	sext.w	s9,a5
ffffffffc0203df8:	1ee79a63          	bne	a5,a4,ffffffffc0203fec <_fifo_check_swap+0x2a8>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dfc:	00004517          	auipc	a0,0x4
ffffffffc0203e00:	0bc50513          	addi	a0,a0,188 # ffffffffc0207eb8 <etext+0x17ac>
ffffffffc0203e04:	b7cfc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e08:	01248023          	sb	s2,0(s1)
    assert(pgfault_num==5);
ffffffffc0203e0c:	401c                	lw	a5,0(s0)
ffffffffc0203e0e:	1b979f63          	bne	a5,s9,ffffffffc0203fcc <_fifo_check_swap+0x288>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e12:	00004517          	auipc	a0,0x4
ffffffffc0203e16:	05650513          	addi	a0,a0,86 # ffffffffc0207e68 <etext+0x175c>
ffffffffc0203e1a:	b66fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e1e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203e22:	4018                	lw	a4,0(s0)
ffffffffc0203e24:	4799                	li	a5,6
ffffffffc0203e26:	18f71363          	bne	a4,a5,ffffffffc0203fac <_fifo_check_swap+0x268>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e2a:	00004517          	auipc	a0,0x4
ffffffffc0203e2e:	08e50513          	addi	a0,a0,142 # ffffffffc0207eb8 <etext+0x17ac>
ffffffffc0203e32:	b4efc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e36:	01248023          	sb	s2,0(s1)
    assert(pgfault_num==7);
ffffffffc0203e3a:	4018                	lw	a4,0(s0)
ffffffffc0203e3c:	479d                	li	a5,7
ffffffffc0203e3e:	14f71763          	bne	a4,a5,ffffffffc0203f8c <_fifo_check_swap+0x248>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e42:	00004517          	auipc	a0,0x4
ffffffffc0203e46:	fe650513          	addi	a0,a0,-26 # ffffffffc0207e28 <etext+0x171c>
ffffffffc0203e4a:	b36fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203e4e:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203e52:	4018                	lw	a4,0(s0)
ffffffffc0203e54:	47a1                	li	a5,8
ffffffffc0203e56:	10f71b63          	bne	a4,a5,ffffffffc0203f6c <_fifo_check_swap+0x228>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e5a:	00004517          	auipc	a0,0x4
ffffffffc0203e5e:	03650513          	addi	a0,a0,54 # ffffffffc0207e90 <etext+0x1784>
ffffffffc0203e62:	b1efc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e66:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e6a:	4018                	lw	a4,0(s0)
ffffffffc0203e6c:	47a5                	li	a5,9
ffffffffc0203e6e:	0cf71f63          	bne	a4,a5,ffffffffc0203f4c <_fifo_check_swap+0x208>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e72:	00004517          	auipc	a0,0x4
ffffffffc0203e76:	06e50513          	addi	a0,a0,110 # ffffffffc0207ee0 <etext+0x17d4>
ffffffffc0203e7a:	b06fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e7e:	6795                	lui	a5,0x5
ffffffffc0203e80:	4739                	li	a4,14
ffffffffc0203e82:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_softint_out_size-0x35f8>
    assert(pgfault_num==10);
ffffffffc0203e86:	401c                	lw	a5,0(s0)
ffffffffc0203e88:	4729                	li	a4,10
ffffffffc0203e8a:	0007849b          	sext.w	s1,a5
ffffffffc0203e8e:	08e79f63          	bne	a5,a4,ffffffffc0203f2c <_fifo_check_swap+0x1e8>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e92:	00004517          	auipc	a0,0x4
ffffffffc0203e96:	fd650513          	addi	a0,a0,-42 # ffffffffc0207e68 <etext+0x175c>
ffffffffc0203e9a:	ae6fc0ef          	jal	ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e9e:	6785                	lui	a5,0x1
ffffffffc0203ea0:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_softint_out_size-0x75f8>
ffffffffc0203ea4:	06979463          	bne	a5,s1,ffffffffc0203f0c <_fifo_check_swap+0x1c8>
    assert(pgfault_num==11);
ffffffffc0203ea8:	4018                	lw	a4,0(s0)
ffffffffc0203eaa:	47ad                	li	a5,11
ffffffffc0203eac:	04f71063          	bne	a4,a5,ffffffffc0203eec <_fifo_check_swap+0x1a8>
}
ffffffffc0203eb0:	60e6                	ld	ra,88(sp)
ffffffffc0203eb2:	6446                	ld	s0,80(sp)
ffffffffc0203eb4:	64a6                	ld	s1,72(sp)
ffffffffc0203eb6:	6906                	ld	s2,64(sp)
ffffffffc0203eb8:	79e2                	ld	s3,56(sp)
ffffffffc0203eba:	7a42                	ld	s4,48(sp)
ffffffffc0203ebc:	7aa2                	ld	s5,40(sp)
ffffffffc0203ebe:	7b02                	ld	s6,32(sp)
ffffffffc0203ec0:	6be2                	ld	s7,24(sp)
ffffffffc0203ec2:	6c42                	ld	s8,16(sp)
ffffffffc0203ec4:	6ca2                	ld	s9,8(sp)
ffffffffc0203ec6:	4501                	li	a0,0
ffffffffc0203ec8:	6125                	addi	sp,sp,96
ffffffffc0203eca:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203ecc:	00004697          	auipc	a3,0x4
ffffffffc0203ed0:	dac68693          	addi	a3,a3,-596 # ffffffffc0207c78 <etext+0x156c>
ffffffffc0203ed4:	00003617          	auipc	a2,0x3
ffffffffc0203ed8:	eb460613          	addi	a2,a2,-332 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203edc:	05100593          	li	a1,81
ffffffffc0203ee0:	00004517          	auipc	a0,0x4
ffffffffc0203ee4:	f7050513          	addi	a0,a0,-144 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203ee8:	d8cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==11);
ffffffffc0203eec:	00004697          	auipc	a3,0x4
ffffffffc0203ef0:	0a468693          	addi	a3,a3,164 # ffffffffc0207f90 <etext+0x1884>
ffffffffc0203ef4:	00003617          	auipc	a2,0x3
ffffffffc0203ef8:	e9460613          	addi	a2,a2,-364 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203efc:	07300593          	li	a1,115
ffffffffc0203f00:	00004517          	auipc	a0,0x4
ffffffffc0203f04:	f5050513          	addi	a0,a0,-176 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203f08:	d6cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f0c:	00004697          	auipc	a3,0x4
ffffffffc0203f10:	05c68693          	addi	a3,a3,92 # ffffffffc0207f68 <etext+0x185c>
ffffffffc0203f14:	00003617          	auipc	a2,0x3
ffffffffc0203f18:	e7460613          	addi	a2,a2,-396 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203f1c:	07100593          	li	a1,113
ffffffffc0203f20:	00004517          	auipc	a0,0x4
ffffffffc0203f24:	f3050513          	addi	a0,a0,-208 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203f28:	d4cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==10);
ffffffffc0203f2c:	00004697          	auipc	a3,0x4
ffffffffc0203f30:	02c68693          	addi	a3,a3,44 # ffffffffc0207f58 <etext+0x184c>
ffffffffc0203f34:	00003617          	auipc	a2,0x3
ffffffffc0203f38:	e5460613          	addi	a2,a2,-428 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203f3c:	06f00593          	li	a1,111
ffffffffc0203f40:	00004517          	auipc	a0,0x4
ffffffffc0203f44:	f1050513          	addi	a0,a0,-240 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203f48:	d2cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==9);
ffffffffc0203f4c:	00004697          	auipc	a3,0x4
ffffffffc0203f50:	ffc68693          	addi	a3,a3,-4 # ffffffffc0207f48 <etext+0x183c>
ffffffffc0203f54:	00003617          	auipc	a2,0x3
ffffffffc0203f58:	e3460613          	addi	a2,a2,-460 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203f5c:	06c00593          	li	a1,108
ffffffffc0203f60:	00004517          	auipc	a0,0x4
ffffffffc0203f64:	ef050513          	addi	a0,a0,-272 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203f68:	d0cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==8);
ffffffffc0203f6c:	00004697          	auipc	a3,0x4
ffffffffc0203f70:	fcc68693          	addi	a3,a3,-52 # ffffffffc0207f38 <etext+0x182c>
ffffffffc0203f74:	00003617          	auipc	a2,0x3
ffffffffc0203f78:	e1460613          	addi	a2,a2,-492 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203f7c:	06900593          	li	a1,105
ffffffffc0203f80:	00004517          	auipc	a0,0x4
ffffffffc0203f84:	ed050513          	addi	a0,a0,-304 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203f88:	cecfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f8c:	00004697          	auipc	a3,0x4
ffffffffc0203f90:	f9c68693          	addi	a3,a3,-100 # ffffffffc0207f28 <etext+0x181c>
ffffffffc0203f94:	00003617          	auipc	a2,0x3
ffffffffc0203f98:	df460613          	addi	a2,a2,-524 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203f9c:	06600593          	li	a1,102
ffffffffc0203fa0:	00004517          	auipc	a0,0x4
ffffffffc0203fa4:	eb050513          	addi	a0,a0,-336 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203fa8:	cccfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==6);
ffffffffc0203fac:	00004697          	auipc	a3,0x4
ffffffffc0203fb0:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207f18 <etext+0x180c>
ffffffffc0203fb4:	00003617          	auipc	a2,0x3
ffffffffc0203fb8:	dd460613          	addi	a2,a2,-556 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203fbc:	06300593          	li	a1,99
ffffffffc0203fc0:	00004517          	auipc	a0,0x4
ffffffffc0203fc4:	e9050513          	addi	a0,a0,-368 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203fc8:	cacfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==5);
ffffffffc0203fcc:	00004697          	auipc	a3,0x4
ffffffffc0203fd0:	f3c68693          	addi	a3,a3,-196 # ffffffffc0207f08 <etext+0x17fc>
ffffffffc0203fd4:	00003617          	auipc	a2,0x3
ffffffffc0203fd8:	db460613          	addi	a2,a2,-588 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203fdc:	06000593          	li	a1,96
ffffffffc0203fe0:	00004517          	auipc	a0,0x4
ffffffffc0203fe4:	e7050513          	addi	a0,a0,-400 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0203fe8:	c8cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==5);
ffffffffc0203fec:	00004697          	auipc	a3,0x4
ffffffffc0203ff0:	f1c68693          	addi	a3,a3,-228 # ffffffffc0207f08 <etext+0x17fc>
ffffffffc0203ff4:	00003617          	auipc	a2,0x3
ffffffffc0203ff8:	d9460613          	addi	a2,a2,-620 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0203ffc:	05d00593          	li	a1,93
ffffffffc0204000:	00004517          	auipc	a0,0x4
ffffffffc0204004:	e5050513          	addi	a0,a0,-432 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0204008:	c6cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==4);
ffffffffc020400c:	00004697          	auipc	a3,0x4
ffffffffc0204010:	c6c68693          	addi	a3,a3,-916 # ffffffffc0207c78 <etext+0x156c>
ffffffffc0204014:	00003617          	auipc	a2,0x3
ffffffffc0204018:	d7460613          	addi	a2,a2,-652 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020401c:	05a00593          	li	a1,90
ffffffffc0204020:	00004517          	auipc	a0,0x4
ffffffffc0204024:	e3050513          	addi	a0,a0,-464 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0204028:	c4cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==4);
ffffffffc020402c:	00004697          	auipc	a3,0x4
ffffffffc0204030:	c4c68693          	addi	a3,a3,-948 # ffffffffc0207c78 <etext+0x156c>
ffffffffc0204034:	00003617          	auipc	a2,0x3
ffffffffc0204038:	d5460613          	addi	a2,a2,-684 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020403c:	05700593          	li	a1,87
ffffffffc0204040:	00004517          	auipc	a0,0x4
ffffffffc0204044:	e1050513          	addi	a0,a0,-496 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0204048:	c2cfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==4);
ffffffffc020404c:	00004697          	auipc	a3,0x4
ffffffffc0204050:	c2c68693          	addi	a3,a3,-980 # ffffffffc0207c78 <etext+0x156c>
ffffffffc0204054:	00003617          	auipc	a2,0x3
ffffffffc0204058:	d3460613          	addi	a2,a2,-716 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020405c:	05400593          	li	a1,84
ffffffffc0204060:	00004517          	auipc	a0,0x4
ffffffffc0204064:	df050513          	addi	a0,a0,-528 # ffffffffc0207e50 <etext+0x1744>
ffffffffc0204068:	c0cfc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020406c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020406c:	751c                	ld	a5,40(a0)
{
ffffffffc020406e:	1141                	addi	sp,sp,-16
ffffffffc0204070:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204072:	cf91                	beqz	a5,ffffffffc020408e <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0204074:	ee0d                	bnez	a2,ffffffffc02040ae <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0204076:	679c                	ld	a5,8(a5)
}
ffffffffc0204078:	60a2                	ld	ra,8(sp)
ffffffffc020407a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020407c:	6394                	ld	a3,0(a5)
ffffffffc020407e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204080:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0204084:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204086:	e314                	sd	a3,0(a4)
ffffffffc0204088:	e19c                	sd	a5,0(a1)
}
ffffffffc020408a:	0141                	addi	sp,sp,16
ffffffffc020408c:	8082                	ret
         assert(head != NULL);
ffffffffc020408e:	00004697          	auipc	a3,0x4
ffffffffc0204092:	f1268693          	addi	a3,a3,-238 # ffffffffc0207fa0 <etext+0x1894>
ffffffffc0204096:	00003617          	auipc	a2,0x3
ffffffffc020409a:	cf260613          	addi	a2,a2,-782 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020409e:	04100593          	li	a1,65
ffffffffc02040a2:	00004517          	auipc	a0,0x4
ffffffffc02040a6:	dae50513          	addi	a0,a0,-594 # ffffffffc0207e50 <etext+0x1744>
ffffffffc02040aa:	bcafc0ef          	jal	ffffffffc0200474 <__panic>
     assert(in_tick==0);
ffffffffc02040ae:	00004697          	auipc	a3,0x4
ffffffffc02040b2:	f0268693          	addi	a3,a3,-254 # ffffffffc0207fb0 <etext+0x18a4>
ffffffffc02040b6:	00003617          	auipc	a2,0x3
ffffffffc02040ba:	cd260613          	addi	a2,a2,-814 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02040be:	04200593          	li	a1,66
ffffffffc02040c2:	00004517          	auipc	a0,0x4
ffffffffc02040c6:	d8e50513          	addi	a0,a0,-626 # ffffffffc0207e50 <etext+0x1744>
ffffffffc02040ca:	baafc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02040ce <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040ce:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02040d0:	cb91                	beqz	a5,ffffffffc02040e4 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02040d2:	6394                	ld	a3,0(a5)
ffffffffc02040d4:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc02040d8:	e398                	sd	a4,0(a5)
ffffffffc02040da:	e698                	sd	a4,8(a3)
}
ffffffffc02040dc:	4501                	li	a0,0
    elm->next = next;
ffffffffc02040de:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02040e0:	f614                	sd	a3,40(a2)
ffffffffc02040e2:	8082                	ret
{
ffffffffc02040e4:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02040e6:	00004697          	auipc	a3,0x4
ffffffffc02040ea:	eda68693          	addi	a3,a3,-294 # ffffffffc0207fc0 <etext+0x18b4>
ffffffffc02040ee:	00003617          	auipc	a2,0x3
ffffffffc02040f2:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02040f6:	03200593          	li	a1,50
ffffffffc02040fa:	00004517          	auipc	a0,0x4
ffffffffc02040fe:	d5650513          	addi	a0,a0,-682 # ffffffffc0207e50 <etext+0x1744>
{
ffffffffc0204102:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204104:	b70fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204108 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204108:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020410a:	00004697          	auipc	a3,0x4
ffffffffc020410e:	eee68693          	addi	a3,a3,-274 # ffffffffc0207ff8 <etext+0x18ec>
ffffffffc0204112:	00003617          	auipc	a2,0x3
ffffffffc0204116:	c7660613          	addi	a2,a2,-906 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020411a:	06d00593          	li	a1,109
ffffffffc020411e:	00004517          	auipc	a0,0x4
ffffffffc0204122:	efa50513          	addi	a0,a0,-262 # ffffffffc0208018 <etext+0x190c>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204126:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204128:	b4cfc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020412c <mm_create>:
mm_create(void) {
ffffffffc020412c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020412e:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0204132:	e022                	sd	s0,0(sp)
ffffffffc0204134:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204136:	993fd0ef          	jal	ffffffffc0201ac8 <kmalloc>
ffffffffc020413a:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020413c:	c505                	beqz	a0,ffffffffc0204164 <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc020413e:	e408                	sd	a0,8(s0)
ffffffffc0204140:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204142:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204146:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020414a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020414e:	0009a797          	auipc	a5,0x9a
ffffffffc0204152:	aea7a783          	lw	a5,-1302(a5) # ffffffffc029dc38 <swap_init_ok>
ffffffffc0204156:	ef81                	bnez	a5,ffffffffc020416e <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0204158:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020415c:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0204160:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204164:	60a2                	ld	ra,8(sp)
ffffffffc0204166:	8522                	mv	a0,s0
ffffffffc0204168:	6402                	ld	s0,0(sp)
ffffffffc020416a:	0141                	addi	sp,sp,16
ffffffffc020416c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020416e:	a11ff0ef          	jal	ffffffffc0203b7e <swap_init_mm>
ffffffffc0204172:	b7ed                	j	ffffffffc020415c <mm_create+0x30>

ffffffffc0204174 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204174:	1101                	addi	sp,sp,-32
ffffffffc0204176:	e04a                	sd	s2,0(sp)
ffffffffc0204178:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020417a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020417e:	e822                	sd	s0,16(sp)
ffffffffc0204180:	e426                	sd	s1,8(sp)
ffffffffc0204182:	ec06                	sd	ra,24(sp)
ffffffffc0204184:	84ae                	mv	s1,a1
ffffffffc0204186:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204188:	941fd0ef          	jal	ffffffffc0201ac8 <kmalloc>
    if (vma != NULL) {
ffffffffc020418c:	c509                	beqz	a0,ffffffffc0204196 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020418e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204192:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204194:	cd00                	sw	s0,24(a0)
}
ffffffffc0204196:	60e2                	ld	ra,24(sp)
ffffffffc0204198:	6442                	ld	s0,16(sp)
ffffffffc020419a:	64a2                	ld	s1,8(sp)
ffffffffc020419c:	6902                	ld	s2,0(sp)
ffffffffc020419e:	6105                	addi	sp,sp,32
ffffffffc02041a0:	8082                	ret

ffffffffc02041a2 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02041a2:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02041a4:	c505                	beqz	a0,ffffffffc02041cc <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02041a6:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02041a8:	c501                	beqz	a0,ffffffffc02041b0 <find_vma+0xe>
ffffffffc02041aa:	651c                	ld	a5,8(a0)
ffffffffc02041ac:	02f5f663          	bgeu	a1,a5,ffffffffc02041d8 <find_vma+0x36>
    return listelm->next;
ffffffffc02041b0:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02041b2:	00f68d63          	beq	a3,a5,ffffffffc02041cc <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02041b6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02041ba:	00e5e663          	bltu	a1,a4,ffffffffc02041c6 <find_vma+0x24>
ffffffffc02041be:	ff07b703          	ld	a4,-16(a5)
ffffffffc02041c2:	00e5e763          	bltu	a1,a4,ffffffffc02041d0 <find_vma+0x2e>
ffffffffc02041c6:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02041c8:	fef697e3          	bne	a3,a5,ffffffffc02041b6 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02041cc:	4501                	li	a0,0
}
ffffffffc02041ce:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc02041d0:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02041d4:	ea88                	sd	a0,16(a3)
ffffffffc02041d6:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02041d8:	691c                	ld	a5,16(a0)
ffffffffc02041da:	fcf5fbe3          	bgeu	a1,a5,ffffffffc02041b0 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02041de:	ea88                	sd	a0,16(a3)
ffffffffc02041e0:	8082                	ret

ffffffffc02041e2 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041e2:	6590                	ld	a2,8(a1)
ffffffffc02041e4:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_softint_out_size-0x75e8>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02041e8:	1141                	addi	sp,sp,-16
ffffffffc02041ea:	e406                	sd	ra,8(sp)
ffffffffc02041ec:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041ee:	01066763          	bltu	a2,a6,ffffffffc02041fc <insert_vma_struct+0x1a>
ffffffffc02041f2:	a085                	j	ffffffffc0204252 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02041f4:	fe87b703          	ld	a4,-24(a5)
ffffffffc02041f8:	04e66863          	bltu	a2,a4,ffffffffc0204248 <insert_vma_struct+0x66>
ffffffffc02041fc:	86be                	mv	a3,a5
ffffffffc02041fe:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204200:	fef51ae3          	bne	a0,a5,ffffffffc02041f4 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0204204:	02a68463          	beq	a3,a0,ffffffffc020422c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204208:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020420c:	fe86b883          	ld	a7,-24(a3)
ffffffffc0204210:	08e8f163          	bgeu	a7,a4,ffffffffc0204292 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204214:	04e66f63          	bltu	a2,a4,ffffffffc0204272 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0204218:	00f50a63          	beq	a0,a5,ffffffffc020422c <insert_vma_struct+0x4a>
ffffffffc020421c:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204220:	05076963          	bltu	a4,a6,ffffffffc0204272 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0204224:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204228:	02c77363          	bgeu	a4,a2,ffffffffc020424e <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020422c:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020422e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0204230:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0204234:	e390                	sd	a2,0(a5)
ffffffffc0204236:	e690                	sd	a2,8(a3)
}
ffffffffc0204238:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020423a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020423c:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc020423e:	0017079b          	addiw	a5,a4,1
ffffffffc0204242:	d11c                	sw	a5,32(a0)
}
ffffffffc0204244:	0141                	addi	sp,sp,16
ffffffffc0204246:	8082                	ret
    if (le_prev != list) {
ffffffffc0204248:	fca690e3          	bne	a3,a0,ffffffffc0204208 <insert_vma_struct+0x26>
ffffffffc020424c:	bfd1                	j	ffffffffc0204220 <insert_vma_struct+0x3e>
ffffffffc020424e:	ebbff0ef          	jal	ffffffffc0204108 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204252:	00004697          	auipc	a3,0x4
ffffffffc0204256:	dd668693          	addi	a3,a3,-554 # ffffffffc0208028 <etext+0x191c>
ffffffffc020425a:	00003617          	auipc	a2,0x3
ffffffffc020425e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204262:	07400593          	li	a1,116
ffffffffc0204266:	00004517          	auipc	a0,0x4
ffffffffc020426a:	db250513          	addi	a0,a0,-590 # ffffffffc0208018 <etext+0x190c>
ffffffffc020426e:	a06fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204272:	00004697          	auipc	a3,0x4
ffffffffc0204276:	df668693          	addi	a3,a3,-522 # ffffffffc0208068 <etext+0x195c>
ffffffffc020427a:	00003617          	auipc	a2,0x3
ffffffffc020427e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204282:	06c00593          	li	a1,108
ffffffffc0204286:	00004517          	auipc	a0,0x4
ffffffffc020428a:	d9250513          	addi	a0,a0,-622 # ffffffffc0208018 <etext+0x190c>
ffffffffc020428e:	9e6fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204292:	00004697          	auipc	a3,0x4
ffffffffc0204296:	db668693          	addi	a3,a3,-586 # ffffffffc0208048 <etext+0x193c>
ffffffffc020429a:	00003617          	auipc	a2,0x3
ffffffffc020429e:	aee60613          	addi	a2,a2,-1298 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02042a2:	06b00593          	li	a1,107
ffffffffc02042a6:	00004517          	auipc	a0,0x4
ffffffffc02042aa:	d7250513          	addi	a0,a0,-654 # ffffffffc0208018 <etext+0x190c>
ffffffffc02042ae:	9c6fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02042b2 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02042b2:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02042b4:	1141                	addi	sp,sp,-16
ffffffffc02042b6:	e406                	sd	ra,8(sp)
ffffffffc02042b8:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02042ba:	e78d                	bnez	a5,ffffffffc02042e4 <mm_destroy+0x32>
ffffffffc02042bc:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02042be:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02042c0:	00a40c63          	beq	s0,a0,ffffffffc02042d8 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02042c4:	6118                	ld	a4,0(a0)
ffffffffc02042c6:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02042c8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02042ca:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02042cc:	e398                	sd	a4,0(a5)
ffffffffc02042ce:	8a5fd0ef          	jal	ffffffffc0201b72 <kfree>
    return listelm->next;
ffffffffc02042d2:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02042d4:	fea418e3          	bne	s0,a0,ffffffffc02042c4 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02042d8:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02042da:	6402                	ld	s0,0(sp)
ffffffffc02042dc:	60a2                	ld	ra,8(sp)
ffffffffc02042de:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02042e0:	893fd06f          	j	ffffffffc0201b72 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02042e4:	00004697          	auipc	a3,0x4
ffffffffc02042e8:	da468693          	addi	a3,a3,-604 # ffffffffc0208088 <etext+0x197c>
ffffffffc02042ec:	00003617          	auipc	a2,0x3
ffffffffc02042f0:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02042f4:	09400593          	li	a1,148
ffffffffc02042f8:	00004517          	auipc	a0,0x4
ffffffffc02042fc:	d2050513          	addi	a0,a0,-736 # ffffffffc0208018 <etext+0x190c>
ffffffffc0204300:	974fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204304 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204304:	6785                	lui	a5,0x1
ffffffffc0204306:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x75f9>
       struct vma_struct **vma_store) {
ffffffffc0204308:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020430a:	787d                	lui	a6,0xfffff
ffffffffc020430c:	963e                	add	a2,a2,a5
       struct vma_struct **vma_store) {
ffffffffc020430e:	f822                	sd	s0,48(sp)
ffffffffc0204310:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204312:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0204314:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204316:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc020431a:	002007b7          	lui	a5,0x200
ffffffffc020431e:	01067433          	and	s0,a2,a6
ffffffffc0204322:	08f4e363          	bltu	s1,a5,ffffffffc02043a8 <mm_map+0xa4>
ffffffffc0204326:	0884f163          	bgeu	s1,s0,ffffffffc02043a8 <mm_map+0xa4>
ffffffffc020432a:	4785                	li	a5,1
ffffffffc020432c:	07fe                	slli	a5,a5,0x1f
ffffffffc020432e:	0687ed63          	bltu	a5,s0,ffffffffc02043a8 <mm_map+0xa4>
ffffffffc0204332:	ec4e                	sd	s3,24(sp)
ffffffffc0204334:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0204336:	c93d                	beqz	a0,ffffffffc02043ac <mm_map+0xa8>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0204338:	85a6                	mv	a1,s1
ffffffffc020433a:	e852                	sd	s4,16(sp)
ffffffffc020433c:	e456                	sd	s5,8(sp)
ffffffffc020433e:	8a3a                	mv	s4,a4
ffffffffc0204340:	8ab6                	mv	s5,a3
ffffffffc0204342:	e61ff0ef          	jal	ffffffffc02041a2 <find_vma>
ffffffffc0204346:	c501                	beqz	a0,ffffffffc020434e <mm_map+0x4a>
ffffffffc0204348:	651c                	ld	a5,8(a0)
ffffffffc020434a:	0487ec63          	bltu	a5,s0,ffffffffc02043a2 <mm_map+0x9e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020434e:	03000513          	li	a0,48
ffffffffc0204352:	f04a                	sd	s2,32(sp)
ffffffffc0204354:	f74fd0ef          	jal	ffffffffc0201ac8 <kmalloc>
ffffffffc0204358:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020435a:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020435c:	02090a63          	beqz	s2,ffffffffc0204390 <mm_map+0x8c>
        vma->vm_start = vm_start;
ffffffffc0204360:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204364:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204368:	01592c23          	sw	s5,24(s2)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020436c:	85ca                	mv	a1,s2
ffffffffc020436e:	854e                	mv	a0,s3
ffffffffc0204370:	e73ff0ef          	jal	ffffffffc02041e2 <insert_vma_struct>
    if (vma_store != NULL) {
ffffffffc0204374:	000a0463          	beqz	s4,ffffffffc020437c <mm_map+0x78>
        *vma_store = vma;
ffffffffc0204378:	012a3023          	sd	s2,0(s4)
ffffffffc020437c:	7902                	ld	s2,32(sp)
ffffffffc020437e:	69e2                	ld	s3,24(sp)
ffffffffc0204380:	6a42                	ld	s4,16(sp)
ffffffffc0204382:	6aa2                	ld	s5,8(sp)
    }
    ret = 0;
ffffffffc0204384:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc0204386:	70e2                	ld	ra,56(sp)
ffffffffc0204388:	7442                	ld	s0,48(sp)
ffffffffc020438a:	74a2                	ld	s1,40(sp)
ffffffffc020438c:	6121                	addi	sp,sp,64
ffffffffc020438e:	8082                	ret
ffffffffc0204390:	70e2                	ld	ra,56(sp)
ffffffffc0204392:	7442                	ld	s0,48(sp)
ffffffffc0204394:	7902                	ld	s2,32(sp)
ffffffffc0204396:	69e2                	ld	s3,24(sp)
ffffffffc0204398:	6a42                	ld	s4,16(sp)
ffffffffc020439a:	6aa2                	ld	s5,8(sp)
ffffffffc020439c:	74a2                	ld	s1,40(sp)
ffffffffc020439e:	6121                	addi	sp,sp,64
ffffffffc02043a0:	8082                	ret
ffffffffc02043a2:	69e2                	ld	s3,24(sp)
ffffffffc02043a4:	6a42                	ld	s4,16(sp)
ffffffffc02043a6:	6aa2                	ld	s5,8(sp)
        return -E_INVAL;
ffffffffc02043a8:	5575                	li	a0,-3
ffffffffc02043aa:	bff1                	j	ffffffffc0204386 <mm_map+0x82>
    assert(mm != NULL);
ffffffffc02043ac:	00003697          	auipc	a3,0x3
ffffffffc02043b0:	75468693          	addi	a3,a3,1876 # ffffffffc0207b00 <etext+0x13f4>
ffffffffc02043b4:	00003617          	auipc	a2,0x3
ffffffffc02043b8:	9d460613          	addi	a2,a2,-1580 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02043bc:	0a700593          	li	a1,167
ffffffffc02043c0:	00004517          	auipc	a0,0x4
ffffffffc02043c4:	c5850513          	addi	a0,a0,-936 # ffffffffc0208018 <etext+0x190c>
ffffffffc02043c8:	f04a                	sd	s2,32(sp)
ffffffffc02043ca:	e852                	sd	s4,16(sp)
ffffffffc02043cc:	e456                	sd	s5,8(sp)
ffffffffc02043ce:	8a6fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02043d2 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02043d2:	7139                	addi	sp,sp,-64
ffffffffc02043d4:	fc06                	sd	ra,56(sp)
ffffffffc02043d6:	f822                	sd	s0,48(sp)
ffffffffc02043d8:	f426                	sd	s1,40(sp)
ffffffffc02043da:	f04a                	sd	s2,32(sp)
ffffffffc02043dc:	ec4e                	sd	s3,24(sp)
ffffffffc02043de:	e852                	sd	s4,16(sp)
ffffffffc02043e0:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02043e2:	c525                	beqz	a0,ffffffffc020444a <dup_mmap+0x78>
ffffffffc02043e4:	892a                	mv	s2,a0
ffffffffc02043e6:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02043e8:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02043ea:	c1a5                	beqz	a1,ffffffffc020444a <dup_mmap+0x78>
    return listelm->prev;
ffffffffc02043ec:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02043ee:	04848c63          	beq	s1,s0,ffffffffc0204446 <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043f2:	03000513          	li	a0,48
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043f6:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043fa:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043fe:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204402:	ec6fd0ef          	jal	ffffffffc0201ac8 <kmalloc>
ffffffffc0204406:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0204408:	c50d                	beqz	a0,ffffffffc0204432 <dup_mmap+0x60>
        vma->vm_start = vm_start;
ffffffffc020440a:	01553423          	sd	s5,8(a0)
ffffffffc020440e:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204412:	01352c23          	sw	s3,24(a0)
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204416:	854a                	mv	a0,s2
ffffffffc0204418:	dcbff0ef          	jal	ffffffffc02041e2 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc020441c:	ff043683          	ld	a3,-16(s0)
ffffffffc0204420:	fe843603          	ld	a2,-24(s0)
ffffffffc0204424:	6c8c                	ld	a1,24(s1)
ffffffffc0204426:	01893503          	ld	a0,24(s2)
ffffffffc020442a:	4701                	li	a4,0
ffffffffc020442c:	cdbfe0ef          	jal	ffffffffc0203106 <copy_range>
ffffffffc0204430:	dd55                	beqz	a0,ffffffffc02043ec <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0204432:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0204434:	70e2                	ld	ra,56(sp)
ffffffffc0204436:	7442                	ld	s0,48(sp)
ffffffffc0204438:	74a2                	ld	s1,40(sp)
ffffffffc020443a:	7902                	ld	s2,32(sp)
ffffffffc020443c:	69e2                	ld	s3,24(sp)
ffffffffc020443e:	6a42                	ld	s4,16(sp)
ffffffffc0204440:	6aa2                	ld	s5,8(sp)
ffffffffc0204442:	6121                	addi	sp,sp,64
ffffffffc0204444:	8082                	ret
    return 0;
ffffffffc0204446:	4501                	li	a0,0
ffffffffc0204448:	b7f5                	j	ffffffffc0204434 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc020444a:	00004697          	auipc	a3,0x4
ffffffffc020444e:	c5668693          	addi	a3,a3,-938 # ffffffffc02080a0 <etext+0x1994>
ffffffffc0204452:	00003617          	auipc	a2,0x3
ffffffffc0204456:	93660613          	addi	a2,a2,-1738 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020445a:	0c000593          	li	a1,192
ffffffffc020445e:	00004517          	auipc	a0,0x4
ffffffffc0204462:	bba50513          	addi	a0,a0,-1094 # ffffffffc0208018 <etext+0x190c>
ffffffffc0204466:	80efc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020446a <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020446a:	1101                	addi	sp,sp,-32
ffffffffc020446c:	ec06                	sd	ra,24(sp)
ffffffffc020446e:	e822                	sd	s0,16(sp)
ffffffffc0204470:	e426                	sd	s1,8(sp)
ffffffffc0204472:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204474:	c531                	beqz	a0,ffffffffc02044c0 <exit_mmap+0x56>
ffffffffc0204476:	591c                	lw	a5,48(a0)
ffffffffc0204478:	84aa                	mv	s1,a0
ffffffffc020447a:	e3b9                	bnez	a5,ffffffffc02044c0 <exit_mmap+0x56>
    return listelm->next;
ffffffffc020447c:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020447e:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204482:	02850663          	beq	a0,s0,ffffffffc02044ae <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204486:	ff043603          	ld	a2,-16(s0)
ffffffffc020448a:	fe843583          	ld	a1,-24(s0)
ffffffffc020448e:	854a                	mv	a0,s2
ffffffffc0204490:	b47fd0ef          	jal	ffffffffc0201fd6 <unmap_range>
ffffffffc0204494:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204496:	fe8498e3          	bne	s1,s0,ffffffffc0204486 <exit_mmap+0x1c>
ffffffffc020449a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020449c:	00848c63          	beq	s1,s0,ffffffffc02044b4 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02044a0:	ff043603          	ld	a2,-16(s0)
ffffffffc02044a4:	fe843583          	ld	a1,-24(s0)
ffffffffc02044a8:	854a                	mv	a0,s2
ffffffffc02044aa:	c57fd0ef          	jal	ffffffffc0202100 <exit_range>
ffffffffc02044ae:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02044b0:	fe8498e3          	bne	s1,s0,ffffffffc02044a0 <exit_mmap+0x36>
    }
}
ffffffffc02044b4:	60e2                	ld	ra,24(sp)
ffffffffc02044b6:	6442                	ld	s0,16(sp)
ffffffffc02044b8:	64a2                	ld	s1,8(sp)
ffffffffc02044ba:	6902                	ld	s2,0(sp)
ffffffffc02044bc:	6105                	addi	sp,sp,32
ffffffffc02044be:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02044c0:	00004697          	auipc	a3,0x4
ffffffffc02044c4:	c0068693          	addi	a3,a3,-1024 # ffffffffc02080c0 <etext+0x19b4>
ffffffffc02044c8:	00003617          	auipc	a2,0x3
ffffffffc02044cc:	8c060613          	addi	a2,a2,-1856 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02044d0:	0d600593          	li	a1,214
ffffffffc02044d4:	00004517          	auipc	a0,0x4
ffffffffc02044d8:	b4450513          	addi	a0,a0,-1212 # ffffffffc0208018 <etext+0x190c>
ffffffffc02044dc:	f99fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02044e0 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02044e0:	7139                	addi	sp,sp,-64
ffffffffc02044e2:	f822                	sd	s0,48(sp)
ffffffffc02044e4:	f426                	sd	s1,40(sp)
ffffffffc02044e6:	fc06                	sd	ra,56(sp)
ffffffffc02044e8:	f04a                	sd	s2,32(sp)
ffffffffc02044ea:	ec4e                	sd	s3,24(sp)
ffffffffc02044ec:	e852                	sd	s4,16(sp)
ffffffffc02044ee:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02044f0:	c3dff0ef          	jal	ffffffffc020412c <mm_create>
    assert(mm != NULL);
ffffffffc02044f4:	842a                	mv	s0,a0
ffffffffc02044f6:	03200493          	li	s1,50
ffffffffc02044fa:	38050463          	beqz	a0,ffffffffc0204882 <vmm_init+0x3a2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044fe:	03000513          	li	a0,48
ffffffffc0204502:	dc6fd0ef          	jal	ffffffffc0201ac8 <kmalloc>
ffffffffc0204506:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0204508:	26050d63          	beqz	a0,ffffffffc0204782 <vmm_init+0x2a2>
        vma->vm_end = vm_end;
ffffffffc020450c:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0204510:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204512:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204514:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0204518:	14ed                	addi	s1,s1,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020451a:	8522                	mv	a0,s0
ffffffffc020451c:	cc7ff0ef          	jal	ffffffffc02041e2 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204520:	fcf9                	bnez	s1,ffffffffc02044fe <vmm_init+0x1e>
ffffffffc0204522:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204526:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020452a:	03000513          	li	a0,48
ffffffffc020452e:	d9afd0ef          	jal	ffffffffc0201ac8 <kmalloc>
ffffffffc0204532:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0204534:	26050763          	beqz	a0,ffffffffc02047a2 <vmm_init+0x2c2>
        vma->vm_end = vm_end;
ffffffffc0204538:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc020453c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020453e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204540:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204544:	0495                	addi	s1,s1,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204546:	8522                	mv	a0,s0
ffffffffc0204548:	c9bff0ef          	jal	ffffffffc02041e2 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020454c:	fd249fe3          	bne	s1,s2,ffffffffc020452a <vmm_init+0x4a>
ffffffffc0204550:	641c                	ld	a5,8(s0)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0204552:	30878863          	beq	a5,s0,ffffffffc0204862 <vmm_init+0x382>
ffffffffc0204556:	4715                	li	a4,5
    for (i = 1; i <= step2; i ++) {
ffffffffc0204558:	1f400593          	li	a1,500
ffffffffc020455c:	a021                	j	ffffffffc0204564 <vmm_init+0x84>
        assert(le != &(mm->mmap_list));
ffffffffc020455e:	0715                	addi	a4,a4,5
ffffffffc0204560:	30878163          	beq	a5,s0,ffffffffc0204862 <vmm_init+0x382>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204564:	fe87b683          	ld	a3,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f6488>
ffffffffc0204568:	2ae69d63          	bne	a3,a4,ffffffffc0204822 <vmm_init+0x342>
ffffffffc020456c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204570:	00270693          	addi	a3,a4,2
ffffffffc0204574:	2ad61763          	bne	a2,a3,ffffffffc0204822 <vmm_init+0x342>
ffffffffc0204578:	679c                	ld	a5,8(a5)
    for (i = 1; i <= step2; i ++) {
ffffffffc020457a:	feb712e3          	bne	a4,a1,ffffffffc020455e <vmm_init+0x7e>
ffffffffc020457e:	4a1d                	li	s4,7
ffffffffc0204580:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204582:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204586:	85a6                	mv	a1,s1
ffffffffc0204588:	8522                	mv	a0,s0
ffffffffc020458a:	c19ff0ef          	jal	ffffffffc02041a2 <find_vma>
ffffffffc020458e:	89aa                	mv	s3,a0
        assert(vma1 != NULL);
ffffffffc0204590:	2a050963          	beqz	a0,ffffffffc0204842 <vmm_init+0x362>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204594:	00148593          	addi	a1,s1,1
ffffffffc0204598:	8522                	mv	a0,s0
ffffffffc020459a:	c09ff0ef          	jal	ffffffffc02041a2 <find_vma>
ffffffffc020459e:	892a                	mv	s2,a0
        assert(vma2 != NULL);
ffffffffc02045a0:	36050163          	beqz	a0,ffffffffc0204902 <vmm_init+0x422>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02045a4:	85d2                	mv	a1,s4
ffffffffc02045a6:	8522                	mv	a0,s0
ffffffffc02045a8:	bfbff0ef          	jal	ffffffffc02041a2 <find_vma>
        assert(vma3 == NULL);
ffffffffc02045ac:	32051b63          	bnez	a0,ffffffffc02048e2 <vmm_init+0x402>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02045b0:	00348593          	addi	a1,s1,3
ffffffffc02045b4:	8522                	mv	a0,s0
ffffffffc02045b6:	bedff0ef          	jal	ffffffffc02041a2 <find_vma>
        assert(vma4 == NULL);
ffffffffc02045ba:	30051463          	bnez	a0,ffffffffc02048c2 <vmm_init+0x3e2>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02045be:	00448593          	addi	a1,s1,4
ffffffffc02045c2:	8522                	mv	a0,s0
ffffffffc02045c4:	bdfff0ef          	jal	ffffffffc02041a2 <find_vma>
        assert(vma5 == NULL);
ffffffffc02045c8:	2c051d63          	bnez	a0,ffffffffc02048a2 <vmm_init+0x3c2>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02045cc:	0089b783          	ld	a5,8(s3)
ffffffffc02045d0:	22979963          	bne	a5,s1,ffffffffc0204802 <vmm_init+0x322>
ffffffffc02045d4:	0109b783          	ld	a5,16(s3)
ffffffffc02045d8:	23479563          	bne	a5,s4,ffffffffc0204802 <vmm_init+0x322>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02045dc:	00893783          	ld	a5,8(s2)
ffffffffc02045e0:	20979163          	bne	a5,s1,ffffffffc02047e2 <vmm_init+0x302>
ffffffffc02045e4:	01093783          	ld	a5,16(s2)
ffffffffc02045e8:	1f479d63          	bne	a5,s4,ffffffffc02047e2 <vmm_init+0x302>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045ec:	0495                	addi	s1,s1,5
ffffffffc02045ee:	0a15                	addi	s4,s4,5
ffffffffc02045f0:	f9549be3          	bne	s1,s5,ffffffffc0204586 <vmm_init+0xa6>
ffffffffc02045f4:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045f6:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045f8:	85a6                	mv	a1,s1
ffffffffc02045fa:	8522                	mv	a0,s0
ffffffffc02045fc:	ba7ff0ef          	jal	ffffffffc02041a2 <find_vma>
        if (vma_below_5 != NULL ) {
ffffffffc0204600:	38051163          	bnez	a0,ffffffffc0204982 <vmm_init+0x4a2>
    for (i =4; i>=0; i--) {
ffffffffc0204604:	14fd                	addi	s1,s1,-1
ffffffffc0204606:	ff2499e3          	bne	s1,s2,ffffffffc02045f8 <vmm_init+0x118>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc020460a:	8522                	mv	a0,s0
ffffffffc020460c:	ca7ff0ef          	jal	ffffffffc02042b2 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0204610:	00004517          	auipc	a0,0x4
ffffffffc0204614:	c1050513          	addi	a0,a0,-1008 # ffffffffc0208220 <etext+0x1b14>
ffffffffc0204618:	b69fb0ef          	jal	ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020461c:	f54fd0ef          	jal	ffffffffc0201d70 <nr_free_pages>
ffffffffc0204620:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0204622:	b0bff0ef          	jal	ffffffffc020412c <mm_create>
ffffffffc0204626:	00099797          	auipc	a5,0x99
ffffffffc020462a:	62a7b923          	sd	a0,1586(a5) # ffffffffc029dc58 <check_mm_struct>
ffffffffc020462e:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0204630:	32050963          	beqz	a0,ffffffffc0204962 <vmm_init+0x482>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204634:	00099497          	auipc	s1,0x99
ffffffffc0204638:	5e44b483          	ld	s1,1508(s1) # ffffffffc029dc18 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020463c:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020463e:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204640:	30079163          	bnez	a5,ffffffffc0204942 <vmm_init+0x462>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204644:	03000513          	li	a0,48
ffffffffc0204648:	c80fd0ef          	jal	ffffffffc0201ac8 <kmalloc>
ffffffffc020464c:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc020464e:	16050a63          	beqz	a0,ffffffffc02047c2 <vmm_init+0x2e2>
        vma->vm_end = vm_end;
ffffffffc0204652:	002007b7          	lui	a5,0x200
ffffffffc0204656:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204658:	4789                	li	a5,2
ffffffffc020465a:	cd1c                	sw	a5,24(a0)

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020465c:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020465e:	00053423          	sd	zero,8(a0)
    insert_vma_struct(mm, vma);
ffffffffc0204662:	8522                	mv	a0,s0
ffffffffc0204664:	b7fff0ef          	jal	ffffffffc02041e2 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204668:	10000593          	li	a1,256
ffffffffc020466c:	8522                	mv	a0,s0
ffffffffc020466e:	b35ff0ef          	jal	ffffffffc02041a2 <find_vma>
ffffffffc0204672:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204676:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020467a:	2aa99463          	bne	s3,a0,ffffffffc0204922 <vmm_init+0x442>
        *(char *)(addr + i) = i;
ffffffffc020467e:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f64a0>
    for (i = 0; i < 100; i ++) {
ffffffffc0204682:	0785                	addi	a5,a5,1
ffffffffc0204684:	fee79de3          	bne	a5,a4,ffffffffc020467e <vmm_init+0x19e>
ffffffffc0204688:	6705                	lui	a4,0x1
ffffffffc020468a:	10000793          	li	a5,256
ffffffffc020468e:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_softint_out_size-0x72a2>
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204692:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204696:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020469a:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020469c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020469e:	fec79ce3          	bne	a5,a2,ffffffffc0204696 <vmm_init+0x1b6>
    }

    assert(sum == 0);
ffffffffc02046a2:	36071263          	bnez	a4,ffffffffc0204a06 <vmm_init+0x526>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046a6:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02046a8:	00099a97          	auipc	s5,0x99
ffffffffc02046ac:	580a8a93          	addi	s5,s5,1408 # ffffffffc029dc28 <npage>
ffffffffc02046b0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046b4:	078a                	slli	a5,a5,0x2
ffffffffc02046b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046b8:	32e7fb63          	bgeu	a5,a4,ffffffffc02049ee <vmm_init+0x50e>
    return &pages[PPN(pa) - nbase];
ffffffffc02046bc:	00004a17          	auipc	s4,0x4
ffffffffc02046c0:	74ca3a03          	ld	s4,1868(s4) # ffffffffc0208e08 <nbase>
ffffffffc02046c4:	414786b3          	sub	a3,a5,s4
ffffffffc02046c8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046ca:	8699                	srai	a3,a3,0x6
ffffffffc02046cc:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046ce:	00c69793          	slli	a5,a3,0xc
ffffffffc02046d2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02046d4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046d6:	30e7f063          	bgeu	a5,a4,ffffffffc02049d6 <vmm_init+0x4f6>
ffffffffc02046da:	00099797          	auipc	a5,0x99
ffffffffc02046de:	5467b783          	ld	a5,1350(a5) # ffffffffc029dc20 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046e2:	4581                	li	a1,0
ffffffffc02046e4:	8526                	mv	a0,s1
ffffffffc02046e6:	00f689b3          	add	s3,a3,a5
ffffffffc02046ea:	cf1fd0ef          	jal	ffffffffc02023da <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046ee:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02046f2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046f6:	078a                	slli	a5,a5,0x2
ffffffffc02046f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046fa:	2ee7fa63          	bgeu	a5,a4,ffffffffc02049ee <vmm_init+0x50e>
    return &pages[PPN(pa) - nbase];
ffffffffc02046fe:	00099997          	auipc	s3,0x99
ffffffffc0204702:	53298993          	addi	s3,s3,1330 # ffffffffc029dc30 <pages>
ffffffffc0204706:	0009b503          	ld	a0,0(s3)
ffffffffc020470a:	414787b3          	sub	a5,a5,s4
ffffffffc020470e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204710:	953e                	add	a0,a0,a5
ffffffffc0204712:	4585                	li	a1,1
ffffffffc0204714:	e1cfd0ef          	jal	ffffffffc0201d30 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204718:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020471a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020471e:	078a                	slli	a5,a5,0x2
ffffffffc0204720:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204722:	2ce7f663          	bgeu	a5,a4,ffffffffc02049ee <vmm_init+0x50e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204726:	0009b503          	ld	a0,0(s3)
ffffffffc020472a:	414787b3          	sub	a5,a5,s4
ffffffffc020472e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204730:	4585                	li	a1,1
ffffffffc0204732:	953e                	add	a0,a0,a5
ffffffffc0204734:	dfcfd0ef          	jal	ffffffffc0201d30 <free_pages>
    pgdir[0] = 0;
ffffffffc0204738:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc020473c:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204740:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0204744:	8522                	mv	a0,s0
ffffffffc0204746:	b6dff0ef          	jal	ffffffffc02042b2 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020474a:	00099797          	auipc	a5,0x99
ffffffffc020474e:	5007b723          	sd	zero,1294(a5) # ffffffffc029dc58 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204752:	e1efd0ef          	jal	ffffffffc0201d70 <nr_free_pages>
ffffffffc0204756:	26a91063          	bne	s2,a0,ffffffffc02049b6 <vmm_init+0x4d6>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020475a:	00004517          	auipc	a0,0x4
ffffffffc020475e:	b5650513          	addi	a0,a0,-1194 # ffffffffc02082b0 <etext+0x1ba4>
ffffffffc0204762:	a1ffb0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc0204766:	7442                	ld	s0,48(sp)
ffffffffc0204768:	70e2                	ld	ra,56(sp)
ffffffffc020476a:	74a2                	ld	s1,40(sp)
ffffffffc020476c:	7902                	ld	s2,32(sp)
ffffffffc020476e:	69e2                	ld	s3,24(sp)
ffffffffc0204770:	6a42                	ld	s4,16(sp)
ffffffffc0204772:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204774:	00004517          	auipc	a0,0x4
ffffffffc0204778:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02082d0 <etext+0x1bc4>
}
ffffffffc020477c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020477e:	a03fb06f          	j	ffffffffc0200180 <cprintf>
        assert(vma != NULL);
ffffffffc0204782:	00003697          	auipc	a3,0x3
ffffffffc0204786:	3b668693          	addi	a3,a3,950 # ffffffffc0207b38 <etext+0x142c>
ffffffffc020478a:	00002617          	auipc	a2,0x2
ffffffffc020478e:	5fe60613          	addi	a2,a2,1534 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204792:	11300593          	li	a1,275
ffffffffc0204796:	00004517          	auipc	a0,0x4
ffffffffc020479a:	88250513          	addi	a0,a0,-1918 # ffffffffc0208018 <etext+0x190c>
ffffffffc020479e:	cd7fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma != NULL);
ffffffffc02047a2:	00003697          	auipc	a3,0x3
ffffffffc02047a6:	39668693          	addi	a3,a3,918 # ffffffffc0207b38 <etext+0x142c>
ffffffffc02047aa:	00002617          	auipc	a2,0x2
ffffffffc02047ae:	5de60613          	addi	a2,a2,1502 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02047b2:	11900593          	li	a1,281
ffffffffc02047b6:	00004517          	auipc	a0,0x4
ffffffffc02047ba:	86250513          	addi	a0,a0,-1950 # ffffffffc0208018 <etext+0x190c>
ffffffffc02047be:	cb7fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(vma != NULL);
ffffffffc02047c2:	00003697          	auipc	a3,0x3
ffffffffc02047c6:	37668693          	addi	a3,a3,886 # ffffffffc0207b38 <etext+0x142c>
ffffffffc02047ca:	00002617          	auipc	a2,0x2
ffffffffc02047ce:	5be60613          	addi	a2,a2,1470 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02047d2:	15200593          	li	a1,338
ffffffffc02047d6:	00004517          	auipc	a0,0x4
ffffffffc02047da:	84250513          	addi	a0,a0,-1982 # ffffffffc0208018 <etext+0x190c>
ffffffffc02047de:	c97fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047e2:	00004697          	auipc	a3,0x4
ffffffffc02047e6:	9ce68693          	addi	a3,a3,-1586 # ffffffffc02081b0 <etext+0x1aa4>
ffffffffc02047ea:	00002617          	auipc	a2,0x2
ffffffffc02047ee:	59e60613          	addi	a2,a2,1438 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02047f2:	13300593          	li	a1,307
ffffffffc02047f6:	00004517          	auipc	a0,0x4
ffffffffc02047fa:	82250513          	addi	a0,a0,-2014 # ffffffffc0208018 <etext+0x190c>
ffffffffc02047fe:	c77fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204802:	00004697          	auipc	a3,0x4
ffffffffc0204806:	97e68693          	addi	a3,a3,-1666 # ffffffffc0208180 <etext+0x1a74>
ffffffffc020480a:	00002617          	auipc	a2,0x2
ffffffffc020480e:	57e60613          	addi	a2,a2,1406 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204812:	13200593          	li	a1,306
ffffffffc0204816:	00004517          	auipc	a0,0x4
ffffffffc020481a:	80250513          	addi	a0,a0,-2046 # ffffffffc0208018 <etext+0x190c>
ffffffffc020481e:	c57fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204822:	00004697          	auipc	a3,0x4
ffffffffc0204826:	8d668693          	addi	a3,a3,-1834 # ffffffffc02080f8 <etext+0x19ec>
ffffffffc020482a:	00002617          	auipc	a2,0x2
ffffffffc020482e:	55e60613          	addi	a2,a2,1374 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204832:	12200593          	li	a1,290
ffffffffc0204836:	00003517          	auipc	a0,0x3
ffffffffc020483a:	7e250513          	addi	a0,a0,2018 # ffffffffc0208018 <etext+0x190c>
ffffffffc020483e:	c37fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma1 != NULL);
ffffffffc0204842:	00004697          	auipc	a3,0x4
ffffffffc0204846:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0208130 <etext+0x1a24>
ffffffffc020484a:	00002617          	auipc	a2,0x2
ffffffffc020484e:	53e60613          	addi	a2,a2,1342 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204852:	12800593          	li	a1,296
ffffffffc0204856:	00003517          	auipc	a0,0x3
ffffffffc020485a:	7c250513          	addi	a0,a0,1986 # ffffffffc0208018 <etext+0x190c>
ffffffffc020485e:	c17fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204862:	00004697          	auipc	a3,0x4
ffffffffc0204866:	87e68693          	addi	a3,a3,-1922 # ffffffffc02080e0 <etext+0x19d4>
ffffffffc020486a:	00002617          	auipc	a2,0x2
ffffffffc020486e:	51e60613          	addi	a2,a2,1310 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204872:	12000593          	li	a1,288
ffffffffc0204876:	00003517          	auipc	a0,0x3
ffffffffc020487a:	7a250513          	addi	a0,a0,1954 # ffffffffc0208018 <etext+0x190c>
ffffffffc020487e:	bf7fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(mm != NULL);
ffffffffc0204882:	00003697          	auipc	a3,0x3
ffffffffc0204886:	27e68693          	addi	a3,a3,638 # ffffffffc0207b00 <etext+0x13f4>
ffffffffc020488a:	00002617          	auipc	a2,0x2
ffffffffc020488e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204892:	10c00593          	li	a1,268
ffffffffc0204896:	00003517          	auipc	a0,0x3
ffffffffc020489a:	78250513          	addi	a0,a0,1922 # ffffffffc0208018 <etext+0x190c>
ffffffffc020489e:	bd7fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma5 == NULL);
ffffffffc02048a2:	00004697          	auipc	a3,0x4
ffffffffc02048a6:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0208170 <etext+0x1a64>
ffffffffc02048aa:	00002617          	auipc	a2,0x2
ffffffffc02048ae:	4de60613          	addi	a2,a2,1246 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02048b2:	13000593          	li	a1,304
ffffffffc02048b6:	00003517          	auipc	a0,0x3
ffffffffc02048ba:	76250513          	addi	a0,a0,1890 # ffffffffc0208018 <etext+0x190c>
ffffffffc02048be:	bb7fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma4 == NULL);
ffffffffc02048c2:	00004697          	auipc	a3,0x4
ffffffffc02048c6:	89e68693          	addi	a3,a3,-1890 # ffffffffc0208160 <etext+0x1a54>
ffffffffc02048ca:	00002617          	auipc	a2,0x2
ffffffffc02048ce:	4be60613          	addi	a2,a2,1214 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02048d2:	12e00593          	li	a1,302
ffffffffc02048d6:	00003517          	auipc	a0,0x3
ffffffffc02048da:	74250513          	addi	a0,a0,1858 # ffffffffc0208018 <etext+0x190c>
ffffffffc02048de:	b97fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma3 == NULL);
ffffffffc02048e2:	00004697          	auipc	a3,0x4
ffffffffc02048e6:	86e68693          	addi	a3,a3,-1938 # ffffffffc0208150 <etext+0x1a44>
ffffffffc02048ea:	00002617          	auipc	a2,0x2
ffffffffc02048ee:	49e60613          	addi	a2,a2,1182 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02048f2:	12c00593          	li	a1,300
ffffffffc02048f6:	00003517          	auipc	a0,0x3
ffffffffc02048fa:	72250513          	addi	a0,a0,1826 # ffffffffc0208018 <etext+0x190c>
ffffffffc02048fe:	b77fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma2 != NULL);
ffffffffc0204902:	00004697          	auipc	a3,0x4
ffffffffc0204906:	83e68693          	addi	a3,a3,-1986 # ffffffffc0208140 <etext+0x1a34>
ffffffffc020490a:	00002617          	auipc	a2,0x2
ffffffffc020490e:	47e60613          	addi	a2,a2,1150 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204912:	12a00593          	li	a1,298
ffffffffc0204916:	00003517          	auipc	a0,0x3
ffffffffc020491a:	70250513          	addi	a0,a0,1794 # ffffffffc0208018 <etext+0x190c>
ffffffffc020491e:	b57fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204922:	00004697          	auipc	a3,0x4
ffffffffc0204926:	93668693          	addi	a3,a3,-1738 # ffffffffc0208258 <etext+0x1b4c>
ffffffffc020492a:	00002617          	auipc	a2,0x2
ffffffffc020492e:	45e60613          	addi	a2,a2,1118 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204932:	15700593          	li	a1,343
ffffffffc0204936:	00003517          	auipc	a0,0x3
ffffffffc020493a:	6e250513          	addi	a0,a0,1762 # ffffffffc0208018 <etext+0x190c>
ffffffffc020493e:	b37fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204942:	00003697          	auipc	a3,0x3
ffffffffc0204946:	1e668693          	addi	a3,a3,486 # ffffffffc0207b28 <etext+0x141c>
ffffffffc020494a:	00002617          	auipc	a2,0x2
ffffffffc020494e:	43e60613          	addi	a2,a2,1086 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204952:	14f00593          	li	a1,335
ffffffffc0204956:	00003517          	auipc	a0,0x3
ffffffffc020495a:	6c250513          	addi	a0,a0,1730 # ffffffffc0208018 <etext+0x190c>
ffffffffc020495e:	b17fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204962:	00004697          	auipc	a3,0x4
ffffffffc0204966:	8de68693          	addi	a3,a3,-1826 # ffffffffc0208240 <etext+0x1b34>
ffffffffc020496a:	00002617          	auipc	a2,0x2
ffffffffc020496e:	41e60613          	addi	a2,a2,1054 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204972:	14b00593          	li	a1,331
ffffffffc0204976:	00003517          	auipc	a0,0x3
ffffffffc020497a:	6a250513          	addi	a0,a0,1698 # ffffffffc0208018 <etext+0x190c>
ffffffffc020497e:	af7fb0ef          	jal	ffffffffc0200474 <__panic>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204982:	6914                	ld	a3,16(a0)
ffffffffc0204984:	6510                	ld	a2,8(a0)
ffffffffc0204986:	0004859b          	sext.w	a1,s1
ffffffffc020498a:	00004517          	auipc	a0,0x4
ffffffffc020498e:	85650513          	addi	a0,a0,-1962 # ffffffffc02081e0 <etext+0x1ad4>
ffffffffc0204992:	feefb0ef          	jal	ffffffffc0200180 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0204996:	00004697          	auipc	a3,0x4
ffffffffc020499a:	87268693          	addi	a3,a3,-1934 # ffffffffc0208208 <etext+0x1afc>
ffffffffc020499e:	00002617          	auipc	a2,0x2
ffffffffc02049a2:	3ea60613          	addi	a2,a2,1002 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02049a6:	13b00593          	li	a1,315
ffffffffc02049aa:	00003517          	auipc	a0,0x3
ffffffffc02049ae:	66e50513          	addi	a0,a0,1646 # ffffffffc0208018 <etext+0x190c>
ffffffffc02049b2:	ac3fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02049b6:	00004697          	auipc	a3,0x4
ffffffffc02049ba:	8d268693          	addi	a3,a3,-1838 # ffffffffc0208288 <etext+0x1b7c>
ffffffffc02049be:	00002617          	auipc	a2,0x2
ffffffffc02049c2:	3ca60613          	addi	a2,a2,970 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02049c6:	17000593          	li	a1,368
ffffffffc02049ca:	00003517          	auipc	a0,0x3
ffffffffc02049ce:	64e50513          	addi	a0,a0,1614 # ffffffffc0208018 <etext+0x190c>
ffffffffc02049d2:	aa3fb0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc02049d6:	00003617          	auipc	a2,0x3
ffffffffc02049da:	9da60613          	addi	a2,a2,-1574 # ffffffffc02073b0 <etext+0xca4>
ffffffffc02049de:	06900593          	li	a1,105
ffffffffc02049e2:	00003517          	auipc	a0,0x3
ffffffffc02049e6:	9f650513          	addi	a0,a0,-1546 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02049ea:	a8bfb0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02049ee:	00003617          	auipc	a2,0x3
ffffffffc02049f2:	a9260613          	addi	a2,a2,-1390 # ffffffffc0207480 <etext+0xd74>
ffffffffc02049f6:	06200593          	li	a1,98
ffffffffc02049fa:	00003517          	auipc	a0,0x3
ffffffffc02049fe:	9de50513          	addi	a0,a0,-1570 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0204a02:	a73fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(sum == 0);
ffffffffc0204a06:	00004697          	auipc	a3,0x4
ffffffffc0204a0a:	87268693          	addi	a3,a3,-1934 # ffffffffc0208278 <etext+0x1b6c>
ffffffffc0204a0e:	00002617          	auipc	a2,0x2
ffffffffc0204a12:	37a60613          	addi	a2,a2,890 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0204a16:	16300593          	li	a1,355
ffffffffc0204a1a:	00003517          	auipc	a0,0x3
ffffffffc0204a1e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0208018 <etext+0x190c>
ffffffffc0204a22:	a53fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204a26 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a26:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a28:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a2a:	f822                	sd	s0,48(sp)
ffffffffc0204a2c:	f426                	sd	s1,40(sp)
ffffffffc0204a2e:	fc06                	sd	ra,56(sp)
ffffffffc0204a30:	f04a                	sd	s2,32(sp)
ffffffffc0204a32:	8432                	mv	s0,a2
ffffffffc0204a34:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a36:	f6cff0ef          	jal	ffffffffc02041a2 <find_vma>

    pgfault_num++;
ffffffffc0204a3a:	00099797          	auipc	a5,0x99
ffffffffc0204a3e:	2167a783          	lw	a5,534(a5) # ffffffffc029dc50 <pgfault_num>
ffffffffc0204a42:	2785                	addiw	a5,a5,1
ffffffffc0204a44:	00099717          	auipc	a4,0x99
ffffffffc0204a48:	20f72623          	sw	a5,524(a4) # ffffffffc029dc50 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204a4c:	c555                	beqz	a0,ffffffffc0204af8 <do_pgfault+0xd2>
ffffffffc0204a4e:	651c                	ld	a5,8(a0)
ffffffffc0204a50:	0af46463          	bltu	s0,a5,ffffffffc0204af8 <do_pgfault+0xd2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a54:	4d1c                	lw	a5,24(a0)
ffffffffc0204a56:	ec4e                	sd	s3,24(sp)
        perm |= READ_WRITE;
ffffffffc0204a58:	49dd                	li	s3,23
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a5a:	8b89                	andi	a5,a5,2
ffffffffc0204a5c:	cfb9                	beqz	a5,ffffffffc0204aba <do_pgfault+0x94>
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a5e:	77fd                	lui	a5,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a60:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a62:	8c7d                	and	s0,s0,a5
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a64:	4605                	li	a2,1
ffffffffc0204a66:	85a2                	mv	a1,s0
ffffffffc0204a68:	b42fd0ef          	jal	ffffffffc0201daa <get_pte>
ffffffffc0204a6c:	c555                	beqz	a0,ffffffffc0204b18 <do_pgfault+0xf2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204a6e:	610c                	ld	a1,0(a0)
ffffffffc0204a70:	c5ad                	beqz	a1,ffffffffc0204ada <do_pgfault+0xb4>
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */


        if (swap_init_ok) {
ffffffffc0204a72:	00099797          	auipc	a5,0x99
ffffffffc0204a76:	1c67a783          	lw	a5,454(a5) # ffffffffc029dc38 <swap_init_ok>
ffffffffc0204a7a:	cbc1                	beqz	a5,ffffffffc0204b0a <do_pgfault+0xe4>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0204a7c:	0030                	addi	a2,sp,8
ffffffffc0204a7e:	85a2                	mv	a1,s0
ffffffffc0204a80:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204a82:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0204a84:	a28ff0ef          	jal	ffffffffc0203cac <swap_in>
ffffffffc0204a88:	892a                	mv	s2,a0
ffffffffc0204a8a:	e915                	bnez	a0,ffffffffc0204abe <do_pgfault+0x98>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0204a8c:	65a2                	ld	a1,8(sp)
ffffffffc0204a8e:	6c88                	ld	a0,24(s1)
ffffffffc0204a90:	86ce                	mv	a3,s3
ffffffffc0204a92:	8622                	mv	a2,s0
ffffffffc0204a94:	9e3fd0ef          	jal	ffffffffc0202476 <page_insert>

            swap_map_swappable(mm,addr,page,1); 
ffffffffc0204a98:	6622                	ld	a2,8(sp)
ffffffffc0204a9a:	4685                	li	a3,1
ffffffffc0204a9c:	85a2                	mv	a1,s0
ffffffffc0204a9e:	8526                	mv	a0,s1
ffffffffc0204aa0:	8eaff0ef          	jal	ffffffffc0203b8a <swap_map_swappable>


            page->pra_vaddr = addr;
ffffffffc0204aa4:	67a2                	ld	a5,8(sp)
ffffffffc0204aa6:	ff80                	sd	s0,56(a5)
ffffffffc0204aa8:	69e2                	ld	s3,24(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0204aaa:	4901                	li	s2,0
failed:
    return ret;
}
ffffffffc0204aac:	70e2                	ld	ra,56(sp)
ffffffffc0204aae:	7442                	ld	s0,48(sp)
ffffffffc0204ab0:	74a2                	ld	s1,40(sp)
ffffffffc0204ab2:	854a                	mv	a0,s2
ffffffffc0204ab4:	7902                	ld	s2,32(sp)
ffffffffc0204ab6:	6121                	addi	sp,sp,64
ffffffffc0204ab8:	8082                	ret
    uint32_t perm = PTE_U;
ffffffffc0204aba:	49c1                	li	s3,16
ffffffffc0204abc:	b74d                	j	ffffffffc0204a5e <do_pgfault+0x38>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204abe:	00004517          	auipc	a0,0x4
ffffffffc0204ac2:	8a250513          	addi	a0,a0,-1886 # ffffffffc0208360 <etext+0x1c54>
ffffffffc0204ac6:	ebafb0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc0204aca:	70e2                	ld	ra,56(sp)
ffffffffc0204acc:	7442                	ld	s0,48(sp)
ffffffffc0204ace:	69e2                	ld	s3,24(sp)
ffffffffc0204ad0:	74a2                	ld	s1,40(sp)
ffffffffc0204ad2:	854a                	mv	a0,s2
ffffffffc0204ad4:	7902                	ld	s2,32(sp)
ffffffffc0204ad6:	6121                	addi	sp,sp,64
ffffffffc0204ad8:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204ada:	6c88                	ld	a0,24(s1)
ffffffffc0204adc:	864e                	mv	a2,s3
ffffffffc0204ade:	85a2                	mv	a1,s0
ffffffffc0204ae0:	859fe0ef          	jal	ffffffffc0203338 <pgdir_alloc_page>
ffffffffc0204ae4:	f171                	bnez	a0,ffffffffc0204aa8 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204ae6:	00004517          	auipc	a0,0x4
ffffffffc0204aea:	85250513          	addi	a0,a0,-1966 # ffffffffc0208338 <etext+0x1c2c>
ffffffffc0204aee:	e92fb0ef          	jal	ffffffffc0200180 <cprintf>
            goto failed;
ffffffffc0204af2:	69e2                	ld	s3,24(sp)
    ret = -E_NO_MEM;
ffffffffc0204af4:	5971                	li	s2,-4
ffffffffc0204af6:	bf5d                	j	ffffffffc0204aac <do_pgfault+0x86>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204af8:	85a2                	mv	a1,s0
ffffffffc0204afa:	00003517          	auipc	a0,0x3
ffffffffc0204afe:	7ee50513          	addi	a0,a0,2030 # ffffffffc02082e8 <etext+0x1bdc>
ffffffffc0204b02:	e7efb0ef          	jal	ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204b06:	5975                	li	s2,-3
        goto failed;
ffffffffc0204b08:	b755                	j	ffffffffc0204aac <do_pgfault+0x86>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204b0a:	00004517          	auipc	a0,0x4
ffffffffc0204b0e:	87650513          	addi	a0,a0,-1930 # ffffffffc0208380 <etext+0x1c74>
ffffffffc0204b12:	e6efb0ef          	jal	ffffffffc0200180 <cprintf>
            goto failed;
ffffffffc0204b16:	bff1                	j	ffffffffc0204af2 <do_pgfault+0xcc>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204b18:	00004517          	auipc	a0,0x4
ffffffffc0204b1c:	80050513          	addi	a0,a0,-2048 # ffffffffc0208318 <etext+0x1c0c>
ffffffffc0204b20:	e60fb0ef          	jal	ffffffffc0200180 <cprintf>
        goto failed;
ffffffffc0204b24:	b7f9                	j	ffffffffc0204af2 <do_pgfault+0xcc>

ffffffffc0204b26 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204b26:	7179                	addi	sp,sp,-48
ffffffffc0204b28:	f022                	sd	s0,32(sp)
ffffffffc0204b2a:	f406                	sd	ra,40(sp)
ffffffffc0204b2c:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204b2e:	c535                	beqz	a0,ffffffffc0204b9a <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204b30:	002007b7          	lui	a5,0x200
ffffffffc0204b34:	04f5ee63          	bltu	a1,a5,ffffffffc0204b90 <user_mem_check+0x6a>
ffffffffc0204b38:	ec26                	sd	s1,24(sp)
ffffffffc0204b3a:	00c584b3          	add	s1,a1,a2
ffffffffc0204b3e:	0695fc63          	bgeu	a1,s1,ffffffffc0204bb6 <user_mem_check+0x90>
ffffffffc0204b42:	4785                	li	a5,1
ffffffffc0204b44:	07fe                	slli	a5,a5,0x1f
ffffffffc0204b46:	0697e863          	bltu	a5,s1,ffffffffc0204bb6 <user_mem_check+0x90>
ffffffffc0204b4a:	e84a                	sd	s2,16(sp)
ffffffffc0204b4c:	e44e                	sd	s3,8(sp)
ffffffffc0204b4e:	e052                	sd	s4,0(sp)
ffffffffc0204b50:	892a                	mv	s2,a0
ffffffffc0204b52:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204b54:	6a05                	lui	s4,0x1
ffffffffc0204b56:	a821                	j	ffffffffc0204b6e <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b58:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204b5c:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204b5e:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b60:	c685                	beqz	a3,ffffffffc0204b88 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204b62:	c399                	beqz	a5,ffffffffc0204b68 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204b64:	02e46263          	bltu	s0,a4,ffffffffc0204b88 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204b68:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204b6a:	04947863          	bgeu	s0,s1,ffffffffc0204bba <user_mem_check+0x94>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204b6e:	85a2                	mv	a1,s0
ffffffffc0204b70:	854a                	mv	a0,s2
ffffffffc0204b72:	e30ff0ef          	jal	ffffffffc02041a2 <find_vma>
ffffffffc0204b76:	c909                	beqz	a0,ffffffffc0204b88 <user_mem_check+0x62>
ffffffffc0204b78:	6518                	ld	a4,8(a0)
ffffffffc0204b7a:	00e46763          	bltu	s0,a4,ffffffffc0204b88 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204b7e:	4d1c                	lw	a5,24(a0)
ffffffffc0204b80:	fc099ce3          	bnez	s3,ffffffffc0204b58 <user_mem_check+0x32>
ffffffffc0204b84:	8b85                	andi	a5,a5,1
ffffffffc0204b86:	f3ed                	bnez	a5,ffffffffc0204b68 <user_mem_check+0x42>
ffffffffc0204b88:	64e2                	ld	s1,24(sp)
ffffffffc0204b8a:	6942                	ld	s2,16(sp)
ffffffffc0204b8c:	69a2                	ld	s3,8(sp)
ffffffffc0204b8e:	6a02                	ld	s4,0(sp)
            return 0;
ffffffffc0204b90:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b92:	70a2                	ld	ra,40(sp)
ffffffffc0204b94:	7402                	ld	s0,32(sp)
ffffffffc0204b96:	6145                	addi	sp,sp,48
ffffffffc0204b98:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b9a:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b9e:	4501                	li	a0,0
ffffffffc0204ba0:	fef5e9e3          	bltu	a1,a5,ffffffffc0204b92 <user_mem_check+0x6c>
ffffffffc0204ba4:	962e                	add	a2,a2,a1
ffffffffc0204ba6:	fec5f6e3          	bgeu	a1,a2,ffffffffc0204b92 <user_mem_check+0x6c>
ffffffffc0204baa:	c8000537          	lui	a0,0xc8000
ffffffffc0204bae:	0505                	addi	a0,a0,1 # ffffffffc8000001 <end+0x7d62381>
ffffffffc0204bb0:	00a63533          	sltu	a0,a2,a0
ffffffffc0204bb4:	bff9                	j	ffffffffc0204b92 <user_mem_check+0x6c>
ffffffffc0204bb6:	64e2                	ld	s1,24(sp)
ffffffffc0204bb8:	bfe1                	j	ffffffffc0204b90 <user_mem_check+0x6a>
ffffffffc0204bba:	64e2                	ld	s1,24(sp)
ffffffffc0204bbc:	6942                	ld	s2,16(sp)
ffffffffc0204bbe:	69a2                	ld	s3,8(sp)
ffffffffc0204bc0:	6a02                	ld	s4,0(sp)
        return 1;
ffffffffc0204bc2:	4505                	li	a0,1
ffffffffc0204bc4:	b7f9                	j	ffffffffc0204b92 <user_mem_check+0x6c>

ffffffffc0204bc6 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204bc6:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204bc8:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204bca:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204bcc:	a1bfb0ef          	jal	ffffffffc02005e6 <ide_device_valid>
ffffffffc0204bd0:	cd01                	beqz	a0,ffffffffc0204be8 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204bd2:	4505                	li	a0,1
ffffffffc0204bd4:	a19fb0ef          	jal	ffffffffc02005ec <ide_device_size>
}
ffffffffc0204bd8:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204bda:	810d                	srli	a0,a0,0x3
ffffffffc0204bdc:	00099797          	auipc	a5,0x99
ffffffffc0204be0:	06a7b223          	sd	a0,100(a5) # ffffffffc029dc40 <max_swap_offset>
}
ffffffffc0204be4:	0141                	addi	sp,sp,16
ffffffffc0204be6:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204be8:	00003617          	auipc	a2,0x3
ffffffffc0204bec:	7c060613          	addi	a2,a2,1984 # ffffffffc02083a8 <etext+0x1c9c>
ffffffffc0204bf0:	45b5                	li	a1,13
ffffffffc0204bf2:	00003517          	auipc	a0,0x3
ffffffffc0204bf6:	7d650513          	addi	a0,a0,2006 # ffffffffc02083c8 <etext+0x1cbc>
ffffffffc0204bfa:	87bfb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204bfe <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204bfe:	1141                	addi	sp,sp,-16
ffffffffc0204c00:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c02:	00855793          	srli	a5,a0,0x8
ffffffffc0204c06:	cbb1                	beqz	a5,ffffffffc0204c5a <swapfs_read+0x5c>
ffffffffc0204c08:	00099717          	auipc	a4,0x99
ffffffffc0204c0c:	03873703          	ld	a4,56(a4) # ffffffffc029dc40 <max_swap_offset>
ffffffffc0204c10:	04e7f563          	bgeu	a5,a4,ffffffffc0204c5a <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204c14:	00099717          	auipc	a4,0x99
ffffffffc0204c18:	01c73703          	ld	a4,28(a4) # ffffffffc029dc30 <pages>
ffffffffc0204c1c:	8d99                	sub	a1,a1,a4
ffffffffc0204c1e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c22:	00004717          	auipc	a4,0x4
ffffffffc0204c26:	1e673703          	ld	a4,486(a4) # ffffffffc0208e08 <nbase>
ffffffffc0204c2a:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c2c:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c30:	8331                	srli	a4,a4,0xc
ffffffffc0204c32:	00099697          	auipc	a3,0x99
ffffffffc0204c36:	ff66b683          	ld	a3,-10(a3) # ffffffffc029dc28 <npage>
ffffffffc0204c3a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c3e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c40:	02d77963          	bgeu	a4,a3,ffffffffc0204c72 <swapfs_read+0x74>
}
ffffffffc0204c44:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c46:	00099797          	auipc	a5,0x99
ffffffffc0204c4a:	fda7b783          	ld	a5,-38(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc0204c4e:	46a1                	li	a3,8
ffffffffc0204c50:	963e                	add	a2,a2,a5
ffffffffc0204c52:	4505                	li	a0,1
}
ffffffffc0204c54:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c56:	99dfb06f          	j	ffffffffc02005f2 <ide_read_secs>
ffffffffc0204c5a:	86aa                	mv	a3,a0
ffffffffc0204c5c:	00003617          	auipc	a2,0x3
ffffffffc0204c60:	78460613          	addi	a2,a2,1924 # ffffffffc02083e0 <etext+0x1cd4>
ffffffffc0204c64:	45d1                	li	a1,20
ffffffffc0204c66:	00003517          	auipc	a0,0x3
ffffffffc0204c6a:	76250513          	addi	a0,a0,1890 # ffffffffc02083c8 <etext+0x1cbc>
ffffffffc0204c6e:	807fb0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0204c72:	86b2                	mv	a3,a2
ffffffffc0204c74:	06900593          	li	a1,105
ffffffffc0204c78:	00002617          	auipc	a2,0x2
ffffffffc0204c7c:	73860613          	addi	a2,a2,1848 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0204c80:	00002517          	auipc	a0,0x2
ffffffffc0204c84:	75850513          	addi	a0,a0,1880 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0204c88:	fecfb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204c8c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c8c:	1141                	addi	sp,sp,-16
ffffffffc0204c8e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c90:	00855793          	srli	a5,a0,0x8
ffffffffc0204c94:	cbb1                	beqz	a5,ffffffffc0204ce8 <swapfs_write+0x5c>
ffffffffc0204c96:	00099717          	auipc	a4,0x99
ffffffffc0204c9a:	faa73703          	ld	a4,-86(a4) # ffffffffc029dc40 <max_swap_offset>
ffffffffc0204c9e:	04e7f563          	bgeu	a5,a4,ffffffffc0204ce8 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204ca2:	00099717          	auipc	a4,0x99
ffffffffc0204ca6:	f8e73703          	ld	a4,-114(a4) # ffffffffc029dc30 <pages>
ffffffffc0204caa:	8d99                	sub	a1,a1,a4
ffffffffc0204cac:	4065d613          	srai	a2,a1,0x6
ffffffffc0204cb0:	00004717          	auipc	a4,0x4
ffffffffc0204cb4:	15873703          	ld	a4,344(a4) # ffffffffc0208e08 <nbase>
ffffffffc0204cb8:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204cba:	00c61713          	slli	a4,a2,0xc
ffffffffc0204cbe:	8331                	srli	a4,a4,0xc
ffffffffc0204cc0:	00099697          	auipc	a3,0x99
ffffffffc0204cc4:	f686b683          	ld	a3,-152(a3) # ffffffffc029dc28 <npage>
ffffffffc0204cc8:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ccc:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204cce:	02d77963          	bgeu	a4,a3,ffffffffc0204d00 <swapfs_write+0x74>
}
ffffffffc0204cd2:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cd4:	00099797          	auipc	a5,0x99
ffffffffc0204cd8:	f4c7b783          	ld	a5,-180(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc0204cdc:	46a1                	li	a3,8
ffffffffc0204cde:	963e                	add	a2,a2,a5
ffffffffc0204ce0:	4505                	li	a0,1
}
ffffffffc0204ce2:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ce4:	933fb06f          	j	ffffffffc0200616 <ide_write_secs>
ffffffffc0204ce8:	86aa                	mv	a3,a0
ffffffffc0204cea:	00003617          	auipc	a2,0x3
ffffffffc0204cee:	6f660613          	addi	a2,a2,1782 # ffffffffc02083e0 <etext+0x1cd4>
ffffffffc0204cf2:	45e5                	li	a1,25
ffffffffc0204cf4:	00003517          	auipc	a0,0x3
ffffffffc0204cf8:	6d450513          	addi	a0,a0,1748 # ffffffffc02083c8 <etext+0x1cbc>
ffffffffc0204cfc:	f78fb0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0204d00:	86b2                	mv	a3,a2
ffffffffc0204d02:	06900593          	li	a1,105
ffffffffc0204d06:	00002617          	auipc	a2,0x2
ffffffffc0204d0a:	6aa60613          	addi	a2,a2,1706 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0204d0e:	00002517          	auipc	a0,0x2
ffffffffc0204d12:	6ca50513          	addi	a0,a0,1738 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0204d16:	f5efb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204d1a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204d1a:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204d1c:	9402                	jalr	s0

	jal do_exit
ffffffffc0204d1e:	668000ef          	jal	ffffffffc0205386 <do_exit>

ffffffffc0204d22 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d22:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d24:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d28:	e022                	sd	s0,0(sp)
ffffffffc0204d2a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d2c:	d9dfc0ef          	jal	ffffffffc0201ac8 <kmalloc>
ffffffffc0204d30:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d32:	cd21                	beqz	a0,ffffffffc0204d8a <alloc_proc+0x68>
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */

    
    proc->state = PROC_UNINIT;
ffffffffc0204d34:	57fd                	li	a5,-1
ffffffffc0204d36:	1782                	slli	a5,a5,0x20
ffffffffc0204d38:	e11c                	sd	a5,0(a0)
    proc->tf = NULL;

    proc->flags = 0;


    proc->cr3 = boot_cr3;
ffffffffc0204d3a:	00099797          	auipc	a5,0x99
ffffffffc0204d3e:	ed67b783          	ld	a5,-298(a5) # ffffffffc029dc10 <boot_cr3>
ffffffffc0204d42:	f55c                	sd	a5,168(a0)
    proc->kstack = 0;
ffffffffc0204d44:	00053823          	sd	zero,16(a0)
    proc->runs = 0;
ffffffffc0204d48:	00052423          	sw	zero,8(a0)
    proc->need_resched  = 0;
ffffffffc0204d4c:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204d50:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204d54:	02053423          	sd	zero,40(a0)
    proc->tf = NULL;
ffffffffc0204d58:	0a053023          	sd	zero,160(a0)
    proc->flags = 0;
ffffffffc0204d5c:	0a052823          	sw	zero,176(a0)

    memset(&(proc->context), 0, sizeof(struct context)); 
ffffffffc0204d60:	07000613          	li	a2,112
ffffffffc0204d64:	4581                	li	a1,0
ffffffffc0204d66:	03050513          	addi	a0,a0,48
ffffffffc0204d6a:	179010ef          	jal	ffffffffc02066e2 <memset>
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204d6e:	463d                	li	a2,15
ffffffffc0204d70:	4581                	li	a1,0
ffffffffc0204d72:	0b440513          	addi	a0,s0,180
ffffffffc0204d76:	16d010ef          	jal	ffffffffc02066e2 <memset>

    proc->yptr=NULL;
ffffffffc0204d7a:	0e043c23          	sd	zero,248(s0)
    proc->optr=NULL;
ffffffffc0204d7e:	10043023          	sd	zero,256(s0)
    proc->cptr=NULL;
ffffffffc0204d82:	0e043823          	sd	zero,240(s0)

    proc->wait_state=0;
ffffffffc0204d86:	0e042623          	sw	zero,236(s0)
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    }
    return proc;
}
ffffffffc0204d8a:	60a2                	ld	ra,8(sp)
ffffffffc0204d8c:	8522                	mv	a0,s0
ffffffffc0204d8e:	6402                	ld	s0,0(sp)
ffffffffc0204d90:	0141                	addi	sp,sp,16
ffffffffc0204d92:	8082                	ret

ffffffffc0204d94 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d94:	00099797          	auipc	a5,0x99
ffffffffc0204d98:	ed47b783          	ld	a5,-300(a5) # ffffffffc029dc68 <current>
ffffffffc0204d9c:	73c8                	ld	a0,160(a5)
ffffffffc0204d9e:	fbdfb06f          	j	ffffffffc0200d5a <forkrets>

ffffffffc0204da2 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204da2:	00099797          	auipc	a5,0x99
ffffffffc0204da6:	ec67b783          	ld	a5,-314(a5) # ffffffffc029dc68 <current>
ffffffffc0204daa:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204dac:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dae:	00003617          	auipc	a2,0x3
ffffffffc0204db2:	65260613          	addi	a2,a2,1618 # ffffffffc0208400 <etext+0x1cf4>
ffffffffc0204db6:	00003517          	auipc	a0,0x3
ffffffffc0204dba:	65a50513          	addi	a0,a0,1626 # ffffffffc0208410 <etext+0x1d04>
user_main(void *arg) {
ffffffffc0204dbe:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dc0:	bc0fb0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc0204dc4:	3fe04797          	auipc	a5,0x3fe04
ffffffffc0204dc8:	4dc78793          	addi	a5,a5,1244 # 92a0 <_binary_obj___user_forktest_out_size>
ffffffffc0204dcc:	e43e                	sd	a5,8(sp)
ffffffffc0204dce:	00003517          	auipc	a0,0x3
ffffffffc0204dd2:	63250513          	addi	a0,a0,1586 # ffffffffc0208400 <etext+0x1cf4>
ffffffffc0204dd6:	0003d797          	auipc	a5,0x3d
ffffffffc0204dda:	3c278793          	addi	a5,a5,962 # ffffffffc0242198 <_binary_obj___user_forktest_out_start>
ffffffffc0204dde:	f03e                	sd	a5,32(sp)
ffffffffc0204de0:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204de2:	e802                	sd	zero,16(sp)
ffffffffc0204de4:	069010ef          	jal	ffffffffc020664c <strlen>
ffffffffc0204de8:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204dea:	4511                	li	a0,4
ffffffffc0204dec:	55a2                	lw	a1,40(sp)
ffffffffc0204dee:	4662                	lw	a2,24(sp)
ffffffffc0204df0:	5682                	lw	a3,32(sp)
ffffffffc0204df2:	4722                	lw	a4,8(sp)
ffffffffc0204df4:	48a9                	li	a7,10
ffffffffc0204df6:	9002                	ebreak
ffffffffc0204df8:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204dfa:	65c2                	ld	a1,16(sp)
ffffffffc0204dfc:	00003517          	auipc	a0,0x3
ffffffffc0204e00:	63c50513          	addi	a0,a0,1596 # ffffffffc0208438 <etext+0x1d2c>
ffffffffc0204e04:	b7cfb0ef          	jal	ffffffffc0200180 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e08:	00003617          	auipc	a2,0x3
ffffffffc0204e0c:	64060613          	addi	a2,a2,1600 # ffffffffc0208448 <etext+0x1d3c>
ffffffffc0204e10:	38100593          	li	a1,897
ffffffffc0204e14:	00003517          	auipc	a0,0x3
ffffffffc0204e18:	65450513          	addi	a0,a0,1620 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0204e1c:	e58fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204e20 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e20:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e22:	1141                	addi	sp,sp,-16
ffffffffc0204e24:	e406                	sd	ra,8(sp)
ffffffffc0204e26:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e2a:	02f6ee63          	bltu	a3,a5,ffffffffc0204e66 <put_pgdir+0x46>
ffffffffc0204e2e:	00099797          	auipc	a5,0x99
ffffffffc0204e32:	df27b783          	ld	a5,-526(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc0204e36:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0204e38:	82b1                	srli	a3,a3,0xc
ffffffffc0204e3a:	00099797          	auipc	a5,0x99
ffffffffc0204e3e:	dee7b783          	ld	a5,-530(a5) # ffffffffc029dc28 <npage>
ffffffffc0204e42:	02f6fe63          	bgeu	a3,a5,ffffffffc0204e7e <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e46:	00004797          	auipc	a5,0x4
ffffffffc0204e4a:	fc27b783          	ld	a5,-62(a5) # ffffffffc0208e08 <nbase>
}
ffffffffc0204e4e:	60a2                	ld	ra,8(sp)
ffffffffc0204e50:	8e9d                	sub	a3,a3,a5
    free_page(kva2page(mm->pgdir));
ffffffffc0204e52:	00099517          	auipc	a0,0x99
ffffffffc0204e56:	dde53503          	ld	a0,-546(a0) # ffffffffc029dc30 <pages>
ffffffffc0204e5a:	069a                	slli	a3,a3,0x6
ffffffffc0204e5c:	4585                	li	a1,1
ffffffffc0204e5e:	9536                	add	a0,a0,a3
}
ffffffffc0204e60:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e62:	ecffc06f          	j	ffffffffc0201d30 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e66:	00002617          	auipc	a2,0x2
ffffffffc0204e6a:	5f260613          	addi	a2,a2,1522 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0204e6e:	06e00593          	li	a1,110
ffffffffc0204e72:	00002517          	auipc	a0,0x2
ffffffffc0204e76:	56650513          	addi	a0,a0,1382 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0204e7a:	dfafb0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e7e:	00002617          	auipc	a2,0x2
ffffffffc0204e82:	60260613          	addi	a2,a2,1538 # ffffffffc0207480 <etext+0xd74>
ffffffffc0204e86:	06200593          	li	a1,98
ffffffffc0204e8a:	00002517          	auipc	a0,0x2
ffffffffc0204e8e:	54e50513          	addi	a0,a0,1358 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0204e92:	de2fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204e96 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204e96:	7179                	addi	sp,sp,-48
ffffffffc0204e98:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204e9a:	00099917          	auipc	s2,0x99
ffffffffc0204e9e:	dce90913          	addi	s2,s2,-562 # ffffffffc029dc68 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204ea2:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204ea4:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204ea8:	f406                	sd	ra,40(sp)
    if (proc != current) {
ffffffffc0204eaa:	02a48a63          	beq	s1,a0,ffffffffc0204ede <proc_run+0x48>
ffffffffc0204eae:	e84e                	sd	s3,16(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204eb0:	100027f3          	csrr	a5,sstatus
ffffffffc0204eb4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204eb6:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204eb8:	ef9d                	bnez	a5,ffffffffc0204ef6 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204eba:	755c                	ld	a5,168(a0)
ffffffffc0204ebc:	577d                	li	a4,-1
ffffffffc0204ebe:	177e                	slli	a4,a4,0x3f
ffffffffc0204ec0:	83b1                	srli	a5,a5,0xc
        current = proc;
ffffffffc0204ec2:	00a93023          	sd	a0,0(s2)
ffffffffc0204ec6:	8fd9                	or	a5,a5,a4
ffffffffc0204ec8:	18079073          	csrw	satp,a5
        switch_to(&(prev->context),&(next->context));
ffffffffc0204ecc:	03050593          	addi	a1,a0,48
ffffffffc0204ed0:	03048513          	addi	a0,s1,48
ffffffffc0204ed4:	10a010ef          	jal	ffffffffc0205fde <switch_to>
    if (flag) {
ffffffffc0204ed8:	00099863          	bnez	s3,ffffffffc0204ee8 <proc_run+0x52>
ffffffffc0204edc:	69c2                	ld	s3,16(sp)
}
ffffffffc0204ede:	70a2                	ld	ra,40(sp)
ffffffffc0204ee0:	7482                	ld	s1,32(sp)
ffffffffc0204ee2:	6962                	ld	s2,24(sp)
ffffffffc0204ee4:	6145                	addi	sp,sp,48
ffffffffc0204ee6:	8082                	ret
        intr_enable();
ffffffffc0204ee8:	69c2                	ld	s3,16(sp)
ffffffffc0204eea:	70a2                	ld	ra,40(sp)
ffffffffc0204eec:	7482                	ld	s1,32(sp)
ffffffffc0204eee:	6962                	ld	s2,24(sp)
ffffffffc0204ef0:	6145                	addi	sp,sp,48
ffffffffc0204ef2:	f48fb06f          	j	ffffffffc020063a <intr_enable>
ffffffffc0204ef6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204ef8:	f48fb0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0204efc:	6522                	ld	a0,8(sp)
ffffffffc0204efe:	4985                	li	s3,1
ffffffffc0204f00:	bf6d                	j	ffffffffc0204eba <proc_run+0x24>

ffffffffc0204f02 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f02:	7119                	addi	sp,sp,-128
ffffffffc0204f04:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f06:	00099917          	auipc	s2,0x99
ffffffffc0204f0a:	d5a90913          	addi	s2,s2,-678 # ffffffffc029dc60 <nr_process>
ffffffffc0204f0e:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f12:	fc86                	sd	ra,120(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f14:	6785                	lui	a5,0x1
ffffffffc0204f16:	34f75d63          	bge	a4,a5,ffffffffc0205270 <do_fork+0x36e>
ffffffffc0204f1a:	f8a2                	sd	s0,112(sp)
ffffffffc0204f1c:	f4a6                	sd	s1,104(sp)
ffffffffc0204f1e:	ecce                	sd	s3,88(sp)
ffffffffc0204f20:	e8d2                	sd	s4,80(sp)
ffffffffc0204f22:	89ae                	mv	s3,a1
ffffffffc0204f24:	8a2a                	mv	s4,a0
ffffffffc0204f26:	8432                	mv	s0,a2
    if( (proc= alloc_proc()) == NULL){
ffffffffc0204f28:	dfbff0ef          	jal	ffffffffc0204d22 <alloc_proc>
ffffffffc0204f2c:	84aa                	mv	s1,a0
ffffffffc0204f2e:	32050563          	beqz	a0,ffffffffc0205258 <do_fork+0x356>
    proc->parent = current;
ffffffffc0204f32:	f862                	sd	s8,48(sp)
ffffffffc0204f34:	00099c17          	auipc	s8,0x99
ffffffffc0204f38:	d34c0c13          	addi	s8,s8,-716 # ffffffffc029dc68 <current>
ffffffffc0204f3c:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state==0);
ffffffffc0204f40:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_softint_out_size-0x750c>
    proc->parent = current;
ffffffffc0204f44:	f11c                	sd	a5,32(a0)
    assert(current->wait_state==0);
ffffffffc0204f46:	3a071663          	bnez	a4,ffffffffc02052f2 <do_fork+0x3f0>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204f4a:	4509                	li	a0,2
ffffffffc0204f4c:	d55fc0ef          	jal	ffffffffc0201ca0 <alloc_pages>
    if (page != NULL) {
ffffffffc0204f50:	30050063          	beqz	a0,ffffffffc0205250 <do_fork+0x34e>
ffffffffc0204f54:	e4d6                	sd	s5,72(sp)
    return page - pages + nbase;
ffffffffc0204f56:	00099a97          	auipc	s5,0x99
ffffffffc0204f5a:	cdaa8a93          	addi	s5,s5,-806 # ffffffffc029dc30 <pages>
ffffffffc0204f5e:	000ab703          	ld	a4,0(s5)
ffffffffc0204f62:	e0da                	sd	s6,64(sp)
ffffffffc0204f64:	00004b17          	auipc	s6,0x4
ffffffffc0204f68:	ea4b0b13          	addi	s6,s6,-348 # ffffffffc0208e08 <nbase>
ffffffffc0204f6c:	000b3783          	ld	a5,0(s6)
ffffffffc0204f70:	40e506b3          	sub	a3,a0,a4
ffffffffc0204f74:	fc5e                	sd	s7,56(sp)
    return KADDR(page2pa(page));
ffffffffc0204f76:	00099b97          	auipc	s7,0x99
ffffffffc0204f7a:	cb2b8b93          	addi	s7,s7,-846 # ffffffffc029dc28 <npage>
ffffffffc0204f7e:	ec6e                	sd	s11,24(sp)
    return page - pages + nbase;
ffffffffc0204f80:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204f82:	5dfd                	li	s11,-1
ffffffffc0204f84:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204f88:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204f8a:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204f8e:	01b6f633          	and	a2,a3,s11
ffffffffc0204f92:	f06a                	sd	s10,32(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f94:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f96:	30e67963          	bgeu	a2,a4,ffffffffc02052a8 <do_fork+0x3a6>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204f9a:	000c3603          	ld	a2,0(s8)
ffffffffc0204f9e:	00099c17          	auipc	s8,0x99
ffffffffc0204fa2:	c82c0c13          	addi	s8,s8,-894 # ffffffffc029dc20 <va_pa_offset>
ffffffffc0204fa6:	000c3703          	ld	a4,0(s8)
ffffffffc0204faa:	02863d03          	ld	s10,40(a2)
ffffffffc0204fae:	e43e                	sd	a5,8(sp)
ffffffffc0204fb0:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204fb2:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0204fb4:	020d0863          	beqz	s10,ffffffffc0204fe4 <do_fork+0xe2>
    if (clone_flags & CLONE_VM) {
ffffffffc0204fb8:	100a7a13          	andi	s4,s4,256
ffffffffc0204fbc:	1a0a0f63          	beqz	s4,ffffffffc020517a <do_fork+0x278>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204fc0:	030d2703          	lw	a4,48(s10)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fc4:	018d3783          	ld	a5,24(s10)
ffffffffc0204fc8:	c02006b7          	lui	a3,0xc0200
ffffffffc0204fcc:	2705                	addiw	a4,a4,1
ffffffffc0204fce:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204fd2:	03a4b423          	sd	s10,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fd6:	2ad7eb63          	bltu	a5,a3,ffffffffc020528c <do_fork+0x38a>
ffffffffc0204fda:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204fde:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fe0:	8f99                	sub	a5,a5,a4
ffffffffc0204fe2:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204fe4:	6789                	lui	a5,0x2
ffffffffc0204fe6:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6718>
ffffffffc0204fea:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204fec:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204fee:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204ff0:	87b6                	mv	a5,a3
ffffffffc0204ff2:	12040893          	addi	a7,s0,288
ffffffffc0204ff6:	00063803          	ld	a6,0(a2)
ffffffffc0204ffa:	6608                	ld	a0,8(a2)
ffffffffc0204ffc:	6a0c                	ld	a1,16(a2)
ffffffffc0204ffe:	6e18                	ld	a4,24(a2)
ffffffffc0205000:	0107b023          	sd	a6,0(a5)
ffffffffc0205004:	e788                	sd	a0,8(a5)
ffffffffc0205006:	eb8c                	sd	a1,16(a5)
ffffffffc0205008:	ef98                	sd	a4,24(a5)
ffffffffc020500a:	02060613          	addi	a2,a2,32
ffffffffc020500e:	02078793          	addi	a5,a5,32
ffffffffc0205012:	ff1612e3          	bne	a2,a7,ffffffffc0204ff6 <do_fork+0xf4>
    proc->tf->gpr.a0 = 0;
ffffffffc0205016:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020501a:	12098d63          	beqz	s3,ffffffffc0205154 <do_fork+0x252>
ffffffffc020501e:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205022:	00000797          	auipc	a5,0x0
ffffffffc0205026:	d7278793          	addi	a5,a5,-654 # ffffffffc0204d94 <forkret>
ffffffffc020502a:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020502c:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020502e:	100027f3          	csrr	a5,sstatus
ffffffffc0205032:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205034:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205036:	12079e63          	bnez	a5,ffffffffc0205172 <do_fork+0x270>
    if (++ last_pid >= MAX_PID) {
ffffffffc020503a:	0008d817          	auipc	a6,0x8d
ffffffffc020503e:	6e280813          	addi	a6,a6,1762 # ffffffffc029271c <last_pid.1>
ffffffffc0205042:	00082783          	lw	a5,0(a6)
ffffffffc0205046:	6709                	lui	a4,0x2
ffffffffc0205048:	0017851b          	addiw	a0,a5,1
ffffffffc020504c:	00a82023          	sw	a0,0(a6)
ffffffffc0205050:	08e55c63          	bge	a0,a4,ffffffffc02050e8 <do_fork+0x1e6>
    if (last_pid >= next_safe) {
ffffffffc0205054:	0008d317          	auipc	t1,0x8d
ffffffffc0205058:	6c430313          	addi	t1,t1,1732 # ffffffffc0292718 <next_safe.0>
ffffffffc020505c:	00032783          	lw	a5,0(t1)
ffffffffc0205060:	00099417          	auipc	s0,0x99
ffffffffc0205064:	b7840413          	addi	s0,s0,-1160 # ffffffffc029dbd8 <proc_list>
ffffffffc0205068:	08f55863          	bge	a0,a5,ffffffffc02050f8 <do_fork+0x1f6>
        proc->pid =get_pid();
ffffffffc020506c:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020506e:	45a9                	li	a1,10
ffffffffc0205070:	2501                	sext.w	a0,a0
ffffffffc0205072:	1dc010ef          	jal	ffffffffc020624e <hash32>
ffffffffc0205076:	02051793          	slli	a5,a0,0x20
ffffffffc020507a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020507e:	00095797          	auipc	a5,0x95
ffffffffc0205082:	b5a78793          	addi	a5,a5,-1190 # ffffffffc0299bd8 <hash_list>
ffffffffc0205086:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205088:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020508a:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020508c:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0205090:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205092:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0205094:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205096:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205098:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc020509c:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc020509e:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02050a0:	e21c                	sd	a5,0(a2)
ffffffffc02050a2:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02050a4:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02050a6:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02050a8:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050ac:	10e4b023          	sd	a4,256(s1)
ffffffffc02050b0:	c311                	beqz	a4,ffffffffc02050b4 <do_fork+0x1b2>
        proc->optr->yptr = proc;
ffffffffc02050b2:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc02050b4:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02050b8:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc02050ba:	2785                	addiw	a5,a5,1
ffffffffc02050bc:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc02050c0:	12099e63          	bnez	s3,ffffffffc02051fc <do_fork+0x2fa>
    wakeup_proc(proc);
ffffffffc02050c4:	8526                	mv	a0,s1
ffffffffc02050c6:	783000ef          	jal	ffffffffc0206048 <wakeup_proc>
    ret = proc->pid;
ffffffffc02050ca:	40c8                	lw	a0,4(s1)
ffffffffc02050cc:	7446                	ld	s0,112(sp)
ffffffffc02050ce:	74a6                	ld	s1,104(sp)
ffffffffc02050d0:	69e6                	ld	s3,88(sp)
ffffffffc02050d2:	6a46                	ld	s4,80(sp)
ffffffffc02050d4:	6aa6                	ld	s5,72(sp)
ffffffffc02050d6:	6b06                	ld	s6,64(sp)
ffffffffc02050d8:	7be2                	ld	s7,56(sp)
ffffffffc02050da:	7c42                	ld	s8,48(sp)
ffffffffc02050dc:	7d02                	ld	s10,32(sp)
ffffffffc02050de:	6de2                	ld	s11,24(sp)
}
ffffffffc02050e0:	70e6                	ld	ra,120(sp)
ffffffffc02050e2:	7906                	ld	s2,96(sp)
ffffffffc02050e4:	6109                	addi	sp,sp,128
ffffffffc02050e6:	8082                	ret
        last_pid = 1;
ffffffffc02050e8:	4785                	li	a5,1
ffffffffc02050ea:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02050ee:	4505                	li	a0,1
ffffffffc02050f0:	0008d317          	auipc	t1,0x8d
ffffffffc02050f4:	62830313          	addi	t1,t1,1576 # ffffffffc0292718 <next_safe.0>
    return listelm->next;
ffffffffc02050f8:	00099417          	auipc	s0,0x99
ffffffffc02050fc:	ae040413          	addi	s0,s0,-1312 # ffffffffc029dbd8 <proc_list>
ffffffffc0205100:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0205104:	6789                	lui	a5,0x2
ffffffffc0205106:	00f32023          	sw	a5,0(t1)
ffffffffc020510a:	86aa                	mv	a3,a0
ffffffffc020510c:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc020510e:	028e0e63          	beq	t3,s0,ffffffffc020514a <do_fork+0x248>
ffffffffc0205112:	88ae                	mv	a7,a1
ffffffffc0205114:	87f2                	mv	a5,t3
ffffffffc0205116:	6609                	lui	a2,0x2
ffffffffc0205118:	a811                	j	ffffffffc020512c <do_fork+0x22a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020511a:	00e6d663          	bge	a3,a4,ffffffffc0205126 <do_fork+0x224>
ffffffffc020511e:	00c75463          	bge	a4,a2,ffffffffc0205126 <do_fork+0x224>
                next_safe = proc->pid;
ffffffffc0205122:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205124:	4885                	li	a7,1
ffffffffc0205126:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205128:	00878d63          	beq	a5,s0,ffffffffc0205142 <do_fork+0x240>
            if (proc->pid == last_pid) {
ffffffffc020512c:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x66bc>
ffffffffc0205130:	fed715e3          	bne	a4,a3,ffffffffc020511a <do_fork+0x218>
                if (++ last_pid >= next_safe) {
ffffffffc0205134:	2685                	addiw	a3,a3,1
ffffffffc0205136:	12c6d763          	bge	a3,a2,ffffffffc0205264 <do_fork+0x362>
ffffffffc020513a:	679c                	ld	a5,8(a5)
ffffffffc020513c:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020513e:	fe8797e3          	bne	a5,s0,ffffffffc020512c <do_fork+0x22a>
ffffffffc0205142:	00088463          	beqz	a7,ffffffffc020514a <do_fork+0x248>
ffffffffc0205146:	00c32023          	sw	a2,0(t1)
ffffffffc020514a:	d18d                	beqz	a1,ffffffffc020506c <do_fork+0x16a>
ffffffffc020514c:	00d82023          	sw	a3,0(a6)
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205150:	8536                	mv	a0,a3
ffffffffc0205152:	bf29                	j	ffffffffc020506c <do_fork+0x16a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205154:	89b6                	mv	s3,a3
ffffffffc0205156:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020515a:	00000797          	auipc	a5,0x0
ffffffffc020515e:	c3a78793          	addi	a5,a5,-966 # ffffffffc0204d94 <forkret>
ffffffffc0205162:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205164:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205166:	100027f3          	csrr	a5,sstatus
ffffffffc020516a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020516c:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020516e:	ec0786e3          	beqz	a5,ffffffffc020503a <do_fork+0x138>
        intr_disable();
ffffffffc0205172:	ccefb0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0205176:	4985                	li	s3,1
ffffffffc0205178:	b5c9                	j	ffffffffc020503a <do_fork+0x138>
ffffffffc020517a:	f466                	sd	s9,40(sp)
    if ((mm = mm_create()) == NULL) {
ffffffffc020517c:	fb1fe0ef          	jal	ffffffffc020412c <mm_create>
ffffffffc0205180:	8caa                	mv	s9,a0
ffffffffc0205182:	c949                	beqz	a0,ffffffffc0205214 <do_fork+0x312>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205184:	4505                	li	a0,1
ffffffffc0205186:	b1bfc0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc020518a:	c151                	beqz	a0,ffffffffc020520e <do_fork+0x30c>
    return page - pages + nbase;
ffffffffc020518c:	000ab683          	ld	a3,0(s5)
ffffffffc0205190:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205192:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0205196:	40d506b3          	sub	a3,a0,a3
ffffffffc020519a:	8699                	srai	a3,a3,0x6
ffffffffc020519c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020519e:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02051a2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02051a4:	10edff63          	bgeu	s11,a4,ffffffffc02052c2 <do_fork+0x3c0>
ffffffffc02051a8:	000c3783          	ld	a5,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02051ac:	6605                	lui	a2,0x1
ffffffffc02051ae:	00099597          	auipc	a1,0x99
ffffffffc02051b2:	a6a5b583          	ld	a1,-1430(a1) # ffffffffc029dc18 <boot_pgdir>
ffffffffc02051b6:	00f68a33          	add	s4,a3,a5
ffffffffc02051ba:	8552                	mv	a0,s4
ffffffffc02051bc:	538010ef          	jal	ffffffffc02066f4 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02051c0:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc02051c4:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02051c8:	4785                	li	a5,1
ffffffffc02051ca:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02051ce:	8b85                	andi	a5,a5,1
ffffffffc02051d0:	4a05                	li	s4,1
ffffffffc02051d2:	c799                	beqz	a5,ffffffffc02051e0 <do_fork+0x2de>
        schedule();
ffffffffc02051d4:	70f000ef          	jal	ffffffffc02060e2 <schedule>
ffffffffc02051d8:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock)) {
ffffffffc02051dc:	8b85                	andi	a5,a5,1
ffffffffc02051de:	fbfd                	bnez	a5,ffffffffc02051d4 <do_fork+0x2d2>
        ret = dup_mmap(mm, oldmm);
ffffffffc02051e0:	85ea                	mv	a1,s10
ffffffffc02051e2:	8566                	mv	a0,s9
ffffffffc02051e4:	9eeff0ef          	jal	ffffffffc02043d2 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02051e8:	57f9                	li	a5,-2
ffffffffc02051ea:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02051ee:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02051f0:	0e078563          	beqz	a5,ffffffffc02052da <do_fork+0x3d8>
    if ((mm = mm_create()) == NULL) {
ffffffffc02051f4:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc02051f6:	e511                	bnez	a0,ffffffffc0205202 <do_fork+0x300>
ffffffffc02051f8:	7ca2                	ld	s9,40(sp)
ffffffffc02051fa:	b3d9                	j	ffffffffc0204fc0 <do_fork+0xbe>
        intr_enable();
ffffffffc02051fc:	c3efb0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0205200:	b5d1                	j	ffffffffc02050c4 <do_fork+0x1c2>
    exit_mmap(mm);
ffffffffc0205202:	8566                	mv	a0,s9
ffffffffc0205204:	a66ff0ef          	jal	ffffffffc020446a <exit_mmap>
    put_pgdir(mm);
ffffffffc0205208:	8566                	mv	a0,s9
ffffffffc020520a:	c17ff0ef          	jal	ffffffffc0204e20 <put_pgdir>
    mm_destroy(mm);
ffffffffc020520e:	8566                	mv	a0,s9
ffffffffc0205210:	8a2ff0ef          	jal	ffffffffc02042b2 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205214:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0205216:	c02007b7          	lui	a5,0xc0200
ffffffffc020521a:	10f6e263          	bltu	a3,a5,ffffffffc020531e <do_fork+0x41c>
ffffffffc020521e:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc0205222:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205226:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020522a:	83b1                	srli	a5,a5,0xc
ffffffffc020522c:	04e7f463          	bgeu	a5,a4,ffffffffc0205274 <do_fork+0x372>
    return &pages[PPN(pa) - nbase];
ffffffffc0205230:	000b3703          	ld	a4,0(s6)
ffffffffc0205234:	000ab503          	ld	a0,0(s5)
ffffffffc0205238:	4589                	li	a1,2
ffffffffc020523a:	8f99                	sub	a5,a5,a4
ffffffffc020523c:	079a                	slli	a5,a5,0x6
ffffffffc020523e:	953e                	add	a0,a0,a5
ffffffffc0205240:	af1fc0ef          	jal	ffffffffc0201d30 <free_pages>
}
ffffffffc0205244:	6aa6                	ld	s5,72(sp)
ffffffffc0205246:	6b06                	ld	s6,64(sp)
ffffffffc0205248:	7be2                	ld	s7,56(sp)
ffffffffc020524a:	7ca2                	ld	s9,40(sp)
ffffffffc020524c:	7d02                	ld	s10,32(sp)
ffffffffc020524e:	6de2                	ld	s11,24(sp)
    kfree(proc);
ffffffffc0205250:	8526                	mv	a0,s1
ffffffffc0205252:	921fc0ef          	jal	ffffffffc0201b72 <kfree>
ffffffffc0205256:	7c42                	ld	s8,48(sp)
ffffffffc0205258:	7446                	ld	s0,112(sp)
ffffffffc020525a:	74a6                	ld	s1,104(sp)
ffffffffc020525c:	69e6                	ld	s3,88(sp)
ffffffffc020525e:	6a46                	ld	s4,80(sp)
    ret = -E_NO_MEM;
ffffffffc0205260:	5571                	li	a0,-4
    return ret;
ffffffffc0205262:	bdbd                	j	ffffffffc02050e0 <do_fork+0x1de>
                    if (last_pid >= MAX_PID) {
ffffffffc0205264:	6789                	lui	a5,0x2
ffffffffc0205266:	00f6c363          	blt	a3,a5,ffffffffc020526c <do_fork+0x36a>
                        last_pid = 1;
ffffffffc020526a:	4685                	li	a3,1
                    goto repeat;
ffffffffc020526c:	4585                	li	a1,1
ffffffffc020526e:	b545                	j	ffffffffc020510e <do_fork+0x20c>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205270:	556d                	li	a0,-5
ffffffffc0205272:	b5bd                	j	ffffffffc02050e0 <do_fork+0x1de>
        panic("pa2page called with invalid pa");
ffffffffc0205274:	00002617          	auipc	a2,0x2
ffffffffc0205278:	20c60613          	addi	a2,a2,524 # ffffffffc0207480 <etext+0xd74>
ffffffffc020527c:	06200593          	li	a1,98
ffffffffc0205280:	00002517          	auipc	a0,0x2
ffffffffc0205284:	15850513          	addi	a0,a0,344 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0205288:	9ecfb0ef          	jal	ffffffffc0200474 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020528c:	86be                	mv	a3,a5
ffffffffc020528e:	00002617          	auipc	a2,0x2
ffffffffc0205292:	1ca60613          	addi	a2,a2,458 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0205296:	18300593          	li	a1,387
ffffffffc020529a:	00003517          	auipc	a0,0x3
ffffffffc020529e:	1ce50513          	addi	a0,a0,462 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc02052a2:	f466                	sd	s9,40(sp)
ffffffffc02052a4:	9d0fb0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc02052a8:	00002617          	auipc	a2,0x2
ffffffffc02052ac:	10860613          	addi	a2,a2,264 # ffffffffc02073b0 <etext+0xca4>
ffffffffc02052b0:	06900593          	li	a1,105
ffffffffc02052b4:	00002517          	auipc	a0,0x2
ffffffffc02052b8:	12450513          	addi	a0,a0,292 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02052bc:	f466                	sd	s9,40(sp)
ffffffffc02052be:	9b6fb0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc02052c2:	00002617          	auipc	a2,0x2
ffffffffc02052c6:	0ee60613          	addi	a2,a2,238 # ffffffffc02073b0 <etext+0xca4>
ffffffffc02052ca:	06900593          	li	a1,105
ffffffffc02052ce:	00002517          	auipc	a0,0x2
ffffffffc02052d2:	10a50513          	addi	a0,a0,266 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02052d6:	99efb0ef          	jal	ffffffffc0200474 <__panic>
        panic("Unlock failed.\n");
ffffffffc02052da:	00003617          	auipc	a2,0x3
ffffffffc02052de:	1be60613          	addi	a2,a2,446 # ffffffffc0208498 <etext+0x1d8c>
ffffffffc02052e2:	03100593          	li	a1,49
ffffffffc02052e6:	00003517          	auipc	a0,0x3
ffffffffc02052ea:	1c250513          	addi	a0,a0,450 # ffffffffc02084a8 <etext+0x1d9c>
ffffffffc02052ee:	986fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(current->wait_state==0);
ffffffffc02052f2:	00003697          	auipc	a3,0x3
ffffffffc02052f6:	18e68693          	addi	a3,a3,398 # ffffffffc0208480 <etext+0x1d74>
ffffffffc02052fa:	00002617          	auipc	a2,0x2
ffffffffc02052fe:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205302:	1d600593          	li	a1,470
ffffffffc0205306:	00003517          	auipc	a0,0x3
ffffffffc020530a:	16250513          	addi	a0,a0,354 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc020530e:	e4d6                	sd	s5,72(sp)
ffffffffc0205310:	e0da                	sd	s6,64(sp)
ffffffffc0205312:	fc5e                	sd	s7,56(sp)
ffffffffc0205314:	f466                	sd	s9,40(sp)
ffffffffc0205316:	f06a                	sd	s10,32(sp)
ffffffffc0205318:	ec6e                	sd	s11,24(sp)
ffffffffc020531a:	95afb0ef          	jal	ffffffffc0200474 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020531e:	00002617          	auipc	a2,0x2
ffffffffc0205322:	13a60613          	addi	a2,a2,314 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0205326:	06e00593          	li	a1,110
ffffffffc020532a:	00002517          	auipc	a0,0x2
ffffffffc020532e:	0ae50513          	addi	a0,a0,174 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0205332:	942fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0205336 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205336:	7129                	addi	sp,sp,-320
ffffffffc0205338:	fa22                	sd	s0,304(sp)
ffffffffc020533a:	f626                	sd	s1,296(sp)
ffffffffc020533c:	f24a                	sd	s2,288(sp)
ffffffffc020533e:	84ae                	mv	s1,a1
ffffffffc0205340:	892a                	mv	s2,a0
ffffffffc0205342:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205344:	4581                	li	a1,0
ffffffffc0205346:	12000613          	li	a2,288
ffffffffc020534a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020534c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020534e:	394010ef          	jal	ffffffffc02066e2 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205352:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205354:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205356:	100027f3          	csrr	a5,sstatus
ffffffffc020535a:	edd7f793          	andi	a5,a5,-291
ffffffffc020535e:	1207e793          	ori	a5,a5,288
ffffffffc0205362:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205364:	860a                	mv	a2,sp
ffffffffc0205366:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020536a:	00000797          	auipc	a5,0x0
ffffffffc020536e:	9b078793          	addi	a5,a5,-1616 # ffffffffc0204d1a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205372:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205374:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205376:	b8dff0ef          	jal	ffffffffc0204f02 <do_fork>
}
ffffffffc020537a:	70f2                	ld	ra,312(sp)
ffffffffc020537c:	7452                	ld	s0,304(sp)
ffffffffc020537e:	74b2                	ld	s1,296(sp)
ffffffffc0205380:	7912                	ld	s2,288(sp)
ffffffffc0205382:	6131                	addi	sp,sp,320
ffffffffc0205384:	8082                	ret

ffffffffc0205386 <do_exit>:
do_exit(int error_code) {
ffffffffc0205386:	7179                	addi	sp,sp,-48
ffffffffc0205388:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc020538a:	00099417          	auipc	s0,0x99
ffffffffc020538e:	8de40413          	addi	s0,s0,-1826 # ffffffffc029dc68 <current>
ffffffffc0205392:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205394:	f406                	sd	ra,40(sp)
    if (current == idleproc) {
ffffffffc0205396:	00099717          	auipc	a4,0x99
ffffffffc020539a:	8e273703          	ld	a4,-1822(a4) # ffffffffc029dc78 <idleproc>
ffffffffc020539e:	ec26                	sd	s1,24(sp)
ffffffffc02053a0:	0ce78f63          	beq	a5,a4,ffffffffc020547e <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02053a4:	00099497          	auipc	s1,0x99
ffffffffc02053a8:	8cc48493          	addi	s1,s1,-1844 # ffffffffc029dc70 <initproc>
ffffffffc02053ac:	6098                	ld	a4,0(s1)
ffffffffc02053ae:	e84a                	sd	s2,16(sp)
ffffffffc02053b0:	e44e                	sd	s3,8(sp)
ffffffffc02053b2:	e052                	sd	s4,0(sp)
ffffffffc02053b4:	0ee78e63          	beq	a5,a4,ffffffffc02054b0 <do_exit+0x12a>
    struct mm_struct *mm = current->mm;
ffffffffc02053b8:	0287b983          	ld	s3,40(a5)
ffffffffc02053bc:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02053be:	02098663          	beqz	s3,ffffffffc02053ea <do_exit+0x64>
ffffffffc02053c2:	00099797          	auipc	a5,0x99
ffffffffc02053c6:	84e7b783          	ld	a5,-1970(a5) # ffffffffc029dc10 <boot_cr3>
ffffffffc02053ca:	577d                	li	a4,-1
ffffffffc02053cc:	177e                	slli	a4,a4,0x3f
ffffffffc02053ce:	83b1                	srli	a5,a5,0xc
ffffffffc02053d0:	8fd9                	or	a5,a5,a4
ffffffffc02053d2:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02053d6:	0309a783          	lw	a5,48(s3)
ffffffffc02053da:	fff7871b          	addiw	a4,a5,-1
ffffffffc02053de:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02053e2:	cf4d                	beqz	a4,ffffffffc020549c <do_exit+0x116>
        current->mm = NULL;
ffffffffc02053e4:	601c                	ld	a5,0(s0)
ffffffffc02053e6:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02053ea:	601c                	ld	a5,0(s0)
ffffffffc02053ec:	470d                	li	a4,3
ffffffffc02053ee:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02053f0:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053f4:	100027f3          	csrr	a5,sstatus
ffffffffc02053f8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053fa:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053fc:	e7f1                	bnez	a5,ffffffffc02054c8 <do_exit+0x142>
        proc = current->parent;
ffffffffc02053fe:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205400:	800007b7          	lui	a5,0x80000
ffffffffc0205404:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff64a1>
        proc = current->parent;
ffffffffc0205406:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205408:	0ec52703          	lw	a4,236(a0)
ffffffffc020540c:	0cf70263          	beq	a4,a5,ffffffffc02054d0 <do_exit+0x14a>
        while (current->cptr != NULL) {
ffffffffc0205410:	6018                	ld	a4,0(s0)
ffffffffc0205412:	7b7c                	ld	a5,240(a4)
ffffffffc0205414:	c3a1                	beqz	a5,ffffffffc0205454 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205416:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020541a:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020541c:	0985                	addi	s3,s3,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff64a1>
ffffffffc020541e:	a021                	j	ffffffffc0205426 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0205420:	6018                	ld	a4,0(s0)
ffffffffc0205422:	7b7c                	ld	a5,240(a4)
ffffffffc0205424:	cb85                	beqz	a5,ffffffffc0205454 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0205426:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020542a:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020542c:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020542e:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205430:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205434:	10e7b023          	sd	a4,256(a5)
ffffffffc0205438:	c311                	beqz	a4,ffffffffc020543c <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020543a:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020543c:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020543e:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205440:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205442:	fd271fe3          	bne	a4,s2,ffffffffc0205420 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205446:	0ec52783          	lw	a5,236(a0)
ffffffffc020544a:	fd379be3          	bne	a5,s3,ffffffffc0205420 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020544e:	3fb000ef          	jal	ffffffffc0206048 <wakeup_proc>
ffffffffc0205452:	b7f9                	j	ffffffffc0205420 <do_exit+0x9a>
    if (flag) {
ffffffffc0205454:	020a1263          	bnez	s4,ffffffffc0205478 <do_exit+0xf2>
    schedule();
ffffffffc0205458:	48b000ef          	jal	ffffffffc02060e2 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020545c:	601c                	ld	a5,0(s0)
ffffffffc020545e:	00003617          	auipc	a2,0x3
ffffffffc0205462:	08260613          	addi	a2,a2,130 # ffffffffc02084e0 <etext+0x1dd4>
ffffffffc0205466:	23700593          	li	a1,567
ffffffffc020546a:	43d4                	lw	a3,4(a5)
ffffffffc020546c:	00003517          	auipc	a0,0x3
ffffffffc0205470:	ffc50513          	addi	a0,a0,-4 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205474:	800fb0ef          	jal	ffffffffc0200474 <__panic>
        intr_enable();
ffffffffc0205478:	9c2fb0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020547c:	bff1                	j	ffffffffc0205458 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020547e:	00003617          	auipc	a2,0x3
ffffffffc0205482:	04260613          	addi	a2,a2,66 # ffffffffc02084c0 <etext+0x1db4>
ffffffffc0205486:	20b00593          	li	a1,523
ffffffffc020548a:	00003517          	auipc	a0,0x3
ffffffffc020548e:	fde50513          	addi	a0,a0,-34 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205492:	e84a                	sd	s2,16(sp)
ffffffffc0205494:	e44e                	sd	s3,8(sp)
ffffffffc0205496:	e052                	sd	s4,0(sp)
ffffffffc0205498:	fddfa0ef          	jal	ffffffffc0200474 <__panic>
            exit_mmap(mm);
ffffffffc020549c:	854e                	mv	a0,s3
ffffffffc020549e:	fcdfe0ef          	jal	ffffffffc020446a <exit_mmap>
            put_pgdir(mm);
ffffffffc02054a2:	854e                	mv	a0,s3
ffffffffc02054a4:	97dff0ef          	jal	ffffffffc0204e20 <put_pgdir>
            mm_destroy(mm);
ffffffffc02054a8:	854e                	mv	a0,s3
ffffffffc02054aa:	e09fe0ef          	jal	ffffffffc02042b2 <mm_destroy>
ffffffffc02054ae:	bf1d                	j	ffffffffc02053e4 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02054b0:	00003617          	auipc	a2,0x3
ffffffffc02054b4:	02060613          	addi	a2,a2,32 # ffffffffc02084d0 <etext+0x1dc4>
ffffffffc02054b8:	20e00593          	li	a1,526
ffffffffc02054bc:	00003517          	auipc	a0,0x3
ffffffffc02054c0:	fac50513          	addi	a0,a0,-84 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc02054c4:	fb1fa0ef          	jal	ffffffffc0200474 <__panic>
        intr_disable();
ffffffffc02054c8:	978fb0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc02054cc:	4a05                	li	s4,1
ffffffffc02054ce:	bf05                	j	ffffffffc02053fe <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02054d0:	379000ef          	jal	ffffffffc0206048 <wakeup_proc>
ffffffffc02054d4:	bf35                	j	ffffffffc0205410 <do_exit+0x8a>

ffffffffc02054d6 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02054d6:	7179                	addi	sp,sp,-48
ffffffffc02054d8:	ec26                	sd	s1,24(sp)
ffffffffc02054da:	e84a                	sd	s2,16(sp)
ffffffffc02054dc:	e44e                	sd	s3,8(sp)
ffffffffc02054de:	f406                	sd	ra,40(sp)
ffffffffc02054e0:	f022                	sd	s0,32(sp)
ffffffffc02054e2:	84aa                	mv	s1,a0
ffffffffc02054e4:	892e                	mv	s2,a1
ffffffffc02054e6:	00098997          	auipc	s3,0x98
ffffffffc02054ea:	78298993          	addi	s3,s3,1922 # ffffffffc029dc68 <current>
    if (pid != 0) {
ffffffffc02054ee:	c105                	beqz	a0,ffffffffc020550e <do_wait.part.0+0x38>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054f0:	6789                	lui	a5,0x2
ffffffffc02054f2:	fff5071b          	addiw	a4,a0,-1
ffffffffc02054f6:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x65fa>
ffffffffc02054f8:	2501                	sext.w	a0,a0
ffffffffc02054fa:	12e7f363          	bgeu	a5,a4,ffffffffc0205620 <do_wait.part.0+0x14a>
    return -E_BAD_PROC;
ffffffffc02054fe:	5579                	li	a0,-2
}
ffffffffc0205500:	70a2                	ld	ra,40(sp)
ffffffffc0205502:	7402                	ld	s0,32(sp)
ffffffffc0205504:	64e2                	ld	s1,24(sp)
ffffffffc0205506:	6942                	ld	s2,16(sp)
ffffffffc0205508:	69a2                	ld	s3,8(sp)
ffffffffc020550a:	6145                	addi	sp,sp,48
ffffffffc020550c:	8082                	ret
        proc = current->cptr;
ffffffffc020550e:	0009b683          	ld	a3,0(s3)
ffffffffc0205512:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205514:	d46d                	beqz	s0,ffffffffc02054fe <do_wait.part.0+0x28>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205516:	470d                	li	a4,3
ffffffffc0205518:	a021                	j	ffffffffc0205520 <do_wait.part.0+0x4a>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020551a:	10043403          	ld	s0,256(s0)
ffffffffc020551e:	cc71                	beqz	s0,ffffffffc02055fa <do_wait.part.0+0x124>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205520:	401c                	lw	a5,0(s0)
ffffffffc0205522:	fee79ce3          	bne	a5,a4,ffffffffc020551a <do_wait.part.0+0x44>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205526:	00098797          	auipc	a5,0x98
ffffffffc020552a:	7527b783          	ld	a5,1874(a5) # ffffffffc029dc78 <idleproc>
ffffffffc020552e:	14878c63          	beq	a5,s0,ffffffffc0205686 <do_wait.part.0+0x1b0>
ffffffffc0205532:	00098797          	auipc	a5,0x98
ffffffffc0205536:	73e7b783          	ld	a5,1854(a5) # ffffffffc029dc70 <initproc>
ffffffffc020553a:	14f40663          	beq	s0,a5,ffffffffc0205686 <do_wait.part.0+0x1b0>
    if (code_store != NULL) {
ffffffffc020553e:	00090663          	beqz	s2,ffffffffc020554a <do_wait.part.0+0x74>
        *code_store = proc->exit_code;
ffffffffc0205542:	0e842783          	lw	a5,232(s0)
ffffffffc0205546:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020554a:	100027f3          	csrr	a5,sstatus
ffffffffc020554e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205550:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205552:	10079463          	bnez	a5,ffffffffc020565a <do_wait.part.0+0x184>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205556:	6c74                	ld	a3,216(s0)
ffffffffc0205558:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL) {
ffffffffc020555a:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc020555e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0205560:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205562:	6474                	ld	a3,200(s0)
ffffffffc0205564:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc0205566:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0205568:	e314                	sd	a3,0(a4)
ffffffffc020556a:	c399                	beqz	a5,ffffffffc0205570 <do_wait.part.0+0x9a>
        proc->optr->yptr = proc->yptr;
ffffffffc020556c:	7c78                	ld	a4,248(s0)
ffffffffc020556e:	fff8                	sd	a4,248(a5)
    if (proc->yptr != NULL) {
ffffffffc0205570:	7c78                	ld	a4,248(s0)
ffffffffc0205572:	c36d                	beqz	a4,ffffffffc0205654 <do_wait.part.0+0x17e>
        proc->yptr->optr = proc->optr;
ffffffffc0205574:	10f73023          	sd	a5,256(a4)
    nr_process --;
ffffffffc0205578:	00098717          	auipc	a4,0x98
ffffffffc020557c:	6e870713          	addi	a4,a4,1768 # ffffffffc029dc60 <nr_process>
ffffffffc0205580:	431c                	lw	a5,0(a4)
ffffffffc0205582:	37fd                	addiw	a5,a5,-1
ffffffffc0205584:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc0205586:	e661                	bnez	a2,ffffffffc020564e <do_wait.part.0+0x178>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205588:	6814                	ld	a3,16(s0)
ffffffffc020558a:	c02007b7          	lui	a5,0xc0200
ffffffffc020558e:	0ef6e063          	bltu	a3,a5,ffffffffc020566e <do_wait.part.0+0x198>
ffffffffc0205592:	00098797          	auipc	a5,0x98
ffffffffc0205596:	68e7b783          	ld	a5,1678(a5) # ffffffffc029dc20 <va_pa_offset>
ffffffffc020559a:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020559c:	82b1                	srli	a3,a3,0xc
ffffffffc020559e:	00098797          	auipc	a5,0x98
ffffffffc02055a2:	68a7b783          	ld	a5,1674(a5) # ffffffffc029dc28 <npage>
ffffffffc02055a6:	0ef6fc63          	bgeu	a3,a5,ffffffffc020569e <do_wait.part.0+0x1c8>
    return &pages[PPN(pa) - nbase];
ffffffffc02055aa:	00004797          	auipc	a5,0x4
ffffffffc02055ae:	85e7b783          	ld	a5,-1954(a5) # ffffffffc0208e08 <nbase>
ffffffffc02055b2:	8e9d                	sub	a3,a3,a5
ffffffffc02055b4:	069a                	slli	a3,a3,0x6
ffffffffc02055b6:	00098517          	auipc	a0,0x98
ffffffffc02055ba:	67a53503          	ld	a0,1658(a0) # ffffffffc029dc30 <pages>
ffffffffc02055be:	9536                	add	a0,a0,a3
ffffffffc02055c0:	4589                	li	a1,2
ffffffffc02055c2:	f6efc0ef          	jal	ffffffffc0201d30 <free_pages>
    kfree(proc);
ffffffffc02055c6:	8522                	mv	a0,s0
ffffffffc02055c8:	daafc0ef          	jal	ffffffffc0201b72 <kfree>
}
ffffffffc02055cc:	70a2                	ld	ra,40(sp)
ffffffffc02055ce:	7402                	ld	s0,32(sp)
ffffffffc02055d0:	64e2                	ld	s1,24(sp)
ffffffffc02055d2:	6942                	ld	s2,16(sp)
ffffffffc02055d4:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc02055d6:	4501                	li	a0,0
}
ffffffffc02055d8:	6145                	addi	sp,sp,48
ffffffffc02055da:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02055dc:	00098997          	auipc	s3,0x98
ffffffffc02055e0:	68c98993          	addi	s3,s3,1676 # ffffffffc029dc68 <current>
ffffffffc02055e4:	0009b683          	ld	a3,0(s3)
ffffffffc02055e8:	f4843783          	ld	a5,-184(s0)
ffffffffc02055ec:	f0d799e3          	bne	a5,a3,ffffffffc02054fe <do_wait.part.0+0x28>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055f0:	f2842703          	lw	a4,-216(s0)
ffffffffc02055f4:	478d                	li	a5,3
ffffffffc02055f6:	06f70663          	beq	a4,a5,ffffffffc0205662 <do_wait.part.0+0x18c>
        current->wait_state = WT_CHILD;
ffffffffc02055fa:	800007b7          	lui	a5,0x80000
ffffffffc02055fe:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff64a1>
        current->state = PROC_SLEEPING;
ffffffffc0205600:	4705                	li	a4,1
        current->wait_state = WT_CHILD;
ffffffffc0205602:	0ef6a623          	sw	a5,236(a3)
        current->state = PROC_SLEEPING;
ffffffffc0205606:	c298                	sw	a4,0(a3)
        schedule();
ffffffffc0205608:	2db000ef          	jal	ffffffffc02060e2 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020560c:	0009b783          	ld	a5,0(s3)
ffffffffc0205610:	0b07a783          	lw	a5,176(a5)
ffffffffc0205614:	8b85                	andi	a5,a5,1
ffffffffc0205616:	eba9                	bnez	a5,ffffffffc0205668 <do_wait.part.0+0x192>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205618:	0004851b          	sext.w	a0,s1
    if (pid != 0) {
ffffffffc020561c:	ee0489e3          	beqz	s1,ffffffffc020550e <do_wait.part.0+0x38>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205620:	45a9                	li	a1,10
ffffffffc0205622:	42d000ef          	jal	ffffffffc020624e <hash32>
ffffffffc0205626:	02051793          	slli	a5,a0,0x20
ffffffffc020562a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020562e:	00094797          	auipc	a5,0x94
ffffffffc0205632:	5aa78793          	addi	a5,a5,1450 # ffffffffc0299bd8 <hash_list>
ffffffffc0205636:	953e                	add	a0,a0,a5
ffffffffc0205638:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc020563a:	a029                	j	ffffffffc0205644 <do_wait.part.0+0x16e>
            if (proc->pid == pid) {
ffffffffc020563c:	f2c42783          	lw	a5,-212(s0)
ffffffffc0205640:	f8978ee3          	beq	a5,s1,ffffffffc02055dc <do_wait.part.0+0x106>
    return listelm->next;
ffffffffc0205644:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205646:	fe851be3          	bne	a0,s0,ffffffffc020563c <do_wait.part.0+0x166>
    return -E_BAD_PROC;
ffffffffc020564a:	5579                	li	a0,-2
ffffffffc020564c:	bd55                	j	ffffffffc0205500 <do_wait.part.0+0x2a>
        intr_enable();
ffffffffc020564e:	fedfa0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0205652:	bf1d                	j	ffffffffc0205588 <do_wait.part.0+0xb2>
       proc->parent->cptr = proc->optr;
ffffffffc0205654:	7018                	ld	a4,32(s0)
ffffffffc0205656:	fb7c                	sd	a5,240(a4)
ffffffffc0205658:	b705                	j	ffffffffc0205578 <do_wait.part.0+0xa2>
        intr_disable();
ffffffffc020565a:	fe7fa0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc020565e:	4605                	li	a2,1
ffffffffc0205660:	bddd                	j	ffffffffc0205556 <do_wait.part.0+0x80>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205662:	f2840413          	addi	s0,s0,-216
ffffffffc0205666:	b5c1                	j	ffffffffc0205526 <do_wait.part.0+0x50>
            do_exit(-E_KILLED);
ffffffffc0205668:	555d                	li	a0,-9
ffffffffc020566a:	d1dff0ef          	jal	ffffffffc0205386 <do_exit>
    return pa2page(PADDR(kva));
ffffffffc020566e:	00002617          	auipc	a2,0x2
ffffffffc0205672:	dea60613          	addi	a2,a2,-534 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0205676:	06e00593          	li	a1,110
ffffffffc020567a:	00002517          	auipc	a0,0x2
ffffffffc020567e:	d5e50513          	addi	a0,a0,-674 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0205682:	df3fa0ef          	jal	ffffffffc0200474 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205686:	00003617          	auipc	a2,0x3
ffffffffc020568a:	e7a60613          	addi	a2,a2,-390 # ffffffffc0208500 <etext+0x1df4>
ffffffffc020568e:	32f00593          	li	a1,815
ffffffffc0205692:	00003517          	auipc	a0,0x3
ffffffffc0205696:	dd650513          	addi	a0,a0,-554 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc020569a:	ddbfa0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020569e:	00002617          	auipc	a2,0x2
ffffffffc02056a2:	de260613          	addi	a2,a2,-542 # ffffffffc0207480 <etext+0xd74>
ffffffffc02056a6:	06200593          	li	a1,98
ffffffffc02056aa:	00002517          	auipc	a0,0x2
ffffffffc02056ae:	d2e50513          	addi	a0,a0,-722 # ffffffffc02073d8 <etext+0xccc>
ffffffffc02056b2:	dc3fa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02056b6 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056b6:	1141                	addi	sp,sp,-16
ffffffffc02056b8:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056ba:	eb6fc0ef          	jal	ffffffffc0201d70 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056be:	c06fc0ef          	jal	ffffffffc0201ac4 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056c2:	4601                	li	a2,0
ffffffffc02056c4:	4581                	li	a1,0
ffffffffc02056c6:	fffff517          	auipc	a0,0xfffff
ffffffffc02056ca:	6dc50513          	addi	a0,a0,1756 # ffffffffc0204da2 <user_main>
ffffffffc02056ce:	c69ff0ef          	jal	ffffffffc0205336 <kernel_thread>
    if (pid <= 0) {
ffffffffc02056d2:	00a04563          	bgtz	a0,ffffffffc02056dc <init_main+0x26>
ffffffffc02056d6:	a071                	j	ffffffffc0205762 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02056d8:	20b000ef          	jal	ffffffffc02060e2 <schedule>
    if (code_store != NULL) {
ffffffffc02056dc:	4581                	li	a1,0
ffffffffc02056de:	4501                	li	a0,0
ffffffffc02056e0:	df7ff0ef          	jal	ffffffffc02054d6 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02056e4:	d975                	beqz	a0,ffffffffc02056d8 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02056e6:	00003517          	auipc	a0,0x3
ffffffffc02056ea:	e5a50513          	addi	a0,a0,-422 # ffffffffc0208540 <etext+0x1e34>
ffffffffc02056ee:	a93fa0ef          	jal	ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056f2:	00098797          	auipc	a5,0x98
ffffffffc02056f6:	57e7b783          	ld	a5,1406(a5) # ffffffffc029dc70 <initproc>
ffffffffc02056fa:	7bf8                	ld	a4,240(a5)
ffffffffc02056fc:	e339                	bnez	a4,ffffffffc0205742 <init_main+0x8c>
ffffffffc02056fe:	7ff8                	ld	a4,248(a5)
ffffffffc0205700:	e329                	bnez	a4,ffffffffc0205742 <init_main+0x8c>
ffffffffc0205702:	1007b703          	ld	a4,256(a5)
ffffffffc0205706:	ef15                	bnez	a4,ffffffffc0205742 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205708:	00098697          	auipc	a3,0x98
ffffffffc020570c:	5586a683          	lw	a3,1368(a3) # ffffffffc029dc60 <nr_process>
ffffffffc0205710:	4709                	li	a4,2
ffffffffc0205712:	0ae69463          	bne	a3,a4,ffffffffc02057ba <init_main+0x104>
ffffffffc0205716:	00098697          	auipc	a3,0x98
ffffffffc020571a:	4c268693          	addi	a3,a3,1218 # ffffffffc029dbd8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020571e:	6698                	ld	a4,8(a3)
ffffffffc0205720:	0c878793          	addi	a5,a5,200
ffffffffc0205724:	06f71b63          	bne	a4,a5,ffffffffc020579a <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205728:	629c                	ld	a5,0(a3)
ffffffffc020572a:	04f71863          	bne	a4,a5,ffffffffc020577a <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020572e:	00003517          	auipc	a0,0x3
ffffffffc0205732:	efa50513          	addi	a0,a0,-262 # ffffffffc0208628 <etext+0x1f1c>
ffffffffc0205736:	a4bfa0ef          	jal	ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc020573a:	60a2                	ld	ra,8(sp)
ffffffffc020573c:	4501                	li	a0,0
ffffffffc020573e:	0141                	addi	sp,sp,16
ffffffffc0205740:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205742:	00003697          	auipc	a3,0x3
ffffffffc0205746:	e2668693          	addi	a3,a3,-474 # ffffffffc0208568 <etext+0x1e5c>
ffffffffc020574a:	00001617          	auipc	a2,0x1
ffffffffc020574e:	63e60613          	addi	a2,a2,1598 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205752:	39400593          	li	a1,916
ffffffffc0205756:	00003517          	auipc	a0,0x3
ffffffffc020575a:	d1250513          	addi	a0,a0,-750 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc020575e:	d17fa0ef          	jal	ffffffffc0200474 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205762:	00003617          	auipc	a2,0x3
ffffffffc0205766:	dbe60613          	addi	a2,a2,-578 # ffffffffc0208520 <etext+0x1e14>
ffffffffc020576a:	38c00593          	li	a1,908
ffffffffc020576e:	00003517          	auipc	a0,0x3
ffffffffc0205772:	cfa50513          	addi	a0,a0,-774 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205776:	cfffa0ef          	jal	ffffffffc0200474 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020577a:	00003697          	auipc	a3,0x3
ffffffffc020577e:	e7e68693          	addi	a3,a3,-386 # ffffffffc02085f8 <etext+0x1eec>
ffffffffc0205782:	00001617          	auipc	a2,0x1
ffffffffc0205786:	60660613          	addi	a2,a2,1542 # ffffffffc0206d88 <etext+0x67c>
ffffffffc020578a:	39700593          	li	a1,919
ffffffffc020578e:	00003517          	auipc	a0,0x3
ffffffffc0205792:	cda50513          	addi	a0,a0,-806 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205796:	cdffa0ef          	jal	ffffffffc0200474 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020579a:	00003697          	auipc	a3,0x3
ffffffffc020579e:	e2e68693          	addi	a3,a3,-466 # ffffffffc02085c8 <etext+0x1ebc>
ffffffffc02057a2:	00001617          	auipc	a2,0x1
ffffffffc02057a6:	5e660613          	addi	a2,a2,1510 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02057aa:	39600593          	li	a1,918
ffffffffc02057ae:	00003517          	auipc	a0,0x3
ffffffffc02057b2:	cba50513          	addi	a0,a0,-838 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc02057b6:	cbffa0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_process == 2);
ffffffffc02057ba:	00003697          	auipc	a3,0x3
ffffffffc02057be:	dfe68693          	addi	a3,a3,-514 # ffffffffc02085b8 <etext+0x1eac>
ffffffffc02057c2:	00001617          	auipc	a2,0x1
ffffffffc02057c6:	5c660613          	addi	a2,a2,1478 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02057ca:	39500593          	li	a1,917
ffffffffc02057ce:	00003517          	auipc	a0,0x3
ffffffffc02057d2:	c9a50513          	addi	a0,a0,-870 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc02057d6:	c9ffa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02057da <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057da:	7171                	addi	sp,sp,-176
ffffffffc02057dc:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057de:	00098d97          	auipc	s11,0x98
ffffffffc02057e2:	48ad8d93          	addi	s11,s11,1162 # ffffffffc029dc68 <current>
ffffffffc02057e6:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057ea:	e54e                	sd	s3,136(sp)
ffffffffc02057ec:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057ee:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057f2:	e94a                	sd	s2,144(sp)
ffffffffc02057f4:	fcd6                	sd	s5,120(sp)
ffffffffc02057f6:	892a                	mv	s2,a0
ffffffffc02057f8:	84ae                	mv	s1,a1
ffffffffc02057fa:	8ab2                	mv	s5,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057fc:	4681                	li	a3,0
ffffffffc02057fe:	862e                	mv	a2,a1
ffffffffc0205800:	85aa                	mv	a1,a0
ffffffffc0205802:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205804:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205806:	b20ff0ef          	jal	ffffffffc0204b26 <user_mem_check>
ffffffffc020580a:	46050163          	beqz	a0,ffffffffc0205c6c <do_execve+0x492>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020580e:	4641                	li	a2,16
ffffffffc0205810:	4581                	li	a1,0
ffffffffc0205812:	1808                	addi	a0,sp,48
ffffffffc0205814:	6cf000ef          	jal	ffffffffc02066e2 <memset>
    if (len > PROC_NAME_LEN) {
ffffffffc0205818:	47bd                	li	a5,15
ffffffffc020581a:	8626                	mv	a2,s1
ffffffffc020581c:	1097e263          	bltu	a5,s1,ffffffffc0205920 <do_execve+0x146>
    memcpy(local_name, name, len);
ffffffffc0205820:	85ca                	mv	a1,s2
ffffffffc0205822:	1808                	addi	a0,sp,48
ffffffffc0205824:	6d1000ef          	jal	ffffffffc02066f4 <memcpy>
    if (mm != NULL) {
ffffffffc0205828:	10098363          	beqz	s3,ffffffffc020592e <do_execve+0x154>
        cputs("mm != NULL");
ffffffffc020582c:	00002517          	auipc	a0,0x2
ffffffffc0205830:	2d450513          	addi	a0,a0,724 # ffffffffc0207b00 <etext+0x13f4>
ffffffffc0205834:	983fa0ef          	jal	ffffffffc02001b6 <cputs>
ffffffffc0205838:	00098797          	auipc	a5,0x98
ffffffffc020583c:	3d87b783          	ld	a5,984(a5) # ffffffffc029dc10 <boot_cr3>
ffffffffc0205840:	577d                	li	a4,-1
ffffffffc0205842:	177e                	slli	a4,a4,0x3f
ffffffffc0205844:	83b1                	srli	a5,a5,0xc
ffffffffc0205846:	8fd9                	or	a5,a5,a4
ffffffffc0205848:	18079073          	csrw	satp,a5
ffffffffc020584c:	0309a783          	lw	a5,48(s3)
ffffffffc0205850:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205854:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205858:	2e070663          	beqz	a4,ffffffffc0205b44 <do_execve+0x36a>
        current->mm = NULL;
ffffffffc020585c:	000db783          	ld	a5,0(s11)
ffffffffc0205860:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205864:	8c9fe0ef          	jal	ffffffffc020412c <mm_create>
ffffffffc0205868:	84aa                	mv	s1,a0
ffffffffc020586a:	20050463          	beqz	a0,ffffffffc0205a72 <do_execve+0x298>
    if ((page = alloc_page()) == NULL) {
ffffffffc020586e:	4505                	li	a0,1
ffffffffc0205870:	c30fc0ef          	jal	ffffffffc0201ca0 <alloc_pages>
ffffffffc0205874:	40050063          	beqz	a0,ffffffffc0205c74 <do_execve+0x49a>
    return page - pages + nbase;
ffffffffc0205878:	e8ea                	sd	s10,80(sp)
ffffffffc020587a:	00098d17          	auipc	s10,0x98
ffffffffc020587e:	3b6d0d13          	addi	s10,s10,950 # ffffffffc029dc30 <pages>
ffffffffc0205882:	000d3783          	ld	a5,0(s10)
ffffffffc0205886:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc0205888:	00098c97          	auipc	s9,0x98
ffffffffc020588c:	3a0c8c93          	addi	s9,s9,928 # ffffffffc029dc28 <npage>
    return page - pages + nbase;
ffffffffc0205890:	40f506b3          	sub	a3,a0,a5
ffffffffc0205894:	00003717          	auipc	a4,0x3
ffffffffc0205898:	57473703          	ld	a4,1396(a4) # ffffffffc0208e08 <nbase>
ffffffffc020589c:	f4de                	sd	s7,104(sp)
ffffffffc020589e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02058a0:	5bfd                	li	s7,-1
ffffffffc02058a2:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc02058a6:	96ba                	add	a3,a3,a4
ffffffffc02058a8:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02058aa:	00cbd713          	srli	a4,s7,0xc
ffffffffc02058ae:	f03a                	sd	a4,32(sp)
ffffffffc02058b0:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02058b2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02058b4:	3ef77363          	bgeu	a4,a5,ffffffffc0205c9a <do_execve+0x4c0>
ffffffffc02058b8:	f8da                	sd	s6,112(sp)
ffffffffc02058ba:	00098b17          	auipc	s6,0x98
ffffffffc02058be:	366b0b13          	addi	s6,s6,870 # ffffffffc029dc20 <va_pa_offset>
ffffffffc02058c2:	000b3783          	ld	a5,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02058c6:	6605                	lui	a2,0x1
ffffffffc02058c8:	00098597          	auipc	a1,0x98
ffffffffc02058cc:	3505b583          	ld	a1,848(a1) # ffffffffc029dc18 <boot_pgdir>
ffffffffc02058d0:	00f68933          	add	s2,a3,a5
ffffffffc02058d4:	854a                	mv	a0,s2
ffffffffc02058d6:	e152                	sd	s4,128(sp)
ffffffffc02058d8:	61d000ef          	jal	ffffffffc02066f4 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058dc:	000aa703          	lw	a4,0(s5)
ffffffffc02058e0:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02058e4:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058e8:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464baa1f>
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058ec:	020aba03          	ld	s4,32(s5)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058f0:	06f70663          	beq	a4,a5,ffffffffc020595c <do_execve+0x182>
        ret = -E_INVAL_ELF;
ffffffffc02058f4:	5961                	li	s2,-8
    put_pgdir(mm);
ffffffffc02058f6:	8526                	mv	a0,s1
ffffffffc02058f8:	d28ff0ef          	jal	ffffffffc0204e20 <put_pgdir>
ffffffffc02058fc:	6a0a                	ld	s4,128(sp)
ffffffffc02058fe:	7b46                	ld	s6,112(sp)
ffffffffc0205900:	7ba6                	ld	s7,104(sp)
ffffffffc0205902:	6ce6                	ld	s9,88(sp)
ffffffffc0205904:	6d46                	ld	s10,80(sp)
    mm_destroy(mm);
ffffffffc0205906:	8526                	mv	a0,s1
ffffffffc0205908:	9abfe0ef          	jal	ffffffffc02042b2 <mm_destroy>
    do_exit(ret);
ffffffffc020590c:	854a                	mv	a0,s2
ffffffffc020590e:	f122                	sd	s0,160(sp)
ffffffffc0205910:	e152                	sd	s4,128(sp)
ffffffffc0205912:	f8da                	sd	s6,112(sp)
ffffffffc0205914:	f4de                	sd	s7,104(sp)
ffffffffc0205916:	f0e2                	sd	s8,96(sp)
ffffffffc0205918:	ece6                	sd	s9,88(sp)
ffffffffc020591a:	e8ea                	sd	s10,80(sp)
ffffffffc020591c:	a6bff0ef          	jal	ffffffffc0205386 <do_exit>
    if (len > PROC_NAME_LEN) {
ffffffffc0205920:	463d                	li	a2,15
    memcpy(local_name, name, len);
ffffffffc0205922:	85ca                	mv	a1,s2
ffffffffc0205924:	1808                	addi	a0,sp,48
ffffffffc0205926:	5cf000ef          	jal	ffffffffc02066f4 <memcpy>
    if (mm != NULL) {
ffffffffc020592a:	f00991e3          	bnez	s3,ffffffffc020582c <do_execve+0x52>
    if (current->mm != NULL) {
ffffffffc020592e:	000db783          	ld	a5,0(s11)
ffffffffc0205932:	779c                	ld	a5,40(a5)
ffffffffc0205934:	db85                	beqz	a5,ffffffffc0205864 <do_execve+0x8a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205936:	00003617          	auipc	a2,0x3
ffffffffc020593a:	d1260613          	addi	a2,a2,-750 # ffffffffc0208648 <etext+0x1f3c>
ffffffffc020593e:	24100593          	li	a1,577
ffffffffc0205942:	00003517          	auipc	a0,0x3
ffffffffc0205946:	b2650513          	addi	a0,a0,-1242 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc020594a:	f122                	sd	s0,160(sp)
ffffffffc020594c:	e152                	sd	s4,128(sp)
ffffffffc020594e:	f8da                	sd	s6,112(sp)
ffffffffc0205950:	f4de                	sd	s7,104(sp)
ffffffffc0205952:	f0e2                	sd	s8,96(sp)
ffffffffc0205954:	ece6                	sd	s9,88(sp)
ffffffffc0205956:	e8ea                	sd	s10,80(sp)
ffffffffc0205958:	b1dfa0ef          	jal	ffffffffc0200474 <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020595c:	038ad703          	lhu	a4,56(s5)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205960:	9a56                	add	s4,s4,s5
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205962:	f122                	sd	s0,160(sp)
ffffffffc0205964:	00371793          	slli	a5,a4,0x3
ffffffffc0205968:	8f99                	sub	a5,a5,a4
ffffffffc020596a:	078e                	slli	a5,a5,0x3
ffffffffc020596c:	97d2                	add	a5,a5,s4
ffffffffc020596e:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205970:	00fa7e63          	bgeu	s4,a5,ffffffffc020598c <do_execve+0x1b2>
ffffffffc0205974:	f0e2                	sd	s8,96(sp)
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205976:	000a2783          	lw	a5,0(s4) # 1000 <_binary_obj___user_softint_out_size-0x75f8>
ffffffffc020597a:	4705                	li	a4,1
ffffffffc020597c:	0ee78d63          	beq	a5,a4,ffffffffc0205a76 <do_execve+0x29c>
    for (; ph < ph_end; ph ++) {
ffffffffc0205980:	77a2                	ld	a5,40(sp)
ffffffffc0205982:	038a0a13          	addi	s4,s4,56
ffffffffc0205986:	fefa68e3          	bltu	s4,a5,ffffffffc0205976 <do_execve+0x19c>
ffffffffc020598a:	7c06                	ld	s8,96(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc020598c:	4701                	li	a4,0
ffffffffc020598e:	46ad                	li	a3,11
ffffffffc0205990:	00100637          	lui	a2,0x100
ffffffffc0205994:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205998:	8526                	mv	a0,s1
ffffffffc020599a:	96bfe0ef          	jal	ffffffffc0204304 <mm_map>
ffffffffc020599e:	892a                	mv	s2,a0
ffffffffc02059a0:	18051d63          	bnez	a0,ffffffffc0205b3a <do_execve+0x360>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02059a4:	6c88                	ld	a0,24(s1)
ffffffffc02059a6:	467d                	li	a2,31
ffffffffc02059a8:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02059ac:	98dfd0ef          	jal	ffffffffc0203338 <pgdir_alloc_page>
ffffffffc02059b0:	38050563          	beqz	a0,ffffffffc0205d3a <do_execve+0x560>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02059b4:	6c88                	ld	a0,24(s1)
ffffffffc02059b6:	467d                	li	a2,31
ffffffffc02059b8:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059bc:	97dfd0ef          	jal	ffffffffc0203338 <pgdir_alloc_page>
ffffffffc02059c0:	34050c63          	beqz	a0,ffffffffc0205d18 <do_execve+0x53e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059c4:	6c88                	ld	a0,24(s1)
ffffffffc02059c6:	467d                	li	a2,31
ffffffffc02059c8:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059cc:	96dfd0ef          	jal	ffffffffc0203338 <pgdir_alloc_page>
ffffffffc02059d0:	32050363          	beqz	a0,ffffffffc0205cf6 <do_execve+0x51c>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059d4:	6c88                	ld	a0,24(s1)
ffffffffc02059d6:	467d                	li	a2,31
ffffffffc02059d8:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059dc:	95dfd0ef          	jal	ffffffffc0203338 <pgdir_alloc_page>
ffffffffc02059e0:	2e050a63          	beqz	a0,ffffffffc0205cd4 <do_execve+0x4fa>
    mm->mm_count += 1;
ffffffffc02059e4:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02059e6:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059ea:	6c94                	ld	a3,24(s1)
ffffffffc02059ec:	2785                	addiw	a5,a5,1
ffffffffc02059ee:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc02059f0:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059f2:	c02007b7          	lui	a5,0xc0200
ffffffffc02059f6:	2cf6e263          	bltu	a3,a5,ffffffffc0205cba <do_execve+0x4e0>
ffffffffc02059fa:	000b3783          	ld	a5,0(s6)
ffffffffc02059fe:	577d                	li	a4,-1
ffffffffc0205a00:	177e                	slli	a4,a4,0x3f
ffffffffc0205a02:	8e9d                	sub	a3,a3,a5
ffffffffc0205a04:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a08:	f654                	sd	a3,168(a2)
ffffffffc0205a0a:	8fd9                	or	a5,a5,a4
ffffffffc0205a0c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a10:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a12:	4581                	li	a1,0
ffffffffc0205a14:	12000613          	li	a2,288
ffffffffc0205a18:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a1a:	10043983          	ld	s3,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a1e:	4c5000ef          	jal	ffffffffc02066e2 <memset>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a22:	000db483          	ld	s1,0(s11)
    tf->epc = elf->e_entry;
ffffffffc0205a26:	018ab703          	ld	a4,24(s5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a2a:	4785                	li	a5,1
ffffffffc0205a2c:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a2e:	0b448493          	addi	s1,s1,180
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // zero archive
ffffffffc0205a32:	edf9f993          	andi	s3,s3,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a36:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a38:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // zero archive
ffffffffc0205a3c:	11343023          	sd	s3,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a40:	4641                	li	a2,16
ffffffffc0205a42:	4581                	li	a1,0
ffffffffc0205a44:	8526                	mv	a0,s1
ffffffffc0205a46:	49d000ef          	jal	ffffffffc02066e2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205a4a:	463d                	li	a2,15
ffffffffc0205a4c:	180c                	addi	a1,sp,48
ffffffffc0205a4e:	8526                	mv	a0,s1
ffffffffc0205a50:	4a5000ef          	jal	ffffffffc02066f4 <memcpy>
ffffffffc0205a54:	740a                	ld	s0,160(sp)
ffffffffc0205a56:	6a0a                	ld	s4,128(sp)
ffffffffc0205a58:	7b46                	ld	s6,112(sp)
ffffffffc0205a5a:	7ba6                	ld	s7,104(sp)
ffffffffc0205a5c:	6ce6                	ld	s9,88(sp)
ffffffffc0205a5e:	6d46                	ld	s10,80(sp)
}
ffffffffc0205a60:	70aa                	ld	ra,168(sp)
ffffffffc0205a62:	64ea                	ld	s1,152(sp)
ffffffffc0205a64:	69aa                	ld	s3,136(sp)
ffffffffc0205a66:	7ae6                	ld	s5,120(sp)
ffffffffc0205a68:	6da6                	ld	s11,72(sp)
ffffffffc0205a6a:	854a                	mv	a0,s2
ffffffffc0205a6c:	694a                	ld	s2,144(sp)
ffffffffc0205a6e:	614d                	addi	sp,sp,176
ffffffffc0205a70:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0205a72:	5971                	li	s2,-4
ffffffffc0205a74:	bd61                	j	ffffffffc020590c <do_execve+0x132>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a76:	028a3603          	ld	a2,40(s4)
ffffffffc0205a7a:	020a3783          	ld	a5,32(s4)
ffffffffc0205a7e:	1ef66f63          	bltu	a2,a5,ffffffffc0205c7c <do_execve+0x4a2>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a82:	004a2783          	lw	a5,4(s4)
ffffffffc0205a86:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a8a:	0027f593          	andi	a1,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a8e:	0026971b          	slliw	a4,a3,0x2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a92:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a94:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a96:	e1e9                	bnez	a1,ffffffffc0205b58 <do_execve+0x37e>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a98:	1a079b63          	bnez	a5,ffffffffc0205c4e <do_execve+0x474>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a9c:	47c5                	li	a5,17
ffffffffc0205a9e:	ec3e                	sd	a5,24(sp)
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205aa0:	0046f793          	andi	a5,a3,4
ffffffffc0205aa4:	c789                	beqz	a5,ffffffffc0205aae <do_execve+0x2d4>
ffffffffc0205aa6:	67e2                	ld	a5,24(sp)
ffffffffc0205aa8:	0087e793          	ori	a5,a5,8
ffffffffc0205aac:	ec3e                	sd	a5,24(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205aae:	010a3583          	ld	a1,16(s4)
ffffffffc0205ab2:	4701                	li	a4,0
ffffffffc0205ab4:	8526                	mv	a0,s1
ffffffffc0205ab6:	84ffe0ef          	jal	ffffffffc0204304 <mm_map>
ffffffffc0205aba:	892a                	mv	s2,a0
ffffffffc0205abc:	1a051e63          	bnez	a0,ffffffffc0205c78 <do_execve+0x49e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ac0:	010a3c03          	ld	s8,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ac4:	020a3903          	ld	s2,32(s4)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ac8:	008a3983          	ld	s3,8(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205acc:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ace:	9962                	add	s2,s2,s8
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ad0:	00fc7bb3          	and	s7,s8,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ad4:	99d6                	add	s3,s3,s5
        while (start < end) {
ffffffffc0205ad6:	052c6963          	bltu	s8,s2,ffffffffc0205b28 <do_execve+0x34e>
ffffffffc0205ada:	aa59                	j	ffffffffc0205c70 <do_execve+0x496>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205adc:	6785                	lui	a5,0x1
ffffffffc0205ade:	417c0533          	sub	a0,s8,s7
ffffffffc0205ae2:	9bbe                	add	s7,s7,a5
            if (end < la) {
ffffffffc0205ae4:	41890633          	sub	a2,s2,s8
ffffffffc0205ae8:	01796463          	bltu	s2,s7,ffffffffc0205af0 <do_execve+0x316>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205aec:	418b8633          	sub	a2,s7,s8
    return page - pages + nbase;
ffffffffc0205af0:	000d3683          	ld	a3,0(s10)
ffffffffc0205af4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205af6:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205afa:	40d406b3          	sub	a3,s0,a3
ffffffffc0205afe:	8699                	srai	a3,a3,0x6
ffffffffc0205b00:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b02:	7782                	ld	a5,32(sp)
ffffffffc0205b04:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b08:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b0a:	16b87c63          	bgeu	a6,a1,ffffffffc0205c82 <do_execve+0x4a8>
ffffffffc0205b0e:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b12:	85ce                	mv	a1,s3
ffffffffc0205b14:	e432                	sd	a2,8(sp)
ffffffffc0205b16:	96c2                	add	a3,a3,a6
ffffffffc0205b18:	9536                	add	a0,a0,a3
ffffffffc0205b1a:	3db000ef          	jal	ffffffffc02066f4 <memcpy>
            start += size, from += size;
ffffffffc0205b1e:	6622                	ld	a2,8(sp)
ffffffffc0205b20:	9c32                	add	s8,s8,a2
ffffffffc0205b22:	99b2                	add	s3,s3,a2
        while (start < end) {
ffffffffc0205b24:	052c7363          	bgeu	s8,s2,ffffffffc0205b6a <do_execve+0x390>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b28:	6c88                	ld	a0,24(s1)
ffffffffc0205b2a:	6662                	ld	a2,24(sp)
ffffffffc0205b2c:	85de                	mv	a1,s7
ffffffffc0205b2e:	80bfd0ef          	jal	ffffffffc0203338 <pgdir_alloc_page>
ffffffffc0205b32:	842a                	mv	s0,a0
ffffffffc0205b34:	f545                	bnez	a0,ffffffffc0205adc <do_execve+0x302>
ffffffffc0205b36:	7c06                	ld	s8,96(sp)
        ret = -E_NO_MEM;
ffffffffc0205b38:	5971                	li	s2,-4
    exit_mmap(mm);
ffffffffc0205b3a:	8526                	mv	a0,s1
ffffffffc0205b3c:	92ffe0ef          	jal	ffffffffc020446a <exit_mmap>
ffffffffc0205b40:	740a                	ld	s0,160(sp)
ffffffffc0205b42:	bb55                	j	ffffffffc02058f6 <do_execve+0x11c>
            exit_mmap(mm);
ffffffffc0205b44:	854e                	mv	a0,s3
ffffffffc0205b46:	925fe0ef          	jal	ffffffffc020446a <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b4a:	854e                	mv	a0,s3
ffffffffc0205b4c:	ad4ff0ef          	jal	ffffffffc0204e20 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b50:	854e                	mv	a0,s3
ffffffffc0205b52:	f60fe0ef          	jal	ffffffffc02042b2 <mm_destroy>
ffffffffc0205b56:	b319                	j	ffffffffc020585c <do_execve+0x82>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b58:	10079263          	bnez	a5,ffffffffc0205c5c <do_execve+0x482>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b5c:	00276713          	ori	a4,a4,2
ffffffffc0205b60:	0007069b          	sext.w	a3,a4
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b64:	47dd                	li	a5,23
ffffffffc0205b66:	ec3e                	sd	a5,24(sp)
ffffffffc0205b68:	bf25                	j	ffffffffc0205aa0 <do_execve+0x2c6>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b6a:	010a3903          	ld	s2,16(s4)
ffffffffc0205b6e:	028a3683          	ld	a3,40(s4)
ffffffffc0205b72:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205b74:	077c7a63          	bgeu	s8,s7,ffffffffc0205be8 <do_execve+0x40e>
            if (start == end) {
ffffffffc0205b78:	e18904e3          	beq	s2,s8,ffffffffc0205980 <do_execve+0x1a6>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b7c:	6505                	lui	a0,0x1
ffffffffc0205b7e:	9562                	add	a0,a0,s8
ffffffffc0205b80:	41750533          	sub	a0,a0,s7
                size -= la - end;
ffffffffc0205b84:	418909b3          	sub	s3,s2,s8
            if (end < la) {
ffffffffc0205b88:	0d797f63          	bgeu	s2,s7,ffffffffc0205c66 <do_execve+0x48c>
    return page - pages + nbase;
ffffffffc0205b8c:	000d3683          	ld	a3,0(s10)
ffffffffc0205b90:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b92:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b96:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b9a:	8699                	srai	a3,a3,0x6
ffffffffc0205b9c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b9e:	00c69593          	slli	a1,a3,0xc
ffffffffc0205ba2:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ba4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ba6:	0cc5fe63          	bgeu	a1,a2,ffffffffc0205c82 <do_execve+0x4a8>
ffffffffc0205baa:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bae:	864e                	mv	a2,s3
ffffffffc0205bb0:	4581                	li	a1,0
ffffffffc0205bb2:	96c2                	add	a3,a3,a6
ffffffffc0205bb4:	9536                	add	a0,a0,a3
ffffffffc0205bb6:	32d000ef          	jal	ffffffffc02066e2 <memset>
            start += size;
ffffffffc0205bba:	9c4e                	add	s8,s8,s3
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bbc:	03797463          	bgeu	s2,s7,ffffffffc0205be4 <do_execve+0x40a>
ffffffffc0205bc0:	dd8900e3          	beq	s2,s8,ffffffffc0205980 <do_execve+0x1a6>
ffffffffc0205bc4:	00003697          	auipc	a3,0x3
ffffffffc0205bc8:	aac68693          	addi	a3,a3,-1364 # ffffffffc0208670 <etext+0x1f64>
ffffffffc0205bcc:	00001617          	auipc	a2,0x1
ffffffffc0205bd0:	1bc60613          	addi	a2,a2,444 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205bd4:	29600593          	li	a1,662
ffffffffc0205bd8:	00003517          	auipc	a0,0x3
ffffffffc0205bdc:	89050513          	addi	a0,a0,-1904 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205be0:	895fa0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0205be4:	ff8b90e3          	bne	s7,s8,ffffffffc0205bc4 <do_execve+0x3ea>
        while (start < end) {
ffffffffc0205be8:	d92c7ce3          	bgeu	s8,s2,ffffffffc0205980 <do_execve+0x1a6>
ffffffffc0205bec:	56fd                	li	a3,-1
ffffffffc0205bee:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205bf2:	e43e                	sd	a5,8(sp)
ffffffffc0205bf4:	a0a9                	j	ffffffffc0205c3e <do_execve+0x464>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bf6:	6785                	lui	a5,0x1
ffffffffc0205bf8:	417c0533          	sub	a0,s8,s7
ffffffffc0205bfc:	9bbe                	add	s7,s7,a5
            if (end < la) {
ffffffffc0205bfe:	418909b3          	sub	s3,s2,s8
ffffffffc0205c02:	01796463          	bltu	s2,s7,ffffffffc0205c0a <do_execve+0x430>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c06:	418b89b3          	sub	s3,s7,s8
    return page - pages + nbase;
ffffffffc0205c0a:	000d3683          	ld	a3,0(s10)
ffffffffc0205c0e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c10:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c14:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c18:	8699                	srai	a3,a3,0x6
ffffffffc0205c1a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c1c:	67a2                	ld	a5,8(sp)
ffffffffc0205c1e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c22:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c24:	04b87f63          	bgeu	a6,a1,ffffffffc0205c82 <do_execve+0x4a8>
ffffffffc0205c28:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c2c:	864e                	mv	a2,s3
ffffffffc0205c2e:	4581                	li	a1,0
ffffffffc0205c30:	96c2                	add	a3,a3,a6
ffffffffc0205c32:	9536                	add	a0,a0,a3
            start += size;
ffffffffc0205c34:	9c4e                	add	s8,s8,s3
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c36:	2ad000ef          	jal	ffffffffc02066e2 <memset>
        while (start < end) {
ffffffffc0205c3a:	d52c73e3          	bgeu	s8,s2,ffffffffc0205980 <do_execve+0x1a6>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c3e:	6c88                	ld	a0,24(s1)
ffffffffc0205c40:	6662                	ld	a2,24(sp)
ffffffffc0205c42:	85de                	mv	a1,s7
ffffffffc0205c44:	ef4fd0ef          	jal	ffffffffc0203338 <pgdir_alloc_page>
ffffffffc0205c48:	842a                	mv	s0,a0
ffffffffc0205c4a:	f555                	bnez	a0,ffffffffc0205bf6 <do_execve+0x41c>
ffffffffc0205c4c:	b5ed                	j	ffffffffc0205b36 <do_execve+0x35c>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c4e:	00176713          	ori	a4,a4,1
ffffffffc0205c52:	47cd                	li	a5,19
ffffffffc0205c54:	0007069b          	sext.w	a3,a4
ffffffffc0205c58:	ec3e                	sd	a5,24(sp)
ffffffffc0205c5a:	b599                	j	ffffffffc0205aa0 <do_execve+0x2c6>
ffffffffc0205c5c:	00376713          	ori	a4,a4,3
ffffffffc0205c60:	0007069b          	sext.w	a3,a4
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c64:	b701                	j	ffffffffc0205b64 <do_execve+0x38a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c66:	418b89b3          	sub	s3,s7,s8
ffffffffc0205c6a:	b70d                	j	ffffffffc0205b8c <do_execve+0x3b2>
        return -E_INVAL;
ffffffffc0205c6c:	5975                	li	s2,-3
ffffffffc0205c6e:	bbcd                	j	ffffffffc0205a60 <do_execve+0x286>
        while (start < end) {
ffffffffc0205c70:	8962                	mv	s2,s8
ffffffffc0205c72:	bdf5                	j	ffffffffc0205b6e <do_execve+0x394>
    int ret = -E_NO_MEM;
ffffffffc0205c74:	5971                	li	s2,-4
ffffffffc0205c76:	b941                	j	ffffffffc0205906 <do_execve+0x12c>
ffffffffc0205c78:	7c06                	ld	s8,96(sp)
ffffffffc0205c7a:	b5c1                	j	ffffffffc0205b3a <do_execve+0x360>
            ret = -E_INVAL_ELF;
ffffffffc0205c7c:	7c06                	ld	s8,96(sp)
ffffffffc0205c7e:	5961                	li	s2,-8
ffffffffc0205c80:	bd6d                	j	ffffffffc0205b3a <do_execve+0x360>
ffffffffc0205c82:	00001617          	auipc	a2,0x1
ffffffffc0205c86:	72e60613          	addi	a2,a2,1838 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0205c8a:	06900593          	li	a1,105
ffffffffc0205c8e:	00001517          	auipc	a0,0x1
ffffffffc0205c92:	74a50513          	addi	a0,a0,1866 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0205c96:	fdefa0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0205c9a:	00001617          	auipc	a2,0x1
ffffffffc0205c9e:	71660613          	addi	a2,a2,1814 # ffffffffc02073b0 <etext+0xca4>
ffffffffc0205ca2:	06900593          	li	a1,105
ffffffffc0205ca6:	00001517          	auipc	a0,0x1
ffffffffc0205caa:	73250513          	addi	a0,a0,1842 # ffffffffc02073d8 <etext+0xccc>
ffffffffc0205cae:	f122                	sd	s0,160(sp)
ffffffffc0205cb0:	e152                	sd	s4,128(sp)
ffffffffc0205cb2:	f8da                	sd	s6,112(sp)
ffffffffc0205cb4:	f0e2                	sd	s8,96(sp)
ffffffffc0205cb6:	fbefa0ef          	jal	ffffffffc0200474 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205cba:	00001617          	auipc	a2,0x1
ffffffffc0205cbe:	79e60613          	addi	a2,a2,1950 # ffffffffc0207458 <etext+0xd4c>
ffffffffc0205cc2:	2b100593          	li	a1,689
ffffffffc0205cc6:	00002517          	auipc	a0,0x2
ffffffffc0205cca:	7a250513          	addi	a0,a0,1954 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205cce:	f0e2                	sd	s8,96(sp)
ffffffffc0205cd0:	fa4fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cd4:	00003697          	auipc	a3,0x3
ffffffffc0205cd8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0208788 <etext+0x207c>
ffffffffc0205cdc:	00001617          	auipc	a2,0x1
ffffffffc0205ce0:	0ac60613          	addi	a2,a2,172 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205ce4:	2ac00593          	li	a1,684
ffffffffc0205ce8:	00002517          	auipc	a0,0x2
ffffffffc0205cec:	78050513          	addi	a0,a0,1920 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205cf0:	f0e2                	sd	s8,96(sp)
ffffffffc0205cf2:	f82fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cf6:	00003697          	auipc	a3,0x3
ffffffffc0205cfa:	a4a68693          	addi	a3,a3,-1462 # ffffffffc0208740 <etext+0x2034>
ffffffffc0205cfe:	00001617          	auipc	a2,0x1
ffffffffc0205d02:	08a60613          	addi	a2,a2,138 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205d06:	2ab00593          	li	a1,683
ffffffffc0205d0a:	00002517          	auipc	a0,0x2
ffffffffc0205d0e:	75e50513          	addi	a0,a0,1886 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205d12:	f0e2                	sd	s8,96(sp)
ffffffffc0205d14:	f60fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d18:	00003697          	auipc	a3,0x3
ffffffffc0205d1c:	9e068693          	addi	a3,a3,-1568 # ffffffffc02086f8 <etext+0x1fec>
ffffffffc0205d20:	00001617          	auipc	a2,0x1
ffffffffc0205d24:	06860613          	addi	a2,a2,104 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205d28:	2aa00593          	li	a1,682
ffffffffc0205d2c:	00002517          	auipc	a0,0x2
ffffffffc0205d30:	73c50513          	addi	a0,a0,1852 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205d34:	f0e2                	sd	s8,96(sp)
ffffffffc0205d36:	f3efa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d3a:	00003697          	auipc	a3,0x3
ffffffffc0205d3e:	97668693          	addi	a3,a3,-1674 # ffffffffc02086b0 <etext+0x1fa4>
ffffffffc0205d42:	00001617          	auipc	a2,0x1
ffffffffc0205d46:	04660613          	addi	a2,a2,70 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205d4a:	2a900593          	li	a1,681
ffffffffc0205d4e:	00002517          	auipc	a0,0x2
ffffffffc0205d52:	71a50513          	addi	a0,a0,1818 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205d56:	f0e2                	sd	s8,96(sp)
ffffffffc0205d58:	f1cfa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0205d5c <do_yield>:
    current->need_resched = 1;
ffffffffc0205d5c:	00098797          	auipc	a5,0x98
ffffffffc0205d60:	f0c7b783          	ld	a5,-244(a5) # ffffffffc029dc68 <current>
ffffffffc0205d64:	4705                	li	a4,1
ffffffffc0205d66:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d68:	4501                	li	a0,0
ffffffffc0205d6a:	8082                	ret

ffffffffc0205d6c <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d6c:	1101                	addi	sp,sp,-32
ffffffffc0205d6e:	e822                	sd	s0,16(sp)
ffffffffc0205d70:	e426                	sd	s1,8(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205d72:	00098797          	auipc	a5,0x98
ffffffffc0205d76:	ef67b783          	ld	a5,-266(a5) # ffffffffc029dc68 <current>
do_wait(int pid, int *code_store) {
ffffffffc0205d7a:	ec06                	sd	ra,24(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205d7c:	779c                	ld	a5,40(a5)
do_wait(int pid, int *code_store) {
ffffffffc0205d7e:	842e                	mv	s0,a1
ffffffffc0205d80:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d82:	c599                	beqz	a1,ffffffffc0205d90 <do_wait+0x24>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d84:	4685                	li	a3,1
ffffffffc0205d86:	4611                	li	a2,4
ffffffffc0205d88:	853e                	mv	a0,a5
ffffffffc0205d8a:	d9dfe0ef          	jal	ffffffffc0204b26 <user_mem_check>
ffffffffc0205d8e:	c909                	beqz	a0,ffffffffc0205da0 <do_wait+0x34>
ffffffffc0205d90:	85a2                	mv	a1,s0
}
ffffffffc0205d92:	6442                	ld	s0,16(sp)
ffffffffc0205d94:	60e2                	ld	ra,24(sp)
ffffffffc0205d96:	8526                	mv	a0,s1
ffffffffc0205d98:	64a2                	ld	s1,8(sp)
ffffffffc0205d9a:	6105                	addi	sp,sp,32
ffffffffc0205d9c:	f3aff06f          	j	ffffffffc02054d6 <do_wait.part.0>
ffffffffc0205da0:	60e2                	ld	ra,24(sp)
ffffffffc0205da2:	6442                	ld	s0,16(sp)
ffffffffc0205da4:	64a2                	ld	s1,8(sp)
ffffffffc0205da6:	5575                	li	a0,-3
ffffffffc0205da8:	6105                	addi	sp,sp,32
ffffffffc0205daa:	8082                	ret

ffffffffc0205dac <do_kill>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205dac:	6789                	lui	a5,0x2
ffffffffc0205dae:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205db2:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x65fa>
ffffffffc0205db4:	06e7e963          	bltu	a5,a4,ffffffffc0205e26 <do_kill+0x7a>
do_kill(int pid) {
ffffffffc0205db8:	1141                	addi	sp,sp,-16
ffffffffc0205dba:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205dbc:	45a9                	li	a1,10
ffffffffc0205dbe:	842a                	mv	s0,a0
ffffffffc0205dc0:	2501                	sext.w	a0,a0
do_kill(int pid) {
ffffffffc0205dc2:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205dc4:	48a000ef          	jal	ffffffffc020624e <hash32>
ffffffffc0205dc8:	02051793          	slli	a5,a0,0x20
ffffffffc0205dcc:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205dd0:	00094797          	auipc	a5,0x94
ffffffffc0205dd4:	e0878793          	addi	a5,a5,-504 # ffffffffc0299bd8 <hash_list>
ffffffffc0205dd8:	953e                	add	a0,a0,a5
ffffffffc0205dda:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205ddc:	a029                	j	ffffffffc0205de6 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205dde:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205de2:	00870a63          	beq	a4,s0,ffffffffc0205df6 <do_kill+0x4a>
ffffffffc0205de6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205de8:	fef51be3          	bne	a0,a5,ffffffffc0205dde <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205dec:	5575                	li	a0,-3
}
ffffffffc0205dee:	60a2                	ld	ra,8(sp)
ffffffffc0205df0:	6402                	ld	s0,0(sp)
ffffffffc0205df2:	0141                	addi	sp,sp,16
ffffffffc0205df4:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205df6:	fd87a703          	lw	a4,-40(a5)
        return -E_KILLED;
ffffffffc0205dfa:	555d                	li	a0,-9
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205dfc:	00177693          	andi	a3,a4,1
ffffffffc0205e00:	f6fd                	bnez	a3,ffffffffc0205dee <do_kill+0x42>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e02:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205e04:	00176713          	ori	a4,a4,1
ffffffffc0205e08:	fce7ac23          	sw	a4,-40(a5)
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e0c:	0006c763          	bltz	a3,ffffffffc0205e1a <do_kill+0x6e>
            return 0;
ffffffffc0205e10:	4501                	li	a0,0
}
ffffffffc0205e12:	60a2                	ld	ra,8(sp)
ffffffffc0205e14:	6402                	ld	s0,0(sp)
ffffffffc0205e16:	0141                	addi	sp,sp,16
ffffffffc0205e18:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205e1a:	f2878513          	addi	a0,a5,-216
ffffffffc0205e1e:	22a000ef          	jal	ffffffffc0206048 <wakeup_proc>
            return 0;
ffffffffc0205e22:	4501                	li	a0,0
ffffffffc0205e24:	b7fd                	j	ffffffffc0205e12 <do_kill+0x66>
    return -E_INVAL;
ffffffffc0205e26:	5575                	li	a0,-3
}
ffffffffc0205e28:	8082                	ret

ffffffffc0205e2a <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205e2a:	1101                	addi	sp,sp,-32
ffffffffc0205e2c:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205e2e:	00098797          	auipc	a5,0x98
ffffffffc0205e32:	daa78793          	addi	a5,a5,-598 # ffffffffc029dbd8 <proc_list>
ffffffffc0205e36:	ec06                	sd	ra,24(sp)
ffffffffc0205e38:	e822                	sd	s0,16(sp)
ffffffffc0205e3a:	e04a                	sd	s2,0(sp)
ffffffffc0205e3c:	00094497          	auipc	s1,0x94
ffffffffc0205e40:	d9c48493          	addi	s1,s1,-612 # ffffffffc0299bd8 <hash_list>
ffffffffc0205e44:	e79c                	sd	a5,8(a5)
ffffffffc0205e46:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e48:	00098717          	auipc	a4,0x98
ffffffffc0205e4c:	d9070713          	addi	a4,a4,-624 # ffffffffc029dbd8 <proc_list>
ffffffffc0205e50:	87a6                	mv	a5,s1
ffffffffc0205e52:	e79c                	sd	a5,8(a5)
ffffffffc0205e54:	e39c                	sd	a5,0(a5)
ffffffffc0205e56:	07c1                	addi	a5,a5,16
ffffffffc0205e58:	fee79de3          	bne	a5,a4,ffffffffc0205e52 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e5c:	ec7fe0ef          	jal	ffffffffc0204d22 <alloc_proc>
ffffffffc0205e60:	00098917          	auipc	s2,0x98
ffffffffc0205e64:	e1890913          	addi	s2,s2,-488 # ffffffffc029dc78 <idleproc>
ffffffffc0205e68:	00a93023          	sd	a0,0(s2)
ffffffffc0205e6c:	10050063          	beqz	a0,ffffffffc0205f6c <proc_init+0x142>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e70:	4789                	li	a5,2
ffffffffc0205e72:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e74:	00003797          	auipc	a5,0x3
ffffffffc0205e78:	18c78793          	addi	a5,a5,396 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e7c:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e80:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e82:	4785                	li	a5,1
ffffffffc0205e84:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e86:	4641                	li	a2,16
ffffffffc0205e88:	4581                	li	a1,0
ffffffffc0205e8a:	8522                	mv	a0,s0
ffffffffc0205e8c:	057000ef          	jal	ffffffffc02066e2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e90:	463d                	li	a2,15
ffffffffc0205e92:	00003597          	auipc	a1,0x3
ffffffffc0205e96:	95658593          	addi	a1,a1,-1706 # ffffffffc02087e8 <etext+0x20dc>
ffffffffc0205e9a:	8522                	mv	a0,s0
ffffffffc0205e9c:	059000ef          	jal	ffffffffc02066f4 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205ea0:	00098717          	auipc	a4,0x98
ffffffffc0205ea4:	dc070713          	addi	a4,a4,-576 # ffffffffc029dc60 <nr_process>
ffffffffc0205ea8:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205eaa:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205eae:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205eb0:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205eb2:	4581                	li	a1,0
ffffffffc0205eb4:	00000517          	auipc	a0,0x0
ffffffffc0205eb8:	80250513          	addi	a0,a0,-2046 # ffffffffc02056b6 <init_main>
    nr_process ++;
ffffffffc0205ebc:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205ebe:	00098797          	auipc	a5,0x98
ffffffffc0205ec2:	dad7b523          	sd	a3,-598(a5) # ffffffffc029dc68 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ec6:	c70ff0ef          	jal	ffffffffc0205336 <kernel_thread>
ffffffffc0205eca:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205ecc:	08a05463          	blez	a0,ffffffffc0205f54 <proc_init+0x12a>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205ed0:	6789                	lui	a5,0x2
ffffffffc0205ed2:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205ed6:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x65fa>
ffffffffc0205ed8:	2501                	sext.w	a0,a0
ffffffffc0205eda:	02e7e463          	bltu	a5,a4,ffffffffc0205f02 <proc_init+0xd8>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205ede:	45a9                	li	a1,10
ffffffffc0205ee0:	36e000ef          	jal	ffffffffc020624e <hash32>
ffffffffc0205ee4:	02051713          	slli	a4,a0,0x20
ffffffffc0205ee8:	01c75793          	srli	a5,a4,0x1c
ffffffffc0205eec:	00f486b3          	add	a3,s1,a5
ffffffffc0205ef0:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205ef2:	a029                	j	ffffffffc0205efc <proc_init+0xd2>
            if (proc->pid == pid) {
ffffffffc0205ef4:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205ef8:	04870b63          	beq	a4,s0,ffffffffc0205f4e <proc_init+0x124>
    return listelm->next;
ffffffffc0205efc:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205efe:	fef69be3          	bne	a3,a5,ffffffffc0205ef4 <proc_init+0xca>
    return NULL;
ffffffffc0205f02:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f04:	0b478493          	addi	s1,a5,180
ffffffffc0205f08:	4641                	li	a2,16
ffffffffc0205f0a:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205f0c:	00098417          	auipc	s0,0x98
ffffffffc0205f10:	d6440413          	addi	s0,s0,-668 # ffffffffc029dc70 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f14:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205f16:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f18:	7ca000ef          	jal	ffffffffc02066e2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205f1c:	463d                	li	a2,15
ffffffffc0205f1e:	00003597          	auipc	a1,0x3
ffffffffc0205f22:	8f258593          	addi	a1,a1,-1806 # ffffffffc0208810 <etext+0x2104>
ffffffffc0205f26:	8526                	mv	a0,s1
ffffffffc0205f28:	7cc000ef          	jal	ffffffffc02066f4 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f2c:	00093783          	ld	a5,0(s2)
ffffffffc0205f30:	cbb5                	beqz	a5,ffffffffc0205fa4 <proc_init+0x17a>
ffffffffc0205f32:	43dc                	lw	a5,4(a5)
ffffffffc0205f34:	eba5                	bnez	a5,ffffffffc0205fa4 <proc_init+0x17a>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f36:	601c                	ld	a5,0(s0)
ffffffffc0205f38:	c7b1                	beqz	a5,ffffffffc0205f84 <proc_init+0x15a>
ffffffffc0205f3a:	43d8                	lw	a4,4(a5)
ffffffffc0205f3c:	4785                	li	a5,1
ffffffffc0205f3e:	04f71363          	bne	a4,a5,ffffffffc0205f84 <proc_init+0x15a>
}
ffffffffc0205f42:	60e2                	ld	ra,24(sp)
ffffffffc0205f44:	6442                	ld	s0,16(sp)
ffffffffc0205f46:	64a2                	ld	s1,8(sp)
ffffffffc0205f48:	6902                	ld	s2,0(sp)
ffffffffc0205f4a:	6105                	addi	sp,sp,32
ffffffffc0205f4c:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205f4e:	f2878793          	addi	a5,a5,-216
ffffffffc0205f52:	bf4d                	j	ffffffffc0205f04 <proc_init+0xda>
        panic("create init_main failed.\n");
ffffffffc0205f54:	00003617          	auipc	a2,0x3
ffffffffc0205f58:	89c60613          	addi	a2,a2,-1892 # ffffffffc02087f0 <etext+0x20e4>
ffffffffc0205f5c:	3b700593          	li	a1,951
ffffffffc0205f60:	00002517          	auipc	a0,0x2
ffffffffc0205f64:	50850513          	addi	a0,a0,1288 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205f68:	d0cfa0ef          	jal	ffffffffc0200474 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205f6c:	00003617          	auipc	a2,0x3
ffffffffc0205f70:	86460613          	addi	a2,a2,-1948 # ffffffffc02087d0 <etext+0x20c4>
ffffffffc0205f74:	3a900593          	li	a1,937
ffffffffc0205f78:	00002517          	auipc	a0,0x2
ffffffffc0205f7c:	4f050513          	addi	a0,a0,1264 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205f80:	cf4fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f84:	00003697          	auipc	a3,0x3
ffffffffc0205f88:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0208840 <etext+0x2134>
ffffffffc0205f8c:	00001617          	auipc	a2,0x1
ffffffffc0205f90:	dfc60613          	addi	a2,a2,-516 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205f94:	3be00593          	li	a1,958
ffffffffc0205f98:	00002517          	auipc	a0,0x2
ffffffffc0205f9c:	4d050513          	addi	a0,a0,1232 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205fa0:	cd4fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205fa4:	00003697          	auipc	a3,0x3
ffffffffc0205fa8:	87468693          	addi	a3,a3,-1932 # ffffffffc0208818 <etext+0x210c>
ffffffffc0205fac:	00001617          	auipc	a2,0x1
ffffffffc0205fb0:	ddc60613          	addi	a2,a2,-548 # ffffffffc0206d88 <etext+0x67c>
ffffffffc0205fb4:	3bd00593          	li	a1,957
ffffffffc0205fb8:	00002517          	auipc	a0,0x2
ffffffffc0205fbc:	4b050513          	addi	a0,a0,1200 # ffffffffc0208468 <etext+0x1d5c>
ffffffffc0205fc0:	cb4fa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0205fc4 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205fc4:	1141                	addi	sp,sp,-16
ffffffffc0205fc6:	e022                	sd	s0,0(sp)
ffffffffc0205fc8:	e406                	sd	ra,8(sp)
ffffffffc0205fca:	00098417          	auipc	s0,0x98
ffffffffc0205fce:	c9e40413          	addi	s0,s0,-866 # ffffffffc029dc68 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205fd2:	6018                	ld	a4,0(s0)
ffffffffc0205fd4:	6f1c                	ld	a5,24(a4)
ffffffffc0205fd6:	dffd                	beqz	a5,ffffffffc0205fd4 <cpu_idle+0x10>
            schedule();
ffffffffc0205fd8:	10a000ef          	jal	ffffffffc02060e2 <schedule>
ffffffffc0205fdc:	bfdd                	j	ffffffffc0205fd2 <cpu_idle+0xe>

ffffffffc0205fde <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205fde:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205fe2:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205fe6:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205fe8:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205fea:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205fee:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205ff2:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205ff6:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205ffa:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205ffe:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0206002:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0206006:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020600a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020600e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0206012:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0206016:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020601a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020601c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020601e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0206022:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0206026:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020602a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020602e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206032:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0206036:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020603a:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020603e:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206042:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0206046:	8082                	ret

ffffffffc0206048 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206048:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020604a:	1141                	addi	sp,sp,-16
ffffffffc020604c:	e406                	sd	ra,8(sp)
ffffffffc020604e:	e022                	sd	s0,0(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206050:	478d                	li	a5,3
ffffffffc0206052:	06f70963          	beq	a4,a5,ffffffffc02060c4 <wakeup_proc+0x7c>
ffffffffc0206056:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206058:	100027f3          	csrr	a5,sstatus
ffffffffc020605c:	8b89                	andi	a5,a5,2
ffffffffc020605e:	eb99                	bnez	a5,ffffffffc0206074 <wakeup_proc+0x2c>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206060:	4789                	li	a5,2
ffffffffc0206062:	02f70763          	beq	a4,a5,ffffffffc0206090 <wakeup_proc+0x48>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206066:	60a2                	ld	ra,8(sp)
ffffffffc0206068:	6402                	ld	s0,0(sp)
            proc->state = PROC_RUNNABLE;
ffffffffc020606a:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc020606c:	0e052623          	sw	zero,236(a0)
}
ffffffffc0206070:	0141                	addi	sp,sp,16
ffffffffc0206072:	8082                	ret
        intr_disable();
ffffffffc0206074:	dccfa0ef          	jal	ffffffffc0200640 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206078:	4018                	lw	a4,0(s0)
ffffffffc020607a:	4789                	li	a5,2
ffffffffc020607c:	02f70863          	beq	a4,a5,ffffffffc02060ac <wakeup_proc+0x64>
            proc->state = PROC_RUNNABLE;
ffffffffc0206080:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0206082:	0e042623          	sw	zero,236(s0)
}
ffffffffc0206086:	6402                	ld	s0,0(sp)
ffffffffc0206088:	60a2                	ld	ra,8(sp)
ffffffffc020608a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020608c:	daefa06f          	j	ffffffffc020063a <intr_enable>
ffffffffc0206090:	6402                	ld	s0,0(sp)
ffffffffc0206092:	60a2                	ld	ra,8(sp)
            warn("wakeup runnable process.\n");
ffffffffc0206094:	00003617          	auipc	a2,0x3
ffffffffc0206098:	80c60613          	addi	a2,a2,-2036 # ffffffffc02088a0 <etext+0x2194>
ffffffffc020609c:	45c9                	li	a1,18
ffffffffc020609e:	00002517          	auipc	a0,0x2
ffffffffc02060a2:	7ea50513          	addi	a0,a0,2026 # ffffffffc0208888 <etext+0x217c>
}
ffffffffc02060a6:	0141                	addi	sp,sp,16
            warn("wakeup runnable process.\n");
ffffffffc02060a8:	c36fa06f          	j	ffffffffc02004de <__warn>
ffffffffc02060ac:	00002617          	auipc	a2,0x2
ffffffffc02060b0:	7f460613          	addi	a2,a2,2036 # ffffffffc02088a0 <etext+0x2194>
ffffffffc02060b4:	45c9                	li	a1,18
ffffffffc02060b6:	00002517          	auipc	a0,0x2
ffffffffc02060ba:	7d250513          	addi	a0,a0,2002 # ffffffffc0208888 <etext+0x217c>
ffffffffc02060be:	c20fa0ef          	jal	ffffffffc02004de <__warn>
    if (flag) {
ffffffffc02060c2:	b7d1                	j	ffffffffc0206086 <wakeup_proc+0x3e>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060c4:	00002697          	auipc	a3,0x2
ffffffffc02060c8:	7a468693          	addi	a3,a3,1956 # ffffffffc0208868 <etext+0x215c>
ffffffffc02060cc:	00001617          	auipc	a2,0x1
ffffffffc02060d0:	cbc60613          	addi	a2,a2,-836 # ffffffffc0206d88 <etext+0x67c>
ffffffffc02060d4:	45a5                	li	a1,9
ffffffffc02060d6:	00002517          	auipc	a0,0x2
ffffffffc02060da:	7b250513          	addi	a0,a0,1970 # ffffffffc0208888 <etext+0x217c>
ffffffffc02060de:	b96fa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02060e2 <schedule>:

void
schedule(void) {
ffffffffc02060e2:	1141                	addi	sp,sp,-16
ffffffffc02060e4:	e406                	sd	ra,8(sp)
ffffffffc02060e6:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060e8:	100027f3          	csrr	a5,sstatus
ffffffffc02060ec:	8b89                	andi	a5,a5,2
ffffffffc02060ee:	4401                	li	s0,0
ffffffffc02060f0:	efbd                	bnez	a5,ffffffffc020616e <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02060f2:	00098897          	auipc	a7,0x98
ffffffffc02060f6:	b768b883          	ld	a7,-1162(a7) # ffffffffc029dc68 <current>
ffffffffc02060fa:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02060fe:	00098517          	auipc	a0,0x98
ffffffffc0206102:	b7a53503          	ld	a0,-1158(a0) # ffffffffc029dc78 <idleproc>
ffffffffc0206106:	04a88e63          	beq	a7,a0,ffffffffc0206162 <schedule+0x80>
ffffffffc020610a:	0c888693          	addi	a3,a7,200
ffffffffc020610e:	00098617          	auipc	a2,0x98
ffffffffc0206112:	aca60613          	addi	a2,a2,-1334 # ffffffffc029dbd8 <proc_list>
        le = last;
ffffffffc0206116:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206118:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020611a:	4809                	li	a6,2
ffffffffc020611c:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020611e:	00c78863          	beq	a5,a2,ffffffffc020612e <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206122:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206126:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020612a:	03070163          	beq	a4,a6,ffffffffc020614c <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc020612e:	fef697e3          	bne	a3,a5,ffffffffc020611c <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206132:	ed89                	bnez	a1,ffffffffc020614c <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206134:	451c                	lw	a5,8(a0)
ffffffffc0206136:	2785                	addiw	a5,a5,1
ffffffffc0206138:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020613a:	00a88463          	beq	a7,a0,ffffffffc0206142 <schedule+0x60>
            proc_run(next);
ffffffffc020613e:	d59fe0ef          	jal	ffffffffc0204e96 <proc_run>
    if (flag) {
ffffffffc0206142:	e819                	bnez	s0,ffffffffc0206158 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206144:	60a2                	ld	ra,8(sp)
ffffffffc0206146:	6402                	ld	s0,0(sp)
ffffffffc0206148:	0141                	addi	sp,sp,16
ffffffffc020614a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020614c:	4198                	lw	a4,0(a1)
ffffffffc020614e:	4789                	li	a5,2
ffffffffc0206150:	fef712e3          	bne	a4,a5,ffffffffc0206134 <schedule+0x52>
ffffffffc0206154:	852e                	mv	a0,a1
ffffffffc0206156:	bff9                	j	ffffffffc0206134 <schedule+0x52>
}
ffffffffc0206158:	6402                	ld	s0,0(sp)
ffffffffc020615a:	60a2                	ld	ra,8(sp)
ffffffffc020615c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020615e:	cdcfa06f          	j	ffffffffc020063a <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206162:	00098617          	auipc	a2,0x98
ffffffffc0206166:	a7660613          	addi	a2,a2,-1418 # ffffffffc029dbd8 <proc_list>
ffffffffc020616a:	86b2                	mv	a3,a2
ffffffffc020616c:	b76d                	j	ffffffffc0206116 <schedule+0x34>
        intr_disable();
ffffffffc020616e:	cd2fa0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0206172:	4405                	li	s0,1
ffffffffc0206174:	bfbd                	j	ffffffffc02060f2 <schedule+0x10>

ffffffffc0206176 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206176:	00098797          	auipc	a5,0x98
ffffffffc020617a:	af27b783          	ld	a5,-1294(a5) # ffffffffc029dc68 <current>
}
ffffffffc020617e:	43c8                	lw	a0,4(a5)
ffffffffc0206180:	8082                	ret

ffffffffc0206182 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206182:	4501                	li	a0,0
ffffffffc0206184:	8082                	ret

ffffffffc0206186 <sys_putc>:
    cputchar(c);
ffffffffc0206186:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206188:	1141                	addi	sp,sp,-16
ffffffffc020618a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020618c:	828fa0ef          	jal	ffffffffc02001b4 <cputchar>
}
ffffffffc0206190:	60a2                	ld	ra,8(sp)
ffffffffc0206192:	4501                	li	a0,0
ffffffffc0206194:	0141                	addi	sp,sp,16
ffffffffc0206196:	8082                	ret

ffffffffc0206198 <sys_kill>:
    return do_kill(pid);
ffffffffc0206198:	4108                	lw	a0,0(a0)
ffffffffc020619a:	c13ff06f          	j	ffffffffc0205dac <do_kill>

ffffffffc020619e <sys_yield>:
    return do_yield();
ffffffffc020619e:	bbfff06f          	j	ffffffffc0205d5c <do_yield>

ffffffffc02061a2 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02061a2:	6d14                	ld	a3,24(a0)
ffffffffc02061a4:	6910                	ld	a2,16(a0)
ffffffffc02061a6:	650c                	ld	a1,8(a0)
ffffffffc02061a8:	6108                	ld	a0,0(a0)
ffffffffc02061aa:	e30ff06f          	j	ffffffffc02057da <do_execve>

ffffffffc02061ae <sys_wait>:
    return do_wait(pid, store);
ffffffffc02061ae:	650c                	ld	a1,8(a0)
ffffffffc02061b0:	4108                	lw	a0,0(a0)
ffffffffc02061b2:	bbbff06f          	j	ffffffffc0205d6c <do_wait>

ffffffffc02061b6 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02061b6:	00098797          	auipc	a5,0x98
ffffffffc02061ba:	ab27b783          	ld	a5,-1358(a5) # ffffffffc029dc68 <current>
ffffffffc02061be:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02061c0:	4501                	li	a0,0
ffffffffc02061c2:	6a0c                	ld	a1,16(a2)
ffffffffc02061c4:	d3ffe06f          	j	ffffffffc0204f02 <do_fork>

ffffffffc02061c8 <sys_exit>:
    return do_exit(error_code);
ffffffffc02061c8:	4108                	lw	a0,0(a0)
ffffffffc02061ca:	9bcff06f          	j	ffffffffc0205386 <do_exit>

ffffffffc02061ce <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02061ce:	715d                	addi	sp,sp,-80
ffffffffc02061d0:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02061d2:	00098497          	auipc	s1,0x98
ffffffffc02061d6:	a9648493          	addi	s1,s1,-1386 # ffffffffc029dc68 <current>
ffffffffc02061da:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02061dc:	e0a2                	sd	s0,64(sp)
ffffffffc02061de:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02061e0:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02061e2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061e4:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02061e6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061ea:	0327ee63          	bltu	a5,s2,ffffffffc0206226 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02061ee:	00391713          	slli	a4,s2,0x3
ffffffffc02061f2:	00003797          	auipc	a5,0x3
ffffffffc02061f6:	8f678793          	addi	a5,a5,-1802 # ffffffffc0208ae8 <syscalls>
ffffffffc02061fa:	97ba                	add	a5,a5,a4
ffffffffc02061fc:	639c                	ld	a5,0(a5)
ffffffffc02061fe:	c785                	beqz	a5,ffffffffc0206226 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206200:	7028                	ld	a0,96(s0)
ffffffffc0206202:	742c                	ld	a1,104(s0)
ffffffffc0206204:	7834                	ld	a3,112(s0)
ffffffffc0206206:	7c38                	ld	a4,120(s0)
ffffffffc0206208:	6c30                	ld	a2,88(s0)
ffffffffc020620a:	e82a                	sd	a0,16(sp)
ffffffffc020620c:	ec2e                	sd	a1,24(sp)
ffffffffc020620e:	e432                	sd	a2,8(sp)
ffffffffc0206210:	f036                	sd	a3,32(sp)
ffffffffc0206212:	f43a                	sd	a4,40(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206214:	0028                	addi	a0,sp,8
ffffffffc0206216:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206218:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020621a:	e828                	sd	a0,80(s0)
}
ffffffffc020621c:	6406                	ld	s0,64(sp)
ffffffffc020621e:	74e2                	ld	s1,56(sp)
ffffffffc0206220:	7942                	ld	s2,48(sp)
ffffffffc0206222:	6161                	addi	sp,sp,80
ffffffffc0206224:	8082                	ret
    print_trapframe(tf);
ffffffffc0206226:	8522                	mv	a0,s0
ffffffffc0206228:	e08fa0ef          	jal	ffffffffc0200830 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020622c:	609c                	ld	a5,0(s1)
ffffffffc020622e:	86ca                	mv	a3,s2
ffffffffc0206230:	00002617          	auipc	a2,0x2
ffffffffc0206234:	69060613          	addi	a2,a2,1680 # ffffffffc02088c0 <etext+0x21b4>
ffffffffc0206238:	43d8                	lw	a4,4(a5)
ffffffffc020623a:	06200593          	li	a1,98
ffffffffc020623e:	0b478793          	addi	a5,a5,180
ffffffffc0206242:	00002517          	auipc	a0,0x2
ffffffffc0206246:	6ae50513          	addi	a0,a0,1710 # ffffffffc02088f0 <etext+0x21e4>
ffffffffc020624a:	a2afa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020624e <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020624e:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206252:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_exit_out_size+0xffffffff9e3664a1>
ffffffffc0206254:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206258:	02000513          	li	a0,32
ffffffffc020625c:	9d0d                	subw	a0,a0,a1
}
ffffffffc020625e:	00a7d53b          	srlw	a0,a5,a0
ffffffffc0206262:	8082                	ret

ffffffffc0206264 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206264:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206268:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020626a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020626e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206270:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206274:	f022                	sd	s0,32(sp)
ffffffffc0206276:	ec26                	sd	s1,24(sp)
ffffffffc0206278:	e84a                	sd	s2,16(sp)
ffffffffc020627a:	f406                	sd	ra,40(sp)
ffffffffc020627c:	84aa                	mv	s1,a0
ffffffffc020627e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206280:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206284:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0206286:	05067063          	bgeu	a2,a6,ffffffffc02062c6 <printnum+0x62>
ffffffffc020628a:	e44e                	sd	s3,8(sp)
ffffffffc020628c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020628e:	4785                	li	a5,1
ffffffffc0206290:	00e7d763          	bge	a5,a4,ffffffffc020629e <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0206294:	85ca                	mv	a1,s2
ffffffffc0206296:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0206298:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020629a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020629c:	fc65                	bnez	s0,ffffffffc0206294 <printnum+0x30>
ffffffffc020629e:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062a0:	1a02                	slli	s4,s4,0x20
ffffffffc02062a2:	020a5a13          	srli	s4,s4,0x20
ffffffffc02062a6:	00002797          	auipc	a5,0x2
ffffffffc02062aa:	66278793          	addi	a5,a5,1634 # ffffffffc0208908 <etext+0x21fc>
ffffffffc02062ae:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02062b0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062b2:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02062b6:	70a2                	ld	ra,40(sp)
ffffffffc02062b8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062ba:	85ca                	mv	a1,s2
ffffffffc02062bc:	87a6                	mv	a5,s1
}
ffffffffc02062be:	6942                	ld	s2,16(sp)
ffffffffc02062c0:	64e2                	ld	s1,24(sp)
ffffffffc02062c2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062c4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02062c6:	03065633          	divu	a2,a2,a6
ffffffffc02062ca:	8722                	mv	a4,s0
ffffffffc02062cc:	f99ff0ef          	jal	ffffffffc0206264 <printnum>
ffffffffc02062d0:	bfc1                	j	ffffffffc02062a0 <printnum+0x3c>

ffffffffc02062d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02062d2:	7119                	addi	sp,sp,-128
ffffffffc02062d4:	f4a6                	sd	s1,104(sp)
ffffffffc02062d6:	f0ca                	sd	s2,96(sp)
ffffffffc02062d8:	ecce                	sd	s3,88(sp)
ffffffffc02062da:	e8d2                	sd	s4,80(sp)
ffffffffc02062dc:	e4d6                	sd	s5,72(sp)
ffffffffc02062de:	e0da                	sd	s6,64(sp)
ffffffffc02062e0:	f862                	sd	s8,48(sp)
ffffffffc02062e2:	fc86                	sd	ra,120(sp)
ffffffffc02062e4:	f8a2                	sd	s0,112(sp)
ffffffffc02062e6:	fc5e                	sd	s7,56(sp)
ffffffffc02062e8:	f466                	sd	s9,40(sp)
ffffffffc02062ea:	f06a                	sd	s10,32(sp)
ffffffffc02062ec:	ec6e                	sd	s11,24(sp)
ffffffffc02062ee:	892a                	mv	s2,a0
ffffffffc02062f0:	84ae                	mv	s1,a1
ffffffffc02062f2:	8c32                	mv	s8,a2
ffffffffc02062f4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062f6:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062fa:	05500b13          	li	s6,85
ffffffffc02062fe:	00003a97          	auipc	s5,0x3
ffffffffc0206302:	8eaa8a93          	addi	s5,s5,-1814 # ffffffffc0208be8 <syscalls+0x100>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206306:	000c4503          	lbu	a0,0(s8)
ffffffffc020630a:	001c0413          	addi	s0,s8,1
ffffffffc020630e:	01350a63          	beq	a0,s3,ffffffffc0206322 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0206312:	cd0d                	beqz	a0,ffffffffc020634c <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0206314:	85a6                	mv	a1,s1
ffffffffc0206316:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206318:	00044503          	lbu	a0,0(s0)
ffffffffc020631c:	0405                	addi	s0,s0,1
ffffffffc020631e:	ff351ae3          	bne	a0,s3,ffffffffc0206312 <vprintfmt+0x40>
        char padc = ' ';
ffffffffc0206322:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0206326:	4b81                	li	s7,0
ffffffffc0206328:	4601                	li	a2,0
        width = precision = -1;
ffffffffc020632a:	5d7d                	li	s10,-1
ffffffffc020632c:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020632e:	00044683          	lbu	a3,0(s0)
ffffffffc0206332:	00140c13          	addi	s8,s0,1
ffffffffc0206336:	fdd6859b          	addiw	a1,a3,-35
ffffffffc020633a:	0ff5f593          	zext.b	a1,a1
ffffffffc020633e:	02bb6663          	bltu	s6,a1,ffffffffc020636a <vprintfmt+0x98>
ffffffffc0206342:	058a                	slli	a1,a1,0x2
ffffffffc0206344:	95d6                	add	a1,a1,s5
ffffffffc0206346:	4198                	lw	a4,0(a1)
ffffffffc0206348:	9756                	add	a4,a4,s5
ffffffffc020634a:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020634c:	70e6                	ld	ra,120(sp)
ffffffffc020634e:	7446                	ld	s0,112(sp)
ffffffffc0206350:	74a6                	ld	s1,104(sp)
ffffffffc0206352:	7906                	ld	s2,96(sp)
ffffffffc0206354:	69e6                	ld	s3,88(sp)
ffffffffc0206356:	6a46                	ld	s4,80(sp)
ffffffffc0206358:	6aa6                	ld	s5,72(sp)
ffffffffc020635a:	6b06                	ld	s6,64(sp)
ffffffffc020635c:	7be2                	ld	s7,56(sp)
ffffffffc020635e:	7c42                	ld	s8,48(sp)
ffffffffc0206360:	7ca2                	ld	s9,40(sp)
ffffffffc0206362:	7d02                	ld	s10,32(sp)
ffffffffc0206364:	6de2                	ld	s11,24(sp)
ffffffffc0206366:	6109                	addi	sp,sp,128
ffffffffc0206368:	8082                	ret
            putch('%', putdat);
ffffffffc020636a:	85a6                	mv	a1,s1
ffffffffc020636c:	02500513          	li	a0,37
ffffffffc0206370:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206372:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206376:	02500793          	li	a5,37
ffffffffc020637a:	8c22                	mv	s8,s0
ffffffffc020637c:	f8f705e3          	beq	a4,a5,ffffffffc0206306 <vprintfmt+0x34>
ffffffffc0206380:	02500713          	li	a4,37
ffffffffc0206384:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0206388:	1c7d                	addi	s8,s8,-1
ffffffffc020638a:	fee79de3          	bne	a5,a4,ffffffffc0206384 <vprintfmt+0xb2>
ffffffffc020638e:	bfa5                	j	ffffffffc0206306 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0206390:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0206394:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc0206396:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc020639a:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc020639e:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063a2:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc02063a4:	02b76563          	bltu	a4,a1,ffffffffc02063ce <vprintfmt+0xfc>
ffffffffc02063a8:	4525                	li	a0,9
                ch = *fmt;
ffffffffc02063aa:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02063ae:	002d171b          	slliw	a4,s10,0x2
ffffffffc02063b2:	01a7073b          	addw	a4,a4,s10
ffffffffc02063b6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02063ba:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc02063bc:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02063c0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02063c2:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc02063c6:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc02063ca:	feb570e3          	bgeu	a0,a1,ffffffffc02063aa <vprintfmt+0xd8>
            if (width < 0)
ffffffffc02063ce:	f60cd0e3          	bgez	s9,ffffffffc020632e <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc02063d2:	8cea                	mv	s9,s10
ffffffffc02063d4:	5d7d                	li	s10,-1
ffffffffc02063d6:	bfa1                	j	ffffffffc020632e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063d8:	8db6                	mv	s11,a3
ffffffffc02063da:	8462                	mv	s0,s8
ffffffffc02063dc:	bf89                	j	ffffffffc020632e <vprintfmt+0x5c>
ffffffffc02063de:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc02063e0:	4b85                	li	s7,1
            goto reswitch;
ffffffffc02063e2:	b7b1                	j	ffffffffc020632e <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc02063e4:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02063e6:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02063ea:	00c7c463          	blt	a5,a2,ffffffffc02063f2 <vprintfmt+0x120>
    else if (lflag) {
ffffffffc02063ee:	1a060163          	beqz	a2,ffffffffc0206590 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc02063f2:	000a3603          	ld	a2,0(s4)
ffffffffc02063f6:	46c1                	li	a3,16
ffffffffc02063f8:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063fa:	000d879b          	sext.w	a5,s11
ffffffffc02063fe:	8766                	mv	a4,s9
ffffffffc0206400:	85a6                	mv	a1,s1
ffffffffc0206402:	854a                	mv	a0,s2
ffffffffc0206404:	e61ff0ef          	jal	ffffffffc0206264 <printnum>
            break;
ffffffffc0206408:	bdfd                	j	ffffffffc0206306 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020640a:	000a2503          	lw	a0,0(s4)
ffffffffc020640e:	85a6                	mv	a1,s1
ffffffffc0206410:	0a21                	addi	s4,s4,8
ffffffffc0206412:	9902                	jalr	s2
            break;
ffffffffc0206414:	bdcd                	j	ffffffffc0206306 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0206416:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0206418:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020641c:	00c7c463          	blt	a5,a2,ffffffffc0206424 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc0206420:	16060363          	beqz	a2,ffffffffc0206586 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc0206424:	000a3603          	ld	a2,0(s4)
ffffffffc0206428:	46a9                	li	a3,10
ffffffffc020642a:	8a3a                	mv	s4,a4
ffffffffc020642c:	b7f9                	j	ffffffffc02063fa <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc020642e:	85a6                	mv	a1,s1
ffffffffc0206430:	03000513          	li	a0,48
ffffffffc0206434:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206436:	85a6                	mv	a1,s1
ffffffffc0206438:	07800513          	li	a0,120
ffffffffc020643c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020643e:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0206442:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206444:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206446:	bf55                	j	ffffffffc02063fa <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc0206448:	85a6                	mv	a1,s1
ffffffffc020644a:	02500513          	li	a0,37
ffffffffc020644e:	9902                	jalr	s2
            break;
ffffffffc0206450:	bd5d                	j	ffffffffc0206306 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0206452:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206456:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0206458:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020645a:	bf95                	j	ffffffffc02063ce <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc020645c:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020645e:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0206462:	00c7c463          	blt	a5,a2,ffffffffc020646a <vprintfmt+0x198>
    else if (lflag) {
ffffffffc0206466:	10060b63          	beqz	a2,ffffffffc020657c <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc020646a:	000a3603          	ld	a2,0(s4)
ffffffffc020646e:	46a1                	li	a3,8
ffffffffc0206470:	8a3a                	mv	s4,a4
ffffffffc0206472:	b761                	j	ffffffffc02063fa <vprintfmt+0x128>
            if (width < 0)
ffffffffc0206474:	fffcc793          	not	a5,s9
ffffffffc0206478:	97fd                	srai	a5,a5,0x3f
ffffffffc020647a:	00fcf7b3          	and	a5,s9,a5
ffffffffc020647e:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206482:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0206484:	b56d                	j	ffffffffc020632e <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206486:	000a3403          	ld	s0,0(s4)
ffffffffc020648a:	008a0793          	addi	a5,s4,8
ffffffffc020648e:	e43e                	sd	a5,8(sp)
ffffffffc0206490:	12040063          	beqz	s0,ffffffffc02065b0 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0206494:	0d905963          	blez	s9,ffffffffc0206566 <vprintfmt+0x294>
ffffffffc0206498:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020649c:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc02064a0:	12fd9763          	bne	s11,a5,ffffffffc02065ce <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064a4:	00044783          	lbu	a5,0(s0)
ffffffffc02064a8:	0007851b          	sext.w	a0,a5
ffffffffc02064ac:	cb9d                	beqz	a5,ffffffffc02064e2 <vprintfmt+0x210>
ffffffffc02064ae:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064b0:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064b4:	000d4563          	bltz	s10,ffffffffc02064be <vprintfmt+0x1ec>
ffffffffc02064b8:	3d7d                	addiw	s10,s10,-1
ffffffffc02064ba:	028d0263          	beq	s10,s0,ffffffffc02064de <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc02064be:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064c0:	0c0b8d63          	beqz	s7,ffffffffc020659a <vprintfmt+0x2c8>
ffffffffc02064c4:	3781                	addiw	a5,a5,-32
ffffffffc02064c6:	0cfdfa63          	bgeu	s11,a5,ffffffffc020659a <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc02064ca:	03f00513          	li	a0,63
ffffffffc02064ce:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064d0:	000a4783          	lbu	a5,0(s4)
ffffffffc02064d4:	3cfd                	addiw	s9,s9,-1
ffffffffc02064d6:	0a05                	addi	s4,s4,1
ffffffffc02064d8:	0007851b          	sext.w	a0,a5
ffffffffc02064dc:	ffe1                	bnez	a5,ffffffffc02064b4 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc02064de:	01905963          	blez	s9,ffffffffc02064f0 <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc02064e2:	85a6                	mv	a1,s1
ffffffffc02064e4:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc02064e8:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc02064ea:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02064ec:	fe0c9be3          	bnez	s9,ffffffffc02064e2 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064f0:	6a22                	ld	s4,8(sp)
ffffffffc02064f2:	bd11                	j	ffffffffc0206306 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02064f4:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02064f6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02064fa:	00c7c363          	blt	a5,a2,ffffffffc0206500 <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc02064fe:	ce25                	beqz	a2,ffffffffc0206576 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc0206500:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206504:	08044d63          	bltz	s0,ffffffffc020659e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0206508:	8622                	mv	a2,s0
ffffffffc020650a:	8a5e                	mv	s4,s7
ffffffffc020650c:	46a9                	li	a3,10
ffffffffc020650e:	b5f5                	j	ffffffffc02063fa <vprintfmt+0x128>
            if (err < 0) {
ffffffffc0206510:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206514:	4661                	li	a2,24
            if (err < 0) {
ffffffffc0206516:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020651a:	8fb9                	xor	a5,a5,a4
ffffffffc020651c:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206520:	02d64663          	blt	a2,a3,ffffffffc020654c <vprintfmt+0x27a>
ffffffffc0206524:	00369713          	slli	a4,a3,0x3
ffffffffc0206528:	00003797          	auipc	a5,0x3
ffffffffc020652c:	81878793          	addi	a5,a5,-2024 # ffffffffc0208d40 <error_string>
ffffffffc0206530:	97ba                	add	a5,a5,a4
ffffffffc0206532:	639c                	ld	a5,0(a5)
ffffffffc0206534:	cf81                	beqz	a5,ffffffffc020654c <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206536:	86be                	mv	a3,a5
ffffffffc0206538:	00000617          	auipc	a2,0x0
ffffffffc020653c:	20060613          	addi	a2,a2,512 # ffffffffc0206738 <etext+0x2c>
ffffffffc0206540:	85a6                	mv	a1,s1
ffffffffc0206542:	854a                	mv	a0,s2
ffffffffc0206544:	0e8000ef          	jal	ffffffffc020662c <printfmt>
            err = va_arg(ap, int);
ffffffffc0206548:	0a21                	addi	s4,s4,8
ffffffffc020654a:	bb75                	j	ffffffffc0206306 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020654c:	00002617          	auipc	a2,0x2
ffffffffc0206550:	3dc60613          	addi	a2,a2,988 # ffffffffc0208928 <etext+0x221c>
ffffffffc0206554:	85a6                	mv	a1,s1
ffffffffc0206556:	854a                	mv	a0,s2
ffffffffc0206558:	0d4000ef          	jal	ffffffffc020662c <printfmt>
            err = va_arg(ap, int);
ffffffffc020655c:	0a21                	addi	s4,s4,8
ffffffffc020655e:	b365                	j	ffffffffc0206306 <vprintfmt+0x34>
            lflag ++;
ffffffffc0206560:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206562:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0206564:	b3e9                	j	ffffffffc020632e <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206566:	00044783          	lbu	a5,0(s0)
ffffffffc020656a:	0007851b          	sext.w	a0,a5
ffffffffc020656e:	d3c9                	beqz	a5,ffffffffc02064f0 <vprintfmt+0x21e>
ffffffffc0206570:	00140a13          	addi	s4,s0,1
ffffffffc0206574:	bf2d                	j	ffffffffc02064ae <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc0206576:	000a2403          	lw	s0,0(s4)
ffffffffc020657a:	b769                	j	ffffffffc0206504 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc020657c:	000a6603          	lwu	a2,0(s4)
ffffffffc0206580:	46a1                	li	a3,8
ffffffffc0206582:	8a3a                	mv	s4,a4
ffffffffc0206584:	bd9d                	j	ffffffffc02063fa <vprintfmt+0x128>
ffffffffc0206586:	000a6603          	lwu	a2,0(s4)
ffffffffc020658a:	46a9                	li	a3,10
ffffffffc020658c:	8a3a                	mv	s4,a4
ffffffffc020658e:	b5b5                	j	ffffffffc02063fa <vprintfmt+0x128>
ffffffffc0206590:	000a6603          	lwu	a2,0(s4)
ffffffffc0206594:	46c1                	li	a3,16
ffffffffc0206596:	8a3a                	mv	s4,a4
ffffffffc0206598:	b58d                	j	ffffffffc02063fa <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc020659a:	9902                	jalr	s2
ffffffffc020659c:	bf15                	j	ffffffffc02064d0 <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc020659e:	85a6                	mv	a1,s1
ffffffffc02065a0:	02d00513          	li	a0,45
ffffffffc02065a4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065a6:	40800633          	neg	a2,s0
ffffffffc02065aa:	8a5e                	mv	s4,s7
ffffffffc02065ac:	46a9                	li	a3,10
ffffffffc02065ae:	b5b1                	j	ffffffffc02063fa <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc02065b0:	01905663          	blez	s9,ffffffffc02065bc <vprintfmt+0x2ea>
ffffffffc02065b4:	02d00793          	li	a5,45
ffffffffc02065b8:	04fd9263          	bne	s11,a5,ffffffffc02065fc <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065bc:	02800793          	li	a5,40
ffffffffc02065c0:	00002a17          	auipc	s4,0x2
ffffffffc02065c4:	361a0a13          	addi	s4,s4,865 # ffffffffc0208921 <etext+0x2215>
ffffffffc02065c8:	02800513          	li	a0,40
ffffffffc02065cc:	b5cd                	j	ffffffffc02064ae <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065ce:	85ea                	mv	a1,s10
ffffffffc02065d0:	8522                	mv	a0,s0
ffffffffc02065d2:	094000ef          	jal	ffffffffc0206666 <strnlen>
ffffffffc02065d6:	40ac8cbb          	subw	s9,s9,a0
ffffffffc02065da:	01905963          	blez	s9,ffffffffc02065ec <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc02065de:	2d81                	sext.w	s11,s11
ffffffffc02065e0:	85a6                	mv	a1,s1
ffffffffc02065e2:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065e4:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc02065e6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065e8:	fe0c9ce3          	bnez	s9,ffffffffc02065e0 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065ec:	00044783          	lbu	a5,0(s0)
ffffffffc02065f0:	0007851b          	sext.w	a0,a5
ffffffffc02065f4:	ea079de3          	bnez	a5,ffffffffc02064ae <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02065f8:	6a22                	ld	s4,8(sp)
ffffffffc02065fa:	b331                	j	ffffffffc0206306 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02065fc:	85ea                	mv	a1,s10
ffffffffc02065fe:	00002517          	auipc	a0,0x2
ffffffffc0206602:	32250513          	addi	a0,a0,802 # ffffffffc0208920 <etext+0x2214>
ffffffffc0206606:	060000ef          	jal	ffffffffc0206666 <strnlen>
ffffffffc020660a:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc020660e:	00002417          	auipc	s0,0x2
ffffffffc0206612:	31240413          	addi	s0,s0,786 # ffffffffc0208920 <etext+0x2214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206616:	00002a17          	auipc	s4,0x2
ffffffffc020661a:	30ba0a13          	addi	s4,s4,779 # ffffffffc0208921 <etext+0x2215>
ffffffffc020661e:	02800793          	li	a5,40
ffffffffc0206622:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206626:	fb904ce3          	bgtz	s9,ffffffffc02065de <vprintfmt+0x30c>
ffffffffc020662a:	b551                	j	ffffffffc02064ae <vprintfmt+0x1dc>

ffffffffc020662c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020662c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020662e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206632:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206634:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206636:	ec06                	sd	ra,24(sp)
ffffffffc0206638:	f83a                	sd	a4,48(sp)
ffffffffc020663a:	fc3e                	sd	a5,56(sp)
ffffffffc020663c:	e0c2                	sd	a6,64(sp)
ffffffffc020663e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206640:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206642:	c91ff0ef          	jal	ffffffffc02062d2 <vprintfmt>
}
ffffffffc0206646:	60e2                	ld	ra,24(sp)
ffffffffc0206648:	6161                	addi	sp,sp,80
ffffffffc020664a:	8082                	ret

ffffffffc020664c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020664c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206650:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206652:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206654:	cb81                	beqz	a5,ffffffffc0206664 <strlen+0x18>
        cnt ++;
ffffffffc0206656:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206658:	00a707b3          	add	a5,a4,a0
ffffffffc020665c:	0007c783          	lbu	a5,0(a5)
ffffffffc0206660:	fbfd                	bnez	a5,ffffffffc0206656 <strlen+0xa>
ffffffffc0206662:	8082                	ret
    }
    return cnt;
}
ffffffffc0206664:	8082                	ret

ffffffffc0206666 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206666:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206668:	e589                	bnez	a1,ffffffffc0206672 <strnlen+0xc>
ffffffffc020666a:	a811                	j	ffffffffc020667e <strnlen+0x18>
        cnt ++;
ffffffffc020666c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020666e:	00f58863          	beq	a1,a5,ffffffffc020667e <strnlen+0x18>
ffffffffc0206672:	00f50733          	add	a4,a0,a5
ffffffffc0206676:	00074703          	lbu	a4,0(a4)
ffffffffc020667a:	fb6d                	bnez	a4,ffffffffc020666c <strnlen+0x6>
ffffffffc020667c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020667e:	852e                	mv	a0,a1
ffffffffc0206680:	8082                	ret

ffffffffc0206682 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206682:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206684:	0005c703          	lbu	a4,0(a1)
ffffffffc0206688:	0785                	addi	a5,a5,1
ffffffffc020668a:	0585                	addi	a1,a1,1
ffffffffc020668c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206690:	fb75                	bnez	a4,ffffffffc0206684 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206692:	8082                	ret

ffffffffc0206694 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206694:	00054783          	lbu	a5,0(a0)
ffffffffc0206698:	e791                	bnez	a5,ffffffffc02066a4 <strcmp+0x10>
ffffffffc020669a:	a02d                	j	ffffffffc02066c4 <strcmp+0x30>
ffffffffc020669c:	00054783          	lbu	a5,0(a0)
ffffffffc02066a0:	cf89                	beqz	a5,ffffffffc02066ba <strcmp+0x26>
ffffffffc02066a2:	85b6                	mv	a1,a3
ffffffffc02066a4:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02066a8:	0505                	addi	a0,a0,1
ffffffffc02066aa:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02066ae:	fef707e3          	beq	a4,a5,ffffffffc020669c <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066b2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02066b6:	9d19                	subw	a0,a0,a4
ffffffffc02066b8:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066ba:	0015c703          	lbu	a4,1(a1)
ffffffffc02066be:	4501                	li	a0,0
}
ffffffffc02066c0:	9d19                	subw	a0,a0,a4
ffffffffc02066c2:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066c4:	0005c703          	lbu	a4,0(a1)
ffffffffc02066c8:	4501                	li	a0,0
ffffffffc02066ca:	b7f5                	j	ffffffffc02066b6 <strcmp+0x22>

ffffffffc02066cc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02066cc:	00054783          	lbu	a5,0(a0)
ffffffffc02066d0:	c799                	beqz	a5,ffffffffc02066de <strchr+0x12>
        if (*s == c) {
ffffffffc02066d2:	00f58763          	beq	a1,a5,ffffffffc02066e0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02066d6:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02066da:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02066dc:	fbfd                	bnez	a5,ffffffffc02066d2 <strchr+0x6>
    }
    return NULL;
ffffffffc02066de:	4501                	li	a0,0
}
ffffffffc02066e0:	8082                	ret

ffffffffc02066e2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02066e2:	ca01                	beqz	a2,ffffffffc02066f2 <memset+0x10>
ffffffffc02066e4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02066e6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02066e8:	0785                	addi	a5,a5,1
ffffffffc02066ea:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02066ee:	fef61de3          	bne	a2,a5,ffffffffc02066e8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02066f2:	8082                	ret

ffffffffc02066f4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02066f4:	ca19                	beqz	a2,ffffffffc020670a <memcpy+0x16>
ffffffffc02066f6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02066f8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02066fa:	0005c703          	lbu	a4,0(a1)
ffffffffc02066fe:	0585                	addi	a1,a1,1
ffffffffc0206700:	0785                	addi	a5,a5,1
ffffffffc0206702:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206706:	feb61ae3          	bne	a2,a1,ffffffffc02066fa <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020670a:	8082                	ret
