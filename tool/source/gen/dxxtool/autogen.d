module gen.dxxtool.autogen;

auto _autogenerator = [
  "runtime","generator","autogen","appmodel",
];



// Generator runtime

auto gen_runtime(T...)(T vars) {
    
      renderVayneToFile!("resources/templates/model/runtime",vars)("resources/templates/model/runtime/__app.sourceDir__/__app.ID__mod.d");
    
}




// Generator generator

auto gen_generator(T...)(T vars) {
    
      renderVayneToFile!("resources/templates/model/generator",vars)("resources/templates/model/generator/__app.workflowDir__/autogen.wf");
    
}




// Generator autogen

auto gen_autogen(T...)(T vars) {
    
      renderVayneToFile!("resources/templates/dxx/autogen",vars)("resources/templates/dxx/autogen/autogen.d");
    
}




// Generator appmodel

auto gen_appmodel(T...)(T vars) {
    
      renderVayneToFile!("resources/templates/model/application",vars)("resources/templates/model/application/__app.resourceDir__/__app.ID__.ini");
    
}




auto _autogen(alias _id,T...)(T vars) {
  
    static if (_id == "runtime") {
      gen_runtime!(T)(vars);
    }
  
    static if (_id == "generator") {
      gen_generator!(T)(vars);
    }
  
    static if (_id == "autogen") {
      gen_autogen!(T)(vars);
    }
  
    static if (_id == "appmodel") {
      gen_appmodel!(T)(vars);
    }
  
}

auto __autogen(T...)(string _id,T vars) {
  
    if (_id == "runtime") {
      gen_runtime!(T)(vars);
    }
  
    if (_id == "generator") {
      gen_generator!(T)(vars);
    }
  
    if (_id == "autogen") {
      gen_autogen!(T)(vars);
    }
  
    if (_id == "appmodel") {
      gen_appmodel!(T)(vars);
    }
  
}
