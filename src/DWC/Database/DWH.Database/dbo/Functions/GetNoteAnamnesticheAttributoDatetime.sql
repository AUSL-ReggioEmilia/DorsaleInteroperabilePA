
--============================================
--Author: SimoneB
--Date: 2017-11-29
--Description: Ottieni gli attributi di tipo DateTime delle note anamnestiche.
--============================================
CREATE FUNCTION [dbo].[GetNoteAnamnesticheAttributoDatetime]
(
	@IdNoteAnamnesticheBase AS uniqueidentifier
	, @DataPartizione as smalldatetime
	, @Nome AS VARCHAR(64)
)  
RETURNS DATETIME AS  
BEGIN 
/*
	CREATA DA ETTORE 2015-05-04: per utilizzare la data di partizione 
*/
DECLARE @Ret AS DATETIME
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM store.NoteAnamnesticheAttributi WITH(NOLOCK)
	WHERE IdNoteAnamnesticheBase = @IdNoteAnamnesticheBase
		AND DataPartizione = @DataPartizione 
		AND Nome = @Nome
	
	IF ISDATE(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS DATETIME)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END