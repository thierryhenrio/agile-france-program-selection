#encoding: utf-8
require 'mail'
require 'model'
require 'renderable'
require 'logger'

class Mailer
  @@logger = Logger.new('mailer.log')
  @@mail_logger = Logger.new('mails.log')
  include Renderable

  def mail_speaker_having_at_least_one_scheduled_session
    speakers = Speaker.all(:sessions => {:scheduled => true})
    mails = []
    speakers.each do |speaker|
      mails << mail(speaker)
    end
    mails
  end

  def mail(speaker)
    erb = ERB.new(read_template('scheduled_session.text.erb'))
    content = erb.result binding
    mail = Mail.new do
      from 'orga@conf.agile-france.org'
      to "#{speaker.email}"
      subject 'vous avez une session retenue au programme de la conférence Agile France'
      body content
    end
    scheduled_sessions = []
    speaker.scheduled_sessions.each {|session| scheduled_sessions << session.title}
    @@logger.info "sending to #{speaker.email} : #{scheduled_sessions} are approved"
    @@mail_logger.info "#{mail} => #{mail.body}"
    mail.deliver!
  end
end