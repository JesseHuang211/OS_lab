#include <stdio.h>
#include <ulib.h>

int zero;

int main(void) {
    if (zero == 0) {
        cprintf("value is -1.\n"); // 输出 -1
        return -1; // 返回 -1
    }
    cprintf("value is %d.\n", 1 / zero);
    panic("FAIL: T.T\n");
}

