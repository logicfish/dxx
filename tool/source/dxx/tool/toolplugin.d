module dxx.tool.toolplugin;

private import dxx.util;
private import dxx.app.plugin;

class ToolPlugin : PluginDefault,PluginActivator {
  override void init() {
      super.init;
      MsgLog.info("init");
      activator(this);
  }
  override void activate(PluginContext* ctx) {
      MsgLog.info("activate");
      MsgLog.info(descr.id);
  }

  override void deactivate(PluginContext* ctx) {
      MsgLog.info("deactivate");
      MsgLog.info(descr.id);
  }

  void registerCommand(string cmd) {

  }
  void registerWorkflowListener() {

  }
}
