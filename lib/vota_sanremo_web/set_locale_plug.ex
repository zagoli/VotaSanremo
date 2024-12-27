defmodule VotaSanremoWeb.SetLocalePlug do
  @behaviour Plug
  import Plug.Conn

  # language => gettext_locale
  @supported_locales %{
    "en" => "en",
    "it" => "it"
  }

  @default_locale Gettext.get_locale(VotaSanremoWeb.Gettext)

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    locale =
      get_params_locale(conn) ||
        get_session_locale(conn) ||
        get_browser_locale(conn) ||
        @default_locale

    Gettext.put_locale(VotaSanremoWeb.Gettext, locale)

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end

  @doc false
  def get_params_locale(conn) do
    conn.params["lang"] |> parse_language() |> locale_for_language()
  end

  @doc false
  def get_session_locale(conn) do
    get_session(conn, :locale) |> parse_language() |> locale_for_language()
  end

  @doc false
  def get_browser_locale(conn) do
    accept_language = Plug.Conn.get_req_header(conn, "accept-language")

    case accept_language do
      [header | _] -> parse_accept_language(header)
      _ -> nil
    end
  end

  defp parse_accept_language(header) do
    header
    |> String.split(",")
    |> Enum.map(fn language ->
      # Split the language by semicolon to handle q-values (ignored).
      # For simplicity, we ignore the q-values and assume the languages are
      # sorted in preferred order. This is what most browsers do anyway.
      # https://developer.mozilla.org/en-US/docs/Glossary/Quality_values
      [language | _] = String.split(language, ";")

      parse_language(language)
    end)
    |> Enum.find_value(&locale_for_language/1)
  end

  defp parse_language(nil), do: nil

  defp parse_language(language) when is_binary(language) do
    String.split(language, ~r/[-_]/, parts: 2) |> List.first() |> String.downcase()
  end

  defp locale_for_language(language) do
    @supported_locales[language]
  end

  def on_mount(:set_locale, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(locale)
    {:cont, Phoenix.Component.assign(socket, :locale, locale)}
  end

  def on_mount(:set_locale, _params, _session, socket) do
    {:cont, socket}
  end
end
