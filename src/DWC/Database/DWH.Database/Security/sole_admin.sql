CREATE SCHEMA [sole_admin]
    AUTHORIZATION [dbo];




GO
GRANT SELECT
    ON SCHEMA::[sole_admin] TO [ExecuteFrontEnd];


GO
GRANT EXECUTE
    ON SCHEMA::[sole_admin] TO [ExecuteFrontEnd];

