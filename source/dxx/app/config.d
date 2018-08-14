module dxx.app.config;

private import ctini.ctini;

private import std.format;
private import std.array : appender;
private import std.stdio;
private import std.experimental.logger;
private import std.conv;
private import std.traits;
private import std.compiler;
private import std.process : environment;
private import std.file : getcwd,thisExePath;

private import dxx.app;

// Compile-time config
enum DXXConfig = IniConfig!("dxx.ini");

// Runtime config

final class AppConfig {
    static __gshared AppConfig _appconfig;

    //@Autowire
    //ValueInjector!string stringValues;

    //@Autowire
    //ValueInjector!int intValues;

    //@Autowire
    //ValueInjector!float floatValues;

    //@Autowire
    //ValueInjector!bool boolValues;

    static void setRuntimeDefaults(ref string[string] properties) {
        properties[DXXConfig.keys.packageVersion] = packageVersion;
        properties[DXXConfig.keys.packageTimestamp] = packageTimestamp;
        properties[DXXConfig.keys.packageTimestampISO] = packageTimestampISO;
        properties[DXXConfig.keys.compilerName] = Constants.compilerName;
        properties[DXXConfig.keys.compilerVersionMajor] = Constants.compilerVersionMajor.to!string;
        properties[DXXConfig.keys.compilerVersionMinor] = Constants.compilerVersionMinor.to!string;
        properties[DXXConfig.keys.currentDir] = getcwd;
        properties[DXXConfig.keys.appDir] = thisExePath;
    }

    shared static this() {
        sharedLog.info("Config initialising.");
        File f;
        auto configFile = environment.get(DXXConfig.envKeys.configFile,
                DXXConfig.app.configFile);
        try {
            sharedLog.info("Loading default config file.");
            f = inputConfigFile(configFile);
        } catch(Exception e) {
            // Create the default config file.
            sharedLog.info("Creating default config file.");
            auto of = outputConfigFile(DXXConfig.app.configFile);
            of.write(import(DXXConfig.app.configDefaults));
            of.flush;
            of.close;
            f = inputConfigFile(DXXConfig.app.configFile);
        }
        auto properties = readInjectorProperties(&f);

        iterateValuesF!(DXXConfig.vars)( (string fqn,string k,string v) {
            properties[k]=v;
        } );

        version(Windows) {
            static if(__traits(compiles,DXXConfig.windows.vars)) {
                iterateValuesF!(DXXConfig.windows.vars)( (string fqn,string k,string v) {
                    properties[k]=v;
                } );
            }
        }

        version(Win32) {
            static if(__traits(compiles,DXXConfig.win32.vars)) {
                iterateValuesF!(DXXConfig.win32.vars)( (string fqn,string k,string v) {
                    properties[k]=v;
                } );
            }
        }

        version(Win64) {
            static if(__traits(compiles,DXXConfig.win64.vars)) {
                iterateValuesF!(DXXConfig.win64.vars)( (string fqn,string k,string v) {
                    properties[k]=v;
                } );
            }
        }

        version(Posix) {
            static if(__traits(compiles,DXXConfig.posix.vars)) {
                iterateValuesF!(DXXConfig.posix.vars)( (string fqn,string k,string v) {
                    properties[k]=v;
                } );
            }
        }

        version(Linux) {
            static if(__traits(compiles,DXXConfig.linux.vars)) {
                iterateValuesF!(DXXConfig.linux.vars)( (string fqn,string k,string v) {
                    properties[k]=v;
                } );
            }
        }

        version(MacOS) {
            static if(__traits(compiles,DXXConfig.macos.vars)) {
                iterateValuesF!(DXXConfig.macos.vars)( (string fqn,string k,string v) {
                    properties[k]=v;
                } );
            }
        }

        setRuntimeDefaults(properties);

        //iterate
        registerInjectorProperties(properties);

        if(_appconfig is null) {
            _appconfig = new AppConfig;
        }
        inject(_appconfig);
    }
    auto static get(string s) {
        return _appconfig.lookup(s);
    }
    auto lookup(string s) {
        //return stringValues.get(s);
        return "";
    }
}
