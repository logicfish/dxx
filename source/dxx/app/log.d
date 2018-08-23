module dxx.app.log;

private import std.experimental.logger;

private import dxx.util;

class MsgLog {

    //static void trace(alias m,Args...)(Args a) {
    //    trace(MsgText!m)(a);
    //}

    static void trace(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.trace(m);
    }

    //static void log(alias m,Args...)(Args a) {
    //    log(MsgText!m)(a);
    //}

    static void log(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.log(m);
    }

    //static void warn(alias m,Args...)(Args a) {
    //    warn(MsgText!m)(a);
    //}

    static void warn(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.warn(m);
    }

    //static void error(alias m,Args...)(Args a) {
    //    error(MsgText!m)(a);
    //}

    static void error(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.error(m);
    }

    //static void info(alias m,Args...)(Args a) {
    //    info(MsgText!m)(a);
    //}

    static void info(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.info(m);
    }
    //static void fatal(alias m,Args...)(Args a) {
    //    fatal(MsgText!m)(a);
    //}

    static void fatal(M)(M m) {
        auto _log = resolveInjector!Logger;
        _log.fatal(m);
    }
};
