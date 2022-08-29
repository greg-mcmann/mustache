return {
  {
    name = "Falsey",
    desc = "Falsey sections should have their contents rendered.",
    data = {
      boolean = false
    },
    template = "\"{{^boolean}}This should be rendered.{{/boolean}}\"",
    expected = "\"This should be rendered.\""
  },
  {
    name = "Truthy",
    desc = "Truthy sections should have their contents omitted.",
    data = {
      boolean = true
    },
    template = "\"{{^boolean}}This should not be rendered.{{/boolean}}\"",
    expected = "\"\""
  },
  {
    name = "Null is falsey",
    desc = "Null is falsey.",
    data = {
      null = nil
    },
    template = "\"{{^null}}This should be rendered.{{/null}}\"",
    expected = "\"This should be rendered.\""
  },
  {
    name = "Context",
    desc = "Objects and hashes should behave like truthy values.",
    data = {
      context = {
        name = "Joe"
      }
    },
    template = "\"{{^context}}Hi {{name}}.{{/context}}\"",
    expected = "\"\""
  },
  {
    name = "List",
    desc = "Lists should behave like truthy values.",
    data = {
      list = {
        {
          n = 1
        },
        {
          n = 2
        },
        {
          n = 3
        }
      }
    },
    template = "\"{{^list}}{{n}}{{/list}}\"",
    expected = "\"\""
  },
  {
    name = "Empty List",
    desc = "Empty lists should behave like falsey values.",
    data = {
      list = {}
    },
    template = "\"{{^list}}Yay lists!{{/list}}\"",
    expected = "\"Yay lists!\""
  },
  {
    name = "Doubled",
    desc = "Multiple inverted sections per template should be permitted.",
    data = {
      bool = false,
      two = "second"
    },
    template = "{{^bool}}\n* first\n{{/bool}}\n* {{two}}\n{{^bool}}\n* third\n{{/bool}}\n",
    expected = "* first\n* second\n* third\n"
  },
  {
    name = "Nested (Falsey)",
    desc = "Nested falsey sections should have their contents rendered.",
    data = {
      bool = false
    },
    template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |",
    expected = "| A B C D E |"
  },
  {
    name = "Nested (Truthy)",
    desc = "Nested truthy sections should be omitted.",
    data = {
      bool = true
    },
    template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |",
    expected = "| A  E |"
  },
  {
    name = "Context Misses",
    desc = "Failed context lookups should be considered falsey.",
    data = {},
    template = "[{{^missing}}Cannot find key 'missing'!{{/missing}}]",
    expected = "[Cannot find key 'missing'!]"
  },
  {
    name = "Dotted Names - Truthy",
    desc = "Dotted names should be valid for Inverted Section tags.",
    data = {
      a = {
        b = {
          c = true
        }
      }
    },
    template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"\"",
    expected = "\"\" == \"\""
  },
  {
    name = "Dotted Names - Falsey",
    desc = "Dotted names should be valid for Inverted Section tags.",
    data = {
      a = {
        b = {
          c = false
        }
      }
    },
    template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\"",
    expected = "\"Not Here\" == \"Not Here\""
  },
  {
    name = "Dotted Names - Broken Chains",
    desc = "Dotted names that cannot be resolved should be considered falsey.",
    data = {
      a = {}
    },
    template = "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\"",
    expected = "\"Not Here\" == \"Not Here\""
  },
  {
    name = "Surrounding Whitespace",
    desc = "Inverted sections should not alter surrounding whitespace.",
    data = {
      boolean = false
    },
    template = " | {{^boolean}}\t|\t{{/boolean}} | \n",
    expected = " | \t|\t | \n"
  },
  {
    name = "Internal Whitespace",
    desc = "Inverted should not alter internal whitespace.",
    data = {
      boolean = false
    },
    template = " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n",
    expected = " |  \n  | \n"
  },
  {
    name = "Indented Inline Sections",
    desc = "Single-line sections should not alter surrounding whitespace.",
    data = {
      boolean = false
    },
    template = " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n",
    expected = " NO\n WAY\n"
  },
  {
    name = "Standalone Lines",
    desc = "Standalone lines should be removed from the template.",
    data = {
      boolean = false
    },
    template = "| This Is\n{{^boolean}}\n|\n{{/boolean}}\n| A Line\n",
    expected = "| This Is\n|\n| A Line\n"
  },
  {
    name = "Standalone Indented Lines",
    desc = "Standalone indented lines should be removed from the template.",
    data = {
      boolean = false
    },
    template = "| This Is\n  {{^boolean}}\n|\n  {{/boolean}}\n| A Line\n",
    expected = "| This Is\n|\n| A Line\n"
  },
  {
    name = "Standalone Line Endings",
    desc = "\"\\r\\n\" should be considered a newline for standalone tags.",
    data = {
      boolean = false
    },
    template = "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|",
    expected = "|\r\n|"
  },
  {
    name = "Standalone Without Previous Line",
    desc = "Standalone tags should not require a newline to precede them.",
    data = {
      boolean = false
    },
    template = "  {{^boolean}}\n^{{/boolean}}\n/",
    expected = "^\n/"
  },
  {
    name = "Standalone Without Newline",
    desc = "Standalone tags should not require a newline to follow them.",
    data = {
      boolean = false
    },
    template = "^{{^boolean}}\n/\n  {{/boolean}}",
    expected = "^\n/\n"
  },
  {
    name = "Padding",
    desc = "Superfluous in-tag whitespace should be ignored.",
    data = {
      boolean = false
    },
    template = "|{{^ boolean }}={{/ boolean }}|",
    expected = "|=|"
  }
}