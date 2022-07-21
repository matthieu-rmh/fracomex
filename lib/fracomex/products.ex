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
    Repo.all(Item)
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
