module dxx.tools.init;

private import dxx.tools;

// Initialise empty project

class InitTool : ToolBase {
    int run(string[] args) {
        MsgLog.info("InitTool run()");
        return Tool.OK;
    }
};

