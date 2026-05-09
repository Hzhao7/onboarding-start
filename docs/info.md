<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
# SPI-Controlled PWM Peripheral

This design takes in SPI commands and drives a 16-bit output across 
uo_out[7:0] and uio_out[7:0], configurable for static or PWM output.

## How it works

SPI inputs are received by an SPI peripheral module operating in Mode 0 
at ~100 kHz. The peripheral writes to 5 internal registers which control 
the behavior of each output pin. Each pin can be independently configured 
as off, static high, or PWM output.

The configuration registers are as follows:

| Addr   | Register            | Description                         | Reset Value |
|--------|---------------------|-------------------------------------|-------------|
| `0x00` | `en_reg_out_7_0`    | Enable outputs on `uo_out[7:0]`       | `0x00`      |
| `0x01` | `en_reg_out_15_8`   | Enable outputs on `uio_out[7:0]`      | `0x00`      |
| `0x02` | `en_reg_pwm_7_0`    | Enable PWM for `uo_out[7:0]`          | `0x00`      |
| `0x03` | `en_reg_pwm_15_8`   | Enable PWM for `uio_out[7:0]`         | `0x00`      |
| `0x04` | `pwm_duty_cycle`    | PWM Duty Cycle (0x00=0%, 0xFF=100%)   | `0x00`      |

## How to test

Send SPI transactions to configure the output enable, PWM enable, and duty cycle registers. 
Verify that uo_out and uio_out respond correctly to register writes. 

The provided SPI test verifies valid/invalid address handling, write operations, and output assertions.
The PWM tests verify frequency accuracy (~3 kHz ±1%) and duty cycle accuracy (0%, 50%, 100% ±1%).

## External hardware

None.