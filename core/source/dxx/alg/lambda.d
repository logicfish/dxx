/**
Copyright 2019 Mark Fisher

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
**/
module dxx.alg.lambda;


import std.traits,
	std.algorithm,
	std.typetuple;

version(unittest) {
	import std.stdio,
		std.conv;
	import core.stdc.stdarg;
}

alias Identity(alias Func) = Func;

auto ref Apply(alias Func,arg ...)() { return Func(arg); }

auto ref _Apply(alias Func,Arg=Parameters!Func)(Arg a) { return Func(a); }

//auto ref Apply(alias Func,A)() { return Func(A); }

//auto ref apply(alias Next,alias Func,Arg ...)(Arg a) {
//	//return Apply!(Next,Apply!(Func,a));
//	return Next(Func(a));
//}

auto ref apply(alias Next,alias Func,Arg=Parameters!Func)(Arg a) {
	return Next(Func(a));
}

auto ref applyNext(alias Next,alias Func,Arg=Parameters!Func)(Arg a) {
	Func(a);
	return Next();
}

template lambda(alias Func,Arg...) {
	alias lambda = (Arg a)=>Func(a);
}

unittest {
	writeln("Test apply");
	static int f(int a) { return a + 1; }
	assert(Apply!(f,10)==11);
	static int g() { return 1; }
	assert(Apply!(g)==1);
	static int h(int a,int b) { return a+b; }
	assert(Apply!(h,2,3)==5);
	assert(_Apply!h(2,3)==5);
}

void Assign(alias F,alias T)() { F=T; }

void AssignTo(alias F,T=typeof(F))(T t) { F=t; }

void assignTo(F,T=F)(ref F f,T t) { f=t; }

void AssignTrue(alias F)() { Assign!(F,true); }

void AssignFalse(alias F)() { Assign!(F,false); }

auto ref Append(alias F,alias T)() { return F~T; }

auto ref _Append(alias F,T=typeof(F))(T t) { return F~t; }

auto ref Prepend(alias F,alias T)() { return T~F; }

auto ref _Prepend(alias F,T=typeof(F))(T t) { return t~F; }
