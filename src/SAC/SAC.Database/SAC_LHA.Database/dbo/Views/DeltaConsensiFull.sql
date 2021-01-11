
CREATE VIEW [dbo].[DeltaConsensiFull]
AS

WITH Consensi AS (
SELECT [Id_Persona]
	  ,[Codice_Sole]
	  ,[Data_Inizio]
	  ,[Data_Fine]
      ,CASE [Codice_Sole] WHEN '0' THEN 'SOLE-LIVELLO0'
						  WHEN '1' THEN 'SOLE-LIVELLO1'
						  WHEN '2' THEN 'SOLE-LIVELLO2'
						  WHEN 'C' THEN 'SOLE-STATO-C'
						  WHEN 'N' THEN 'SOLE-STATO-N'
						  WHEN 'R' THEN 'SOLE-STATO-R'
						  WHEN 'S' THEN 'SOLE-STATO-S'
						  ELSE 'SOLE-STATO-' + [Codice_Sole]
		END AS TipoConsenso
      ,CONVERT(VARCHAR(20), [Id_Persona]) + '_'
			+ REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), [Data_Inizio], 120), '-' , ''), ' ' , ''), ':' , '')
			+ '_' + [Codice_Sole] AS IdConsenso
  FROM [dbo].[Consensi_Sole]
  )

SELECT cs.*
   FROM Consensi cs
WHERE NOT cs.[Data_Inizio] IS NULL
	AND NOT EXISTS ( SELECT *
				FROM dbo.SacFullSyncLhaPazientiConsensi
				WHERE IdProvenienza = cs.IdConsenso
				)

