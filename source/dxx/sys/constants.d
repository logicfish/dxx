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
module dxx.sys.constants;

private import dxx.packageVersion;

private import std.compiler;
private import core.cpuid;

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

    version(Posix) { enum hostOperatingSystem = "Posix"; }
    else version(Windows) { enum hostOperatingSystem = "Windows"; }
    else version(MacOS) { enum hostOperatingSystem = "MacOS"; }
    else { enum hostOperatingSystem = "<unknown-OS>"; }

    version(unittest) { enum unitTest = true; }
    else { enum unitTest = false; }

    debug {
        enum buildType = "Debug";
    } else version(Release) {
        enum buildType = "Release";
    } else {
        enum buildType = "<unknown-buildtype>";
    }
};

struct RTConstants {
    const(string) compilerName = Constants.compilerName;
    const(uint) compilerVersionMajor = Constants.compilerVersionMajor;
    const(uint) compilerVersionMinor = Constants.compilerVersionMinor;

    const(string) compileTimestamp = Constants.compileTimestamp;

    const(string) hostOperatingSystem = Constants.hostOperatingSystem;
    
    const(bool) unitTest = Constants.unitTest;
    const(string) buildType = Constants.buildType;

    const(string) libVersion = packageVersion;
    const(string) libTimestamp = packageTimestamp;
    const(string) libTimestampISO = packageTimestampISO;

    static __gshared RTConstants runtimeConstants;
    
    unittest {
        assert(runtimeConstants.unitTest);
    }
};



