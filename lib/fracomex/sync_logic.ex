defmodule Fracomex.SyncLogic do
  alias Fracomex.{EbpRepo, Products}
  alias Fracomex.Products.ItemFamily

  ###########  ITEM FAMILY SYNC LOGICS ###########

  # SYNCHRONISATION DES FAMILLES D'ARTICLES
  def sync_item_families do
    start = NaiveDateTime.local_now()
    IO.puts "ITEMFAMILY SYNC STARTING"
    insert_missing_item_families()
    update_item_families_diffs()
    delete_item_families()
    IO.puts "ITEMFAMILY SYNC STOPPING"
    ending = NaiveDateTime.local_now()
    IO.inspect(NaiveDateTime.diff(ending, start, :millisecond))
  end

  # SUPPRESSION DES FAMILLES N'EXISTANT PLUS SUR EBP OU NON PUBLIÉES
  def delete_item_families() do
    select_all_item_family_ids_to_be_deleted()
    |> Products.delete_item_families()
  end

  # SELECTION DE TOUS LES ID'S DE FAMILLES QUI NE SONT PLUS SUR EBP OU NON PUBLIÉES
  def select_all_item_family_ids_to_be_deleted do
    Enum.filter(select_all_item_family_ids_from_postgres(), fn id ->
      id not in select_all_item_family_ids_from_ebp()
    end)
  end

  # MISE A JOUR DES CHANGEMENTS DE VALEUR DES FAMILLES
  def update_item_families_diffs() do
    for changeset <- check_item_families_diffs() do

      if changeset.changes != %{} and changeset.valid? do
        Fracomex.Repo.update(changeset)
      end

    end
  end

  # VÉRIFICATION DES DIFFÉRENCES ENTRE LES FAMILLES POSTGRES ET EBP
  def check_item_families_diffs do
    ids = get_item_family_ids_already_inserted()

    for id <- ids do
      {:ok, result} = EbpRepo.query("SELECT Caption from ItemFamily WHERE Id='#{id}'")

      ebp_caption = result.rows |> Enum.at(0) |> Enum.at(0)
      item_family = Products.get_item_family!(id)
      ItemFamily.update_changeset(item_family, %{"caption" => ebp_caption})

    end
  end

  # TROUVER LES ID'S DE FAMILLES DÉJÀ INSÉRÉES SUR POSTGRES
  def get_item_family_ids_already_inserted do
    Enum.filter(select_all_item_family_ids_from_ebp(), fn id ->
                            id in select_all_item_family_ids_from_postgres()
                          end)
  end

  ### INSERTION DES FAMILLES MANQUANTES
  def insert_missing_item_families() do
    select_item_families_to_be_inserted()
    |> Products.insert_item_families
  end

  # SELECTION DES FAMILLES A INSÉRER
  def select_item_families_to_be_inserted do
    ids = get_item_family_ids_to_be_inserted()
    readable_ids = ids_list_to_sql_readable(ids)

    case EbpRepo.query("select Id, Caption from ItemFamily where AllowPublishOnWeb=1 and Id in #{readable_ids}") do
      {:ok, result} ->
        result.rows
      |> Enum.map(fn row -> %{item_family_id: Enum.at(row, 0), caption: Enum.at(row, 1)} end)

      _ ->
        []
    end

  end

  # CONVERSION DE LISTE D'ID'S POUR ÉTRE LUE PAR LE SCRIPT SQL
  def ids_list_to_sql_readable(ids_list) do
    ids = Enum.map(ids_list, fn id -> "\'#{id}\'" end)
    "(#{Enum.join(ids, ",")})"
  end

  # TROUVER LES ID'S DE FAMILLE MANQUANTS SUR POSTGRES
  def get_item_family_ids_to_be_inserted do
    Enum.filter(select_all_item_family_ids_from_ebp(), fn id ->
                            id not in select_all_item_family_ids_from_postgres()
                          end)
  end

  # SELECTION DE TOUS LES ID'S DE FAMILLE VENANT DE LA BASE POSTGRES DU SITE
  def select_all_item_family_ids_from_postgres do
    Products.list_item_family_ids()
  end

  # SELECTION DE TOUS LES ID'S DE FAMILLE VENANT DE LA BASE EBP
  def select_all_item_family_ids_from_ebp do
    {:ok, result} = EbpRepo.query("select Id from ItemFamily where AllowPublishOnWeb=1")
    result.rows |> Enum.map(fn result_row ->
      Enum.at(result_row, 0)
    end)
  end

end
