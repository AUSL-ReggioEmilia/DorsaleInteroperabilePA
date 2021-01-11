------------------------------------------------------------
--Converte da IdEsterno a Id guid
--MODIFICA SANDRO 2015-08-19: Usa le VIEW store
--MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
--							Usa GetPrescrizioniPk()
--							Nella JOIN anche DataPartizione
-------------------------------------------------------------
CREATE FUNCTION [dbo].[GetAllegatiId]
(@IdEsternoRefero AS varchar(64), @IdEsterno AS varchar(64))  
RETURNS uniqueidentifier AS  
BEGIN 
DECLARE @Ret AS uniqueidentifier

	SELECT @Ret = AllegatiBase.ID
	FROM store.AllegatiBase WITH(NOLOCK)
		INNER JOIN [dbo].[GetRefertiPk](RTRIM(@IdEsternoRefero)) PK
			ON AllegatiBase.IdRefertiBase = PK.ID
			AND AllegatiBase.DataPartizione = PK.DataPartizione

	WHERE AllegatiBase.IDEsterno = RTRIM(@IdEsterno)
	
	RETURN @Ret
END
