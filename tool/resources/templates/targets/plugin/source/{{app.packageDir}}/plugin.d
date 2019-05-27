/**
{{pluginDoc}}
**/
module {{app.packageName}}.plugin;

{{app.pluginImports}}

private import dxx.util.plugin;

class {{app.pluginClassName}} : {{app.pluginBaseClass}} {
    override void activate(PluginContext* ctx) {
        // TODO ...
    }

    override void deactivate(PluginContext* ctx) {
        // TODO ...
    }
}
