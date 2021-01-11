


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-07-11
-- Description:	Transcodifica una UO dal codice Centrale al codice Sistema
-- =============================================
CREATE PROC [organigramma_da].[TranscodificaUnitaOperativaDaCentraleASistema]
(
 @SistemaAzienda varchar(16),
 @SistemaCodice varchar(16),

 @UnitaOperativaAzienda varchar(16),
 @UnitaOperativaCodice varchar(16),
 @UnitaOperativaDescrizione varchar(128) = NULL,

 @UoTransAzienda varchar(16) OUTPUT,
 @UoTransCodice varchar(16) OUTPUT,
 @UoTransDescrizione varchar(128) OUTPUT
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[TranscodificaUnitaOperativaDaCentraleASistema]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[TranscodificaUnitaOperativaDaCentraleASistema]!', 16, 1)
		RETURN
	END

	-- Eseguo query
	IF @UnitaOperativaCodice LIKE 'U@%'
		BEGIN
			-- Inizia con U@ non è da transcodificare

			SET @UoTransAzienda = @UnitaOperativaAzienda
			SET @UoTransCodice = @UnitaOperativaCodice
			SET @UoTransDescrizione = @UnitaOperativaDescrizione
		END
	ELSE
		BEGIN
			-- Cerco la transcodifica

			SELECT @UoTransAzienda = UOS.CodiceAzienda
				,@UoTransCodice = UOS.Codice
				,@UoTransDescrizione = UOS.Descrizione

			FROM [organigramma].[UnitaOperativeSistemi] UOS
				INNER JOIN [organigramma].[UnitaOperative] UO
					ON UOS.IdUnitaOperativa = UO.ID

				INNER JOIN [organigramma].[Sistemi] S
					ON UOS.IdSistema = S.ID
			
			WHERE UO.CodiceAzienda = @UnitaOperativaAzienda
				AND UO.Codice = @UnitaOperativaCodice
				AND S.CodiceAzienda = @SistemaAzienda
				AND S.Codice = @SistemaCodice

			-- Se non trovato o se * ritorno l'originale
			IF @UoTransCodice IS NULL OR @UoTransCodice = '*'
				BEGIN
					SET @UoTransAzienda = @UnitaOperativaAzienda
					SET @UoTransCodice = @UnitaOperativaCodice
					SET @UoTransDescrizione = @UnitaOperativaDescrizione
				END
		END
END



