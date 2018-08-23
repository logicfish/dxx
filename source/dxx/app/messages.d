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
module dxx.app.messages;

private import std.format;
private import std.array : appender;

private import dxx.app.config;

mixin template __Text(string lang = DXXConfig.app.lang) {
    enum _Text = IniConfig!(lang ~ ".ini");
    import ctini.ctini;
    const(string) MsgText(alias K,Args...)(Args args) {
        return MsgParam!(mixin("_Text.text."~K))(args);
    }
}

const(string) MsgParam(alias K,Args...)(Args args) {
    auto writer = appender!string;
    writer.formattedWrite(K, args);
    return writer.data;
}

unittest {
  mixin __Text;
  assert(MsgText!(DXXConfig.messages.MSG_APP_NAME) == "DXX Library");
}
