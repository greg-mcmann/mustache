return {
  {
    name = "Inline",
    desc = "Comment blocks should be removed from the template.",
    data = {},
    template = "12345{{! Comment Block! }}67890",
    expected = "1234567890"
  },
  {
    name = "Multiline",
    desc = "Multiline comments should be permitted.",
    data = {},
    template = "12345{{!\n  This is a\n  multi-line comment...\n}}67890\n",
    expected = "1234567890\n"
  },
  {
    name = "Standalone",
    desc = "All standalone comment lines should be removed.",
    data = {},
    template = "Begin.\n{{! Comment Block! }}\nEnd.\n",
    expected = "Begin.\nEnd.\n"
  },
  {
    name = "Indented Standalone",
    desc = "All standalone comment lines should be removed.",
    data = {},
    template = "Begin.\n  {{! Indented Comment Block! }}\nEnd.\n",
    expected = "Begin.\nEnd.\n"
  },
  {
    name = "Standalone Line Endings",
    desc = "\"\\r\\n\" should be considered a newline for standalone tags.",
    data = {},
    template = "|\r\n{{! Standalone Comment }}\r\n|",
    expected = "|\r\n|"
  },
  {
    name = "Standalone Without Previous Line",
    desc = "Standalone tags should not require a newline to precede them.",
    data = {},
    template = "  {{! I'm Still Standalone }}\n!",
    expected = "!"
  },
  {
    name = "Standalone Without Newline",
    desc = "Standalone tags should not require a newline to follow them.",
    data = {},
    template = "!\n  {{! I'm Still Standalone }}",
    expected = "!\n"
  },
  {
    name = "Multiline Standalone",
    desc = "All standalone comment lines should be removed.",
    data = {},
    template = "Begin.\n{{!\nSomething's going on here...\n}}\nEnd.\n",
    expected = "Begin.\nEnd.\n"
  },
  {
    name = "Indented Multiline Standalone",
    desc = "All standalone comment lines should be removed.",
    data = {},
    template = "Begin.\n  {{!\n    Something's going on here...\n  }}\nEnd.\n",
    expected = "Begin.\nEnd.\n"
  },
  {
    name = "Indented Inline",
    desc = "Inline comments should not strip whitespace",
    data = {},
    template = "  12 {{! 34 }}\n",
    expected = "  12 \n"
  },
  {
    name = "Surrounding Whitespace",
    desc = "Comment removal should preserve surrounding whitespace.",
    data = {},
    template = "12345 {{! Comment Block! }} 67890",
    expected = "12345  67890"
  },
  {
    name = "Variable Name Collision",
    desc = "Comments must never render, even if variable with same name exists.",
    data = {
      ["! comment"] = 1,
      ["! comment "] = 2,
      ["!comment"] = 3,
      ["comment"] = 4
    },
    template = "comments never show: >{{! comment }}<",
    expected = "comments never show: ><"
  }
}