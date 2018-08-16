module dxx.ini;

private import ctini.ctini;

private import std.typecons;
private import std.variant;

void iterateTupleTree(alias Tuples,alias Func,string fqn=null)() {
    static foreach (fieldName ; Tuples.fieldNames) {
        static if(isTuple!(typeof(mixin("Tuples."~fieldName)))) {
            Func!(true,fieldName,mixin("Tuples."~fieldName),fqn);
            static if(fqn !is null) {
                iterateTupleTree!(mixin("Tuples."~fieldName),Func,fqn ~ "." ~ fieldName);
            } else {
                iterateTupleTree!(mixin("Tuples."~fieldName),Func,fieldName);
            }
        } else {
            Func!(false,fieldName,mixin("Tuples."~fieldName),fqn);
        }
    }
}
void iterateTupleTreeF(alias Tuples,Func,string fqn=null)(Func f) {
    static foreach (fieldName ; Tuples.fieldNames) {
        static if(isTuple!(typeof(mixin("Tuples."~fieldName)))) {
            //f(true,fieldName,mixin("Tuples."~fieldName),fqn);
            static if(fqn !is null) {
                iterateTupleTreeF!(mixin("Tuples."~fieldName),Func,fqn ~ "." ~ fieldName)(f);
            } else {
                iterateTupleTreeF!(mixin("Tuples."~fieldName),Func,fieldName)(f);
            }
        } else {
            //f(false,fieldName,mixin("Tuples."~fieldName),fqn);
            f(fieldName,mixin("Tuples."~fieldName),fqn);
        }
    }
}
void iterateTupleTreeV(alias Tuples,alias Func,string fqn=null)() {
    static void __f(bool isSection,string k,alias v,string fqn)() {
        Func!(isSection,k,typeof(Variant(v)),fqn)(Variant(v));
    }
    iterateTupleTree!(Tuples,__f,fqn)();
}
auto iterateSections(alias fields,alias Func)() {
    static void __f(bool isSection,string k,alias v,string fqn)() {
        static if (isSection) {
            Func!(fqn,k,v)();
        }
    }
    iterateTupleTree!(fields,__f)();
}
auto iterateValues(alias fields,alias Func)() {
    static void __f(bool isSection,string k,alias v,string fqn)() {
        static if (!isSection) {
            Func!(fqn,k,v)();
        }
    }
    iterateTupleTree!(fields,__f)();
}
auto iterateValuesF(alias fields,Func)(Func f) {
    void __f(string k,string v,string fqn) {
        f(fqn,k,v);
    }
    iterateTupleTreeF!(fields)(&__f);
}

template ctConfig(string fname) {
    enum ctConfig = IniConfig!fname;
}

unittest {
    import std.stdio;
    import std.conv;
    
    void writeFields(alias fields)() {
        static void __f(bool isSection,string k,alias v,string fqn)() {
            static if (isSection) {
                if(fqn !is null) {
                    writeln(" ** [" ~ fqn ~ "." ~ k ~ "]");
                } else {
                    writeln(" -- [" ~ k ~ "]");
                }
            } else {
                writeln(typeid(v).to!string ~ " " ~ k ~ " = " ~ v.to!string~";");
            }
        }
        iterateTupleTree!(fields,__f)();
    }
    void writeFieldsV(alias fields,string fqn=null)() {
        static void __f(bool isSection,string k,V,string fqn)(V v) {
            writeln(" v@ " ~ v.type.toString ~ " " ~ fqn ~ "." ~ k ~ " -- " ~ v.toString);
        }
        iterateTupleTreeV!(fields,__f,fqn)();
    }
    void writeSections(alias fields)() {
        static void __f(string fqn,string k,alias v)() {
            writeln("[" ~ k ~ "]");
        }
        iterateSections!(fields,__f)();
    }
    void writeValues(alias fields)() {
        static void __f(string fqn,string k,alias v)() {
            writeln(k ~ " == " ~ v.to!string);
        }
        iterateValues!(fields,__f)();
    }

    enum config = IniConfig!"test-config.ini";
    
    //Four data types
    //Everything available at compile time
    static assert(config.Section.intValue == 3);
    static assert(config.Section.stringValue == "string");
    static assert(config.Section.floatValue == 123.45f);
    static assert(config.Section.Subsection.boolValue == false);

    writeFields!config();
    writeFieldsV!config();
    writeSections!config();
    writeValues!config();

    //writeln(getSectionNames!config);
}


