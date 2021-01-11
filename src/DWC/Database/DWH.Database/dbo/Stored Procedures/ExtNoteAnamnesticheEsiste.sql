

-- =============================================
-- Author:		Garulli Ettore
-- Create date: 2018-06-12
-- Description:	Controlla se esiste una nota anamnestica
--				usando come chiave @IdEsternoNotaAnamnestica
-- =============================================
CREATE PROCEDURE [dbo].[ExtNoteAnamnesticheEsiste]
(
	@IdEsternoNotaAnamnestica			varchar (64)
	---- Restituisce la PK del record inserito
	--, @IdNotaAnamnestica				uniqueidentifier = NULL OUTPUT
	--, @DataPartizione					smalldatetime = NULL OUTPUT
	--, @DataModificaEsterno				datetime = NULL OUTPUT
) AS
BEGIN

	SET NOCOUNT ON

	------------------------------------------------------
	--  Cerco se esiste gia IdEsterno
	------------------------------------------------------	

	-- Join con la tabella perchè [GetNoteAnamnestichePk] usa NOLOCK
	SELECT 
		PK.[ID] AS IdNotaAnamnestica 
		, PK.[DataPartizione] AS DataPartizione 
		, PK.[DataModificaEsterno] AS DataModificaEsterno 
	FROM 
		[store].[NoteAnamnesticheBase] AS NoteAnamnestiche
		INNER JOIN [dbo].[GetNoteAnamnestichePk](RTRIM(@IdEsternoNotaAnamnestica)) AS PK
			ON PK.[ID] = NoteAnamnestiche.Id 
				AND PK.[DataPartizione] = NoteAnamnestiche.[DataPartizione]

	RETURN 0
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtNoteAnamnesticheEsiste] TO [ExecuteExt]
    AS [dbo];

