
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-18
-- Modify date: 2013-10-09 
-- Description:	Seleziona la lista delle prestazioni relative al profilo
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniProfiliList]
	@IDPadre as uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
		SELECT
			  P.ID
			, P.DataInserimento
			, P.DataModifica
			, P.IDTicketInserimento
			, P.IDTicketModifica
			, P.TS
			, P.Codice
			, P.Descrizione
			, P.Tipo
			, P.Provenienza
			, P.IDSistemaErogante
			, S.CodiceAzienda AS CodiceAzienda
			, A.Descrizione AS DescrizioneAzienda
			, S.Codice AS CodiceSistema
			, S.Descrizione AS DescrizioneSistema
		FROM 
			Prestazioni P			
			INNER JOIN Sistemi S ON S.ID = P.IDSistemaErogante
			INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda
			INNER JOIN PrestazioniProfili PP ON PP.IDFiglio = P.ID
		WHERE
			PP.IDPadre = @IDPadre
			
		ORDER BY
			P.Codice
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniProfiliList] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniProfiliList] TO [DataAccessWs]
    AS [dbo];

