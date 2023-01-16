# Mustache for Lua

A lightweight Lua implementation of the Mustache templating language.

## Features

* Compliant with version [1.3.0](https://github.com/mustache/spec/releases/tag/v1.3.0) of the [Mustache language specification](https://github.com/mustache/spec)
* Passes all required tests for normal usage and edge-case behavior
* Does not support optional features, like lambdas
* Supports Lua 5.4

## Getting Started

Mustache.lua was designed to be minimal, and fits into a single script file. To use the script, place the script directly in your project or within your [package search path](https://www.lua.org/manual/5.4/manual.html#pdf-package.path). A table loaded from the script, which contains functions necessary to render a Mustache template. Below is an introductory example of how you might render various templates using Lua's interactive mode.

```Text
> mustache = require "mustache"
> mustache.compile("Hello, World!")
Hello, World!
> mustache.compile("Hello, {{name}}!", {name="World"})
Hello, World!
> mustache.compile("{{>message}}", {}, {message="Hello, World!"})
Hello, World!
> mustache.compile("{{>message}}", {name="World"}, {message="Hello, {{name}}!"})
Hello, World!
```

## Language Guide

Mustache is a general-purpose templating language that expands tags using values provided by a data table. A 'tag' is indicated by double mustaches. Tags may contain modifier symbols that alter the behavior of the tag. For example, if the tag begins with an exclamation point then it represents a comment. This guide starts with a list of all supported tags, followed by sections describing each tag with examples.

### Supported Tags

|Tag Name|Open|Close|Description|
|----|--------|---------|---|
|Escaped Variable|`{{`|`}}`|Inserts a value into a template with HTML escaping|
|Unescaped Variable|`{{{`|`}}}`|Inserts a value into a template without HTML escaping|
|Unescaped Variable|`{{&`|`}}`|Inserts a value into a template without HTML escaping|
|Section|`{{#`|`}}`|Starts a section that renders if the value is 'truthy'|
|Inverted Section|`{{^`|`}}`|Starts a section that renders if the value is 'falsey'|
|Close Section|`{{/`|`}}`|Closes the section with the matching name|
|Partial|`{{>`|`}}`|Renders an external template|
|Comment|`{{!`|`}}`|A comment that does not show in the output|
|Set Delimitter|`{{=`|`=}}`|Changes the tag delimitters|

### Variables

A variable merges a data value into a template. Variables are HTML escaped by default, and must be surrounded by triple mustaches or begin with an ampersand to prevent escaping. The tag name is resolved to a key in the data table starting from current section. Variables not found in the current section will attempt to resolve in each parent section. If a value can't be found, then the tag will be ignored and you will not receive an error. If your data contains nested tables, you can use a dotted name to reference a value deep within your tables.

**Template**
```Text
{{student.name}} knew that the answer was "{{{answer}}}".
```

**Data**
```Lua
{
  answer = 'a > b',
  student = {
    name = 'Alice'
  }
}
```

**Output**
```Text
Alice knew that the answer was "a > b".
```

### Sections

Sections render a section of a template zero or more times. Each section must have an opening tag and a closing tag with the same name. For example, you can create a section for rendering a list of animals with a starting tag `{{#animals}}` followed by a closing tag `{{/animals}}`. Section names are looked up in the data table, and the value's type determines the behavior of the section. If the value is a list, then the section tag will render the contents once for each item in the list. If the value is 'true' then the section is rendered once. If the section is 'false' then the section is not rendered, unless you are rendering an inverted section. Variables in sections are searched starting from the context of the current section before searching parent sections. To get the current item from a list of primitives, or the value evaluated by a conditional section, use the special `.` variable name. Lines with a standalone opening tag or closing tag are stripped from the output rather than leaving an empty line.

**Template**
```Text
{{#people}}
- {{name}} enjoys {{hobby}}{{#where}} in the {{.}}{{/where}}.
{{/people}}
```

**Data**
```Lua
{
  people = {
    { name = 'Alice', hobby = 'painting', where = 'park' },
    { name = 'Bob', hobby = 'sketching' }
  }
}
```

**Output**
```Text
- Alice enjoys painting in the park.
- Bob enjoys sketching.
```

### Partials

Partials render external templates in the context of the current template. The tag's content names the partial template to inject. If the tag is standalone, then the whitespace preceding the tag is used as indentation and prepended to the beginning of each line in the partial template before the partial is rendered. If a partial can't be found, then the tag will be ignored and you will not receive an error.

**Template**
```Text
{{#people}}
- {{>hobby}}
{{/people}}
```

**Data**
```Lua
{
  people = {
    { name = 'Alice', hobby = 'painting' },
    { name = 'Bob', hobby = 'sketching' }
  }
}
```

**Partials**
```Lua
{
  hobby = '{{name}} enjoys {{hobby}}.'
}
```

**Output**
```Text
- Alice enjoys painting.
- Bob enjoys sketching.
```

### Comments

A comment is an explanatory note that never appears in the resulting output. Comments may contain a single letter, or span multiple lines. Lines with a standalone comment tag are stripped from the output rather than leaving an empty line.

**Template**
```Text
{{!Multi-line
comment}}Hello, {{!Ignore}}World!
```

**Output**
```Text
Hello, World!
```

### Set Delimiter

Set delimiter tags change the tag delimiters from `{{` and `}}` to different sequences. The new sequences may not contain whitespace or equal signs. The set delimiter tag is useful when the contents of a template contains tag delimiter sequences. Partials do not inherit changed delimiters from a template. Lines with a standalone delimiter tag are stripped from the output rather than leaving an empty line.

**Template**
```Text
{{greeting}}, {{=[ ]=}}[name]!
```

**Data**
```Lua
{ greeting = 'Hello', name = 'World' }
```

**Output**
```Text
Hello, World!
```
