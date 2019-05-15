/**
{{app.docHeader}}
**/
module {{app.genModuleName}}.{{app.ID}}base;

{{* imp;app.bareImports}}
private static import {{imp}};
{{/}}

private static import dxx.app;
private static import dxx.util;

enum {{app.ID}}Config = DXXConfig ~ IniConfig!("{{app.ID}}.ini");

@component
class {{app.ID}}_RuntimeBase : {{app.appRuntimeModuleBase}} {
  mixin __Text!({{app.ID}}Config.{{app.ID}}.lang);
}
