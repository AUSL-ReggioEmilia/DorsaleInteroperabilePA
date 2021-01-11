
-- =============================================
-- Author:		
-- Created: 
-- Description:	Aggiorna un record di DatiAccessori
-- Modified: 2016-08-24 Stefano P.: Aggiunto campo ConcatenaNomeUguale
-- =============================================
CREATE PROCEDURE [dbo].[UiDatiAccessoriUpdate]

 @Codice as varchar(64)
,@Descrizione as varchar(256)
,@Etichetta as varchar(64)
,@Tipo as varchar(32)
,@Obbligatorio as bit
,@Ripetibile as bit
,@Valori as varchar(max)
,@Ordinamento as int
,@Gruppo as varchar(64)
,@ValidazioneRegex as varchar(max)
,@ValidazioneMessaggio as varchar(max)
,@UserName as varchar(max)
,@Sistema bit
,@ValoreDefault varchar(1024)
,@NomeDatoAggiuntivo  varchar(64)
,@ConcatenaNomeUguale bit = 1

AS
BEGIN
SET NOCOUNT ON

	UPDATE [dbo].[DatiAccessori]
	SET [Codice] = @Codice
      ,[DataModifica] = GETDATE() 
      ,[UtenteModifica] = CONVERT(VARCHAR(64), @UserName)
      ,[Descrizione] = @Descrizione
      ,[Etichetta] = @Etichetta
      ,[Tipo] = @Tipo
      ,[Obbligatorio] = @Obbligatorio
      ,[Ripetibile] = @Ripetibile
      ,[Valori] = @Valori
      ,[Ordinamento] = @Ordinamento
      ,[Gruppo] = @Gruppo
      ,[ValidazioneRegex] = @ValidazioneRegex
      ,[ValidazioneMessaggio] = @ValidazioneMessaggio
      ,Sistema = @Sistema
      ,ValoreDefault = CASE WHEN @ValoreDefault = '' THEN null ELSE @ValoreDefault END
      ,NomeDatoAggiuntivo = @NomeDatoAggiuntivo
      ,ConcatenaNomeUguale = @ConcatenaNomeUguale 

	WHERE Codice = @Codice

	SELECT * FROM [dbo].[DatiAccessori] 
	WHERE Codice = @Codice


END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriUpdate] TO [DataAccessUi]
    AS [dbo];

