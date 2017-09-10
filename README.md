# Verilator module generator for Ruby

This is a quick & dirty script to generate
[Verilator](https://www.veripool.org/projects/verilator/wiki/Intro) extension
for Ruby.

## Requirements
* Ruby
* swig

## Usage

```shell
$ ls
VerilatorGen.rb  test.v
$ ruby VerilatorGen.rb -cc --top-module foo *.v  ### command options are same as those for verilator. generates Makefile, obj_dir/, verilator.i
$ ls
Makefile  VerilatorGen.rb  obj_dir  test.v  verilator.i
$ make
$ ls
Makefile  VerilatorGen.rb  obj_dir  test.v  verilator.i  verilator.so
```
## Writing test bench

Notes:
* you have to add /*verilator public*/ direction to the internal signals in modules;
* only top module ports can be accessed without /*verilator public*/ direction.

```
$ cat test.v
module foo(clk,o);
   input  wire        clk;
   output wire [31:0] o;

   reg [31:0] 	   bar/* verilator public */;
   reg [31:0]      goo_o;

   goo goo1(clk, goo_o);

initial begin
   bar = 0;
end

always @(posedge clk) begin
   bar = bar + 1;
   o = bar;
   end
endmodule // foo

module goo(clk,o);
   input  wire        clk;
   output wire [31:0] o/* verilator public */; // this direction is needed!

   reg [31:0] 	    bar/* verilator public */;

initial begin
   bar = 1;
   end

always @(posedge clk) begin
   bar = bar * 2;
   o = bar;
   end
endmodule // goo

$ cat test.rb
require "./verilator"

top = Verilator::Vfoo.new
(0..10).each do |i|
  clk = i % 2
  top.clk = clk
  top.eval
  puts "clk: #{clk} / top.foo.o: #{top.foo.o} / top.foo.goo1.bar #{top.foo.goo1.bar} / top.foo.goo1.o #{top.foo.goo1.o}"
end

$ ruby test.rb
clk: 0 / top.foo.o: 0 / top.foo.goo1.bar 1 / top.foo.goo1.o 0
clk: 1 / top.foo.o: 1 / top.foo.goo1.bar 2 / top.foo.goo1.o 2
clk: 0 / top.foo.o: 1 / top.foo.goo1.bar 2 / top.foo.goo1.o 2
clk: 1 / top.foo.o: 2 / top.foo.goo1.bar 4 / top.foo.goo1.o 4
clk: 0 / top.foo.o: 2 / top.foo.goo1.bar 4 / top.foo.goo1.o 4
clk: 1 / top.foo.o: 3 / top.foo.goo1.bar 8 / top.foo.goo1.o 8
clk: 0 / top.foo.o: 3 / top.foo.goo1.bar 8 / top.foo.goo1.o 8
clk: 1 / top.foo.o: 4 / top.foo.goo1.bar 16 / top.foo.goo1.o 16
clk: 0 / top.foo.o: 4 / top.foo.goo1.bar 16 / top.foo.goo1.o 16
clk: 1 / top.foo.o: 5 / top.foo.goo1.bar 32 / top.foo.goo1.o 32
clk: 0 / top.foo.o: 5 / top.foo.goo1.bar 32 / top.foo.goo1.o 32
```