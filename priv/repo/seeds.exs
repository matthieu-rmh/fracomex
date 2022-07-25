# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fracomex.Repo.insert!(%Fracomex.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Fracomex.Accounts
alias Fracomex.Accounts.{Country, City}

Fracomex.Repo.insert!(%Country{name: "Mayotte"})
Fracomex.Repo.insert!(%City{name: "Koungou", zipcode: "97600"})
Fracomex.Repo.insert!(%City{name: "Mamoudzou", zipcode: "97600"})
Fracomex.Repo.insert!(%City{name: "Dzaoudzi", zipcode: "97610"})
Fracomex.Repo.insert!(%City{name: "Pamandzi", zipcode: "97610"})
Fracomex.Repo.insert!(%City{name: "Bandrélé", zipcode: "97620"})
Fracomex.Repo.insert!(%City{name: "Bouéni", zipcode: "97620"})
Fracomex.Repo.insert!(%City{name: "Chirongui", zipcode: "97620"})
Fracomex.Repo.insert!(%City{name: "Kani-Kéli", zipcode: "97625"})
Fracomex.Repo.insert!(%City{name: "Acoua", zipcode: "97630"})
Fracomex.Repo.insert!(%City{name: "Mtsamboro", zipcode: "97630"})
Fracomex.Repo.insert!(%City{name: "Sada", zipcode: "97640"})
Fracomex.Repo.insert!(%City{name: "Bandraboua", zipcode: "97650"})
Fracomex.Repo.insert!(%City{name: "M'tsangamouji", zipcode: "97650"})
Fracomex.Repo.insert!(%City{name: "Dembéni", zipcode: "97660"})
Fracomex.Repo.insert!(%City{name: "Chiconi", zipcode: "97670"})
Fracomex.Repo.insert!(%City{name: "Ouangani", zipcode: "97670"})
Fracomex.Repo.insert!(%City{name: "Tsingoni", zipcode: "97680"})

alias Fracomex.Products.{Item, ItemFamily, ItemSubFamily}

items = [
  %Item{
    item_id: "00110",
    caption: "Legrand - Conduit cintrable ICTA 3522 Rai'Gliss Ø110mm  -  noir à bandes grises",
    sale_price_vat_excluded: 21.72000000,
    item_image: "/images/slider1.png",
    image_version: 0,
    real_stock: 0.00,
    stock_status: false,
    item_family_id: "",
    item_sub_family_id: ""
  },
  %Item{
    item_id: "00005",
    caption: "Legrand - Goulotte gaine de protection GP 100 GS dimensions 100x73x135mm",
    sale_price_vat_excluded: 54.37000000,
    item_image: "/images/slider2.png",
    image_version: 0,
    real_stock: 0.00,
    stock_status: false,
    item_family_id: "",
    item_sub_family_id: ""
  },
  %Item{
    item_id: "510136",
    caption: "PINCEAU ROND 28MM",
    sale_price_vat_excluded: 5.00000000,
    item_image: "/images/slider3.png",
    image_version: 0,
    real_stock: 0.00,
    stock_status: false,
    item_family_id: "",
    item_sub_family_id: ""
  }
]

# items_families = [
#   %ItemFamily{
#     item_family_id: "",
#     caption: "Gaine de protection"
#   },
#   %ItemFamily{
#     item_family_id: "",
#     caption: "Conduits"
#   },
#   %ItemFamily{
#     item_family_id: "",
#     caption: "Pinceaux"
#   }
# ]

items_sub_families = [
  %ItemSubFamily{
    item_sub_family_id: "",
    caption: "Gaine de protection GP",
    item_family_id: ""
  },
  %ItemSubFamily{
    item_sub_family_id: "",
    caption: "Conduit cintrable",
    item_family_id: ""
  },
  %ItemSubFamily{
    item_sub_family_id: "",
    caption: "Pinceaux ronds",
    item_family_id: ""
  }
]

for item <- items do
  Fracomex.Repo.insert!(item)
end

# for item_family <- items_families do
#   Fracomex.Repo.insert!(item_family)
# end

for item_sub_family <- items_sub_families do
  Fracomex.Repo.insert!(item_sub_family)
end
