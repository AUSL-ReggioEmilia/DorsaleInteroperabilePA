
CREATE PROCEDURE [dbo].[ExtRefertiCalcolaAnteprimaPaziente]
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
	EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPaziente, 1, 0
END 




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiCalcolaAnteprimaPaziente] TO [ExecuteExt]
    AS [dbo];

