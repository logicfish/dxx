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
module dxx.example.plugin.advplugin;

private import ctini.ctini;

private import dxx.util;
private import dxx.app.plugin;

enum CFG = DXXConfig ~ IniConfig!"plugin.ini";

mixin __Text!(CFG.plugin.lang);


class AdvExamplePlugin : PluginDefault,PluginActivator {
    override void init() {
        super.init;
        MsgLog.info("init");
        setDescr(PluginDescriptor("advanced-example-plugin","v0.1.0","Advanced Example"));
        activator(this);
    }
    override void activate(PluginContext* ctx) {
        MsgLog.info("activate");
        MsgLog.info(descr.id);
    }

    override void deactivate(PluginContext* ctx) {
        MsgLog.info("deactivate");
        MsgLog.info(descr.id);
    }
    //void activate(PluginContext* ctx) {
    //    debug(Pugin) {
    //        MsgLog.info("activate");
    //        MsgLog.info(descr.id);
    //    }
    //}
    //
    //void deactivate(PluginContext* ctx) {
    //    debug(Pugin) {
    //        MsgLog.info("deactivate");
    //        MsgLog.info(descr.id);
    //    }
    //}
}
