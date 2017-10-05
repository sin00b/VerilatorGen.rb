require "mkmf"

OBJ_DIR  = "./obj_dir"
WRAP_CPP = "verilator.cpp"
OPT_FLAG = " -O3 "

ORG_PATH = Dir.pwd
VERILATOR_ROOT = `verilator -V | grep VERILATOR_ROOT | grep verilator`.gsub(/^\s+VERILATOR_ROOT\s+=\s+/, '').chomp


cmd = "verilator #{ARGV.join(" ")}"
system cmd
vmkfile = ""
Dir.glob(OBJ_DIR + "/*.mk").each do |mk|
  vmkfile = "#{File.basename(mk)}" if mk !~ /_classes\.mk$/
end

vmkfile = vmkfile.to_s
top_mod = vmkfile.gsub(/^V/, "").gsub(/\.mk/, "")

Dir.chdir(OBJ_DIR)
system("CPPFLAGS=\"-fPIC #{OPT_FLAG}\" make -f #{vmkfile}")
Dir.chdir(ORG_PATH)


vincs_basename =""
vincs_relative =""

Dir.glob(OBJ_DIR + "/*.h").each do |h|
  vincs_basename += "#include \"#{File.basename(h)}\"\n"
  vincs_relative += "%include \"#{h}\"\n"
end

swig_src = <<SWIG_RECIPE_END
%module verilator

%include stdint.i
%{
#define SWIG_FILE_WITH_INIT 1
#include "verilatedos.h"
#include "verilated.h"
#{vincs_basename}
#include <ruby.h>
%}

%ignore _Vbit;
%ignore _VERILATEDOS_H_;
%ignore _VERILATED_H_;
%ignore Verilated::getCommandArgs();

%define __restrict %enddef

%include "verilatedos.h"
%include "verilated.h"
#{vincs_relative}
%include ruby.h
SWIG_RECIPE_END

fp = File.open("verilator.i", "w")
fp.print swig_src
fp.close

$libs += " -lstdc++ "

$objs = ["#{VERILATOR_ROOT}/include/verilated.cpp", "#{OBJ_DIR}/verilator.cpp", "#{OBJ_DIR}/V#{top_mod}__ALL.a"]

incdir_opt = " -I#{VERILATOR_ROOT}/include -I#{VERILATOR_ROOT}/include/vltstd" + " -I#{OBJ_DIR}"

flags   = " -fPIC #{OPT_FLAG} " +" " + incdir_opt + " -I#{$hdrdir} -I#{$arch_hdrdir}"
$CPPFLAGS += flags
$CFLAGS   += flags
$LDFLAGS  += flags

swig_cmd = "swig -ruby -c++ #{incdir_opt} -I#{$hdrdir} -o #{OBJ_DIR}/#{WRAP_CPP} -w509 -w451 verilator.i"

puts swig_cmd
system swig_cmd

create_makefile("verilator")
