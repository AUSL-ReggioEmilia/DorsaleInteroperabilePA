
-- =============================================
-- Author:		Nostini Alessandro
-- Create date: 2016-10-07
-- Description:	Ritorna tutti gli attributi delle vista in un unica select
-- =============================================
CREATE FUNCTION [dbo].[GetPrescrizioniAttributi]
(
 @IdPrescrizioniBase AS UNIQUEIDENTIFIER
,@DataPartizione AS SMALLDATETIME
)
RETURNS @Ret TABLE (
	 Cognome VARCHAR(64)
	,Nome VARCHAR(64)
	,Sesso VARCHAR(4)
	,CodiceFiscale VARCHAR(16)
	,DataNascita DATETIME
	,ComuneNascita VARCHAR(64)
	,CodiceSanitario VARCHAR(64)
	,MedicoPrescrittoreCognome VARCHAR(64)
	,MedicoPrescrittoreNome VARCHAR(64)
	,PrioritaCodice VARCHAR(16)
	,EsenzioneCodici VARCHAR(8000)
	,Prestazioni VARCHAR(8000)
	,Farmaci VARCHAR(8000)
)
AS
BEGIN

DECLARE @Attrib AS TABLE (Nome VARCHAR(64), Valore SQL_VARIANT)

	INSERT INTO @Attrib
	SELECT Nome, Valore
	FROM PrescrizioniAttributi WITH(NOLOCK)
	WHERE IdPrescrizioniBase = @IdPrescrizioniBase
		AND DataPartizione = @DataPartizione

	-- Retirn DATA
	INSERT INTO @Ret
	SELECT 
		 (SELECT CONVERT( VARCHAR(64), Valore) FROM @Attrib WHERE Nome = 'Cognome') AS Cognome
		,(SELECT CONVERT( VARCHAR(64), Valore) FROM @Attrib WHERE Nome = 'Nome') AS Nome
		,(SELECT CONVERT( VARCHAR(4), Valore) FROM @Attrib WHERE Nome = 'Sesso') AS Sesso
		,(SELECT CONVERT( VARCHAR(16), Valore) FROM @Attrib WHERE Nome = 'CodiceFiscale') AS CodiceFiscale
		,(SELECT CONVERT( DATETIME, Valore) FROM @Attrib WHERE Nome = 'DataNascita'
									AND ISDATE(CONVERT( VARCHAR(40), Valore) ) = 1) AS DataNascita
		,(SELECT CONVERT( VARCHAR(64), Valore) FROM @Attrib WHERE Nome = 'ComuneNascita') AS ComuneNascita
		,(SELECT CONVERT( VARCHAR(64), Valore) FROM @Attrib WHERE Nome = 'CodiceSanitario') AS CodiceSanitario

		,(SELECT CONVERT( VARCHAR(64), Valore) FROM @Attrib WHERE Nome = 'MedicoPrescrittoreCognome') AS MedicoPrescrittoreCognome
		,(SELECT CONVERT( VARCHAR(64), Valore) FROM @Attrib WHERE Nome = 'MedicoPrescrittoreNome') AS MedicoPrescrittoreNome
		,(SELECT CONVERT( VARCHAR(16), Valore) FROM @Attrib WHERE Nome = 'PrioritaCodice') AS PrioritaCodice
		,(SELECT CONVERT( VARCHAR(8000), Valore) FROM @Attrib WHERE Nome = 'EsenzioneCodici') AS EsenzioneCodici
		,(SELECT CONVERT( VARCHAR(8000), Valore) FROM @Attrib WHERE Nome = 'Prestazioni') AS Prestazioni
		,(SELECT CONVERT( VARCHAR(8000), Valore) FROM @Attrib WHERE Nome = 'Farmaci') AS Farmaci
	RETURN
END