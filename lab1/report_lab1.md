# OS 实验报告 (Lab0 & Lab1)

## 第三十五组
- 韩煦光
- 李博瑞
- 黄师祺

---

## Lab0: 实验环境配置

在 Ubuntu 官网下载 ubuntu 系统包，将其导入 VMware 中，配置相关信息，得到基础实验环境，并下载安装 sifive 的预编译工具。安装成功后，再下载模拟器 QEMU 的新版本源码，并验证其内置的 openSBI 是否正常使用。以上完成后，导入 GitHub 上的实验代码包，实验环境搭建基本完成。

### 练习一

熟悉使用 QEMU 和 GDB 进行调试工作，使用 GDB 调试 QEMU 模拟的 RISC-V 计算机加电开始运行到执行应用程序的第一条指令（即跳转到 0x80200000）阶段的执行过程。

- **RISC-V 硬件加电后的几条指令在哪里？完成了哪些功能？**

答：一旦启动，OpenSBI 会跳转到内存地址 0x80200000 处，具体执行的代码在 `kern/init/entry.S` 中，执行名为 `kern_init()` 的函数，定义在 `kern/init/init.c` 中。该函数调用 `cprintf()` 输出信息，最后调用 `console.c` 提供的字符输出接口逐个输出字符。

通过 `make debug` 和 `make gdb` 进行调试，可以看到 RISC-V 计算机加电后处理器从机器模式（M-mode）开始执行，通常从低地址 0x1000 处启动。处理器初始化硬件后为操作系统做准备。

---

## Lab1: RISC-V 中断处理机制

### 练习一

理解内核启动中的程序入口操作，阅读 `kern/init/entry.S` 内容，结合操作系统内核启动流程。

- **la sp bootstacktop**：用于初始化栈指针，确保 core 能在有效的栈空间中启动，并为函数调用和数据存储提供空间。
- **tail kern_init**：调用 `kern_init` 函数完成内核初始化，该指令直接跳转到 `kern_init` 而不返回。

### 练习二

完善 `trap.c` 中的中断处理函数 `trap`，使操作系统在每 100 次时钟中断后打印 “100 ticks”，并在打印 10 行后调用关机函数 `shut_down()`。

代码如下：

```c
void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
        case IRQ_U_SOFT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_SOFT:
            cprintf("Supervisor software interrupt\n");
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
            break;
        case IRQ_U_TIMER:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_TIMER:
            clock_set_next_event();
            ticks++;
            if (ticks % TICK_NUM == 0) {
                print_ticks();
                num++;
            }
            if (num == 10) {
                sbi_shutdown();
            }
            break;
        case IRQ_H_TIMER:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_TIMER:
            cprintf("Machine software interrupt\n");
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
            break;
        case IRQ_H_EXT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_EXT:
            cprintf("Machine software interrupt\n");
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
```

### 扩展练习一
描述与理解中断流程，描述 ucore 中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps中都需要保存所有寄存器吗？请说明理由。

答：mov a0，sp是为了将栈顶指针赋值给$a0,之后的中断处理函数可以直接得到中断帧以进行计算处理；SAVE_ALL根据当前栈指针和寄存器数量确定其存储位置；需要，在中断处理后为了避免某寄存器数据丢失，直接保存所有寄存器的操作简单粗暴但有效。

### 扩展练习二
在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？。

答：第一条指令csrw (Control and Status Register Write)将当前的栈指针 sp 的值写入到 sscratch 寄存器中。在处理异常时，有时需要暂时保存栈指针的值，以便在陷阱处理过程中恢复栈的正常状态。将 sp 保存到 sscratch 中的目的，是为后续的恢复操作提供参考和支持。
第二条指令的作用是将 sscratch 寄存器的值读入到 s0 中，并将 x0 的值（即 0）写入 sscratch 寄存器。将 sscratch 中保存的栈指针恢复到寄存器 s0 中，并且清空 sscratch（即将 sscratch 设置为 0）。在陷阱处理过程中，清空 sscratch 的目的是防止意外递归陷阱时重复使用 sscratch 中的旧值。

stval scause这些csr中的值是只读的，它们仅用于描述当时陷阱发生时的情况。在异常处理完成之后，它们的内容已经失去了继续使用的意义，因为接下来的代码执行不会再依赖这些寄存器。一旦陷阱处理完成，操作系统只需要恢复程序执行的上下文（如通用寄存器和程序计数器 sepc）。stval 和 scause 不属于需要恢复的上下文，它们的值不影响后续的程序执行。

保存 stval 和 scause 是为了确保在处理异常时能够正确获取异常的详细信息。stval提供故障地址或异常相关的值。比如当你遇到访问非法地址的异常时，stval 会告诉你这个非法地址是什么，以便操作系统能够处理这类错误（如缺页异常时用于加载缺失的页面）。scause 提供异常或中断的具体原因。例如，scause 可以告诉操作系统是因为页面错误、系统调用还是断点引发的异常。
