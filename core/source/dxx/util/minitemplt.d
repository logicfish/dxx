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
module dxx.util.minitemplt;

private import std.array;

private import dxx.util.grammar;

template MiniTemplate(alias Compiler,alias TemplateGrammar) {
    enum _GRAMMAR = "
MiniTemplateGrammar(Template):
    Doc <- Line+ :endOfInput
    Line <- :LDelim ^Template :RDelim / Text
    LDelim <- \"{{\"
    RDelim <- \"}}\"
    Text <- ~((!LDelim) Char )*
    Char <- .
    ";

    mixin(parseGrammar!_GRAMMAR);

    alias GRAMMAR = MiniTemplateGrammar!TemplateGrammar;

    template __dataFile(string s) {
        enum __dataFile = parseDataFile!(GRAMMAR,s);
    }
    template __data(string s) {
        enum __data = parseData!(GRAMMAR,s);
    }

    static string execute(alias Data)() {
        string n = "";
        pragma(msg,"Compile: "~ Data.name);
        switch(Data.name) {
            case "MiniTemplate":
            case "MiniTemplate.Doc":
            case "MiniTemplate.Line":
                static foreach(x;Data.children) n~=execute!x();
                break;
            case "MiniTemplate.Text":
                n ~= Data.matches.join("");
                break;
            default:
                n ~= Compiler!Data;
                break;
        }
        return n;
    }
}

struct ExpandIdentifiers {
    alias _COMPILER = MiniTemplate!(__compile,identifier);
    alias execute = _COMPILER.execute;
    alias compileFile(string fileName) = _COMPILER.__dataFile!fileName; 
    alias compileFile(string txt) = _COMPILER.__data!txt; 

    string[string] values;
    
    static string __compile(alias Data)() {
        string n = "";
        pragma(msg,"Data "~ Data.name);
        switch(Data.name) {
            case "identifier":
            n ~= values[Data.matches[0]];
            break;
            default:
            break;
        }
        return n;
    }
}

unittest {
    ExpandIdentifiers x;
    x.compile();
}
