module gen.dxxtool.autogen;

private import std.path : dirName;
private import std.file : mkdirRecurse;

private import dxx.util.minitemplt;
private import dxx.util.log;
private import dxx.app.properties;
private import dxx.app.vaynetmplt;
private import dxx.app.resource;
private import dxx.app.resource.resource;
private import dxx.app.resource.project;

enum _autogenerator = [
  "runtime","generator","shellTarget","libraryTarget","autogen","appmodel",
];

alias _lookup=Properties.__;

string _expand(alias x)() {
  // Expand identifiers in single braces, in the output filename, at runtime
  //return miniInterpreter!(_lookup,"{","}")(x);
  return miniInterpreter!(_lookup)(x);
  //return x;
}



// Generator runtime

mixin template gen_runtime(Vars...) {
  auto gen_runtime() {
    
    /* {{app.genSourceDir}}/{{app.ID}}build.d */
    MsgLog.info("gen:",_expand!"{{app.genSourceDir}}/{{app.ID}}build.d");
    dirName(_expand!"{{app.genSourceDir}}/{{app.ID}}build.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/runtime/{{app.genSourceDir}}/{{app.ID}}build.d.vayne",Vars)(_expand!"{{app.genSourceDir}}/{{app.ID}}build.d");
    
    /* {{app.genSourceDir}}/{{app.ID}}base.d */
    MsgLog.info("gen:",_expand!"{{app.genSourceDir}}/{{app.ID}}base.d");
    dirName(_expand!"{{app.genSourceDir}}/{{app.ID}}base.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/runtime/{{app.genSourceDir}}/{{app.ID}}base.d.vayne",Vars)(_expand!"{{app.genSourceDir}}/{{app.ID}}base.d");
    
    /* {{app.sourceDir}}/{{app.ID}}mod.d */
    MsgLog.info("gen:",_expand!"{{app.sourceDir}}/{{app.ID}}mod.d");
    dirName(_expand!"{{app.sourceDir}}/{{app.ID}}mod.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/runtime/{{app.sourceDir}}/{{app.ID}}mod.d.vayne",Vars)(_expand!"{{app.sourceDir}}/{{app.ID}}mod.d");
    
  }
}



// Generator generator

mixin template gen_generator(Vars...) {
  auto gen_generator() {
    
    /* {{app.genSourceDir}}/{{app.generatorModuleName}}.d */
    MsgLog.info("gen:",_expand!"{{app.genSourceDir}}/{{app.generatorModuleName}}.d");
    dirName(_expand!"{{app.genSourceDir}}/{{app.generatorModuleName}}.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/generator/{{app.genSourceDir}}/{{app.generatorModuleName}}.d.vayne",Vars)(_expand!"{{app.genSourceDir}}/{{app.generatorModuleName}}.d");
    
    /* {{app.workflowDir}}/autogen.wf */
    MsgLog.info("gen:",_expand!"{{app.workflowDir}}/autogen.wf");
    dirName(_expand!"{{app.workflowDir}}/autogen.wf").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/generator/{{app.workflowDir}}/autogen.wf.vayne",Vars)(_expand!"{{app.workflowDir}}/autogen.wf");
    
  }
}



// Generator shellTarget

mixin template gen_shellTarget(Vars...) {
  auto gen_shellTarget() {
    
    /* dub.json */
    MsgLog.info("gen:",_expand!"dub.json");
    dirName(_expand!"dub.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/shell/dub.json.vayne",Vars)(_expand!"dub.json");
    
    /* source/{app.packageDir}/{app.ID}.d */
    MsgLog.info("gen:",_expand!"source/{app.packageDir}/{app.ID}.d");
    dirName(_expand!"source/{app.packageDir}/{app.ID}.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/shell/source/{app.packageDir}/{app.ID}.d.vayne",Vars)(_expand!"source/{app.packageDir}/{app.ID}.d");
    
  }
}



// Generator libraryTarget

mixin template gen_libraryTarget(Vars...) {
  auto gen_libraryTarget() {
    
    /* {app.resourceDir}/{app.ID}-dev.ini */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}-dev.ini");
    dirName(_expand!"{app.resourceDir}/{app.ID}-dev.ini").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/library/{app.resourceDir}/{app.ID}-dev.ini.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}-dev.ini");
    
    /* dale.d */
    MsgLog.info("gen:",_expand!"dale.d");
    dirName(_expand!"dale.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/library/dale.d.vayne",Vars)(_expand!"dale.d");
    
    /* {app.resourceDir}/{app.ID}.ini */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}.ini");
    dirName(_expand!"{app.resourceDir}/{app.ID}.ini").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/library/{app.resourceDir}/{app.ID}.ini.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}.ini");
    
    /* {app.resourceDir}/{app.ID}.json */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}.json");
    dirName(_expand!"{app.resourceDir}/{app.ID}.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/library/{app.resourceDir}/{app.ID}.json.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}.json");
    
    /* dub.json */
    MsgLog.info("gen:",_expand!"dub.json");
    dirName(_expand!"dub.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/library/dub.json.vayne",Vars)(_expand!"dub.json");
    
    /* {app.resourceDir}/{app.ID}-dev.json */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}-dev.json");
    dirName(_expand!"{app.resourceDir}/{app.ID}-dev.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/library/{app.resourceDir}/{app.ID}-dev.json.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}-dev.json");
    
    /* {app.resourceDir}/{app.ID}-enGB.ini */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}-enGB.ini");
    dirName(_expand!"{app.resourceDir}/{app.ID}-enGB.ini").mkdirRecurse;
    renderVayneToFile!("resources/templates/targets/library/{app.resourceDir}/{app.ID}-enGB.ini.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}-enGB.ini");
    
  }
}



// Generator autogen

mixin template gen_autogen(Vars...) {
  auto gen_autogen() {
    
    /* autogen.d */
    MsgLog.info("gen:",_expand!"autogen.d");
    dirName(_expand!"autogen.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/dxx/autogen/autogen.d.vayne",Vars)(_expand!"autogen.d");
    
  }
}



// Generator appmodel

mixin template gen_appmodel(Vars...) {
  auto gen_appmodel() {
    
    /* {app.resourceDir}/{app.ID}.json */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}.json");
    dirName(_expand!"{app.resourceDir}/{app.ID}.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/{app.ID}.json.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}.json");
    
    /* {app.sourceDir}/{app.ID}/app.d */
    MsgLog.info("gen:",_expand!"{app.sourceDir}/{app.ID}/app.d");
    dirName(_expand!"{app.sourceDir}/{app.ID}/app.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/{app.sourceDir}/{app.ID}/app.d.vayne",Vars)(_expand!"{app.sourceDir}/{app.ID}/app.d");
    
    /* {app.resourceDir}/dxx-dev.json */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/dxx-dev.json");
    dirName(_expand!"{app.resourceDir}/dxx-dev.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/dxx-dev.json.vayne",Vars)(_expand!"{app.resourceDir}/dxx-dev.json");
    
    /* {app.resourceDir}/{app.ID}-enGB.ini */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}-enGB.ini");
    dirName(_expand!"{app.resourceDir}/{app.ID}-enGB.ini").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/{app.ID}-enGB.ini.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}-enGB.ini");
    
    /* .gitignore */
    MsgLog.info("gen:",_expand!".gitignore");
    dirName(_expand!".gitignore").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/.gitignore.vayne",Vars)(_expand!".gitignore");
    
    /* dub.json */
    MsgLog.info("gen:",_expand!"dub.json");
    dirName(_expand!"dub.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/dub.json.vayne",Vars)(_expand!"dub.json");
    
    /* dale.d */
    MsgLog.info("gen:",_expand!"dale.d");
    dirName(_expand!"dale.d").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/dale.d.vayne",Vars)(_expand!"dale.d");
    
    /* {app.resourceDir}/dxx.json */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/dxx.json");
    dirName(_expand!"{app.resourceDir}/dxx.json").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/dxx.json.vayne",Vars)(_expand!"{app.resourceDir}/dxx.json");
    
    /* {app.resourceDir}/{app.ID}.ini */
    MsgLog.info("gen:",_expand!"{app.resourceDir}/{app.ID}.ini");
    dirName(_expand!"{app.resourceDir}/{app.ID}.ini").mkdirRecurse;
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/{app.ID}.ini.vayne",Vars)(_expand!"{app.resourceDir}/{app.ID}.ini");
    
  }
}



mixin template _dxxtool_autogen(alias _id,Vars...) {
  auto _dxxtool_autogen() {
  
    /* runtime */
    static if (_id == "runtime") {
      mixin gen_runtime!vars;
      return gen_runtime();
    }
  
    /* generator */
    static if (_id == "generator") {
      mixin gen_generator!vars;
      return gen_generator();
    }
  
    /* shellTarget */
    static if (_id == "shellTarget") {
      mixin gen_shellTarget!vars;
      return gen_shellTarget();
    }
  
    /* libraryTarget */
    static if (_id == "libraryTarget") {
      mixin gen_libraryTarget!vars;
      return gen_libraryTarget();
    }
  
    /* autogen */
    static if (_id == "autogen") {
      mixin gen_autogen!vars;
      return gen_autogen();
    }
  
    /* appmodel */
    static if (_id == "appmodel") {
      mixin gen_appmodel!vars;
      return gen_appmodel();
    }
  
  }
}

template dxxtool_autogen(Vars...) {
  auto dxxtool_autogen(string _id) {
    
      /* runtime */
      if (_id == "runtime") {
        MsgLog.info("gen: runtime");
        mixin gen_runtime!Vars;
        return gen_runtime();
      }
    
      /* generator */
      if (_id == "generator") {
        MsgLog.info("gen: generator");
        mixin gen_generator!Vars;
        return gen_generator();
      }
    
      /* shellTarget */
      if (_id == "shellTarget") {
        MsgLog.info("gen: shellTarget");
        mixin gen_shellTarget!Vars;
        return gen_shellTarget();
      }
    
      /* libraryTarget */
      if (_id == "libraryTarget") {
        MsgLog.info("gen: libraryTarget");
        mixin gen_libraryTarget!Vars;
        return gen_libraryTarget();
      }
    
      /* autogen */
      if (_id == "autogen") {
        MsgLog.info("gen: autogen");
        mixin gen_autogen!Vars;
        return gen_autogen();
      }
    
      /* appmodel */
      if (_id == "appmodel") {
        MsgLog.info("gen: appmodel");
        mixin gen_appmodel!Vars;
        return gen_appmodel();
      }
    
  }
}
