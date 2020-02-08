module gen.{{vars.appid}}.autogen;

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
  {{* id,gen; vars.generators}}"{{id}}",{{/}}
];

alias _lookup=Properties.__;

string _expand(alias x)() {
  // Expand identifiers in single braces, in the output filename, at runtime
  //return miniInterpreter!(_lookup,"{","}")(x);
  return miniInterpreter!(_lookup)(x);
  //return x;
}

{{* id,gen; vars.generators}}

// Generator {{id}}

mixin template gen_{{id}}(Vars...) {
  auto gen_{{id}}() {
    {{* tmplt,out;gen.templates}}
    /* {{out}} */
    MsgLog.info("gen:",_expand!"{{out}}");
    dirName(_expand!"{{out}}").mkdirRecurse;
    renderVayneToFile!("{{tmplt}}",Vars)(_expand!"{{out}}");
    {{/}}
  }
}

{{/}}

mixin template _{{vars.appid}}_autogen(alias _id,Vars...) {
  auto _{{vars.appid}}_autogen() {
  {{* id,gen; vars.generators}}
    /* {{id}} */
    static if (_id == "{{id}}") {
      mixin gen_{{id}}!vars;
      return gen_{{id}}();
    }
  {{/}}
  }
}

template {{vars.appid}}_autogen(Vars...) {
  auto {{vars.appid}}_autogen(string _id) {
    {{* id,gen; vars.generators}}
      /* {{id}} */
      if (_id == "{{id}}") {
        MsgLog.info("gen: {{id}}");
        mixin gen_{{id}}!Vars;
        return gen_{{id}}();
      }
    {{/}}
  }
}
