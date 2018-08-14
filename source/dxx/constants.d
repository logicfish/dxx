module dxx.constants;

import std.compiler;
import core.cpuid;

class Constants {
    //enum {
    //    COMPILER_VERSION = std.compiler.name,
    //    PALTFORM = _PLATFORM,
    //    //CPU = core.cpuid.getCpuFeatures.vendorID
    //}
    enum compilerName =  __VENDOR__;
    enum compilerVersionMajor = version_major;
    enum compilerVersionMinor = version_minor;

    version(Windows) { enum platform_os = "Windows"; }
    version(Posix) { enum platform_os = "Posix"; }
    version(MacOS) { enum platform_os = "MacOS"; }
};
