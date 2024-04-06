#include <platform.h>
#include <stdint.h>
#include "delay.h"

void delay_ms(unsigned int ms) {
 unsigned int max_step = 1000 * (UINT32_MAX / CLK_FREQ);
 unsigned int max_sleep_cycles = max_step * (CLK_FREQ / 1000);
 while (ms > max_step) {
  ms -= max_step;
  delay_cycles(max_sleep_cycles);
 }
 delay_cycles(ms * (CLK_FREQ / 1000));
}

void delay_us(unsigned int us) {
 unsigned int max_step = 1000000 * (UINT32_MAX / CLK_FREQ);
 unsigned int max_sleep_cycles = max_step * (CLK_FREQ / 1000000);
 while (us > max_step) {
  us -= max_step;
  delay_cycles(max_sleep_cycles);
 }
 delay_cycles(us * (CLK_FREQ / 1000000));
}


// https://stackoverflow.com/questions/32719767/cycles-per-instruction-in-delay-loop-on-arm
void delay_cycles(unsigned int cycles) {
		uint32_t l = cycles;
    __asm volatile( "0:" "SUBS %[count], 1;" "BNE 0b;" :[count]"+r"(l) );

}

/*
__asm void delay_cycles(unsigned int cycles) {
 LSRS r0, #2
 BEQ done
loop
 SUBS r0, #1
#if __CORTEX_M == 3 || __CORTEX_M == 4
 NOP
#endif
 BNE loop
done
 BX lr
}
*/
// *******************************ARM University Program Copyright © ARM Ltd 2014*************************************
