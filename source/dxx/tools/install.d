module dxx.tools.install;

private import dxx.tools;

// Install

class InstallTool : ToolBase {
    int run(string[] args) {
        MsgLog.info("InstallTool run()");
        return Tool.OK;
    }
    
};

