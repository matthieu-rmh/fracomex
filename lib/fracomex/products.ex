defmodule Fracomex.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Fracomex.Repo

  alias Fracomex.Products.{Item, Family, SubFamily}
  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    family_caption = from f in Family
    sub_family_caption = from sf in SubFamily

    query = from i in Item,
            preload: [family: ^family_caption, sub_family: ^sub_family_caption]

    Repo.all(query)
  end

  def list_items_paginate(params, sort) do
    case sort do
       "1" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [asc: i.sale_price_vat_excluded]

        Repo.paginate(query, params)
      "2" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [desc: i.sale_price_vat_excluded]

        Repo.paginate(query, params)

      "3" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [desc: i.id]

        Repo.paginate(query, params)

      "4" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                where: i.real_stock > 0,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption]
        Repo.paginate(query, params)

      _ ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption]

        Repo.paginate(query, params)
    end
  end

  def list_items_arrival do
    family_query = from f in Family
    sub_family_query = from sf in SubFamily

    query = from i in Item,
            preload: [family: ^family_query, sub_family: ^sub_family_query],
            limit: 8
    Repo.all(query)
  end

  def list_item_ids do
    query = from i in Item,
            select: i.id
    Repo.all(query)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  def get_item_with_its_family_and_sub_family!(id) do
    family_query = from f in Family
    sub_family_query = from sf in SubFamily

    query = from i in Item,
            preload: [family: ^family_query, sub_family: ^sub_family_query],
            where: i.id == ^id

    Repo.one(query)
  end

  # Function de filtre de tous les produits
  def filter_items(tri) do
    case tri do
      "1" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [asc: i.sale_price_vat_excluded]

        Repo.paginate(query)
      "2" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [desc: i.sale_price_vat_excluded]

        Repo.paginate(query)

      "3" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [desc: i.id]

        Repo.paginate(query)

      "4" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                where: i.real_stock > 0,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption]

        Repo.paginate(query)

      _ ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption]

        Repo.paginate(query)
    end
  end

  def filter_items_by_family_and_sub_family(tri, family_caption, sub_family_caption) do
    family_id = get_family_id_by_caption!(family_caption)
    sub_family_id = get_sub_family_id_by_caption!(sub_family_caption)

    case tri do
      "1" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [asc: i.sale_price_vat_excluded]

        Repo.paginate(query)
      "2" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [desc: i.sale_price_vat_excluded]

        Repo.paginate(query)

      "3" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption],
                order_by: [desc: i.id]

        Repo.paginate(query)

      "4" ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id and i.real_stock > 0,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption]

        Repo.paginate(query)

      _ ->
        family_caption = from f in Family
        sub_family_caption = from sf in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_caption, sub_family: ^sub_family_caption]

        Repo.paginate(query)
    end
  end

  # Recherche des produits par nom
  def search_item(search) do
    search_term = "%#{search}%"

    family_query = from f in Family
    sub_family_query = from f in SubFamily

    query =
      from i in Item,
      where: ilike(i.caption, ^search_term),
      preload: [family: ^family_query, sub_family: ^sub_family_query]

    Repo.paginate(query)
  end

  def get_item_with_family_and_sub_family!(id) do
    family_query = from f in Family
    sub_family_query = from f in SubFamily

    query = from i in Item,
            where: i.id == ^id,
            preload: [family: ^family_query, sub_family: ^sub_family_query]
    Repo.one(query)
  end

  def get_item_by_sub_family!(id, params) do
    family_query = from f in Family
    sub_family_query = from f in SubFamily

    query = from i in Item,
            where: i.sub_family_id == ^id,
            preload: [family: ^family_query, sub_family: ^sub_family_query]
    Repo.paginate(query, params)
  end

  # Récupérer les articles ayant une famille et sous-famille correspondante
  def get_item_by_family_and_sub_family!(sort, family_id, sub_family_id, params) do
    case sort do
      "1" ->
        family_query = from f in Family
        sub_family_query = from f in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_query, sub_family: ^sub_family_query],
                order_by: [asc: i.sale_price_vat_excluded]

        Repo.paginate(query, params)

      "2" ->
        family_query = from f in Family
        sub_family_query = from f in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_query, sub_family: ^sub_family_query],
                order_by: [desc: i.sale_price_vat_excluded]

        Repo.paginate(query, params)

      "3" ->
        family_query = from f in Family
        sub_family_query = from f in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_query, sub_family: ^sub_family_query],
                order_by: [desc: i.id]

        Repo.paginate(query, params)

      "4" ->
        family_query = from f in Family
        sub_family_query = from f in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id and i.real_stock > 0,
                preload: [family: ^family_query, sub_family: ^sub_family_query]
        Repo.paginate(query, params)

      _ ->
        family_query = from f in Family
        sub_family_query = from f in SubFamily

        query = from i in Item,
                where: i.family_id == ^family_id and i.sub_family_id == ^sub_family_id,
                preload: [family: ^family_query, sub_family: ^sub_family_query]

        Repo.paginate(query, params)
    end
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def insert_items(list) do
    Repo.insert_all(Item, list)
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def delete_items(ids) do
    query = from item in Item,
            where: item.id in ^ids
    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end



  @doc """
  Returns the list of item_families.

  ## Examples

      iex> list_item_families()
      [%ItemFamily{}, ...]

  """
  def list_families do
    Repo.all(Family)
  end

  # Ne pas paginer les familles
  def list_families_paginate do
    query = from f in Family,
            preload: [:sub_families]

    Repo.all(query)
  end

  # Récupérer les familles et sous-familles par l'id de la famille
  def list_paginate_families_by_family!(family_id) do
    query = from f in Family,
            where: f.id == ^family_id,
            preload: [:sub_families]

    Repo.paginate(query)
  end

  def list_limited_families do
    query = from f in Family,
            limit: 5
    Repo.all(query)
  end

  def list_families_with_subs do
    query = from f in Family,
            preload: [:sub_families]

    Repo.all(query)
  end

  def list_family_ids do
    query = from family in Family,
            select: family.id
    Repo.all(query)
  end

  @doc """
  Gets a single item_family.

  Raises `Ecto.NoResultsError` if the Item family does not exist.

  ## Examples

      iex> get_item_family!(123)
      %ItemFamily{}

      iex> get_item_family!(456)
      ** (Ecto.NoResultsError)

  """
  def get_family!(id), do: Repo.get!(Family, id)

  # Récupérer l'id de la famille depuis family_caption
  def get_family_id_by_caption!(family_caption) do
    query = from f in Family,
            where: f.caption == ^family_caption,
            select: f.id
    Repo.one(query)
  end

  def get_family_with_its_subs!(id) do
      query = from family in Family,
              where: family.id == ^id,
              preload: [:sub_families]

      Repo.one(query)
  end

  def _family_caption!(id) do
    query = from family in Family,
            where: family.id == ^id,
            select: family.caption
    Repo.one(query)
  end
  @doc """
  Creates a item_family.

  ## Examples

      iex> create_item_family(%{field: value})
      {:ok, %ItemFamily{}}

      iex> create_item_family(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_family(attrs \\ %{}) do
    %Family{}
    |> Family.changeset(attrs)
    |> Repo.insert()
  end

  def insert_families(list) do
    Repo.insert_all(Family, list)
  end

  @doc """
  Updates a item_family.

  ## Examples

      iex> update_item_family(item_family, %{field: new_value})
      {:ok, %ItemFamily{}}

      iex> update_item_family(item_family, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_family(%Family{} = item_family, attrs) do
    item_family
    |> Family.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item_family.

  ## Examples

      iex> delete_item_family(item_family)
      {:ok, %ItemFamily{}}

      iex> delete_item_family(item_family)
      {:error, %Ecto.Changeset{}}

  """
  def delete_family(%Family{} = family) do
    Repo.delete(family)
  end

  def delete_families(ids) do
    query = from family in Family,
            where: family.id in ^ids
    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_family changes.

  ## Examples

      iex> change_item_family(item_family)
      %Ecto.Changeset{data: %ItemFamily{}}

  """
  def change_family(%Family{} = family, attrs \\ %{}) do
    Family.changeset(family, attrs)
  end



  @doc """
  Returns the list of item_sub_families.

  ## Examples

      iex> list_item_sub_families()
      [%ItemSubFamily{}, ...]

  """
  def list_sub_families do
    Repo.all(SubFamily)
  end

  def list_sub_family_ids do
    query = from sub_family in SubFamily,
            select: sub_family.id
    Repo.all(query)
  end

  @doc """
  Gets a single item_sub_family.

  Raises `Ecto.NoResultsError` if the Item sub family does not exist.

  ## Examples

      iex> get_item_sub_family!(123)
      %ItemSubFamily{}

      iex> get_item_sub_family!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sub_family!(id), do: Repo.get!(SubFamily, id)

  # Récupérer l'id de la sous-famille depuis sub_family_caption
  def get_sub_family_id_by_caption!(sub_family_caption) do
    query = from sf in SubFamily,
            where: sf.caption == ^sub_family_caption,
            select: sf.id
    Repo.one(query)
  end

  # Récuperer la sous-famille par l'id de la famille
  def get_sub_family_by_family!(family_id, params) do
    query = from sf in SubFamily,
            where: sf.family_id == ^family_id

    Repo.paginate(query, params)
  end

  @doc """
  Creates a item_sub_family.

  ## Examples

      iex> create_item_sub_family(%{field: value})
      {:ok, %ItemSubFamily{}}

      iex> create_item_sub_family(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sub_family(attrs \\ %{}) do
    %SubFamily{}
    |> SubFamily.changeset(attrs)
    |> Repo.insert()
  end

  def insert_sub_families(list) do
    Repo.insert_all(SubFamily, list)
  end

  @doc """
  Updates a item_sub_family.

  ## Examples

      iex> update_item_sub_family(item_sub_family, %{field: new_value})
      {:ok, %ItemSubFamily{}}

      iex> update_item_sub_family(item_sub_family, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_sub_family(%SubFamily{} = sub_family, attrs) do
    sub_family
    |> SubFamily.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item_sub_family.

  ## Examples

      iex> delete_item_sub_family(item_sub_family)
      {:ok, %ItemSubFamily{}}

      iex> delete_item_sub_family(item_sub_family)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sub_family(%SubFamily{} = sub_family) do
    Repo.delete(sub_family)
  end

  def delete_sub_families(ids) do
    query = from sub_family in SubFamily,
            where: sub_family.id in ^ids
    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_sub_family changes.

  ## Examples

      iex> change_item_sub_family(item_sub_family)
      %Ecto.Changeset{data: %ItemSubFamily{}}

  """
  def change_item_sub_family(%SubFamily{} = sub_family, attrs \\ %{}) do
    SubFamily.changeset(sub_family, attrs)
  end
end
