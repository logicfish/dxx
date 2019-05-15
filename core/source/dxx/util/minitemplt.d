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

private import pegged.grammar;

private import std.array;
private import std.typecons;

private import metad.compiler;
private import metad.interp;

enum _GRAMMAR = q{
MiniTemplateGrammar:
Doc <- Line+ :endOfInput
Line <- :LDelim Inner :RDelim / Text
Text <- ~((!LDelim) Char )*
Inner <- ~((!RDelim) Char )*
Char <- .
LDelim <- "{{"
RDelim <- "}}"
};
mixin(grammar(_GRAMMAR));

template MiniTemplate(alias idParser) {
  struct MiniTemplateCompiler(ParseTree T,alias Parser=MiniTemplateCompiler) {
    mixin Compiler!(T,Parser);
    mixin (compilerOverride!("MiniTemplateGrammar.Text","T.matches.join(\"\")"));
    mixin (compilerOverride!("MiniTemplateGrammar.Inner","idParser!T()"));
  }
}

unittest {
  static string v(ParseTree T)() {
    pragma(msg,"** Value:"~ T.name);
    pragma(msg,"** = "~ T.matches.join(""));
    return "<" ~ T.matches.join("") ~ ">";
  }
    enum inputText = q{
      {{MyValue}}.{{MyVal2}}
    };
    enum c= MiniTemplate!(v).MiniTemplateCompiler!(MiniTemplateGrammar(inputText)).compileNode;
    assert(c == "<MyValue>.<MyVal2>");
}

template miniTemplateParser(alias idParser,string txt) {
    enum miniTemplateParser = MiniTemplate!(idParser).MiniTemplateCompiler!(MiniTemplateGrammar(txt)).compileNode();
}

template miniTemplate(alias idParser,alias txt) {
  static string __id(ParseTree T)() {
    return idParser!(T.matches.join(""))();
  }
  auto miniTemplate() {
    enum data = MiniTemplateGrammar(txt);
    return MiniTemplate!(__id).MiniTemplateCompiler!(data).compileNode();
  }
}

unittest {
  static string v(ParseTree T)() {
    pragma(msg,"++ Value:"~ T.name);
    pragma(msg,"++ = "~ T.matches.join(""));
    return "[" ~ T.matches.join("") ~ "]";
  }
  enum inputText = q{
    {{MyValue.a.b.c}}.{{MyVal2.d.e.f}}
  };
  enum c = miniTemplateParser!(v,inputText);
  assert(c == "[MyValue.a.b.c].[MyVal2.d.e.f]");
}

unittest {
  static string v(string k)() {
    pragma(msg,"v = "~ k);
    return "[" ~ k ~ "]";
  }
  enum inputText = q{
    123{{MyValue.a.b.c}}.{{MyVal2.d.e.f}}456
  };
  enum c = miniTemplate!(v,inputText);
  assert(c == "123[MyValue.a.b.c].[MyVal2.d.e.f]456");
}

template MiniInterpreter(T) {
    static auto MiniInterpreter(T idParser,ParseTree t) {
      string delegate(ParseTree)[string] nodes;
      nodes["GRAMMAR.LDelim"] = f=>"";
      nodes["GRAMMAR.RDelim"] = f=>"";
      nodes["GRAMMAR.Text"] = f=>f.matches.join("");
      nodes["GRAMMAR.Inner"] = (f)=>idParser(f.matches.join(""));
      return Interpreter(nodes,t);
    }
}

unittest {
  static string v(ParseTree T) {
    pragma(msg,"** Value:"~ T.name);
    pragma(msg,"** = "~ T.matches.join(""));
    return "<" ~ T.matches.join("") ~ ">";
  }
    enum inputText = q{
      {{MyValue}}.{{MyVal2}}
    };
    auto c = MiniInterpreter(v,MiniTemplateGrammar(inputText));
    assert(c == "<MyValue>.<MyVal2>");
}

template miniInterpreter(alias idParser) {
  static string __id(ParseTree t) {
    return idParser(t.matches.join(""));
  }
  auto miniInterpreter(string txt) {
    auto data = MiniTemplateGrammar(txt);
    //auto compiler = MiniInterpreter!(__id).MiniTemplateInterpreter!(data).interp();
    return MiniInterpreter!(typeof(&__id),data)(&__id);
    //return I.MiniTemplateInterperter!(data).interpNode();
    //return compiler();
  }
}
unittest {
  static string v(ParseTree T) {
    //pragma(msg,"++ Value:"~ T.name);
    //pragma(msg,"++ = "~ T.matches.join(""));
    return "[" ~ T.matches.join("") ~ "]";
  }
  enum inputText = q{
    {{MyValue.a.b.c}}.{{MyVal2.d.e.f}}
  };
  auto c = miniInterperter!(v)(inputText);
  assert(c == "[MyValue.a.b.c].[MyVal2.d.e.f]");
}

unittest {
  static string v(string k) {
    pragma(msg,"v = "~ k);
    return "[" ~ k ~ "]";
  }
  enum inputText = q{
    123{{MyValue.a.b.c}}.{{MyVal2.d.e.f}}456
  };
  enum c = miniTemplate!(v,inputText);
  assert(c == "123[MyValue.a.b.c].[MyVal2.d.e.f]456");
}
