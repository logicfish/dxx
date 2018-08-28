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
module dxx.util.script;

//private import utils.misc : fileToArray;
private import qscript.qscript;

private import std.datetime;
private import std.stdio;

private import dxx.util.config;
private import dxx.util.messages;
private import dxx.util.log;

mixin __Text;

class Script : QScript {
    string scriptName;
    
protected:
	override bool onRuntimeError(RuntimeError error){
		//std.stdio.writeln ("# Runtime Error #");
		//std.stdio.writeln ("# Function: ", error.functionName, " Instruction: ",error.instructionIndex);
		//std.stdio.writeln ("# ", error.error);
		//std.stdio.writeln ("Enter n to return false, or just enter to return true");
		//string input = std.stdio.readln;
		//if (input == "n\n"){
		//	return false;
		//}else{
		//	return true;
		//}
        MsgLog.error(MsgText!(DXXConfig.messages.MSG_ERR_SCRIPT_RUNTIME)(scriptName,error.functionName,error.instructionIndex));
        return true;
	}

	override bool onUndefinedFunctionCall(string fName){
		//std.stdio.writeln ("# undefined Function Called #");
		//std.stdio.writeln ("# Function: ", fName);
		//std.stdio.writeln ("Enter n to return false, or just enter to return true");
		//string input = std.stdio.readln;
		//if (input == "n\n"){
		//	return false;
		//}else{
		//	return true;
		//}
        MsgLog.error(MsgText!(DXXConfig.messages.MSG_ERR_SCRIPT_UNDEFINED_FUNCTION)(scriptName,fName));
        return true;
	}
private:
	/// writeln function
	QData writeln(QData[] args){
		std.stdio.writeln (args[0].strVal);
		return QData(0);
	}
	/// write function
	QData write(QData[] args){
		std.stdio.write (args[0].strVal);
		return QData(0);
	}
	/// write int
	QData writeInt(QData[] args){
		std.stdio.write(args[0].intVal);
		return QData(0);
	}
	/// write double
	QData writeDbl(QData[] args){
		std.stdio.write(args[0].doubleVal);
		return QData(0);
	}
	/// readln function
	QData readln(QData[] args){
		string s = std.stdio.readln;
		s.length--;
		return QData(s);
	}
public:
	/// constructor
	this (string name){
        this.scriptName = name;
		this.addFunction(Function("writeln", DataType("void"), [DataType("string")]), &writeln);
		this.addFunction(Function("write", DataType("void"), [DataType("string")]), &write);
		this.addFunction(Function("writeInt", DataType("void"), [DataType("int")]), &writeInt);
		this.addFunction(Function("writeDbl", DataType("void"), [DataType("double")]), &writeDbl);
		this.addFunction(Function("readln", DataType("string"), []), &readln);
	}
};

