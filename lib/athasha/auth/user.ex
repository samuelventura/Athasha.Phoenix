defmodule Athasha.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Athasha.Auth.Tools

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :origin, :string
    field :confirmed, :boolean

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :origin, :confirmed])
    |> validate_name()
    |> validate_email()
    |> validate_password()
    |> validate_origin()
    |> validate_confirmed()
    |> unique_constraint(:name, message: "Name has already been taken")
    |> unique_constraint(:email, message: "Email has already been taken")
  end

  def validate_name(changeset) do
    value = get_field(changeset, :name) |> nil_to_blank
    trimlen = trimmed_length(value)
    len = String.length(value)
    blank = trimlen == 0
    tooLarge = len > 16

    case {blank, tooLarge} do
      {true, _} -> add_error(changeset, :name, "A non empty unique name is required")
      {_, true} -> add_error(changeset, :name, "Name maximum length is 16 characters")
      _ -> changeset
    end
  end

  def validate_email(changeset) do
    value = get_field(changeset, :email) |> nil_to_blank
    trimlen = trimmed_length(value)
    blank = trimlen == 0
    valid = valid_email?(value)

    case {blank, valid} do
      {true, _} -> add_error(changeset, :email, "A non empty unique email is required")
      {_, false} -> add_error(changeset, :email, "Invalid email address format")
      _ -> changeset
    end
  end

  def validate_password(changeset) do
    value = get_field(changeset, :password) |> nil_to_blank
    trimlen = trimmed_length(value)
    len = String.length(value)
    blank = trimlen == 0
    len64 = len == 64

    case {blank, len64} do
      {true, _} -> add_error(changeset, :password, "Password cannot be blank")
      {_, false} -> add_error(changeset, :password, ":password must be 64 chars long")
      _ -> changeset
    end
  end

  def validate_origin(changeset) do
    value = get_field(changeset, :origin) |> nil_to_blank
    trimlen = trimmed_length(value)
    blank = trimlen == 0

    case {blank} do
      {true} -> add_error(changeset, :origin, ":origin must be non empty")
      _ -> changeset
    end
  end

  def validate_confirmed(changeset) do
    value = get_field(changeset, :confirmed)

    case {value} do
      {true} -> changeset
      {false} -> changeset
      _ -> add_error(changeset, :confirmed, ":confirmed must be boolean")
    end
  end
end
