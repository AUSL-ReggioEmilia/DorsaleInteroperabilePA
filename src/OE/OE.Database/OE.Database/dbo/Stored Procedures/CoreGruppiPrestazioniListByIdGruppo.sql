-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-11-04
-- Modify date: 2018-02-07 SANDRO: Aggiunto OPTION (RECOMPILE)
--
-- Description:	Riscritta creando una Func che ritorna le prestazioni richiedibili
--
-- =============================================
CREATE PROCEDURE [dbo].[CoreGruppiPrestazioniListByIdGruppo](
  @utente VARCHAR (64)
, @idUnitaOperativa UNIQUEIDENTIFIER
, @idSistemaRichiedente UNIQUEIDENTIFIER
, @codiceRegime VARCHAR (16)
, @codicePriorita VARCHAR (16)
, @idStato TINYINT
, @IdGruppo UNIQUEIDENTIFIER
)
AS
BEGIN

DECLARE @Result TABLE(ID uniqueidentifier NOT NULL, Descrizione varchar(256) NULL, SistemaErogante varchar(40) NULL, NumeroPrestazioni int NULL)

	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1

	-- Tabella per poi calcolare le aggregazioni dei sistemi eroganti
	INSERT INTO @Result (ID, Descrizione, SistemaErogante, NumeroPrestazioni)
	SELECT DISTINCT GP_R.ID
					, GP_R.Descrizione
					, S.CodiceAzienda + '-' + S.Codice AS SistemaErogante
					, SUM(GPP.NumeroPrestazioni) NumeroPrestazioni

	FROM [dbo].[GruppiPrestazioni] GP_R
		INNER JOIN [dbo].[GetGruppiPrestazioniPreferiti](@utente, @idUnitaOperativa, @idSistemaRichiedente
								,@codiceRegime , @codicePriorita, @idStato, NULL) GPP
			ON GPP.ID = GP_R.ID AND GP_R.Preferiti = 1

		INNER JOIN dbo.Sistemi S
			ON S.ID = GPP.IdSistemaErogante
			
	WHERE GP_R.Preferiti = 1
		AND GP_R.ID =  @IdGruppo
	GROUP BY GP_R.ID, GP_R.Descrizione, S.CodiceAzienda, S.Codice

	-- Aggrego i Sistemi erognati in una unica stringa. Query XML e replace dei TAG
	SELECT ID, Descrizione
		, REPLACE(REPLACE(REPLACE((SELECT S.SistemaErogante D
				FROM @Result S
				WHERE S.ID = R.ID
				FOR XML AUTO), '"/><S D="', ', '), '<S D="', ''), '"/>', '') SistemiEroganti
		, SUM(NumeroPrestazioni) NumeroPrestazioni
	FROM @Result R
	GROUP BY ID, Descrizione
	ORDER BY Descrizione

	--2018-02-07 Aggiunto OPTION (RECOMPILE)
	OPTION (RECOMPILE)

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreGruppiPrestazioniListByIdGruppo] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreGruppiPrestazioniListByIdGruppo] TO [DataAccessWs]
    AS [dbo];

