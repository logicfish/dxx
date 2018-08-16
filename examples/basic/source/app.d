module app;

import std.stdio;
import dxx.app;

class Example {
};

class BasicAppContext : ApplicationDefaultContext {
    //override void registerAppDependencies(DefaultInjector injector) {
      //injector.register!(DObjectImpl,DObject);
      //DCoreModelImpl.registerPackage(injector);
      //injector.register!Example;
    //}

};

void main()
{
	writeln("Edit source/app.d to start your project.");
}
