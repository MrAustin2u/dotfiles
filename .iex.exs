import_if_available(Ecto.Query)

defmodule IExHelpers do
  def whats_this?(term) when is_nil(term), do: "Type: Nil"
  def whats_this?(term) when is_binary(term), do: "Type: Binary"
  def whats_this?(term) when is_boolean(term), do: "Type: Boolean"
  def whats_this?(term) when is_atom(term), do: "Type: Atom"
  def whats_this?(_term), do: "Type: Unknown"
end

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
      # ANSI CHA, move cursor to column 1
      "\e[G",
      :light_magenta,
      # plain string
      "🧪 iex",
      ">",
      :white,
      :reset
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
)
