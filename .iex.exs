import_if_available(Ecto.Query)

IEx.configure(
  inspect: [limit: :infinity, pretty: true],
  colors: [
    syntax_colors: [
      number: :light_yellow,
      atom: :light_cyan,
      string: :white,
      boolean: [:light_blue],
      nil: [:magenta, :bright]
    ],
    ls_directory: :cyan,
    ls_device: :yellow,
    doc_code: :green,
    doc_inline_code: :magenta,
    doc_headings: [:cyan, :underline],
    doc_title: [:cyan, :bright, :underline]
  ],
  default_prompt:
    [
      :light_magenta,
      "🧪 iex",
      ">",
      :white,
      :reset
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
)
