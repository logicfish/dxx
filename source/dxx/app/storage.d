module dxx.app.storage;

private import dxx.app;

private import standardpaths;
private import std.stdio;
private import std.path;
private import std.file;

mixin __Text;

auto outputConfigFile(string fn)
{
    string configDir = writablePath(StandardPath.config, buildPath(DXXConfig.app.organizationName, DXXConfig.app.applicationName), FolderFlag.create);
    if (!configDir.length) {
        enum msg = DXXConfig.messages.MSG_CONFIG_DIR;
        throw new Exception(MsgText!msg());
    }
    string configFile = buildPath(configDir, fn);

    return File(configFile, "w"); 
}

auto inputConfigFile(string fn)
{
    string[] configDirs = standardPaths(StandardPath.config, buildPath(DXXConfig.app.organizationName, DXXConfig.app.applicationName));

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
    auto confOut = outputConfigFile("tests.conf");
    confOut.write("[tests]");
    auto confIn = inputConfigFile("tests.conf");
    
}
