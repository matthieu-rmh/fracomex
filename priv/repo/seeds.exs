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
