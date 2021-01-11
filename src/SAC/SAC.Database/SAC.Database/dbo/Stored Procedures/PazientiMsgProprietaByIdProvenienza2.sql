-- =============================================
-- Author:		Ettore
-- Create date: 2015-09-18
-- Description:	Nuova versione dela SP di ricerca per Provenienza e IdProvenienza che restituisce anche i figli
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgProprietaByIdProvenienza2]
(
	  @Utente AS varchar(64)
	, @IdProvenienza AS varchar(64)
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-26: restituito anche Provenienza, IdProvenienza, LivelloAttendibilita del paziente ROOT (padre della catena di fusione)
*/
	DECLARE @Provenienza AS varchar(16)
	SET NOCOUNT ON;
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggePazientiPermessiLettura(@Utente) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiMsgProprietaByIdProvenienza2', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN 1002
	END
	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	---------------------------------------------------
	--  Restituisce i dati
	---------------------------------------------------
	SELECT TOP 1
		P.Id
		, P.DataInserimento
		, P.DataModifica
		, P.DataDisattivazione
		, P.DataSequenza
		, P.LivelloAttendibilita
		, P.Provenienza
		, P.IdProvenienza
		, P.Disattivato							--mi dice se FUSO o NO
		, P.Cognome
		, P.Nome
		, P.DataNascita
		, P.CodiceFiscale
		, P.Sesso
		, P.ComuneNascitaCodice
		, P.Tessera
		------------------------------------------------------------------------------
		, P_ROOT.Id AS IdPazienteRoot
		--MODIFICA ETTORE 2016-01-26: Nuovi campi
		, P_ROOT.Provenienza AS ProvenienzaPazienteRoot
		, P_ROOT.IdProvenienza AS IdProvenienzaPazienteRoot
		, P_ROOT.LivelloAttendibilita AS LivelloAttendibilitaPazienteRoot
	FROM 
		Pazienti AS P
		LEFT OUTER JOIN PazientiFusioni AS PF
			ON PF.IdPazienteFuso = P.id and Abilitato = 1
		LEFT OUTER JOIN Pazienti as P_ROOT
			ON PF.IdPaziente = P_ROOT.Id 
	WHERE
		P.Disattivato IN (0,2) --ATTIVI o FUSI
		AND P.Provenienza = @Provenienza
		AND P.IdProvenienza = @IdProvenienza
	ORDER BY 
		P.LivelloAttendibilita DESC, P.DataModifica DESC
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgProprietaByIdProvenienza2] TO [DataAccessDll]
    AS [dbo];

