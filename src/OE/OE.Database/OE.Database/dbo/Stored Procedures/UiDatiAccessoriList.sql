-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-02-23
-- Description:	Ricerca dei dati accessori
-- Modified: 2014-10-10 filtri in and
-- Modified: 2016-08-24 Stefano P.: Aggiunto campo ConcatenaNomeUguale
-- Modified: 2016-10-13 Stefano P.: Aggiunto parametro Top
-- =============================================
CREATE PROCEDURE [dbo].[UiDatiAccessoriList]
 @Codice AS VARCHAR(64) = NULL
,@Etichetta AS VARCHAR(256) = NULL
,@Tipo AS VARCHAR(32) = NULL
,@Top AS INT = 200

AS
BEGIN
	SET NOCOUNT ON
	IF @Top IS NULL SET @Top = 200

	SELECT TOP(@Top)
		 Codice
		,ISNULL(DatiAccessori.Descrizione,'') AS Descrizione
		,DataInserimento
		,DataModifica
		,UtenteModifica AS UserName     
		,Etichetta
		,Tipo
		,Obbligatorio
		,Ripetibile
		,ISNULL(Valori,'') AS Valori
		,ISNULL(Ordinamento, 0) AS Ordinamento
		,ISNULL(Gruppo,'') AS Gruppo
		,ISNULL(ValidazioneRegex,'') AS ValidazioneRegex
		,ISNULL(ValidazioneMessaggio,'') AS ValidazioneMessaggio
		,Sistema
		,ISNULL(ValoreDefault,'') AS ValoreDefault
		,ISNULL(NomeDatoAggiuntivo,'') AS NomeDatoAggiuntivo
		,ConcatenaNomeUguale

	FROM 
		dbo.DatiAccessori			  
	
	WHERE 
		(@Codice IS NULL OR Codice LIKE '%'+ REPLACE(@Codice, '_', '_') + '%')
		AND 
		(@Etichetta IS NULL OR Etichetta LIKE '%'+ REPLACE(@Etichetta, '_', '_') + '%')
		AND 
		(@Tipo IS NULL OR Tipo = @Tipo)

	ORDER BY 
		Etichetta, Codice

END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriList] TO [DataAccessUi]
    AS [dbo];

