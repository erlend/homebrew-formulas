require "formula"

class MuttKz < Formula
  homepage "https://github.com/karelzak/mutt-kz/"
  url "https://github.com/karelzak/mutt-kz/archive/v1.5.22.1.tar.gz"
  sha1 "8b2c3ed0438c2b16d4965f7190f0ce7ff79fa398"

  head "https://github.com/karelzak/mutt-kz.git"

  unless Tab.for_name("signing-party").with? "rename-pgpring"
    conflicts_with "signing-party",
      :because => "mutt installs a private copy of pgpring"
  end

  conflicts_with "tin",
    :because => "both install mmdf.5 and mbox.5 man pages"

  conflicts_with "mutt",
    :because => "this is just a fork"

  option "with-debug", "Build with debug option enabled"
  option "with-trash-patch", "Apply trash folder patch"
  option "with-s-lang", "Build against slang instead of ncurses"
  option "with-pgp-verbose-mime-patch", "Apply PGP verbose mime patch"
  option "with-confirm-attachment-patch", "Apply confirm attachment patch"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "openssl"
  depends_on "tokyo-cabinet"
  depends_on "s-lang" => :optional
  depends_on "gpgme" => :optional

  depends_on "notmuch" => :optional

  patch do
    url "ftp://ftp.openbsd.org/pub/OpenBSD/distfiles/mutt/trashfolder-1.5.22.diff0.gz"
    sha1 "c597566c26e270b99c6f57e046512a663d2f415e"
  end if build.with? "trash-patch"

  patch do
    url "https://raw.githubusercontent.com/psych0tik/mutt/73c09bc56e79605cf421a31c7e36958422055a20/debian/patches/features-old/patch-1.5.4.vk.pgp_verbose_mime"
    sha1 "a436f967aa46663cfc9b8933a6499ca165ec0a21"
  end if build.with? "pgp-verbose-mime-patch"

  patch do
    url "https://gist.githubusercontent.com/tlvince/5741641/raw/c926ca307dc97727c2bd88a84dcb0d7ac3bb4bf5/mutt-attach.patch"
    sha1 "94da52d50508d8951aa78ca4b073023414866be1"
  end if build.with? "confirm-attachment-patch"

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--with-ssl=#{Formula['openssl'].opt_prefix}",
            "--with-sasl",
            "--with-gss",
            "--enable-imap",
            "--enable-smtp",
            "--enable-pop",
            "--enable-hcache",
            "--with-tokyocabinet",
            # This is just a trick to keep 'make install' from trying to chgrp
            # the mutt_dotlock file (which we can't do if we're running as an
            # unpriviledged user)
            "--with-homespool=.mbox"]
    args << "--with-slang" if build.with? "s-lang"
    args << "--enable-gpgme" if build.with? "gpgme"
    args << "--enable-notmuch" if build.with? "notmuch"

    if build.with? "debug"
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    system "./prepare", *args
    system "make"
    system "make", "install"

    doc.install resource("html") if build.head?
  end
end
