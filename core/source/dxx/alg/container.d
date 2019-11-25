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
module dxx.alg.container;

import dxx.alg.lambda;

import std.traits,
	std.algorithm,
	std.typetuple;

version(unittest) {
	import std.stdio,
		std.conv;
	import core.stdc.stdarg;
}
template Map(alias Func,args...) {
	static if (args.length > 1)
		alias Map = TypeTuple!(Apply!(Func,args[0]),Map!(Func,args[1..$]));
	else
		alias Map = Apply!(Func,args[0]);
}

unittest {
	static void test(int x,int y,int z) {
		assert(x==4 && y==5 && z==6);
	}
	static int add2(int a) { return a+2; }
	int a=2,b=3,c=4;
	test(Map!(add2,a,b,c));
	test(Map!(add2,2,3,4));
	alias x = Map!(add2,2,3,4);
	test(x);
}
unittest {
	static int square(int arg)
	{
		return arg * arg;
	}

	static int refSquare(ref int arg)
	{
		arg *= arg;
		return arg;
	}

	static ref int refRetSquare(ref int arg)
	{
		arg *= arg;
		return arg;
	}

	static void test(int a, int b)
	{
		assert(a == 4);
		assert(b == 16);
	}

	static void testRef(ref int a, ref int b)
	{
		assert(a++ == 16);
		assert(b++ == 256);
	}

	static int a = 2;
	static int b = 4;

	test(Map!(square, a, b));

	test(Map!(refSquare, a, b));
	assert(a == 4);
	assert(b == 16);

	testRef(Map!(refRetSquare, a, b));
	assert(a == 17);
	assert(b == 257);
}

//template Reduce(alias Func,alias Param,args...) {
 //static if (args.length > 1)
 //	alias Reduce = Apply!(Func,args[0],Reduce!(Func,args[1..$]));
 //else
 //	alias Reduce = Apply!(Func,args[0],Param);
//}
//
template removeElement(T,alias V) {
  auto ref removeElement(ref T t) { return t.remove(a => a is V); }
}
