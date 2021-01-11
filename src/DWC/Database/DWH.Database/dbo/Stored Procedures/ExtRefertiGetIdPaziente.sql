/*
	CREATA DA ETTORE 2015-02-13: 
		SP chiamata dalla DAE in fase di cancellazione per ottenere l'IdPaziente associato al referto

	MODIFICATO SANDRO 2015-11-02: Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]
*/
CREATE PROCEDURE [dbo].[ExtRefertiGetIdPaziente]
(
	@IdEsterno VARCHAR(64)
)
AS 
BEGIN
 
	SELECT IdPaziente
	FROM [store].RefertiBase
		INNER JOIN [dbo].[GetRefertiPk](RTRIM(@IdEsterno)) PK
			ON RefertiBase.Id = PK.ID
			AND RefertiBase.DataPartizione = PK.DataPartizione

END 





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiGetIdPaziente] TO [ExecuteExt]
    AS [dbo];

