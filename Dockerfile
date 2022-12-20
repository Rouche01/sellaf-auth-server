FROM quay.io/keycloak/keycloak:19.0.2 As development

USER root
RUN microdnf update -y && microdnf install -y jq && microdnf clean all

COPY ./keycloak-scripts /startup-scripts

RUN find /startup-scripts -type f -exec chmod 755 {} \;

# ENTRYPOINT [ "/startup-scripts/kc-entrypoint.sh", "start" ]

FROM development As prod_build

RUN /opt/keycloak/bin/kc.sh build --db=postgres

FROM quay.io/keycloak/keycloak:19.0.2 As production

USER root
RUN microdnf update -y && microdnf install -y jq && microdnf clean all

COPY --from=prod_build /opt/keycloak/ /opt/keycloak/
COPY ./keycloak-scripts /startup-scripts

RUN find /startup-scripts -type f -exec chmod 755 {} \;

ENTRYPOINT [ "/startup-scripts/kc-entrypoint.sh", "start", "--optimized" ]
