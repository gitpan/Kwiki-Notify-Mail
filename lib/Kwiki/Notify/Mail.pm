# $Header: /home/staff/peregrin/cvs/Kwiki-Notify-Mail/lib/Kwiki/Notify/Mail.pm,v 1.7 2005/01/25 20:49:23 peregrin Exp $
#
package Kwiki::Notify::Mail;
use warnings;
use strict;
use Kwiki::Plugin '-Base';
use mixin 'Kwiki::Installer';
use MIME::Lite;

our $VERSION = '0.03';

const class_id    => 'notify_mail';
const class_title => 'Kwiki page edit notification via email';
const config_file => 'notify_mail.yaml';


sub debug {
    my $debug = $self->hub->config->notify_mail_debug || 0;
    return $debug;
}

sub register {
    my $registry = shift;
    $registry->add(hook => 'page:store',
		   post => 'notify',
		  );
}

sub notify {
    my $hook = pop;
    my $page = shift;
    my $notify_mail_obj = $self->hub->load_class('notify_mail');

    my $meta_data = $self->hub->edit->pages->current->metadata;
    my $site_title = $self->hub->config->site_title;

    my $edited_by   = $meta_data->{edit_by}                || 'unknown name';
    my $page_name   = $meta_data->{id}                     || 'unknown page';
    my $to          = $notify_mail_obj->config->notify_mail_to   || 'unknown@unknown';
    my $from        = $notify_mail_obj->config->notify_mail_from || 'unknown';
    my $subject     = sprintf($notify_mail_obj->config->notify_mail_subject,
			      $site_title,
			      $page_name,
			      $edited_by)   || 'unknown';

    my $body        = "$site_title page $page_name edited by $edited_by\n";

    $notify_mail_obj->mail_it($to,$from,$subject,$body);
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

    if (debug($self)) {
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

Version 0.03

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

Specify a subject line for the mail message.  You can make use of
sprintf()-type formatting codes (%s is the only one that is relevant).
If you put or more %s in the configuration directive it will print out
the site title, page name and whom it was edited by.  You can can't
change the order, however.

Examples:

 notify_mail_subject: Kwiki was updated

gives you the Subject: line

 Subject: Kwiki was updated

If your site title (defined in site_title in config.yaml) was
'ProjectDiscussion', then

 notify_mail_subject: My wiki %s was updated

gives you the Subject: line

 Subject: My wiki ProjectDiscussion was updated

Next you can add the page name with a second %s.  If the updated
page happened to be 'NextWeeksAgenda', the configuration directive

 notify_mail_subject: My wiki %s page %s was updated

gives you the Subject: line

 Subject: My wiki ProjectDiscussion page NextWeeksAgenda was updated

Finally, a third %s gives you the name of the person who edited the page:

 notify_mail_subject: My wiki %s page %s was updated by %s

 Subject: My wiki ProjectDiscussion page NextWeeksAgenda was updated
 by PointyHairedBoss

The important thing to remember is that you can have either none or one or two
or three %s, but you can't change the order.  The default value is

 notify_mail_subject: %s wiki page %s updated by %s

which should be fine for most people.

=item * notify_mail_debug

When set, saves the mail message to /tmp/kwiki_notify_mail.txt instead
of sending it.

=back

=head1 AUTHOR

James Peregrino, C<< <jperegrino@post.harvard.edu> >>

=head1 ACKNOWLEDGMENTS

The folks at irc::/irc.freenode.net/kwiki, especially alevin and
statico.  The style of this module has been adapted from statico's
Kwiki::Notify::IRC.

=head1 BUGS

The subject line configuration relies on sprintf() which doesn't allow
you to change the order of what gets printed out.

The debug file is saved to /tmp and should be user configurable.  This
module was not tested under Windows and certainly /tmp doesn't exist
there.

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
notify_mail_subject: %s wiki page %s updated by %s
notify_mail_debug: 0

