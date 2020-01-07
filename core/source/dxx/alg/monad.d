/**
Copyright: 2019 Mark Fisher

License:
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
module dxx.alg.monad;

private import std.traits : isNumeric, isBoolean;

class Monad(T) {
	ref T t;
	private this(ref T _t) { this.t = _t; }
	public auto lift(alias U)() {
		return partial!(U,t);
	}
	static Monad!U bind(U)(ref U u) {
		return new Monad!U(u);
	}
}

class Maybe(T) :Monad!T {
	static class Empty : Maybe!T {
		this() { super(null); }
		override R lift(alias V,R : typeof(()=>ReturnType!V))() {
			static if(is(ReturnType!V==void)) return ()=>{};
      else if(isBoolean!(ReturnType!V)) return ()=>false;
      else if(isNumeric!(ReturnType!V)) return ()=>0;
      else return ()=>null;
		}
		static __gshared Empty _empty;
		shared static this () { _empty = new Empty; }
	};
	static Maybe!U empty(U)() { return (Maybe!U).Empty._empty; }
	static auto bind(U)(ref U _t) { return new Maybe!U(_t); }
	private this(ref T _t) { super(_t); }
};

class Each(T) : Monad!T {
	public auto lift(alias U,V...)() {
		return (V v){t.each!((a){U(a,v);});};
	}
};
