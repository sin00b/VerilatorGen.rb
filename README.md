# Verilator module generator for Ruby

This is a quick & dirty script to generate
([Verilator](https://www.veripool.org/projects/verilator/wiki/Intro) extension
for Ruby.

## Requirements
* Ruby
* swig

## Usage

```
$ ls
foo.v  goo.v  koo.v  verilator.extconf.rb
$ ruby veridator.extconf.rb -cc --top-module foo *.v  ### command options are same as those for verilator. generates Makefile, obj_dir/, verilator.i


$ ls
Makefile  foo.v  goo.v  koo.v  obj_dir  verilator.extconf.rb  verilator.i
$ make
$ ls
Makefile  foo.v  goo.v  koo.v  obj_dir  verilator.extconf.rb  verilator.i  *verilator.so*
```
