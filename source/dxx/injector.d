module dxx.injector;

private import std.stdio;

static string[string] readInjectorProperties(File* f) {
    string[string] res;
    return res;
}

static void registerInjectorProperties(string[string] properties) {
}

static T inject(T)(T t) {
//    DefaultInjector._DEFAULT_CONTAINER.autowire(t);
//    Annotations.process(t);
    return t;
}
