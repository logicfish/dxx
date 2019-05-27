module gen.{{vars.appid}}.autogen;

auto _autogenerator = [
  {{* id,gen; vars.generators}}"{{id}}",{{/}}
];

{{* id,gen; vars.generators}}

// Generator {{id}}

auto gen_{{id}}(T...)(T vars) {
    {{* tmplt,out;gen.templates}}
      renderVayneToFile!("{{tmplt}}",vars)("{{out}}");
    {{/}}
}


{{/}}

auto _autogen(alias _id,T...)(T vars) {
  {{* id,gen; vars.generators}}
    static if (_id == "{{id}}") {
      gen_{{id}}!(T)(vars);
    }
  {{/}}
}

auto __autogen(T...)(string _id,T vars) {
  {{* id,gen; vars.generators}}
    if (_id == "{{id}}") {
      gen_{{id}}!(T)(vars);
    }
  {{/}}
}
