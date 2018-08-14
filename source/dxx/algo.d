module dxx.algo;


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

template lambda(alias Func) {
	alias lambda = ()=>Func;
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

template Reduce(alias Func,alias Param,args...) {
	static if (args.length > 1)
		alias Reduce = Apply!(Func,args[0],Reduce!(Func,args[1..$]));
	else
		alias Reduce = Apply!(Func,args[0],Param);
}

