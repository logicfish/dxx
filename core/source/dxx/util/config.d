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
module dxx.util.config;

private import ctini.ctini;

private import std.format;
private import std.array : appender,join;
private import std.stdio;
private import std.experimental.logger;
private import std.conv;
private import std.traits;
private import std.compiler;
private import std.process : environment;
private import std.variant;

private import core.runtime;

private import dxx.packageVersion;
private import dxx.constants;
private import dxx.util.storage;
//private import dxx.util.injector;
private import dxx.util.ini;

// Compile-time config
enum DXXConfig = IniConfig!("dxx.ini");

// Runtime config
final class AppConfig {
    static __gshared AppConfig _appconfig;

    static void setRuntimeDefaults(ref Variant[string] properties) {
        properties[DXXConfig.keys.packageVersion] = packageVersion;
        properties[DXXConfig.keys.packageTimestamp] = packageTimestamp;
        properties[DXXConfig.keys.packageTimestampISO] = packageTimestampISO;
        properties[DXXConfig.keys.compilerName] = Constants.compilerName;
        properties[DXXConfig.keys.compilerVersionMajor] = Constants.compilerVersionMajor.to!string;
        properties[DXXConfig.keys.compilerVersionMinor] = Constants.compilerVersionMinor.to!string;
        properties[DXXConfig.keys.currentDir] = getcwd;
        properties[DXXConfig.keys.compileTimestamp] = Constants.compileTimestamp;
        properties[DXXConfig.keys.appDir] = RTConstants.constants.appDir;
        //properties[DXXConfig.keys.applicationName] =
        properties[DXXConfig.keys.commandLine] =  RTConstants.constants.argString;
    }

    shared static this() {
        Variant[string] properties;
        //sharedLog.info("Config initialising.");
        //MsgLog.info(DXXConfig.messages.MSG_CONFIG_INIT);
        File f;
        auto configFile = environment.get(DXXConfig.envKeys.configFile,
                DXXConfig.app.configFile);
        try {
            //sharedLog.info("Loading default config file.");
            //MsgLog.info(MsgText!(DXXConfig.messages.MSG_CONFIG_DEFAULT)(configFile));
            f = inputConfigFile!(DXXConfig.app)(configFile);
            //properties = readInjectorProperties(&f);
        } catch(Exception e) {
            // Create the default config file.
            //sharedLog.info("Creating default config file.");
            //MsgLog.info(MsgText!(DXXConfig.messages.MSG_CONFIG_INIT_DEFAULT));
            //auto of = outputConfigFile!(DXXConfig.app)(DXXConfig.app.configFile);
            //of.write(import(DXXConfig.app.configDefaults));
            //of.flush;
            //of.close;
            //f = inputConfigFile!(DXXConfig.app)(DXXConfig.app.configFile);
            //properties = readInjectorProperties(&f);
        }

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

        //setRuntimeDefaults(properties);
        //registerInjectorProperties(properties);

        if(_appconfig is null) {
            _appconfig = new AppConfig;
        }
    }
    auto static get(string s) {
        return _appconfig.lookup(s);
    }
    auto lookup(string s) {
        //return stringValues.get(s);
        return "";
    }
}
