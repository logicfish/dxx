module dxx.app.messages;

private import std.format;
private import std.array : appender;

private import dxx.app.config;

mixin template __Text(string lang = DXXConfig.app.lang) {
    enum _Text = IniConfig!(lang ~ ".ini");
    import ctini.ctini;
    string MsgText(alias K,Args...)(Args args) {
        return MsgParam!(mixin("_Text.text."~K))(args);
    }
}

string MsgParam(alias K,Args...)(Args args) {
    auto writer = appender!string;
    writer.formattedWrite(K, args);
    return writer.data;
}

