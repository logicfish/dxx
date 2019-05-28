module gen.{{vars.appid}}.autogen;

private import dxx.util.minitemplt;
private import dxx.app.properties;

enum _autogenerator = [
  {{* id,gen; vars.generators}}"{{id}}",{{/}}
];

alias _lookup=Properties.__;

string _expand(alias x)() {
  // Expand identifiers in single braces, in the output filename, at runtime
  return miniInterpreter!(_lookup,"{","}")(x);
}

{{* id,gen; vars.generators}}

// Generator {{id}}

auto gen_{{id}}(T...)(T vars) {
    {{* tmplt,out;gen.templates}}
    renderVayneToFile!("{{tmplt}}",vars)(_expand!"{{out}}");
    {{/}}
}


{{/}}

auto _{{vars.appid}}_autogen(alias _id,alias vars)() {
  {{* id,gen; vars.generators}}
    static if (_id == "{{id}}") {
      gen_{{id}}(vars);
    }
  {{/}}
}

auto {{vars.appid}}_autogen(T...)(string _id,T vars) {
  {{* id,gen; vars.generators}}
    if (_id == "{{id}}") {
      gen_{{id}}!(T)(vars);
    }
  {{/}}
}
