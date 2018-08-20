module dxx.tool;

private import aermicioi.aedi;

private import std.getopt;
private import std.experimental.logger;

private import dxx.app;
private import dxx.tools;

// Compile-time config
enum ToolConfig = IniConfig!("tool.ini");

@component
class ToolsContext : AppModule!(dxx.tool) {
    //override void registerAppDependencies(DefaultInjector injector) {
      //injector.register!(DObjectImpl,DObject);
      //DCoreModelImpl.registerPackage(injector);
      //injector.register!Example;
    //}
    @component
    public Logger getLogger() {
        return sharedLog;
    }

};
struct Options {
};

int main(string[] args) {
    Options opt;
    auto rslt = getopt(args
    );
    if (rslt.helpWanted) {
        defaultGetoptPrinter("DXX Tool",
            rslt.options);
    }
    if(args.length < 2) {
        return -1;
    }
    string cmd = args[1];
    
    /*switch(cmd) {
        case "init" : 
            InitTool.run(args);
            break;
        default:
            return -1;
    }*/
    
    return 0;
}
