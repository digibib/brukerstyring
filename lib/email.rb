# encoding: UTF-8
require 'net/smtp'

require_relative "../config/settings"

class Email

  FROM = Settings::EMAIL
  FROM_ALIAS = "Bokanbefalinger/Deichmanske bibliotek"

  def self.new_user(email, name)

   msg = <<END_OF_MESSAGE
Content-type: text/plain; charset=UTF-8
From: #{FROM_ALIAS} <#{FROM}>
To: <#{email}>
Subject: Velkommen til anbefalinger.deichman.no!

Hei, #{name}!

Du kan nå logge deg på http://anbefalinger.deichman.no og begynne å bidra til bokanbefalingsbasen.

Brukernavn er e-postadressen din, og passordet er #{email.split('@').first+'123'}
Du bør bytte passord første gang du logger deg på.

Beste hilsen,
Bokanbefalingsteamet
END_OF_MESSAGE

    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp.start("gmail.com", Settings::EMAIL, Settings::EMAIL_PASS, :login) do
      smtp.send_message msg, FROM, email
    end

  end

  def self.new_password(email, name, password)

   msg = <<END_OF_MESSAGE
Content-type: text/plain; charset=UTF-8
From: #{FROM_ALIAS} <#{FROM}>
To: <#{email}>
Subject: anbefalinger.deichman.no: nytt passord

Hei, #{name}!

Det har blitt laget et nytt passord for din konto: #{password}
Du bør bytte passord når du logger deg på.

Du logger inn på http://anbefalinger.deichman.no for å bidra med anbefalinger.

Brukernavn er e-postadressen din.

Beste hilsen,
Bokanbefalingsteamet
END_OF_MESSAGE

    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp.start("gmail.com", Settings::EMAIL, Settings::EMAIL_PASS, :login) do
      smtp.send_message msg, FROM, email
    end

  end

end
