return {
  {
    name = "No Interpolation",
    desc = "Mustache-free templates should render as-is.",
    data = {},
    template = "Hello from {Mustache}!\n",
    expected = "Hello from {Mustache}!\n"
  },
  {
    name = "Basic Interpolation",
    desc = "Unadorned tags should interpolate content into the template.",
    data = {
      subject = "world"
    },
    template = "Hello, {{subject}}!\n",
    expected = "Hello, world!\n"
  },
  {
    name = "HTML Escaping",
    desc = "Basic interpolation should be HTML escaped.",
    data = {
      forbidden = "& \" < >"
    },
    template = "These characters should be HTML escaped: {{forbidden}}\n",
    expected = "These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
  },
  {
    name = "Triple Mustache",
    desc = "Triple mustaches should interpolate without HTML escaping.",
    data = {
      forbidden = "& \" < >"
    },
    template = "These characters should not be HTML escaped: {{{forbidden}}}\n",
    expected = "These characters should not be HTML escaped: & \" < >\n"
  },
  {
    name = "Ampersand",
    desc = "Ampersand should interpolate without HTML escaping.",
    data = {
      forbidden = "& \" < >"
    },
    template = "These characters should not be HTML escaped: {{&forbidden}}\n",
    expected = "These characters should not be HTML escaped: & \" < >\n"
  },
  {
    name = "Basic Integer Interpolation",
    desc = "Integers should interpolate seamlessly.",
    data = {
      mph = 85
    },
    template = "\"{{mph}} miles an hour!\"",
    expected = "\"85 miles an hour!\""
  },
  {
    name = "Triple Mustache Integer Interpolation",
    desc = "Integers should interpolate seamlessly.",
    data = {
      mph = 85
    },
    template = "\"{{{mph}}} miles an hour!\"",
    expected = "\"85 miles an hour!\""
  },
  {
    name = "Ampersand Integer Interpolation",
    desc = "Integers should interpolate seamlessly.",
    data = {
      mph = 85
    },
    template = "\"{{&mph}} miles an hour!\"",
    expected = "\"85 miles an hour!\""
  },
  {
    name = "Basic Decimal Interpolation",
    desc = "Decimals should interpolate seamlessly with proper significance.",
    data = {
      power = 1.21
    },
    template = "\"{{power}} jiggawatts!\"",
    expected = "\"1.21 jiggawatts!\""
  },
  {
    name = "Triple Mustache Decimal Interpolation",
    desc = "Decimals should interpolate seamlessly with proper significance.",
    data = {
      power = 1.21
    },
    template = "\"{{{power}}} jiggawatts!\"",
    expected = "\"1.21 jiggawatts!\""
  },
  {
    name = "Ampersand Decimal Interpolation",
    desc = "Decimals should interpolate seamlessly with proper significance.",
    data = {
      power = 1.21
    },
    template = "\"{{&power}} jiggawatts!\"",
    expected = "\"1.21 jiggawatts!\""
  },
  {
    name = "Basic Null Interpolation",
    desc = "Nulls should interpolate as the empty string.",
    data = {
      cannot = nil
    },
    template = "I ({{cannot}}) be seen!",
    expected = "I () be seen!"
  },
  {
    name = "Triple Mustache Null Interpolation",
    desc = "Nulls should interpolate as the empty string.",
    data = {
      cannot = nil
    },
    template = "I ({{{cannot}}}) be seen!",
    expected = "I () be seen!"
  },
  {
    name = "Ampersand Null Interpolation",
    desc = "Nulls should interpolate as the empty string.",
    data = {
      cannot = nil
    },
    template = "I ({{&cannot}}) be seen!",
    expected = "I () be seen!"
  },
  {
    name = "Basic Context Miss Interpolation",
    desc = "Failed context lookups should default to empty strings.",
    data = {},
    template = "I ({{cannot}}) be seen!",
    expected = "I () be seen!"
  },
  {
    name = "Triple Mustache Context Miss Interpolation",
    desc = "Failed context lookups should default to empty strings.",
    data = {},
    template = "I ({{{cannot}}}) be seen!",
    expected = "I () be seen!"
  },
  {
    name = "Ampersand Context Miss Interpolation",
    desc = "Failed context lookups should default to empty strings.",
    data = {},
    template = "I ({{&cannot}}) be seen!",
    expected = "I () be seen!"
  },
  {
    name = "Dotted Names - Basic Interpolation",
    desc = "Dotted names should be considered a form of shorthand for sections.",
    data = {
      person = {
        name = "Joe"
      }
    },
    template = "\"{{person.name}}\" == \"{{#person}}{{name}}{{/person}}\"",
    expected = "\"Joe\" == \"Joe\""
  },
  {
    name = "Dotted Names - Triple Mustache Interpolation",
    desc = "Dotted names should be considered a form of shorthand for sections.",
    data = {
      person = {
        name = "Joe"
      }
    },
    template = "\"{{{person.name}}}\" == \"{{#person}}{{{name}}}{{/person}}\"",
    expected = "\"Joe\" == \"Joe\""
  },
  {
    name = "Dotted Names - Ampersand Interpolation",
    desc = "Dotted names should be considered a form of shorthand for sections.",
    data = {
      person = {
        name = "Joe"
      }
    },
    template = "\"{{&person.name}}\" == \"{{#person}}{{&name}}{{/person}}\"",
    expected = "\"Joe\" == \"Joe\""
  },
  {
    name = "Dotted Names - Arbitrary Depth",
    desc = "Dotted names should be functional to any level of nesting.",
    data = {
      a = {
        b = {
          c = {
            d = {
              e = {
                name = "Phil"
              }
            }
          }
        }
      }
    },
    template = "\"{{a.b.c.d.e.name}}\" == \"Phil\"",
    expected = "\"Phil\" == \"Phil\""
  },
  {
    name = "Dotted Names - Broken Chains",
    desc = "Any falsey value prior to the last part of the name should yield ''.",
    data = {
      a = {
      }
    },
    template = "\"{{a.b.c}}\" == \"\"",
    expected = "\"\" == \"\""
  },
  {
    name = "Dotted Names - Broken Chain Resolution",
    desc = "Each part of a dotted name should resolve only against its parent.",
    data = {
      a = {
        b = {
        }
      },
      c = {
        name = "Jim"
      }
    },
    template = "\"{{a.b.c.name}}\" == \"\"",
    expected = "\"\" == \"\""
  },
  {
    name = "Dotted Names - Initial Resolution",
    desc = "The first part of a dotted name should resolve as any other name.",
    data = {
      a = {
        b = {
          c = {
            d = {
              e = {
                name = "Phil"
              }
            }
          }
        }
      },
      b = {
        c = {
          d = {
            e = {
              name = "Wrong"
            }
          }
        }
      }
    },
    template = "\"{{#a}}{{b.c.d.e.name}}{{/a}}\" == \"Phil\"",
    expected = "\"Phil\" == \"Phil\""
  },
  {
    name = "Dotted Names - Context Precedence",
    desc = "Dotted names should be resolved against former resolutions.",
    data = {
      a = {
        b = {}
      },
      b = {
        c = "ERROR"
      }
    },
    template = "{{#a}}{{b.c}}{{/a}}",
    expected = ""
  },
  {
    name = "Implicit Iterators - Basic Interpolation",
    desc = "Unadorned tags should interpolate content into the template.",
    data = "world",
    template = "Hello, {{.}}!\n",
    expected = "Hello, world!\n"
  },
  {
    name = "Implicit Iterators - HTML Escaping",
    desc = "Basic interpolation should be HTML escaped.",
    data = "& \" < >",
    template = "These characters should be HTML escaped: {{.}}\n",
    expected = "These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
  },
  {
    name = "Implicit Iterators - Triple Mustache",
    desc = "Triple mustaches should interpolate without HTML escaping.",
    data = "& \" < >",
    template = "These characters should not be HTML escaped: {{{.}}}\n",
    expected = "These characters should not be HTML escaped: & \" < >\n"
  },
  {
    name = "Implicit Iterators - Ampersand",
    desc = "Ampersand should interpolate without HTML escaping.",
    data = "& \" < >",
    template = "These characters should not be HTML escaped: {{&.}}\n",
    expected = "These characters should not be HTML escaped: & \" < >\n"
  },
  {
    name = "Implicit Iterators - Basic Integer Interpolation",
    desc = "Integers should interpolate seamlessly.",
    data = 85,
    template = "\"{{.}} miles an hour!\"",
    expected = "\"85 miles an hour!\""
  },
  {
    name = "Interpolation - Surrounding Whitespace",
    desc = "Interpolation should not alter surrounding whitespace.",
    data = {
      string = "---"
    },
    template = "| {{string}} |",
    expected = "| --- |"
  },
  {
    name = "Triple Mustache - Surrounding Whitespace",
    desc = "Interpolation should not alter surrounding whitespace.",
    data = {
      string = "---"
    },
    template = "| {{{string}}} |",
    expected = "| --- |"
  },
  {
    name = "Ampersand - Surrounding Whitespace",
    desc = "Interpolation should not alter surrounding whitespace.",
    data = {
      string = "---"
    },
    template = "| {{&string}} |",
    expected = "| --- |"
  },
  {
    name = "Interpolation - Standalone",
    desc = "Standalone interpolation should not alter surrounding whitespace.",
    data = {
      string = "---"
    },
    template = "  {{string}}\n",
    expected = "  ---\n"
  },
  {
    name = "Triple Mustache - Standalone",
    desc = "Standalone interpolation should not alter surrounding whitespace.",
    data = {
      string = "---"
    },
    template = "  {{{string}}}\n",
    expected = "  ---\n"
  },
  {
    name = "Ampersand - Standalone",
    desc = "Standalone interpolation should not alter surrounding whitespace.",
    data = {
      string = "---"
    },
    template = "  {{&string}}\n",
    expected = "  ---\n"
  },
  {
    name = "Interpolation With Padding",
    desc = "Superfluous in-tag whitespace should be ignored.",
    data = {
      string = "---"
    },
    template = "|{{ string }}|",
    expected = "|---|"
  },
  {
    name = "Triple Mustache With Padding",
    desc = "Superfluous in-tag whitespace should be ignored.",
    data = {
      string = "---"
    },
    template = "|{{{ string }}}|",
    expected = "|---|"
  },
  {
    name = "Ampersand With Padding",
    desc = "Superfluous in-tag whitespace should be ignored.",
    data = {
      string = "---"
    },
    template = "|{{& string }}|",
    expected = "|---|"
  }
}