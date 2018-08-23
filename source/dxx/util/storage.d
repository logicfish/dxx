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
module dxx.util.storage;

private import dxx.app;

private import standardpaths;
private import std.stdio;
private import std.path;
private import std.file;

mixin __Text;

auto outputConfigFile(alias app)(string fn)
{
    string configDir = writablePath(StandardPath.config, buildPath(app.organizationName, app.applicationName), FolderFlag.create);
    if (!configDir.length) {
        enum msg = DXXConfig.messages.MSG_CONFIG_DIR;
        throw new Exception(MsgText!msg());
    }
    string configFile = buildPath(configDir, fn);

    return File(configFile, "w"); 
}

auto inputConfigFile(alias app)(string fn)
{
    string[] configDirs = standardPaths(StandardPath.config, buildPath(app.organizationName, app.applicationName));

    foreach(configDir; configDirs) {
        string configFile = buildPath(configDir, fn);
        if (configFile.exists) {
            return File(configFile, "r");
        }
    }
    enum msg = DXXConfig.messages.MSG_CONFIG_NOT_FOUND;
    throw new Exception(MsgText!msg(fn));
}

unittest {
    auto confOut = outputConfigFile!(DXXConfig.app)("tests.conf");
    confOut.write("[tests]");
    auto confIn = inputConfigFile!(DXXConfig.app)("tests.conf");
    
}
