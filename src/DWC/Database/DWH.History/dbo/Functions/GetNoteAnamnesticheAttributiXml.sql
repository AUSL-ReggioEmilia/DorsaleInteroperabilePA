

-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-24
-- Description:	Ritorna XML di tutti gli attributi delle note anamnestiche
-- =============================================
CREATE FUNCTION [dbo].[GetNoteAnamnesticheAttributiXml]
(
	@IdNoteAnamnesticheBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
)  
RETURNS XML AS  
BEGIN 

DECLARE @Ret AS XML

	SET @Ret = (SELECT Nome, Valore
					, SQL_VARIANT_PROPERTY(Valore, 'BaseType') AS [BaseType] 
					, SQL_VARIANT_PROPERTY(Valore, 'Precision') AS [Precision]
					, SQL_VARIANT_PROPERTY(Valore, 'Scale') AS [Scale]
				FROM dbo.NoteAnamnesticheAttributi Attributo WITH(NOLOCK)
				WHERE IdNoteAnamnesticheBase = @IdNoteAnamnesticheBase 
					AND DataPartizione = @DataPartizione
				FOR XML AUTO, ROOT('Attributi')
				)				
	RETURN @Ret
END