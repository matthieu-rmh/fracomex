defmodule Fracomex.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fracomex.Accounts.City
  alias Fracomex.Utilities

  schema "users" do
    field :firstname, :string
    field :mail_address, :string
    field :name, :string
    field :password, :string
    field :phone_number, :string
    field :street, :string
    field :country_id, :id
    # field :city_id, :id
    belongs_to :city, City
    field :is_valid, :boolean
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :firstname, :mail_address, :street, :phone_number, :password, :country_id, :city_id, :is_valid])
    |> validate_required([:name, :firstname, :mail_address, :street, :phone_number, :password, :country_id, :city_id])
  end

  def edit_oneself_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :firstname, :password])
    |> validate_required(:name, message: "Le nom ne peut être vide")
    |> validate_required(:firstname, message: "Le prénom ne peut être vide")
    |> check_if_current_password_is_entered(user, attrs)
  end

  def edit_address_changeset(user, attrs) do
    user
    |> cast(attrs, [:street, :city_id])
    |> validate_required(:street, message: "L'adresse est obligatoire")
  end

  defp check_if_current_password_is_entered(changeset, user, attrs) do
    # IO.inspect(attrs)

    cond do

      not is_nil(get_change(changeset, :password)) ->
        cond do

          is_nil(attrs["current_password"]) or attrs["current_password"] == "" ->
            changeset |> add_error(:current_password, "Entrez votre mot de passe actuel si vous voulez le changer")

          not Pbkdf2.verify_pass(attrs["current_password"], user.password) ->
            changeset |> add_error(:current_password, "Mot de passe actuel incorrect")

          is_nil(attrs["password_confirmation"]) or attrs["password_confirmation"] == "" ->
            changeset |> add_error(:password_confirmation, "Confirmez votre nouveau mot de passe")


          get_change(changeset, :password) != attrs["password_confirmation"] ->
            changeset |> add_error(:password_confirmation, "Les mots de passe doivent correspondre")

          Pbkdf2.verify_pass(get_change(changeset, :password), user.password) ->
            changeset |> add_error(:password, "Ceci est déjà votre mot de passe actuel")

          true ->
            changeset
            |> validate_format(:password, ~r/^.{6,}$/, message: "Nouveau mot de passe trop court, 6 caractères minimum")
            |> put_change(:password, Pbkdf2.hash_pwd_salt(get_change(changeset, :password)))
        end

      true ->
        changeset |> delete_change(:password)
    end
  end

  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :firstname, :mail_address, :phone_number, :password, :country_id, :city_id])
    |> validate_required(:name, message: "Entrez votre nom")
    |> validate_required(:firstname, message: "Entrez votre prénom")
    |> validate_required(:mail_address, message: "Entrez votre adresse email")
    |> validate_required(:phone_number, message: "Entrez votre téléphone")
    |> validate_required(:password, message: "Entrez mot de passe")
    |> validate_required(:country_id, message: "Sélectionnez un pays")
    |> validate_required(:city_id, message: "Sélectionnez une ville")
    |> validate_format(:mail_address, ~r/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/, message: "Format d'email non valide")
    |> unique_mail_address()
    # |> validate_format(:phone_number, ~r/^[0-9][A-Za-z0-9 -]*$/, message: "Entrez un numéro")
    |> validate_password_confirmation(attrs)
    |> validate_format(:password, ~r/^.{6,}$/, message: "Mot de passe trop court, 6 caractères minimum")
    |> hash_password()
    |> put_default_fields()
  end

  def validate_user_changeset(user) do
    user
    |> cast(%{}, [])
    |> put_change(:is_valid, true)
  end

  def signin_changeset(user, attrs) do
    user
    |> cast(attrs, [:mail_address, :password])
    |> validate_required(:mail_address, message: "Entrez votre adresse email")
    |> validate_required(:password, message: "Entrez mot de passe")
    |> check_if_mail_address_exist()
    |> check_password()
    |> check_if_account_is_valid()
    |> apply_action(:signin)
  end

  def resend_confirmation_mail_changeset(user, attrs) do
    user
    |> cast(attrs, [:mail_address])
    |> validate_required(:mail_address, message: "Entrez votre adresse email")
    |> validate_format(:mail_address, ~r<(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])>, message: "Format d'email non valide")
    |> check_if_mail_address_exist()
    |> check_if_account_is_not_already_valid()
    |> apply_action(:resend_confirmation_mail)
  end

  defp check_if_account_is_not_already_valid(changeset) do
    mail_address = get_field(changeset, :mail_address)
    list_mail_addresses = Fracomex.Repo.all(Fracomex.Accounts.User)
                          |> Enum.map(fn user ->
                            user.mail_address
                          end)
    cond do
      is_nil(mail_address) or mail_address == "" ->
        add_error(changeset, :mail_address, "Entrez votre adresse email", [validation: :required])
      mail_address not in list_mail_addresses ->
        add_error(changeset, :mail_address, "Vous n'êtes pas encore inscrit")
       Fracomex.Accounts.get_user_by_mail_address!(mail_address).is_valid ->
        add_error(changeset, :mail_address, "Ce compte a déjà été vérifié")
      true ->
        changeset
      end
  end

  defp check_if_account_is_valid(changeset) do
    mail_address = get_field(changeset, :mail_address)
    list_mail_addresses = Fracomex.Repo.all(Fracomex.Accounts.User)
                          |> Enum.map(fn user ->
                            user.mail_address
                          end)
    cond do
      is_nil(mail_address) or mail_address == "" ->
        add_error(changeset, :mail_address, "Entrez votre adresse email", [validation: :required])
      mail_address not in list_mail_addresses ->
        add_error(changeset, :mail_address, "Vous n'êtes pas encore inscrit")
      not Fracomex.Accounts.get_user_by_mail_address!(mail_address).is_valid ->
        add_error(changeset, :invalid_account, "Ce compte n'a pas encore été confirmé")
      true ->
        changeset
      end
  end

  def forgot_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:mail_address])
    |> validate_required(:mail_address, message: "Entrez votre adresse email")
    |> validate_format(:mail_address, ~r<(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])>, message: "Email non valide")
    |> check_if_mail_address_exist()
    |> apply_action(:forgot_password)
  end

  def new_password_forgotten_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required(:password, message: "Entrez nouveau mot de passe")
    |> validate_format(:password, ~r/^.{6,}$/, message: "Mot de passe trop court, 6 caractères minimum")
    |> validate_password_confirmation(attrs)
    |> check_if_old_password(user)
    |> hash_password()
  end

  defp check_if_old_password(changeset, user) do
    user_password = user.password
    change_password = get_change(changeset, :password)
    cond do
      is_nil(change_password) ->
        add_error(changeset, :password, "Entrez nouveau mot de passe", [validation: :required])
        Pbkdf2.verify_pass(change_password, user_password) ->
        add_error(changeset, :password, "Vous avez déjà utilisé ce mot de passe")
      true ->
        changeset
      end
  end

  defp check_if_mail_address_exist(changeset) do
    mail_address = get_field(changeset, :mail_address)

    list_mail_addresses = Fracomex.Repo.all(Fracomex.Accounts.User)
                          |> Enum.map(fn user ->
                            user.mail_address
                          end)
    cond do
      is_nil(mail_address) ->
        add_error(changeset, :mail_address, "Entrez votre adresse email", [validation: :required])
      mail_address not in list_mail_addresses ->
        add_error(changeset, :mail_address, "Vous n'êtes pas encore inscrit")
      true ->
        changeset
    end
  end

  defp check_password(changeset) do
    mail_address = get_field(changeset, :mail_address)
    password = get_field(changeset, :password)

    list_mail_addresses = Fracomex.Repo.all(Fracomex.Accounts.User)
    |> Enum.map(fn user ->
      user.mail_address
    end)

    cond do
      is_nil(mail_address) ->
        add_error(changeset, :mail_address, "Entrez votre adresse email", [validation: :required])
      mail_address not in list_mail_addresses ->
        add_error(changeset, :mail_address, "Vous n'êtes pas encore inscrit")
      is_nil(password) ->
        add_error(changeset, :password, "Entrez mot de passe", [validation: :required])
      not Pbkdf2.verify_pass(password, Fracomex.Accounts.get_user_by_mail_address!(mail_address).password) ->
        add_error(changeset, :password, "Mot de passe incorrect")
      true ->
        changeset
    end
  end

  defp validate_password_confirmation(changeset, attrs) do
    password = get_change(changeset, :password)
    # IO.inspect(password)
    # IO.inspect(attrs["password_confirmation"])
    cond do
      is_nil(attrs["password_confirmation"]) ->
        add_error(changeset, :password_confirmation, "Confirmez le mot de passe")
      password != attrs["password_confirmation"] ->
        add_error(changeset, :password_confirmation, "Les mots de passe doivent être identiques")
      true ->
        changeset
    end
  end

  defp hash_password(changeset) do
    pass_field = get_change(changeset, :password)
    cry = to_string(pass_field)
    encrypted = Pbkdf2.hash_pwd_salt(cry)
    put_change(changeset, :password, encrypted)
  end

  defp unique_mail_address(changeset) do
    mail_address = get_change(changeset, :mail_address)
    list_mail_addresses = Fracomex.Repo.all(Fracomex.Accounts.User)
                          |> Enum.map(fn user ->
                            user.mail_address
                          end)

    cond do
      mail_address in list_mail_addresses ->
        add_error(changeset, :mail_address, "Adresse email déjà prise")
      true ->
        changeset |> validate_format(:mail_address, ~r/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/, message: "Format d'email non valide")
    end
  end

  defp put_default_fields(changeset) do
    changeset
    |> put_change(:inserted_at, Utilities.get_remote_naive_date)
    |> put_change(:updated_at, Utilities.get_remote_naive_date)
  end

end
