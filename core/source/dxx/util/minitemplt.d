/**
Copyright: 2018 Mark Fisher

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
module dxx.util.minitemplt;

private import pegged.grammar;

private import std.array;
private import std.typecons;
private import std.string;

private import metad.compiler;
private import metad.interp;

enum _GRAMMAR = q{
MiniTemplateGrammar:
  Doc <- Line+ :endOfInput
  Line <- (Var / Text)
  Var <- LDelim ^Inner RDelim
  LDelim < "{{"
  RDelim < "}}"
  Text <- ~((!LDelim) Char )*
  Char <- .
  Inner <- ~((!RDelim) Char )*
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
    //pragma(msg,"** Value:"~ T.name);
    //pragma(msg,"** = "~ T.matches.join);
    return "<" ~ T.matches.join ~ ">";
  }
    enum inputText = q{
      {{MyValue}}.{{MyVal2}}
    };
    enum c= MiniTemplate!(v).MiniTemplateCompiler!(MiniTemplateGrammar(inputText)).compileNode.strip;
    static assert(c == "<MyValue>.<MyVal2>",c);
}

template miniTemplateParser(alias idParser,string txt) {
    enum miniTemplateParser = MiniTemplate!(idParser).MiniTemplateCompiler!(MiniTemplateGrammar(txt)).compileNode();
}

template miniTemplate(alias idParser,alias txt) {
  static string __id(ParseTree T)() {
    return idParser!(T.matches.join)();
  }
  auto miniTemplate() {
    enum data = MiniTemplateGrammar(txt);
    return MiniTemplate!(__id).MiniTemplateCompiler!(data).compileNode();
  }
}

unittest {
  static string v(ParseTree T)() {
    //pragma(msg,"++ Value:"~ T.name);
    //pragma(msg,"++ = "~ T.matches.join);
    return "[" ~ T.matches.join ~ "]";
  }
  enum inputText = q{
    {{MyValue.a.b.c}}.{{MyVal2.d.e.f}}
  };
  enum c = miniTemplateParser!(v,inputText).strip;
  static assert(c == "[MyValue.a.b.c].[MyVal2.d.e.f]");
}

unittest {
  static string v(string k)() {
  //  pragma(msg,"v = "~ k);
    return "[" ~ k ~ "]";
  }
  enum inputText = q{
    123{{MyValue.a.b.c}}.{{MyVal2.d.e.f}}456
  };
  enum c = miniTemplate!(v,inputText).strip;
  static assert(c == "123[MyValue.a.b.c].[MyVal2.d.e.f]456");
}

template MiniInterpreter(T) {
    static auto MiniInterpreter(T idParser,ParseTree t) {
      import std.variant;
      import std.algorithm;
      Variant delegate(ParseTree)[string] nodes;
      nodes["MiniTemplateGrammar.LDelim"] = f=>Variant("");
      nodes["MiniTemplateGrammar.RDelim"] = f=>Variant("");
      nodes["MiniTemplateGrammar.Text"] = f=>Variant(f.matches.join);
      //nodes["GRAMMAR.Inner"] = (f)=>idParser(f.matches.join(""));
      nodes["MiniTemplateGrammar.Inner"] = (f)=>Variant(idParser(f.matches.join));
      //return Interpreter!(string,typeof(nodes))(nodes,t).join;
      return Interpreter(nodes,t).map!(x=>x.get!string).join;
    }
}

unittest {
    static string v(string f) {
      return "<" ~ f ~ ">";
    }
    enum inputText = q{
      {{MyValue}}.{{MyVal2}}
    };
    auto d = MiniTemplateGrammar(inputText);
    string c = MiniInterpreter(&v,d).strip;
    assert("<MyValue>.<MyVal2>" == c);
}
/*unittest {
    static string v(string f) {
      return "<" ~ f ~ ">";
    }
    enum inputText = q{
      {MyValue}.{MyVal2}
    };
    auto d = MiniTemplateGrammar(inputText);
    string c = MiniInterpreter(&v,d).strip;
    assert("<MyValue>.<MyVal2>" == c);
}*/

template miniInterpreter(alias idParser) {
  //static string __id(ParseTree t) {
  //  return idParser(t.matches.join(""));
  //}
  static string __id(string t) {
    return idParser(t);
  }
  auto miniInterpreter(string txt) {
    auto data = MiniTemplateGrammar(txt);
    //auto compiler = MiniInterpreter!(__id).MiniTemplateInterpreter!(data).interp();
    //return MiniInterpreter!(typeof(&__id))(&__id,data);
    return MiniInterpreter!(typeof(&__id))(&__id,data);
    //return I.MiniTemplateInterperter!(data).interpNode();
    //return compiler();
  }
}
unittest {
  /*static string v(ParseTree T) {
    //pragma(msg,"++ Value:"~ T.name);
    //pragma(msg,"++ = "~ T.matches.join(""));
    return "[" ~ T.matches.join("") ~ "]";
  }*/
  static string v(string x) {
    return "[" ~ x ~ "]";
  }

  enum inputText = q{
    {{MyValue.a.b.c}}.{{MyVal2.d.e.f}}
  };
  auto c = miniInterpreter!(v)(inputText).strip;
  assert(c == "[MyValue.a.b.c].[MyVal2.d.e.f]");
}

/*unittest {

  static string v(string x) {
    return "[" ~ x ~ "]";
  }

  enum inputText = q{
    {MyValue.a.b.c}.{MyVal2.d.e.f}
  };
  auto c = miniInterpreter!(v,"{","}")(inputText).strip;
  assert(c == "[MyValue.a.b.c].[MyVal2.d.e.f]");
}*/

unittest {
  static string v(string k) {
    //pragma(msg,"v = "~ k);
    return "[" ~ k ~ "]";
  }
  enum inputText = q{
    123{{MyValue.a.b.c}}.{{MyVal2.d.e.f}}456
  };
  auto c = miniInterpreter!(v)(inputText);
  assert(c == "123[MyValue.a.b.c].[MyVal2.d.e.f]456");
}
/*
unittest {
  static string v(string k) {
    pragma(msg,"v = "~ k);
    return "[" ~ k ~ "]";
  }
  enum inputText = q{
    123{MyValue.a.b.c}.{MyVal2.d.e.f}456
  };
  auto c = miniInterpreter!(v,"{","}")(inputText);
  assert(c == "123[MyValue.a.b.c].[MyVal2.d.e.f]456");
}
*/
