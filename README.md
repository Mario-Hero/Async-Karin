# Async-Karin

Author: Jingge Chen (mariocanfly@hotmail.com)

Version: 0.2  *( Last Update: 2020/01/14 )*



## 写在前面

经过许多测试，这套代码在FPGA上的运行速度和资源消耗实在是不堪。而且缺少约束文件的情况下，运行速度依赖于大量手动调试，如果用自动布局布线那带来的就是比较随机的结果，恐怕很难保证在功能复杂的情况下不出错。

使用时钟+状态机(再整个总线？）的正常设计流程，配合FPGA自带的DSP，就可以很好地解决问题、完成项目，而使用这套代码并不能实现更快的异步电路，如果你仍然要采用完全的异步电路的模式来设计，可以选择自己设计代码和握手流程，并加以约束，但一般情况下完全异步的电路在FPGA上都是速度慢而且消耗资源大的，在ASIC上也许就不一样了。

我现在做FPGA的东西也是用的同步时钟的方法，不同时钟域的状态机通过2相握手协议来传递信息，这样代码编写起来比较方便。

所以……没有必要再用它了。



## First

With many tests, the running speed and resource consumption of this code on FPGA are still really bad. Moreover, in the case of lack of constraint files, if automatic layout and routing is used, it will bring more random results. I am afraid it is difficult to ensure that there is no error in the case of complex functions.

Using the normal design process of clock & state machine with the DSP in FPGAs, we can solve most of the problems and complete projects well. But using this code can't realize the faster asynchronous circuit. If you still want to design in the mode of complete asynchronous circuit, you can write your own code and handshake process, then make constraint files. But in general, completely asynchronous circuits in FPGA, work slow and consumes a lot of resources, which is different in ASIC.

Recently I did an FPGA project. And I'm getting used to use synchronize method with state machines. And two-phase handshake protocol for crossing clock domain transfers. Using synchronize method is much more convenient.

So there is no need to use this code again. 


<br>

**Async-Karin** is an asynchronous framework for FPGA written in Verilog. It has been tested on a Xilinx Artix-7 board and an Altera Cyclone-IV board.

- **Async:** It doesn't need a clock to work.
- **Universal:** It can be applied on almost every FPGA. And it doesn't need a constraints file.
- **Power-saving:** Comparing to normal synchronous design, using this framework can save power.
- **Larger area:** Using this framework may result in consuming more area and time than normal synchronous design using DSPs and IP Cores. Sometimes it runs faster than the IP Cores and sometimes not. This situation is getting improved as the development goes on.

Here is an example to calculate the square root of `dataIn`.

```verilog
sqrt #(32) anyName (request,finish,dataIn,dataOut);
```

Just set the `dataIn` and make `request`  0 -> 1.

The `dataOut` will be the square root of `dataIn` as soon as `finish` 0 -> 1.

`#(32)`  makes the bit width of `dataIn` and `dataOut` both become 32.



# Update Info (v0.2)

At first, I wanted to let the structure itself generate the delay time. However, it ran slowly and wasted too much area. So I completely abandoned it and simply let the delay become the delay time of a flip-flop and it is really **fast** now.

Here is the new time and resource consumption table of operations.



*The "Artix-7" rows are the post-implementation simulation results. And the "Cyclone-IV" is the result on a real Cyclone-IV FPGA, the time is counted by the 50MHz clock on the chip, so I can only give the precision of 20ns.*

|                                                    | Type                    | Method                    | Total Time (ns) | Resource  Utilization |                                  |
| -------------------------------------------------- | ----------------------- | ------------------------- | --------------- | --------------------- | -------------------------------- |
|                                                    |                         |                           |                 | LUT                   | FF (for Cyclone-IV, is  register |
| **32-bit  integer divide (x,y) x=43923751, y=573** | Async-Karin(Artix-7)    | subtraction and shift     | 523             | 459                   | 359                              |
|                                                    | Async-Karin(Cyclone-IV) | subtraction and shift     | 340~360         | 453                   | 253                              |
|                                                    | 100MHz Sync             | IP Core, Divider, Radix2  | 438             | 1151                  | 3202                             |
| **32-bit  integer sqrt (a) a=10454520**            | Async-Karin(Artix-7)    | Newton’s iterative method | 1554            | 594                   | 506                              |
|                                                    | Async-Karin(Cyclone-IV) | Newton’s iterative method | 980~1000        | 681                   | 388                              |
|                                                    | 100MHz Sync             | IP Core, Cordic           | 188             | 395                   | 246                              |
| **32-bit  Fibonacci (N) N=45**                     | Async-Karin(Artix-7)    | Loop                      | 444             | 66                    | 222                              |
|                                                    | Async-Karin(Cyclone-IV) | Loop                      | 280~300         | 219                   | 161                              |
|                                                    | 100MHz Sync             | Loop                      | 528             | 45                    | 128                              |


# Background

This chapter introduces the background of asynchronous circuit, including the definition, advantage, disadvantage of asynchronous circuit and how to realize it on a FPGA.



## What's Async circuit?

**Async(asynchronous) circuit:** The circuit without a global clock. It always uses handshake components to realize local 'clocks'.



### What's the advantages of Async circuit?

In Sparsø J's book *Principles of Asynchronous Circuit Design : A Systems Perspective (2010), page 3*, it says that the advantages of Async circuit are:

> - Low power consumption,  due to ﬁne-grain clock gating and zero standby power consumption.
> - High operating speed, operating speed is determined by actual local latencies rather than global worst-case latency.
> - Less emission of electro-magnetic noise, the local clocks tend to tick at random points in time.
> - Robustness towards variations in supply voltage, temperature, and fabrication process parameters,timing is based on matched delays (and can even be insensitive to circuit and wire delays).
> - Better composability and modularity, because of the simple handshake interfaces and the local timing.
> - No clock distribution and clock skew problems, here is no global signal that needs to be distributed with minimal phase skew across the circuit.

Async-Karin realizes most of them ... however, it is always much slower than normal synchronous design. On one hand, the author lacks of algorithm knowledge on hardware calculation. On the other hand, in order to make the code workable on more FPGA devices, the delay of circuits should not be optimized to particular chip. In Async-Karin, the delay of a calculation is related to the delay of LUT. I think as the development of this project goes on, the time consumption of Async-Karin will be better and better.



### What's the disadvantages of Async circuit?

The asynchronous circuit needs a component to do handshakes between modules, so generally it takes more LUTs and DFFs. Because of no clock, the total time to finish a mission is sometimes unpredictable.

- More area, due to handshake components.
- Unpredictable time sometimes, due to the principle of it.
- No suitable EDA for it.     *[Now, my graduation project is a graphical EDA for Async-Karin].*



## How to realize Async circuits on FPGA?

The picture below shows a handshake model.



![](https://s2.ax1x.com/2019/12/08/QaGJGq.jpg)



When the sender finishes its calculations and the data is valid, it sends a request signal to the receiver.

Then, the receiver catches the request signal and data, sends an acknowledge signal to the sender.

The request and acknowledge signal can be positive edge effective or both edge effective, which is called 4-phase handshake or 2-phase handshake.



# Async-Karin's Method

This chapter introduces the basic structures and principles of Async-Karin.



## Basic Structure

I removes the Acknowledge signal by default, and use it only when it is inevitable to use the Acknowledge signal.

The request signal is positive edge effective here.

The basic structure is as the picture below.

![lLPXPf.jpg](https://s2.ax1x.com/2020/01/14/lLPXPf.jpg)

The timing diagram is as the picture below.



![](https://s2.ax1x.com/2019/12/08/Qarmz4.png)



That structure is the basic structure, sometimes when we need acknowledge, reset signal or so on, the structure must change a bit.



## Naming Rules

The signals are named according to the following table.

| Name | Function                                                     | Name | Function      |
| ---- | ------------------------------------------------------------ | ---- | ------------- |
| req  | Request signal, which is the finish signal from the module before | fin  | Finish signal |
| ack  | Acknowledge signal                                           | rst  | Reset signal  |

 

## List of Important Functions

The chapter introduces the some important functions which are commonly used in Async-Karin. For more details, readers can read the comments in the Verilog files.



### Register

These modules can store values. The var2 is very important when you want to set the initial value before going into a loop.

| Name                       | Function                                                     |
| -------------------------- | ------------------------------------------------------------ |
| var                        | A register with set and reset functions.                     |
| var2                       | A register with two request and finish signals to set the value but only have one data output. |
| registerLeft/registerRight | A shift register with reset and shift functions.             |



### Math

integer add, minus, multiply, divide and square root are supported. The author will add more math functions in the future versions.



### Flow Control

The spirit of asynchronous circuit is it can do flow control like branch and loop directly yet a synchronous cannot do it directly.

| Name           | Function                                                     |
| -------------- | ------------------------------------------------------------ |
| branch         | When req rises, choose a path from two according to the value of boolIn. |
| comparator     | Compare x and y. Output the result, then raise the finish signal. |
| equalOrNot     | Compare x and y. Output whether they are equal or not.       |
| reqAnd         | When all the input request signals have risen, rise fin.     |
| reqOr          | When one of the input request signals rises, rise fin.       |
| once           | The key to jumping into a loop.                              |
| delay/delayOne | The key to generate delay.                                   |



# Power, Speed and Area. Compare with SYNC

The table below shows some comparations between Async-Karin and normal synchronous method. 

I believe that as the project goes on, it will get better and better.

*The "Artix-7" rows are the post-implementation simulation results. And the "Cyclone-4" is the result on a real Cyclone-IV FPGA, the time is counted by the 50MHz clock on the chip, so I can only give the precision of 20ns.*

|                                                    | Type                    | Method                    | Power(W)            |             | Total Time (ns) | Resource  Utilization |      |                                  |
| -------------------------------------------------- | ----------------------- | ------------------------- | ------------------- | ----------- | --------------- | --------------------- | ---- | -------------------------------- |
|                                                    |                         |                           | Total On-chip Power | **Dynamic** | Static          |                       | LUT  | FF (for Cyclone-4, is  register) |
| **32-bit  integer sqrt (a) a=10454520**            | Async-Karin(Artix-7)    | Newton’s iterative method | 0.064               | 0.005       | 0.06            | 1554                  | 594  | 506                              |
|                                                    | Async-Karin(Cyclone-IV) | Newton’s iterative method |                     |             |                 | 980~1000              | 681  | 388                              |
|                                                    | 100MHz Sync             | IP Core, Cordic           | 0.063               | 0.003       | 0.06            | 188                   | 395  | 246                              |
| **32-bit  integer divide (x,y) x=43923751, y=573** | Async-Karin(Artix-7)    | subtraction and shift     | 0.064               | 0.005       | 0.06            | 523                   | 459  | 359                              |
|                                                    | Async-Karin(Cyclone-IV) | subtraction and shift     |                     |             |                 | 340~360               | 453  | 253                              |
|                                                    | 100MHz Sync             | IP Core, Divider, Radix2  | 0.074               | 0.014       | 0.06            | 438                   | 1151 | 3202                             |
| **32-bit  Fibonacci (N) N=45**                     | Async-Karin(Artix-7)    | Loop                      | 0.062               | 0.002       | 0.06            | 444                   | 66   | 222                              |
|                                                    | Async-Karin(Cyclone-IV) | Loop                      |                     |             |                 | 280~300               | 219  | 161                              |
|                                                    | 100MHz Sync             | Loop                      | 0.061               | 0.001       | 0.06            | 528                   | 45   | 128                              |



# License

Licensed under MIT license. Read LICENSE file for more information.

