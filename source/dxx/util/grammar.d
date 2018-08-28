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
module dxx.util.grammar;

public import pegged.grammar;

private import dxx.util;

template parseGrammar(string g) {
    enum parseGrammar = grammar(g);
}
template parseGrammarFile(string fname) {
    enum parseGrammarFile = parseGrammar!(import(fname));
}

template parseData(alias Grammar,string data) {
    enum parseData = Grammar(data);
}
template parseData(alias Grammar) {
    auto parseData(string data) {
        return Grammar(data);
    }
}
//template parseData(string data,string g,alias Grammar) {
    //auto g = parseGrammar!g;
//    enum parseData = Grammar(data);
//}
template parseDataFile(alias Grammar,string grammarFile,string dataFile) {
    mixin(parseGrammarFile!grammarFile);
    enum parseDataFile = parseDataFile!(Grammar,dataFile);
}
template parseDataFile(alias Grammar,string dataFile) {
    enum parseDataFile = Grammar(import(dataFile));
}
template outputData(Sink,alias data) {
    auto outputData(Sink sink) {
        return sink ~= data;
    }
}

template iterateParseTree(alias Node,alias Fnc) {
    string iterateParseTree() {
        appender:string s;
        static foreach(n;Node.children) {
            s ~= iterateParseTree!n;
        }
        return Fnc!(Node.name,Node,s);
    }
}

string renderData(Data)() {
    // string buffer
    outputData!Data(sb);
    return sb.data;
}

template GrammarParser(string g,string name) {
    mixin(parseGrammar!g);
    auto GrammarParser(string d) {
        mixin(name)(d);
    }
}

unittest {

    import std.stdio;
    import std.conv;
    import std.array;
    import std.algorithm;

    enum g=q{
MyGrammar:
    test < "test" {myaction} test2
    test2 < "test2" identifier
    };
    enum d=`test test2 testId`;

    class MyGrammar {
        static bool _assert = false;
        static string[] names;

        mixin(parseGrammar!g);

        static PT myaction(PT)(PT p) {
            writeln(text("_action ",p));
            _assert = true;
            names ~= p.name;
            return p;
        }
        this() {
            auto a = parseData!(MyGrammar)(d);
            writeln("Grammar test " ~ a.toString);
            assert(_assert);
        }
    }
    auto a = new MyGrammar;

    class MyGrammar2 {
    enum g=q{
MyGrammar2:
    test < "test" {myaction} test2
    test2 <- "test2" identifier
    };
    enum d=`test test2 testId`;
        mixin(parseGrammar!g);

        static PT myaction(PT)(PT p) {
            return p;
        }
        enum data = parseData!(MyGrammar2,d);
        enum _dataString = dataString(data);

        static string dataString(ParseTree Data) {
            string n = "";
            switch(Data.name) {
                case "MyGrammar2":
                    n = "enum __a = \"";
                    n ~= "_MY:";
                    n ~= dataString(Data.children[0]);
                    n ~= "\";";
                    break;
                case "MyGrammar2.test":
                case "MyGrammar2.test2":
                    n = nodeToString(Data);
                    n ~= Data.children.map!(dataString).join(", ").text;
                default:
                    break;
            }
            return n;
        }
        static string nodeToString(N)(N n) {
            return "\" ~ impl_" ~ n.name ~ "!(\""~ n.name ~ "\") ~ \"";
        }

    }

    auto b = new MyGrammar2;
    class impl_MyGrammar2 {
        static auto test(string n)() {
            return "TEST";
        }
        static auto test2(string n)() {
            return "TEST2";
        }
        mixin(MyGrammar2._dataString);
    }
    writeln("Grammar2 test " ~ impl_MyGrammar2.__a);

}

unittest {
    import std.array;
    import std.string;
    import std.stdio;
    import std.algorithm;
    import std.regex;

    enum GRAMMAR = q{
MYGRAMMAR(Template):
    MyDoc <- MyLine+ :endOfInput
    MyLine <- :LDelim ^Template :RDelim / Text
    LDelim <- "{{"
    RDelim <- "}}"
    Text <- ~((!LDelim) Char )*
    Char <- .
    };
    mixin(parseGrammar!GRAMMAR);

    struct range {
        enum varOne = "varOne";
        static string opCall(string i)() {
            return i;
        }
    }

    template compile(string n)
    {
        enum compile = "range.opCall!(\"" ~ n ~ "\")()";
    }

    static string dataString(alias Data)() {
        string n = "";
        pragma(msg,"Data "~ Data.toString);
        switch(Data.name) {
            case "MYGRAMMAR":
            case "MYGRAMMAR.MyDoc":
            case "MYGRAMMAR.MyLine":
                static foreach(x;Data.children) n~=dataString!x();
                break;
            case "MYGRAMMAR.Text":
                n ~= Data.matches.join("");
                break;
            case "identifier":
                n ~= compile!(Data.matches.join(""));
                break;
            default:
                break;
        }
        return n;
    }
    enum d = "enum fred = {{varOne}};";
    enum data = parseData!(MYGRAMMAR!identifier,d);
    pragma(msg,data);
    enum _dataString = dataString!(data);
    pragma(msg,_dataString);
    writeln("Grammar Test: " ~ _dataString);
    mixin(_dataString);
    static assert(__traits(compiles,"writeln(fred);"));
    writeln("" ~ fred);
    static assert("varOne" == fred);
}
