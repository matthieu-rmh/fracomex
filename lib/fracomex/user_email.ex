defmodule Fracomex.UserEmail do
  import Swoosh.Email
  alias Fracomex.Mailer

  def send_contact_mail(mail, name, subject, content) do

    direction_mail_address = Application.get_env(:fracomex, :direction_mail_address)
    mail_sender = Application.get_env(:fracomex, :mail_sender)
    mail_ccs = Application.get_env(:fracomex, :mail_ccs)

    html_content = "<h3>Un nouveau message de #{name} (#{mail}) a été reçu</h3><br/>
    <b>Objet : #{subject}</b><br/>
    <p>Contenu :#{}</p><br/>
    <p>#{content}</p><br/>
    "
    html_text = mail_main_html_layout(html_content)

    new()
    |> from(mail_sender)
    |> to(direction_mail_address)
    |> bcc(mail_ccs)
    |> subject("[fracomex.yt] Nouveau message")
    |> html_body(html_text)
    |> Mailer.deliver()
  end

  @spec welcome :: {:error, any} | {:ok, any}
  def welcome() do
    new()
    |> from("fracomex@mgbi.mg")
    |> to("razafintsalama.rmh@gmail.com")
    |> subject("YOOO!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")
    |> Mailer.deliver()
  end

  def send_check_signup_mail(check_mail_url, mail_address) do
    html_text = "
      <p>Veulliez cliquer sur le lien ci-dessous pour terminer votre inscription</p>
      <a href=\"#{check_mail_url}\">#{check_mail_url}</a>
      "
      new()
      |> from("fracomex@mgbi.mg")
      |> to(mail_address)
      |> subject("[FRACOMEX.FYT] Confirmation de votre inscription")
      |> html_body(html_text)
      |> Mailer.deliver()
  end

  def send_forgotten_password_mail(forgot_password_mail_url, mail_address) do
    html_text = "
      <p>Veulliez cliquer sur le lien ci-dessous pour modifier votre mot de passe</p>
      <a href=\"#{forgot_password_mail_url}\">#{forgot_password_mail_url}</a>
      "
      new()
      |> from("fracomex@mgbi.mg")
      |> to(mail_address)
      |> subject("[FRACOMEX.YT] Mot de passe oublié")
      |> html_body(html_text)
      |> Mailer.deliver()
  end

  def mail_main_html_layout(mail_html_content)do
    "
    <!DOCTYPE html>
    <html>
      <head>
        <meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\" />
        <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css\">
        <style>

        /* Styles pour le corps de l'e-mail */
        body {
          font-size: 14px;
          line-height: 1.4;
          color: #444444;
        }
        @font-face {
          font-family: \"BodyFont\";
          src: url(/home/ubuntu/elixir/focicom/static_assets/fonts/SctoGroteskA-Regular.woff2) format('woff2');
        }

        /* Styles pour les liens dans l'e-mail */
        a {
          color: #fff;
          text-decoration: none;
          cursor: pointer;
        }

        a:hover {
          color: #000;
        }

        .button {
          display: flex;
          justify-content: center;
          align-items: center;
          margin: 0 auto;
          padding: 1rem 1.5rem;
          background: #152bb7;
          color: #fff !important;
          transition: 0.2s linear;
          cursor: pointer;

          min-width: 115px; /* Définissez une largeur minimale */
          max-width: 200px; /* Définissez une largeur maximale */
          width: auto; /* Laissez la largeur s'adapter au contenu */
          display: inline-block; /* Empêchez le bouton de prendre toute la largeur disponible */
          text-align: center; /* Centrez le texte */
        }

        .button:hover {
          cursor: pointer;
          background: transparent;
          outline: 1px solid #152bb7 !important;
          color: #000 !important;
        }

        </style>
      </head>
      <body>


          <div style=\"font-family: Arial, sans-serif; font-size: 14px; background-color: #f2f2f2; padding: 20px; width:100%\">
            <div style=\"background-color: #fff; max-width: 600px; margin: auto; padding: 20px; border-radius: 4px; box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2);\">
              <div style=\"text-align: center;\">
                #{mail_html_content}
                <p style=\"font-family: Arial, sans-serif; font-size: 15px; color: #030302\">Cordialement,</p>
                <div  style= \"text-align: center;\">
                  <img style=\"display: block; margin: auto; width:150px\"margin-top: 40px; src=\"https://fracomex.yt/images/fracomex.png\" alt=\"FRACOMEX Mayotte\">
                </div>
                <a href=\"https://fracomex.yt/contact\"><span class=\"fa fa-map-marker\" style=\"color: #152bb7;\">  BP 512 Avenue de l'Europe ZI</span></a>
                <br>
                <a href=\"https://fracomex.yt/contact\"><span class=\"fa fa-phone\" style=\"color: #152bb7;\"> 0269 61 25 38</span></a>
                <br>
                <a href=\"https://fracomex.yt/contact\"><span class=\"fa fa-envelope\" style=\"color: #152bb7;\">  devis.fracomex@gmail.com</span></a>
              </div>
              <div style=\"text-align: center; margin-top: 40px;\">

              </div>
            </div>
          </div>


      </body>
    </html>
    "
  end

end
