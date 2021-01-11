

--==============================================
-- Author: SimoneB	 
-- Date: 2017-11-28
-- Description: Ottiene l'attributo @Nome dall'xml della nota anamnestica @IdNotaNotaAnamnestica
--  (copiata da dbo.GetRefertiAttributo2)
--==============================================
CREATE FUNCTION [dbo].[GetNoteAnamnesticheAttributo] 
(
	@IdNotaAnamnesticaBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	,@Nome AS VARCHAR(32)
)  
RETURNS SQL_VARIANT AS  
BEGIN 
DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore 
	FROM store.NoteAnamnesticheAttributi WITH(NOLOCK) 
	WHERE IdNoteAnamnesticheBase = @IdNotaAnamnesticaBase
		AND DataPartizione = @DataPartizione 
		AND Nome = @Nome

	RETURN @Ret
END