
-- =============================================
-- Author:		/
-- Date:		/
-- Description:	Seleziona un template utente per id
-- Modify Auhtor: SimoneB
-- Modify Date:	2017-08-31
-- Modify Description: Aggiunto il parametro @CancellazionePostInCarico. Non viene più utilizzata la view UiSelect ma la tabella Sistemi nella from.
-- =============================================
CREATE PROCEDURE [dbo].[UiSistemiSelect1]
	@ID as uniqueidentifier = NULL,
	@CodiceDescrizione as varchar(max) = NULL,
	@Azienda as varchar(16) = NULL,
	@Erogante as bit = NULL,
	@Richiedente as bit = NULL,
	@Attivo as bit= NULL,
	@CancellazionePostInoltro as bit= NULL,
	@CancellazionePostInCarico AS BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT ID
		  ,Codice
		  ,ISNULL(Descrizione,'') as Descrizione
		  ,ISNULL(Erogante, 0) as Erogante
		  ,ISNULL(Richiedente, 0) as Richiedente
		  ,CodiceAzienda as Azienda
		  ,ISNULL(Attivo, 0) as Attivo 
		  ,ISNULL(CancellazionePostInoltro, 0) as CancellazionePostInoltro
		  ,ISNULL(CancellazionePostInCarico,0) AS CancellazionePostInCarico
	FROM dbo.Sistemi
	WHERE 
	  --AttivoSac=1 --mostro solo i sistemi attivi sul SAC
	  --AND	
	  (@ID is null or ID = @ID)
	  AND (@CodiceDescrizione is null or Codice like '%'+@CodiceDescrizione+'%' 
	      OR Descrizione like '%'+ @CodiceDescrizione+'%' )
	  AND (@Azienda is null or CodiceAzienda = @Azienda)
	  AND (@Erogante is null or Erogante = @Erogante)
	  AND (@Richiedente is null or Richiedente = @Richiedente)
	  AND (@Attivo is null or Attivo = @Attivo)
	  AND (@CancellazionePostInoltro is null or CancellazionePostInoltro = @CancellazionePostInoltro)
	  AND (NOT ID = '00000000-0000-0000-0000-000000000000')
	  AND (@CancellazionePostInCarico IS NULL OR CancellazionePostInCarico = @CancellazionePostInCarico)
	ORDER BY Codice

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiSelect1] TO [DataAccessUi]
    AS [dbo];

