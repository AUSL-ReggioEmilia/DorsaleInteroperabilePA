
-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-24
-- Description:	Ritorna l'attributo non tipizzato delle note anamnestiche
-- =============================================
CREATE FUNCTION [dbo].[GetNoteAnamnesticheAttributo]
(
	 @IdNoteAnamnesticheBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	,@Nome AS VARCHAR(64)
)
RETURNS SQL_VARIANT AS  
BEGIN 

DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore
	FROM dbo.NoteAnamnesticheAttributi WITH(NOLOCK)
	WHERE IdNoteAnamnesticheBase = @IdNoteAnamnesticheBase
		AND DataPartizione = @DataPartizione
		AND Nome = @Nome
	
	RETURN @Ret
END