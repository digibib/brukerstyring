# encoding: UTF-8
require 'net/smtp'

class Email
  include TorqueBox::Messaging::Backgroundable

  FROM = Settings::EMAIL
  FROM_ALIAS = "Bokanbefalinger/Deichmanske bibliotek"

  always_background :new_user

  def self.new_user(email, name)

   msg = <<END_OF_MESSAGE
Content-type: text/plain; charset=UTF-8
From: #{FROM_ALIAS} <#{FROM}>
To: <#{email}>
Subject: Velkommen til anbefalinger.deichman.no!

Hei, #{name}!

Du kan nå logge deg på anbefalinger.deichman.no.
Brukernavn er e-postadressen din, og passordet er #{email.split('@').first+'123'}
Du kan/bør bytte passord første gang du logger på.

hilsen Deichman
END_OF_MESSAGE

    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp.start("gmail.com", Settings::EMAIL, Settings::EMAIL_PASS, :login) do
      smtp.send_message msg, FROM, email
    end

  end
end