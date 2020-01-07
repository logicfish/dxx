/**
{{app.docHeader}}
**/
module {{app.modulePackage}};

{{* imp;app.bareImports}}
private static import {{imp}};
{{/}}

private static import dxx.app;
private static import dxx.util;

private static import {{app.genModuleName}}.{{app.ID}}base;

@component
class {{app.appRuntimeModuleName}} : {{app.ID}}_RuntimeBase {
  /* Add per-application overrides here... */
}
