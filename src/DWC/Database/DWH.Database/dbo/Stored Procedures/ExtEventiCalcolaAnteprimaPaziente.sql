
CREATE PROCEDURE [dbo].[ExtEventiCalcolaAnteprimaPaziente]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS 
BEGIN 

/*
	CREATA DA ETTORE 2015-02-13: 
		SP chiamata dalla DAE fuori dalla transazione che gestisce l'aggiornamento di un referto
		Chiama la SP di core per impostare il ricalcolo dell'anteprima per i referti
*/
	EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPaziente, 0, 1
END 



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiCalcolaAnteprimaPaziente] TO [ExecuteExt]
    AS [dbo];

