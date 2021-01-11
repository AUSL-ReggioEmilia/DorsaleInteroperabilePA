
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-02-23
-- Modify date: 2013-09-05 SANDRO: Setto il TOP variabile da 2000 a 500
-- Modify date: 2013-10-02 SANDRO: Aggiunto filtro Prestazione.Attivo=1
-- Modify date: 2013-10-11 SANDRO: Aggiunto filtro Sistema.Attivo=1
-- Modify date: 2013-10-14 SANDRO: Aggiunto filtro Sistema.Attivo=1 OR Sistema.ID = '00000000-0000-0000-0000-000000000000'
-- Modify date: 2014-03-03 SANDRO: Aggiunto controllo accesso su profili e accesso ai sistemi
-- Modify date: 2014-11-04 SANDRO: Usa la nuova Func GetPrestazioniRichiedibili() per valutare l'accesso
-- Modify date: 2018-02-06 SANDRO: Rimosso blocco di debug
-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
--									Rimosso WITH RECOMPILE e aggiunto OPTION (RECOMPILE)
-- Modify date: 2018-06-19 SANDRO: Usa nuovo Func (già provata in ByIdGruppo)
--
-- Description:	Ritorna un elenco di prestazioni
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniListByCodiceDescrizione3]
( @utente varchar(64)
, @idUnitaOperativa uniqueidentifier
, @idSistemaRichiedente uniqueidentifier
, @idSistemaErogante uniqueidentifier
, @codiceRegime varchar(16)
, @codicePriorita varchar(16)
, @idStato tinyint = 1
, @valore varchar(256)
)
AS
BEGIN
	SET NOCOUNT ON;

	--########################################################################
	-- Tutte le SP della famiglia CorePrestazioniListBy*() + qualche altra, utilizzano
	--  la stessa FuncTable dbo.GetPrestazioniRichiedibili2() che ingloba tutte le
	--  logiche di erogabilità.
	--
	--[dbo].[CorePrestazioniListByCodiceDescrizione3]
	--[dbo].[CorePrestazioniListByIdGruppo]
	--[dbo].[CorePrestazioniListByPaziente3]
	--[dbo].[CorePrestazioniListBySistemaErogante4]
	--[dbo].[CorePrestazioniListByUnitaOperativa3]
	--[dbo].[WsProfiliListByCodiceDescrizione]
	--[dbo].[UiSimulazioneEnnupleList2]
	--
	--Ci sono delle eccezioni, le SP seguenti sono da tenere allineate come
	--  logiche di erogabilità.
	--
	--[dbo].[CorePrestazioniCheckByIds]
	--
	--
	--########################################################################

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1

	--Se filtro scarso abbasso il TOP
	DECLARE @MaxRecord INT = 2000
	IF @valore IS NULL OR LEN(@valore) < 2
		SET @MaxRecord = 500

	-- Prestazioni richiedibili
	DECLARE @RIC TABLE (Id uniqueidentifier) 
	INSERT INTO @RIC 
		SELECT Id FROM dbo.GetPrestazioniRichiedibili2(@utente, @idUnitaOperativa, @idSistemaRichiedente
												, GETDATE(), @codiceRegime, @codicePriorita
												, @idStato, @idSistemaErogante, @valore
												, NULL, 1, 1)

	--Cerco tra prestazioni del paziente
	SELECT DISTINCT TOP(@MaxRecord) P.*
	FROM dbo.CorePrestazioniList P

		--Prestazioni richiedibili 
		INNER JOIN @RIC PR ON PR.ID = P.ID

	WHERE  (@idSistemaErogante IS NULL OR P.IDSistemaErogante = @idSistemaErogante)
		AND	(@valore IS NULL OR (P.Codice Like '%' + @valore + '%' OR P.Descrizione Like '%' + @valore + '%'))
				
	ORDER BY Codice

	-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
	OPTION (RECOMPILE)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListByCodiceDescrizione3] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListByCodiceDescrizione3] TO [DataAccessWs]
    AS [dbo];

