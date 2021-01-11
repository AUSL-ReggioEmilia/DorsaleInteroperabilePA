
CREATE PROCEDURE [dbo].[BeRefertiRiassociazioneSACPazienteCerca]
(
 @IdPaziente uniqueidentifier = NULL,
 @IdProvenienza varchar(64) = NULL,
 @Provenienza as varchar(16) = NULL, 
 @Disattivato tinyint = NULL,
 @Cognome varchar(64) = NULL,
 @Nome varchar(64) = NULL, 
 @AnnoNascita as int = NULL,
 @CodiceFiscale as varchar(16) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF @Disattivato = 255	SET @Disattivato = NULL
		
  SELECT TOP (ISNULL(@Top, 200)) 
    Id,
	Provenienza,
	IdProvenienza,    
    Disattivato,
    CASE Disattivato
		WHEN 0 THEN 'Attivo'
		WHEN 1 THEN 'Cancellato'
		WHEN 2 THEN 'Fuso'
		ELSE ''
	END AS  DisattivatoDescrizione,
    Cognome,
	Nome,
    DataNascita,
    Sesso,
    ComuneNascitaCodice,
    ComuneNascitaNome,
    ProvincianascitaCodice,
    CASE ProvinciaNascitaNome 
		WHEN '??' THEN NULL
		ELSE ProvinciaNascitaNome
	END AS ProvincianascitaNome,
    CodiceFiscale,
    Tessera
		
  FROM  dbo.Sac_Pazienti WITH(NOLOCK) 
  
  WHERE
	Occultato = 0
	AND	(@IdPaziente IS NULL OR Id = @IdPaziente)
	AND (@Cognome IS NULL OR Cognome LIKE @Cognome + '%')
	AND (@Nome IS NULL OR Nome LIKE @Nome + '%')
	AND (@AnnoNascita IS NULL OR YEAR(DataNascita) = @AnnoNascita)
	AND (@CodiceFiscale IS NULL OR CodiceFiscale = @CodiceFiscale)	
	AND (@Provenienza IS NULL OR Provenienza = @Provenienza)
	AND (@IdProvenienza IS NULL OR IdProvenienza = @IdProvenienza)
	AND (@Disattivato IS NULL OR Disattivato = @Disattivato)

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiRiassociazioneSACPazienteCerca] TO [ExecuteFrontEnd]
    AS [dbo];

