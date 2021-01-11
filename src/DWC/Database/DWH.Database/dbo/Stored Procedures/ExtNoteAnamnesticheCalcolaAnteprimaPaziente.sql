

-- =============================================
-- Author:		ETTORE
-- Create date: 2017-11-21
-- Description:	SP chiamata dalla DAE fuori dalla transazione che gestisce l'aggiornamento di una norta anamnestica
--				Chiama la SP di core per impostare il ricalcolo dell'anteprima per le note anamnestiche
-- =============================================
CREATE PROCEDURE [dbo].[ExtNoteAnamnesticheCalcolaAnteprimaPaziente]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS 
BEGIN 
	EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPaziente, 0, 0, 1
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtNoteAnamnesticheCalcolaAnteprimaPaziente] TO [ExecuteExt]
    AS [dbo];

