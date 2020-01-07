/**
{{app.docHeader}}
**/
module {{app.genModuleName}}.{{app.ID}}build;

{{* imp;app.bareImports}}
private static import {{imp}};
{{/}}

private static import dxx.app;
private static import dxx.util;

private static import {{app.moduleName}}

@component
class {{app.ID}}_RuntimeDefault : {{app.appRuntimeModuleName}} {
  mixin registerComponent!({{app.ID}}_RuntimeDefault,AppParam);
  {{* o; app.appRuntimeModuleOverrides}}
    {{o}};
  {{/}}
}
