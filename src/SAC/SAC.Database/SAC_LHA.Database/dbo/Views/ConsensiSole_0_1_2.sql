






CREATE VIEW [dbo].[ConsensiSole_0_1_2]
AS

SELECT     
	  C.Id_Persona
	, C.Codice_Sole
	, C.Data_Inizio
	, C.Data_Fine
	, A.TesseraSanitaria
	, A.CodiceFiscale
	, A.Cognome
	, A.Nome
	, A.DataNascita
	, A.CodiceInternoComuneNascita
	, A.CodiceInternoNazionalita
	
FROM         
	dbo.Consensi_Sole AS C 
	
	INNER JOIN dbo.AppCn_Anagrafe AS A ON C.Id_Persona = A.IdPersona
	
WHERE     
	C.Codice_Sole IN ('0', '1', '2')





