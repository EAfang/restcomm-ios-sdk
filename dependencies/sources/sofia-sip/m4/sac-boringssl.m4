dnl ======================================================================
dnl SAC_BORINGSSL
dnl ======================================================================
AC_DEFUN([SAC_BORINGSSL], [

AC_ARG_WITH(boringssl,
[  --with-boringssl        use BoringSSL [[enabled]]],, with_boringssl=pkg-config)

dnl SOSXXX:SAC_ASSERT_DEF([boringssl libraries])


if test "$with_boringssl" = no  ;then
  : # No boringssl
else

  if test "$with_boringssl" = "pkg-config" ; then
    PKG_CHECK_MODULES(boringssl, boringssl,
	[HAVE_TLS=1 HAVE_BORINGSSL=1],
	[HAVE_BORINGSSL=0])
  fi

  if test x$HAVE_BORINGSSL = x1 ; then
dnl     AC_DEFINE([HAVE_LIBWEBRTC], 1, [Define to 1 if you have the `webrtc' library (-lwebrtc).])
     AC_DEFINE([HAVE_LIBCRYPTO], 1, [Define to 1 if you have the `crypto' library (-lcrypto).])
     AC_DEFINE([HAVE_LIBSSL], 1, [Define to 1 if you have the `ssl' library (-lssl).])
  else
    AC_CHECK_HEADERS([openssl/tls1.h], [
      HAVE_BORINGSSL=1 HAVE_TLS=1

dnl      AC_CHECK_LIB(boringssl, BIO_new,,
dnl      	HAVE_BORINGSSL=0
dnl      	AC_MSG_WARN(BoringSSL library was not found))
dnl
dnl      AC_CHECK_LIB(boringssl, TLSv1_method,,
dnl      	HAVE_TLS=0
dnl      	AC_MSG_WARN(BoringSSL protocol library was not found))
     ],[AC_MSG_WARN(BoringSSL include files were not found)])
  fi

  if test x$HAVE_BORINGSSL = x1; then
     AC_DEFINE([HAVE_BORINGSSL], 1, [Define to 1 if you have BoringSSL])
  fi

  if test x$HAVE_TLS = x1; then
    AC_DEFINE([HAVE_TLS], 1, [Define to 1 if you have TLS])
  fi
fi

AM_CONDITIONAL(HAVE_TLS, test x$HAVE_TLS = x1)
])
