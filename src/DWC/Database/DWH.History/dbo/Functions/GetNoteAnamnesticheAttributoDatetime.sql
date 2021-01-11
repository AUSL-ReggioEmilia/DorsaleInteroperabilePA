
-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-24
-- Description:	Ritorna l'attributo tipizzato DATETIME delle note anamnestiche
-- =============================================
CREATE FUNCTION [dbo].[GetNoteAnamnesticheAttributoDatetime]
(
	 @IdNoteAnamnesticheBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	,@Nome AS VARCHAR(64)
)  
RETURNS DATETIME AS  
BEGIN 

DECLARE @Ret AS DATETIME
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM dbo.NoteAnamnesticheAttributi WITH(NOLOCK)
	WHERE IdNoteAnamnesticheBase = @IdNoteAnamnesticheBase
		AND DataPartizione = @DataPartizione
		AND Nome = @Nome
	
	IF ISDATE(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS DATETIME)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END