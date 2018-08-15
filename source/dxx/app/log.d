module dxx.app.log;

private import std.experimental.logger;

private import dxx.app;

class MsgLog {
    static Logger _log;

    static this() {
        _log = resolveInjector!Logger;
    }

    static void trace(alias m,Args...)(Args a) {
        trace(MsgText!m)(a);
    }

    static void trace(M)(M m) {
        _log.trace(m);
    }

    static void log(alias m,Args...)(Args a) {
        log(MsgText!m)(a);
    }

    static void log(M)(M m) {
        _log.log(m);
    }

    static void warn(alias m,Args...)(Args a) {
        warn(MsgText!m)(a);
    }

    static void warn(M)(M m) {
        _log.warn(m);
    }

    static void error(alias m,Args...)(Args a) {
        error(MsgText!m)(a);
    }

    static void error(M)(M m) {
        _log.error(m);
    }

    static void info(alias m,Args...)(Args a) {
        info(MsgText!m)(a);
    }

    static void info(M)(M m) {
        _log.info(m);
    }
    static void fatal(alias m,Args...)(Args a) {
        fatal(MsgText!m)(a);
    }

    static void fatal(M)(M m) {
        _log.fatal(m);
    }
};
