/**
Copyright: 2018 Mark Fisher

License:
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
module dxx.tools.init;

private import eph.args;

private import std.array : split;
private import std.algorithm : each;
//private import std.algorithm.iteration : joiner;


private import dxx.util;
private import dxx.tools;
private import dxx.tool;
private import dxx.app.resource;
private import gen.dxxtool.autogen;

// Initialise empty project

class InitTool : ToolBase {
	alias injector = localInjector;

	override
	int runTool(WorkflowJob job) {
      debug {
          MsgLog.info("InitTool run");
      }
    	string[] types = injector.getArgument(ToolConfig.args.type).values;
    	injector.getArgument(ToolConfig.args.define).values.each!((string a) {
    			string[] keyValue = a.split("=");
	    		//if(keyValue.length == 2) job.setProperty(keyValue[0],keyValue[1]);
		    	//else job.setProperty(keyValue[0],"true");
			    //MsgLog.trace("defn ",keyValue.joiner("="));
					if(keyValue.length == 2) {
						MsgLog.trace("defn ",keyValue[0]," = ",keyValue[1]);
						job.setProperty(keyValue[0],keyValue[1]);
					}	else {
						MsgLog.trace("defn ",keyValue[0]," = true");
						job.setProperty(true,keyValue[0]);
					}
    	});
			//auto t = injector.getArgument(ToolConfig.args.type);
      //MsgLog.info("InitTool runTool() %s",types.joiner(","));

			Project project = new ProjectBase("",null);
			project.desc.app.ID = "Test ID";

			//app.ID = "__APP_ID__";
			//app.appName = "__APP_NAME__";
			//app.organizationName = "__ORGANIZATION_NAME__";

			types.each!(((string a){
				MsgLog.info("Init Type: ",a);
				dxxtool_autogen!(project)(a);
			}));

			debug {
          MsgLog.info("InitTool done.");
      }
      return Tool.OK;
    }
    //void initWorkflow(Workflow wf) {
    //}

    override
    ArgParser registerArguments(ArgParser parser,WorkflowJob job) {
    	//auto parser = super.registerDefaultArgs();
    	Argument typeArg = new Argument().shortFlag('t').longFlag("type").requireParam();
    	injector.registerArgument(typeArg,ToolConfig.args.type);

    	Parameter param = new Parameter();
    	injector.register!Parameter(param,ToolConfig.args.param);

    	return parser.register(typeArg).register(param);
    }
};
