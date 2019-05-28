module gen.dxxtool.autogen;

private import dxx.util.minitemplt;
private import dxx.app.properties;

enum _autogenerator = [
  "runtime","generator","shellTarget","libraryTarget","autogen","appmodel",
];

alias _lookup=Properties.__;

string _expand(alias x)() {
  // Expand identifiers in single braces, in the output filename, at runtime
  return miniInterpreter!(_lookup,"{","}")(x);
}



// Generator runtime

auto gen_runtime(T...)(T vars) {
    
    renderVayneToFile!("resources/templates/model/runtime/{app.genSourceDir}/{app.ID}build.d.vayne",vars)(_expand!"resources/templates/model/runtime/{app.genSourceDir}/{app.ID}build.d");
    
    renderVayneToFile!("resources/templates/model/runtime/{app.genSourceDir}/{app.ID}base.d.vayne",vars)(_expand!"resources/templates/model/runtime/{app.genSourceDir}/{app.ID}base.d");
    
    renderVayneToFile!("resources/templates/model/runtime/{app.sourceDir}/{app.ID}mod.d.vayne",vars)(_expand!"resources/templates/model/runtime/{app.sourceDir}/{app.ID}mod.d");
    
}




// Generator generator

auto gen_generator(T...)(T vars) {
    
    renderVayneToFile!("resources/templates/model/generator/{app.workflowDir}/autogen.wf.vayne",vars)(_expand!"resources/templates/model/generator/{app.workflowDir}/autogen.wf");
    
    renderVayneToFile!("resources/templates/model/generator/{app.genSourceDir}/{app.generatorModuleName}.d.vayne",vars)(_expand!"resources/templates/model/generator/{app.genSourceDir}/{app.generatorModuleName}.d");
    
}




// Generator shellTarget

auto gen_shellTarget(T...)(T vars) {
    
    renderVayneToFile!("resources/templates/targets/shell/source/__app.packageDir__/__app.ID.d.vayne",vars)(_expand!"resources/templates/targets/shell/source/__app.packageDir__/__app.ID.d");
    
    renderVayneToFile!("resources/templates/targets/shell/dub.json.vayne",vars)(_expand!"resources/templates/targets/shell/dub.json");
    
}




// Generator libraryTarget

auto gen_libraryTarget(T...)(T vars) {
    
    renderVayneToFile!("resources/templates/targets/library/dub.json.vayne",vars)(_expand!"resources/templates/targets/library/dub.json");
    
    renderVayneToFile!("resources/templates/targets/library/{app.resourceDir}/{{app.ID}}-enGB.ini.vayne",vars)(_expand!"resources/templates/targets/library/{app.resourceDir}/{{app.ID}}-enGB.ini");
    
    renderVayneToFile!("resources/templates/targets/library/{app.resourceDir}/{{app.ID}}.ini.vayne",vars)(_expand!"resources/templates/targets/library/{app.resourceDir}/{{app.ID}}.ini");
    
    renderVayneToFile!("resources/templates/targets/library/dale.d.vayne",vars)(_expand!"resources/templates/targets/library/dale.d");
    
}




// Generator autogen

auto gen_autogen(T...)(T vars) {
    
    renderVayneToFile!("resources/templates/dxx/autogen/autogen.d.vayne",vars)(_expand!"resources/templates/dxx/autogen/autogen.d");
    
}




// Generator appmodel

auto gen_appmodel(T...)(T vars) {
    
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/dxx-dev.json.vayne",vars)(_expand!"resources/templates/model/application/{app.resourceDir}/dxx-dev.json");
    
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/{app.ID}-enGB.ini.vayne",vars)(_expand!"resources/templates/model/application/{app.resourceDir}/{app.ID}-enGB.ini");
    
    renderVayneToFile!("resources/templates/model/application/.gitignore.vayne",vars)(_expand!"resources/templates/model/application/.gitignore");
    
    renderVayneToFile!("resources/templates/model/application/dub.json.vayne",vars)(_expand!"resources/templates/model/application/dub.json");
    
    renderVayneToFile!("resources/templates/model/application/dale.d.vayne",vars)(_expand!"resources/templates/model/application/dale.d");
    
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/dxx.json.vayne",vars)(_expand!"resources/templates/model/application/{app.resourceDir}/dxx.json");
    
    renderVayneToFile!("resources/templates/model/application/{app.resourceDir}/{app.ID}.ini.vayne",vars)(_expand!"resources/templates/model/application/{app.resourceDir}/{app.ID}.ini");
    
}




auto _dxxtool_autogen(alias _id,alias vars)() {
  
    static if (_id == "runtime") {
      gen_runtime(vars);
    }
  
    static if (_id == "generator") {
      gen_generator(vars);
    }
  
    static if (_id == "shellTarget") {
      gen_shellTarget(vars);
    }
  
    static if (_id == "libraryTarget") {
      gen_libraryTarget(vars);
    }
  
    static if (_id == "autogen") {
      gen_autogen(vars);
    }
  
    static if (_id == "appmodel") {
      gen_appmodel(vars);
    }
  
}

auto dxxtool_autogen(T...)(string _id,T vars) {
  
    if (_id == "runtime") {
      gen_runtime!(T)(vars);
    }
  
    if (_id == "generator") {
      gen_generator!(T)(vars);
    }
  
    if (_id == "shellTarget") {
      gen_shellTarget!(T)(vars);
    }
  
    if (_id == "libraryTarget") {
      gen_libraryTarget!(T)(vars);
    }
  
    if (_id == "autogen") {
      gen_autogen!(T)(vars);
    }
  
    if (_id == "appmodel") {
      gen_appmodel!(T)(vars);
    }
  
}
