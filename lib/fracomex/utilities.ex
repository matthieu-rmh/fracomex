defmodule Fracomex.Utilities do

  def get_page_title_tag(request_path, user_id) do
    uid = cond do
      not is_nil(user_id) -> user_id
      true -> ""
    end

    modif_mdp = "/modifier_motdepasse/#{uid}"
    modif_profil = "/modifier_profil/#{uid}"
    modif_adresse = "/modifier_adresse/#{uid}"

    case request_path do

      "/" -> "Eléctricité | Quincaillerie | Sanitaire"
      "/boutique" -> "Boutique"
      "/panier" -> "Panier"
      "/connexion" -> "Connexion"
      "/inscription" -> "Inscription"
      "/verification_confirmation_mail" -> "Vérification"
      "/verification_motdepasse_oublie" -> "Vérification"
      "/motdepasse_oublie" -> "Vérification"
      "/renvoi_verification_mail" -> "Vérification"
      "/mon_profil" -> "Mon profil"
      "/mon_adresse" -> "Mon adresse"
      "/valider_connexion" -> "Validation"
      "/valider_inscription" -> "Validation"
      "/envoi_mail_motdepasse_oublie" -> "Envoi"
      "/renvoi_mail_confirmation" -> "Envoi"
      modif_mdp -> "Modification"
      modif_profil -> "Modification"
      modif_adresse -> "Modification"
      _ -> "Fracomex"

    end

  end

end
