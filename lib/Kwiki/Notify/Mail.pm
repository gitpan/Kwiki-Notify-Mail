# $Header: /home/staff/peregrin/cvs/Kwiki-Notify-Mail/lib/Kwiki/Notify/Mail.pm,v 1.3 2004/08/29 23:43:31 peregrin Exp $
#
package Kwiki::Notify::Mail;
use warnings;
use strict;
use Kwiki::Plugin '-Base';
use mixin 'Kwiki::Installer';
use MIME::Lite;

our $VERSION = '0.01';
my $DEBUG = 0;
const class_id    => 'notify';
const class_title => 'Kwiki page edit notification via email';
const config_file => 'notify_mail.yaml';


sub register {
    my $registry = shift;
    $registry->add(page_hook_store => 'notify');
}

sub notify {
    my $meta_data = $self->hub->edit->pages->current->metadata;

    my $edited_by   = $meta_data->{edit_by}                || 'unknown name';
    my $page_name   = $meta_data->{id}                     || 'unknown page';
    my $to          = $self->config->notify_mail_to        || 'unknown@unknown';
    my $from        = $self->config->notify_mail_from      || 'unknown';
    my $subject     = $self->config->notify_mail_subject   || 'unknown';
    my $body        = "Kwiki page $page_name edited by $edited_by\n";

    $self->mail_it($to,$from,$subject,$body);
    return $self;
}


sub mail_it {
    my ($to,$from,$subject,$body) = @_;

    my $msg = MIME::Lite->new(
	To      => $to,
	From    => $from,
	Subject => $subject,
	Data    => $body,
    );

    if ($DEBUG) {
	open(TEMPFILE,'>','/tmp/kwiki_notify_mail.txt') 
	    || die "can't open tmp file $!";
	$msg->print(\*TEMPFILE);
	close TEMPFILE;
    } else {
	$msg->send;
    }
}


1; # End of Kwiki::Notify::Mail

__DATA__

=head1 NAME

Kwiki::Notify::Mail - send an email when a page is updated

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

 $ cd /path/to/kwiki
 $ kwiki -add Kwiki::Notify::Mail
 $ cat config/notify_mail.yaml >> config.yaml
 $ edit config.yaml

=head1 REQUIRES

This module requires MIME::Lite to send email.

=head1 DESCRIPTION

This module allows you to notify yourself by email when some one
updates a page.  You can specify the To:, From: and Subject: headers,
but the email message body is not currently configurable.

A sample email looks like: 

 Content-Disposition: inline
 Content-Length: 52
 Content-Transfer-Encoding: binary
 Content-Type: text/plain
 MIME-Version: 1.0
 X-Mailer: MIME::Lite 3.01 (F2.72; B3.01; Q3.01)
 Date: Sun, 29 Aug 2004 22:00:31 UT
 To: geo_bush@casablanca.gov
 From: nobody@countykerry.ir
 Subject: Kwiki page update

 Kwiki page LotsOfWikiWords edited by AnonymousGnome

=head2 Configuration Directives

=over 4

=item * notify_mail_to

Specify the mail address you are sending to.

=item * notify_mail_from

Specify the address this is apparently from.

=item * notify_mail_subject

Specify a subject line for the mail message.

=back

=head1 AUTHOR

James Peregrino, C<< <jperegrino@post.harvard.edu> >>

=head1 ACKNOWLEDGMENTS

The folks at irc::/irc.freenode.net/kwiki, especially alevin and
statico.  The style of this module has been adapted from statico's
Kwiki::Notify::IRC.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-kwiki-notify-mail@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2004 James Peregrino, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
__config/notify_mail.yaml__
notify_mail_to: nobody@nobody.abc
notify_mail_from: nobody
notify_mail_subject: Nobody Kwiki
