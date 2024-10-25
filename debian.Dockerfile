FROM rustlang/rust:nightly-slim AS builder

RUN apt update -qq && \
    apt install -y \
      libcom-err2 \
      libgnutls30 \
      libgssapi-krb5-2 \
      libk5crypto3 \
      libkrb5-3 \
      libldap-2.5-0 \
      libpq-dev \
      libsasl2-2 \
      && \
    mv /usr/lib/*/libpq* /usr/lib/ && \
    mv /usr/lib/*/libgssapi_krb5* /usr/lib/ && \
    mv /usr/lib/*/liblber* /usr/lib/ && \
    mv /usr/lib/*/libldap* /usr/lib/ && \
#   mv /usr/lib/*/krb5/plugins/preauth/spake.so /usr/lib/krb5/plugins/preauth/spake.so && \
    mv /usr/lib/*/libkrb5* /usr/lib/ && \
    mv /usr/lib/*/libk5crypto* /usr/lib/ && \
    mv /lib/*/libcom_err* /lib/ && \
    mv /usr/lib/*/libsasl2* /usr/lib/ && \
    mv /usr/lib/*/libgnutls.so.30 /usr/lib/

WORKDIR /app

COPY . .

RUN cargo build --release

FROM gcr.io/distroless/cc-debian12 AS runner

COPY --from=builder /app/target/release/serve-actix-diesel-auth-scaffold* /app/bin/
# libpq-dev:
#ENV LD_LIBRARY_PATH
#COPY --from=builder /usr/lib/*/libpq* /usr/lib/
COPY --from=builder /usr/lib/libpq* /usr/lib/
COPY --from=builder /usr/include/postgresql /usr/include/
COPY --from=builder /usr/bin/pg_config /usr/bin/

# libgssapi-krb5-2
COPY --from=builder /usr/lib/libgssapi_krb5* /usr/lib/

# libldap-2.5-0
COPY --from=builder /usr/lib/liblber* /usr/lib/
COPY --from=builder /usr/lib/libldap* /usr/lib/

# libkrb5-3
#COPY --from=builder /usr/lib/krb5/plugins/preauth/spake.so /usr/lib/krb5/plugins/preauth/spake.so
COPY --from=builder /usr/lib/libkrb5* /usr/lib/

# libk5crypto3
COPY --from=builder /usr/lib/libk5crypto* /usr/lib/

# libcom-err2
COPY --from=builder /lib/libcom_err* /lib/

# libsasl2-2
COPY --from=builder /usr/lib/libsasl2* /usr/lib/

# libgnutls30
COPY --from=builder /usr/lib/libgnutls* /usr/lib/
COPY --from=builder /usr/share/locale/cs/LC_MESSAGES/gnutls30.mo /usr/share/locale/cs/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/de/LC_MESSAGES/gnutls30.mo /usr/share/locale/de/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/eo/LC_MESSAGES/gnutls30.mo /usr/share/locale/eo/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/es/LC_MESSAGES/gnutls30.mo /usr/share/locale/es/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/fi/LC_MESSAGES/gnutls30.mo /usr/share/locale/fi/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/fr/LC_MESSAGES/gnutls30.mo /usr/share/locale/fr/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/it/LC_MESSAGES/gnutls30.mo /usr/share/locale/it/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/ka/LC_MESSAGES/gnutls30.mo /usr/share/locale/ka/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/ms/LC_MESSAGES/gnutls30.mo /usr/share/locale/ms/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/nl/LC_MESSAGES/gnutls30.mo /usr/share/locale/nl/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/pl/LC_MESSAGES/gnutls30.mo /usr/share/locale/pl/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/pt_BR/LC_MESSAGES/gnutls30.mo /usr/share/locale/pt_BR/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/ro/LC_MESSAGES/gnutls30.mo /usr/share/locale/ro/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/sr/LC_MESSAGES/gnutls30.mo /usr/share/locale/sr/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/sv/LC_MESSAGES/gnutls30.mo /usr/share/locale/sv/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/uk/LC_MESSAGES/gnutls30.mo /usr/share/locale/uk/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/vi/LC_MESSAGES/gnutls30.mo /usr/share/locale/vi/LC_MESSAGES/gnutls30.mo
COPY --from=builder /usr/share/locale/zh_CN/LC_MESSAGES/gnutls30.mo /usr/share/locale/zh_CN/LC_MESSAGES/gnutls30.mo

ENTRYPOINT ["/app/bin/serve-actix-diesel-auth-scaffold"]
