



CREATE VIEW [dbo].[DeltaAnagrafeEsentiFull]
AS
/*
	MODIFICA ETTORE: 2017-06-09 modificato test su DataFineValidita per tenere conto che LHA 
			per le esenzioni da fascia di reddito invia NULL al posto di '3000-12-31' 
			come scritto presente nella tabella LHA che ci hanno dato per leggere le 
			esenzioni da fascia di reddito usata per popolare la tabella SacConnLHA.dbo.AppCn_AnagrafeEsenti.
*/
SELECT DISTINCT 
	  AE.IdPersona AS IdLha
	, PE.IdPaziente AS IdSac
	,'Esenzione' AS Motivo

FROM         
	dbo.AppCn_Anagrafe AS A 
	
	INNER JOIN dbo.AppCn_AnagrafeEsenti AS AE WITH (nolock)
		ON A.IdPersona = AE.IdPersona 
			
	LEFT JOIN dbo.SacFullSyncLhaPazientiEsenzioni AS PE WITH (nolock) 
		ON CAST(AE.IdPersona as varchar(16)) = PE.IdLha
		 AND AE.CodiceEsenzione = PE.CodiceEsenzione
		 AND AE.DataInizioValidita = PE.DataInizioValidita
		 AND AE.DataFineValidita = ISNULL(PE.DataFineValidita , '3000-12-31')

WHERE     
		A.Annullato = 'N'
	AND A.CodiceFiscale IS NOT NULL
	
	--
	-- Solo mancanti
	--
	AND PE.Id IS NULL
	--
	-- Non già nella DropTable da inviare
	--
	AND NOT EXISTS (SELECT *
					FROM dbo.PazientiDropTable dt WITH (nolock) 
					WHERE dt.IdLha = A.IdPersona AND dt.Inviato = 0)



