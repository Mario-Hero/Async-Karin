# Async-Karin

Author: Jingge Chen (mariocanfly@hotmail.com)

Version: 0.1

**Async-Karin** is an asynchronous framework for FPGA written in Verilog. It has been tested on a Xilinx Artix-7 board and an Altera Cyclone-IV board.

- **Async:** It doesn't need a clock to work.
- **Universal:** It can be applied on almost every FPGA because this framework doesn't contain any DSPs or carry chains. And it doesn't need a constraints file.
- **Power-saving:** Comparing to normal synchronous design, using this framework can save power cost.
- **Larger area and lower speed:** Using this framework may result in consuming more than **6x** area and time than normal synchronous design using DSPs and IP Cores. This situation will be improved as the development goes on.

Here is an example to calculate the square root of `dataIn`.

```verilog
sqrt #(32) anyName (request,finish,dataIn,dataOut);
```

Just set the `dataIn` and make `request`  0 -> 1.

The `dataOut` will be the square root of `dataIn` as soon as `finish` 0 -> 1.

`#(32)`  makes the bit width of `dataIn` and `dataOut` both 32.

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
- No suitable EDA for it.



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

![](https://s2.ax1x.com/2019/12/08/QareWF.jpg)



The timing diagram is as the picture below.



![](https://s2.ax1x.com/2019/12/08/Qarmz4.png)



That structure is the basic structure, sometimes when we need acknowledge, reset signal or so on, the structure must change a bit.



## Naming Rules

The signals are named according to the following table.

| Name | Function                                                     | Name | Function      |
| ---- | ------------------------------------------------------------ | ---- | ------------- |
| req  | Request signal, which is the finish signal from the module before | fin  | Finish signal |
| ack  | Acknowledge signal                                           | rst  | Reset signal  |

 

## The Example of Add

Here I give an example of add in Async-Karin to let reader understand the principle of this structure.



#### Usage

**add #(Width)  (req, fin, cin, x, y, s, cout)**

Make the `req` rise,set `x` and `y`. When the `fin` rises, the result `s` is valid.

The `cin` is carry in. The `cout` is carry out. 

It realizes the same function to  `{cout, s} = cin + x + y;`

`Width` is the bit width of `x`, `y` and `s`.



#### Algorithm

The basic thing is to add, but Async-Karin doesn't use symbol '+' to add,

Its design principle is to let request signals go through the same route as data, so that the delay time can be promised.

Readers maybe know how to make a full-adder.

```verilog
module fullAdder (cin,x,y,s,cout);
	input cin; 			// The carry out from the previous fullAdder
    input x,y;     
	output wire s;		// The result of this bit
    output wire cout;	// The carry out to the next fullAdder
    
	assign s = x^y^cin;
    assign cout = (x&y)|(x&cin)|(y&cin);
    // It works actually the same to: assign {cout,s} = x+y+cin;
    
endmodule
```

And we can connect them together and make an adder, which is called Ripple Carry Adder.

Noticing that the carry out is 'flowing' in the circuit. A fullAdder cannot make sure whether its result is correct unless the cin from the previous fullAdder is correct. So the request signal should flow with carry out.

This is the code of Async-Karin's fullAdder.

```verilog
module fullAdder (reqParent,req,fin,cin,x,y,s,cout);
	input req;			// The fin signal from the previous fullAdder
    input reqParent;	// The req signal from the Adder (which is its parent)
    output wire fin;	
    input cin,x,y;
	output wire s,cout;

	assign s = x^y^cin;
	assign cout = (x&y)|(x&cin)|(y&cin);
    assign fin = reqParent&(req|(!x&!y));  // If both x and y is 0, the cout is surely 0, the next fullAdder can start its 'request wave' in no time.

endmodule
```

The `fin` signal represents the availability of `cout`. Connect them together, assign the `fin` of adder to the AND (all the `fin` of fullAdders). 

**Most of the LUTs in FPGA are 6-LUTs. Each `s`, `cout` and `fin` use a LUT. The delay of a LUT is much longer than the routing delay so it is reasonable to assume that the speed of `fin` of a fullAdder is almost the same to `cout`. Furthermore, the `fin` of adder is the AND result of all the `fin` from fullAdders, which offers at least the delay of one LUT. So that when the `fin` of adder rises, the result shall be correct.**

The `reqParent` is very important. It can be used to start or stop the 'request wave'.

This is the code of Async-Karin's adder.

```verilog
module add #(parameter N=32) (req,fin,cin,x,y,so,couto);
input req,cin;
input [N-1:0] x,y;
output reg fin=1'b1;
output reg [N-1:0] so=0;
output reg couto=1'b0;

wire [N-1:0] s;
wire cout;
reg rec=1'b0;
wire fin_add;
wire [N:0] c,f,ft;

assign c[0]=cin;
assign cout=c[N];
assign f[0]=rec;
assign ft[0]=f[0];
assign fin_add=ft[N];

always@(posedge req or posedge fin_add) begin
if(fin_add) begin
	fin<=1'b1;
	rec<=1'b0;
	so<=s;
	couto<=cout;
end
else begin
	fin<=1'b0;
	rec<=1'b1;
	so<=0;
	couto<=1'b0;
end
end

genvar i;
generate 
	for(i=0;i<N;i=i+1)
	begin:fullAdder
		fullAdder fullAdder (rec,f[i],f[i+1],c[i],x[i],y[i],s[i],c[i+1]);
        assign ft[i+1] = f[i] & ft[i];
	end
endgenerate

endmodule
```



#### Delay Measure 

In the post-implementation simulation, I compare the 'add' of Async-Karin to just using a symbol '+' .

The input number x and y are 32-bit.

I let req rise and data change at the same time, and observed the output. 

| **Device:  Artix-7 (xa7a12tcsg325-2I)**        | **Time(ns)**   |               |            |
| ---------------------------------------------- | -------------- | ------------- | ---------- |
| **Post-Implementation Simulation, x + y**      | x=y=1294967291 | x=y=682068749 | x=y=304598 |
| **Async-Karin, add (finish when `fin` rises)** | 16.7           | 15.9          | 15.6       |
| **+ (finish when output stops changing)**      | 9.6            | 9.6           | 9.5        |

The table reveals that the add method of Async-Karin is slower than synchronous ... but you can start to use the data as soon as fin rises and don't have to wait for the next positive edge of clock. 

# List of Important Functions

The chapter introduces the some important functions which are commonly used in Async-Karin. For more details, readers can read the comments in the Verilog files.



## Register

These modules can store values. The var2 is very important when you want to set the initial value before going into a loop.

| Name         | Inputs and Outputs                                | Function                                                     |
| ------------ | ------------------------------------------------- | ------------------------------------------------------------ |
| var          | saveReq, saveFin, rstReq, rstFin,dataIn, dataOut  | save or reset a variable                                     |
| var2         | req1, req2, fin1, fin2, dataIn1, dataIn2, dataOut | When req1 rises, dataIn1 -> dataOut, fin1 rises. When req2 rises, dataIn2 -> dataOut, fin2 rises. |
| registerLeft | saveReq, saveFin, leftReq, leftFin, in, out       | When saveReq rises, in -> out. When leftReq rises, {out<<1,0} -> out. |



## Math

integer add, minus, multiply, divide and square root are supported. The author will add more math functions in the future versions.



## Flow Control

The spirit of asynchronous circuit is it can do flow control like branch and loop directly yet a synchronous cannot do it directly.

| Name       | Inputs and Outputs                     | Function                                                     |
| ---------- | -------------------------------------- | ------------------------------------------------------------ |
| branch     | req, finTrue, finFalse, boolIn         | When req rises, choose which path to go according to boolIn  |
| comparator | req, fin, x, y, bigger, equal, smaller | Compare x and y.                                             |
| equalOrNot | req, equal, notEqual, x, y             | If x==y, rise equal. If x!=y, rise notEqual.                 |
| reqAnd     | #(parameter reqNumber=2) (reqs, fin)   | When all the request signals in reqs have risen, rise fin.   |
| reqOr      | #(parameter reqNumber=2) (reqs, fin)   | When one of the request signals in reqs rises, rise fin.     |
| once       | req1, req2, fin, rstReq, rstFin        | Always used when you wan to go into a loop. The fin is assign to req1 as default. When req1 rises, the fin rises, then the fin will be assigned to req2, until rstReq rises. The rstReq is usually connected to the finish signal of the whole module. |



# Power, Speed and Area. Compare with SYNC

The table below shows some comparations between Async-Karin and normal synchronous method. Because the author lacks of sophisticated algorithm on it, the circuits are much slower and take much more space on FPGA. And sometimes it even consumes more power. 

I believe that as the project goes on, it will get better and better.



| Device:  Artix-7     (xa7a12tcsg325-2I)      Post-Implementation Simulation | ASYNC or SYNC | Method                    | Power(W)                |             |            | Total Time (ns) | Resource     Utilization |        |
| ------------------------------------------------------------ | ------------- | ------------------------- | ----------------------- | ----------- | ---------- | --------------- | ------------------------ | ------ |
|                                                              |               |                           | **Total On-chip Power** | **Dynamic** | **Static** |                 | **LUT**                  | **FF** |
| 32-bit integer sqrt (a) a=10454520                           | Async-Karin   | Newton’s iterative method | 0.062                   | 0.002       | 0.060      | 5500            | 908                      | 586    |
|                                                              | 100MHz Sync   | IP Core, Cordic           | 0.063                   | 0.003       | 0.060      | 188             | 395                      | 246    |
| 32-bit integer divide (x,y) x=43923751, y=573                | Async-Karin   | subtraction and shift     | 0.061                   | 0.001       | 0.060      | 1571            | 592                      | 403    |
|                                                              | 100MHz Sync   | IP Core, Divider, Radix2  | 0.074                   | 0.014       | 0.060      | 438             | 1151                     | 3202   |
| 32-bit Fibonacci (N) N=100                                   | Async-Karin   | Loop                      | 0.062                   | 0.004       | 0.058      | 1881            | 317                      | 324    |
|                                                              | 100MHz Sync   | Loop                      | 0.060                   | 0.002       | 0.058      | 1078            | 45                       | 128    |

# License

Licensed under MIT license. Read LICENSE file for more information.

