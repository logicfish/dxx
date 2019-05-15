module gen.{{app.ID}}.autogen;

{{* id,gen; generators}}

auto gen_{{id}}(T...)(T vars) {
    {{* t;gen.templates}}
      renderVayneToFile!(t.name,vars)(t.outFile);
    {{/}}
}

{{/}}
