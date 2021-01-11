



-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-27
-- Description:	Restituisce le informazioni di testata relative alla NotaAnamnestica
-- =============================================
CREATE PROCEDURE [ws3].[NotaAnamnesticaById]
(
	@IdToken			UNIQUEIDENTIFIER
	, @IdNotaAnamnestica	UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		Id 
		, DataPartizione
		, IdEsterno
		, IdPaziente
		, DataInserimento
		, DataModifica
		, DataModificaEsterno
		, AziendaErogante
		, SistemaErogante
		, StatoCodice
		, StatoDescrizione
		, TipoCodice
		, TipoDescrizione
		, DataNota
		, DataFineValidita
		, Contenuto	
		, TipoContenuto
		, ContenutoHtml
		, ContenutoText
		, Cognome
		, Nome
		, Sesso
		, CodiceFiscale
		, DataNascita
		, ComuneNascita
		, CodiceSanitario
		, Attributi
	FROM 
		ws3.NoteAnamnestiche
	WHERE Id = @IdNotaAnamnestica
	RETURN @@ERROR
END