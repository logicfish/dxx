module app;

import std.stdio;
import dxx.app;

class Example {
};

class BasicModule : AppModule!(app) {
    //override void registerAppDependencies(DefaultInjector injector) {
      //injector.register!(DObjectImpl,DObject);
      //DCoreModelImpl.registerPackage(injector);
      //injector.register!Example;
    //}

};

void main()
{
	MsgLog.info("Edit source/app.d to start your project.");
}
