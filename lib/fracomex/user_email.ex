defmodule Fracomex.UserEmail do
  import Swoosh.Email
  alias Fracomex.Mailer

  @spec welcome :: {:error, any} | {:ok, any}
  def welcome() do
    new()
    |> from("fracomexmayotte@outlook.com")
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
      |> from("fracomexmayotte@outlook.com")
      |> to(mail_address)
      |> subject("[FRACOMEX.FR] Confirmation de votre inscription")
      |> html_body(html_text)
      |> Mailer.deliver()

  end
end
