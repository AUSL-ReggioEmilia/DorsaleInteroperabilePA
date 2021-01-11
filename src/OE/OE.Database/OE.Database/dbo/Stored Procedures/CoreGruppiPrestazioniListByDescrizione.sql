
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date:  2014-10-14 Sandro - Aggiunto filtro per i gruppi senza prestazioni
-- Modify date:  2014-10-22 Sandro - Diversamente dai profili, il gruppi preferiti diventano accessibile se lo è almeno una prestazione
-- Modify date:  2014-11-04 Sandro - Riscritta creando una Func che ritorna le prestazioni richiedibili
-- Modify date:  2015-03-23 Sandro - Riscritta creando una Func che ritorna i gruppi con ennupla specifica
-- Modify date:  2018-02-07 SANDRO: Aggiunto OPTION (RECOMPILE)
-- Modify date:  2018-10-09 SANDRO: Rimosso limite per filtro scarso
--
-- Description:	Riscritta creando una Func che ritorna le prestazioni richiedibili
--
-- =============================================
CREATE PROCEDURE [dbo].[CoreGruppiPrestazioniListByDescrizione](
  @utente VARCHAR (64)
, @idUnitaOperativa UNIQUEIDENTIFIER
, @idSistemaRichiedente UNIQUEIDENTIFIER
, @codiceRegime VARCHAR (16)
, @codicePriorita VARCHAR (16)
, @idStato TINYINT
, @valore VARCHAR (256)=NULL
)
AS
BEGIN

DECLARE @Result TABLE(ID uniqueidentifier NOT NULL, Descrizione varchar(256) NULL, SistemaErogante varchar(40) NULL, NumeroPrestazioni int NULL)

	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1
	
	--Se filtro scarso abbasso il TOP
	DECLARE @MaxRecord INT = 200
	--IF @valore IS NULL OR LEN(@valore) < 2
	--	SET @MaxRecord = 50

	-- Tabella per poi calcolare le aggregazioni dei sistemi eroganti
	INSERT INTO @Result (ID, Descrizione, SistemaErogante, NumeroPrestazioni)

	SELECT DISTINCT GP_R.ID
					, GP_R.Descrizione
					, S.CodiceAzienda + '-' + S.Codice AS SistemaErogante
					--, COUNT(P.Id) NumeroPrestazioni
					, SUM(GPP.NumeroPrestazioni) NumeroPrestazioni

	FROM [dbo].[GruppiPrestazioni] GP_R

		INNER JOIN [dbo].[GetGruppiPrestazioniPreferiti](@utente, @idUnitaOperativa, @idSistemaRichiedente
								,@codiceRegime , @codicePriorita, @idStato, @valore) GPP
			ON GPP.ID = GP_R.ID AND GP_R.Preferiti = 1

		INNER JOIN dbo.Sistemi S
			ON S.ID = GPP.IdSistemaErogante
						
	WHERE GP_R.Preferiti = 1
	GROUP BY GP_R.ID, GP_R.Descrizione, S.CodiceAzienda, S.Codice

	-- Aggrego i Sistemi erognati in una unica stringa. Query XML e replace dei TAG
	SELECT TOP(@MaxRecord) ID, Descrizione
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
    ON OBJECT::[dbo].[CoreGruppiPrestazioniListByDescrizione] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreGruppiPrestazioniListByDescrizione] TO [DataAccessWs]
    AS [dbo];

