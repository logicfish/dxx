module dxx.util.ctfe;

template tryCompile(T ...) {
    static foreach (t;T) {
        static if(__traits(compiles,t)) {
            mixin(t);
        }
    }
}
template compileIf(Q,T...) {
    static if(Q) {
        alias compileIf = tryCompile!(T);
    } else {
        alias compileIf = void;
    }
}
