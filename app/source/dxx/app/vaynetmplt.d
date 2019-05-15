/**
Copyright 2018 Mark Fisher

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
module dxx.app.vaynetmplt;

private import std.conv;
private import std.functional;
private import std.stdio;
private import std.array;
static import std.file;

private import vayne.compiler;
private import vayne.lib;
private import vayne.serializer;
private import vayne.vm;

private import dxx.util.log;

void renderVayneToFile(string inFile,Vars...)(string outputFile) {
		auto f = File(outputFile,"w");
		renderVayne!(typeof(f),inFile,Vars)(f,"en");
}
void renderVayneAppender(string inFile,Vars...)(Appender!string output) {
		renderVayne!(typeof(output),inFile,Vars)(output,"en");
}

void renderVayne(OutputStreamT, string FileName, Vars...)(OutputStreamT o__, string language__) {
	alias VayneVM = VM!();
	VayneVM vm;

	auto compiled = unserialize(cast(ubyte[])std.file.read("resources/" ~ FileName ~ ".vayne"));

	Value[] constants;
	constants.reserve(compiled.constants.length);

	foreach(i, c; compiled.constants) {
		final switch (c.type) with (ConstantType) {
		case Null:
			constants ~= Value(null);
			break;
		case Boolean:
			constants ~= Value(c.value.to!bool);
			break;
		case Integer:
			constants ~= Value(c.value.to!long);
			break;
		case Float:
			constants ~= Value(c.value.to!double);
			break;
		case String:
			constants ~= Value(c.value.to!string);
			break;
		}
	}

	vm.load(compiled.registerCount, constants, compiled.instrs, compiled.locs, compiled.sources);

	VayneVM.Globals globals;

	bindLibDefault(globals);

	mixin(bindVars!(0, globals, Vars));

	auto translate(Value[] args) {
		assert(language__ == "en");
		auto tag = args[0].get!string;
		switch (tag) {
			case "footer":	return "This is the footer translation";
			case "empty":	return "Move along, nothing to see here";
			default: return tag;
		}
	}

	static errorHandler(VayneVM.Error error) {
		MsgLog.info("%s(%s) template error: %s", error.source, error.line, error.msg);
	}

	globals["__translate"] = Value(&translate);
	vm.bindGlobals(globals);

	vm.errorHandler = toDelegate(&errorHandler);
	vm.execute(o__);
}
