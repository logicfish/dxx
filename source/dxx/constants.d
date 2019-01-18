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
module dxx.constants;

private import std.compiler;
private import std.file;
private import std.path;
private import std.string : split;

private import core.runtime;
private import core.cpuid;
private import std.array : appender,join;

private import semver;

private import dxx.packageVersion;

/**
 * Constants that represt the platform configuration.
 * The class Constants constains enums or aliases,
 * whereas RTConstants contains static strings.
 **/
class Constants {
    //enum {
    //    COMPILER_VERSION = std.compiler.name,
    //    PALTFORM = _PLATFORM,
    //    //CPU = core.cpuid.getCpuFeatures.vendorID
    //}
    enum compilerName =  __VENDOR__;
    enum compilerVersionMajor = version_major;
    enum compilerVersionMinor = version_minor;

    enum compileTimestamp = __TIMESTAMP__;

    enum libVersion = packageVersion;
    enum libVersionRange = "~>"~(packageVersion[1..$].split("-")[0]);
    enum libTimestamp = packageTimestamp;
    enum libTimestampISO = packageTimestampISO;

    //enum cpuID = core.cpuid.getCpuFeatures.vendorID;
    alias cpuCores = core.cpuid.coresPerCPU;
    alias cpuThreads = core.cpuid.threadsPerCPU;
    //alias cpuID = core.cpuid.getCpuFeatures.vendorID;

    version (OSX) { enum hostOperatingSystem = "OSX"; }
    else version(MacOS) { enum hostOperatingSystem = "MacOS"; }
    else version (linux) { enum hostOperatingSystem = "linux"; }
    else version(Windows) { enum hostOperatingSystem = "Windows"; }
    else version (FreeBSD) { enum hostOperatingSystem = "FreeBSD"; }
    else version (NetBSD) { enum hostOperatingSystem = "NetBSD"; }
    else version (DragonFlyBSD) { enum hostOperatingSystem = "DragonFlyBSD"; }
    else version (Solaris) { enum hostOperatingSystem = "Solaris"; }
    else version(Posix) { enum hostOperatingSystem = "Posix"; }
    else { enum hostOperatingSystem = "<unknown-OS>"; }

    version(Windows) {
        enum Windows = true;
        enum Posix = false;
    } else version(Posix) {
        enum Windows = false;
        enum Posix = true;
    } else {
        enum Windows = false;
        enum Posix = false;
    }

    version(unittest) { enum unitTest = true; }
    else { enum unitTest = false; }

    debug {
        enum buildType = "Debug";
    } else version(Release) {
        enum buildType = "Release";
    } else {
        enum buildType = "<unknown-buildtype>";
    }

    version(DXX_Module) {
        enum dxxModule = true;
    } else {
        enum dxxModule = false;
    }

    //template libSemVer() {
    //    auto libSemVer = SemVer(packageVersion);
    //}
};

alias runtimeConstants = RTConstants.runtimeConstants;

struct RTConstants {
    const(string) libVersion = Constants.libVersion;
    const(string) libTimestamp = Constants.libTimestamp;
    const(string) libTimestampISO = Constants.libTimestampISO;
    const(string) libVersionRange = Constants.libVersionRange;

    const(string) compilerName = Constants.compilerName;
    const(uint) compilerVersionMajor = Constants.compilerVersionMajor;
    const(uint) compilerVersionMinor = Constants.compilerVersionMinor;

    const(string) compileTimestamp = Constants.compileTimestamp;

    const(string) hostOperatingSystem = Constants.hostOperatingSystem;

    const(bool) unitTest = Constants.unitTest;
    const(string) buildType = Constants.buildType;

    const(bool) dxxModule = Constants.dxxModule;

    const(string) appFileName;
    const(string) appDir;
    const(string) curDir;
    const(string) appBaseName;
    const(string) argString;
    const(string)[] args;

    shared static this() {
        runtimeConstants.appFileName = thisExePath;
        runtimeConstants.appDir = dirName(runtimeConstants.appFileName);
        runtimeConstants.curDir = getcwd;
        runtimeConstants.argString = Runtime.args.join(" ");
        runtimeConstants.args = Runtime.args.dup;

        version(Windows) {
            version(DXX_Module) {
                runtimeConstants.appBaseName = baseName(runtimeConstants.appFileName,".dll");
            } else {
                runtimeConstants.appBaseName = baseName(runtimeConstants.appFileName,".exe");
            }
        } else {
            runtimeConstants.appBaseName = baseName(runtimeConstants.appFileName);
        }
    }

    // the following variables may be filled in by the application...

    /* string userAppVersion; // user-defined app version string.
    string appName; // user-defined app name.
    string orgName; // user-defined org name.

    shared void registerAppVersion(vers)() {
        userAppVersion = vers;
    }

    shared void registerAppVars(T)() {
        orgName = T.organizationName;
        appName = T.applicationName;
    } */

    static __gshared shared(RTConstants) runtimeConstants;

    alias constants = runtimeConstants;

    unittest {
        assert(runtimeConstants.unitTest);
        debug {
            assert(runtimeConstants.buildType == "Debug");
        } else version(Release) {
            assert(runtimeConstants.buildType == "Release");
        } else {
            assert(runtimeConstants.buildType == "<unknown-buildtype>");
        }
        version(DXX_Module) {
            assert(runtimeConstants.dxxModule);
        } else {
            assert(runtimeConstants.dxxModule == false);
        }
    }

    const shared inout ref
    auto libVersions() {
        auto r = SemVerRange(libVersionRange);
        assert(r.isValid);
        return r;
    }
    const shared inout ref
    auto semVer() {
        return SemVer(libVersion);
    }
    const shared inout
    bool checkVersion(SemVer v) {
        assert(v.isValid);
        return v.satisfies(libVersions);
    }
};
