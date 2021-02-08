defmodule Athasha.Auth.Tools do
  # iex(1)> :crypto.hash(:sha256, "") |> Base.encode16()
  # "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
  def encrypt(password) do
    :crypto.hash(:sha256, password) |> Base.encode16()
  end

  def encrypt_ifn_blank(password) do
    case String.trim(password) do
      "" -> ""
      _ -> encrypt(password)
    end
  end

  def nil_to_blank(nil), do: ""
  def nil_to_blank(value), do: value

  def trimmed_length(text) when is_binary(text) do
    text |> String.trim() |> String.length()
  end

  # https://en.wikipedia.org/wiki/Email_address
  def valid_email?(email) when is_binary(email) do
    len = String.length(email)
    trimlen = trimmed_length(email)
    partsWs = String.split(email)
    partsAt = String.split(email, "@")

    String.valid?(email) &&
      String.printable?(email) &&
      trimlen > 0 &&
      trimlen == len &&
      length(partsAt) == 2 &&
      length(partsWs) == 1 &&
      !String.starts_with?(email, "@") &&
      !String.ends_with?(email, "@")
  end
end
